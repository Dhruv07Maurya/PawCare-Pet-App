import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pet_model.dart';

class PetDetailsScreen extends StatefulWidget {
  final String petId;

  const PetDetailsScreen({Key? key, required this.petId}) : super(key: key);

  @override
  _PetDetailsScreenState createState() => _PetDetailsScreenState();
}

class _PetDetailsScreenState extends State<PetDetailsScreen> {
  late Pet pet;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isSubmittingAdoption = false;
  final PetService _petService = PetService();

  // Firebase instances
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    _loadPet();
    _checkIfFavorite();
  }

  Future<void> _loadPet() async {
    setState(() {
      _isLoading = true;
    });

    // In a real app, this would be an async call
    // Simulating network delay
    await Future.delayed(Duration(milliseconds: 500));

    try {
      // Handle nullable Pet return type
      final loadedPet = _petService.getPetById(widget.petId);
      if (loadedPet != null) {
        pet = loadedPet;
      } else {
        throw Exception('Pet not found');
      }
    } catch (e) {
      // Handle error
      print('Error loading pet: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _checkIfFavorite() async {
    // Check if user is logged in
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final docSnapshot = await _firestore
          .collection('userFavorites')
          .doc(user.uid)
          .collection('pets')
          .doc(widget.petId)
          .get();

      if (mounted) {
        setState(() {
          _isFavorite = docSnapshot.exists;
        });
      }
    } catch (e) {
      print('Error checking favorite status: $e');
    }
  }

  Future<void> _toggleFavorite() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showLoginRequiredDialog('favorite pets');
      return;
    }

    setState(() {
      _isFavorite = !_isFavorite;
    });

    try {
      final favoriteRef = _firestore
          .collection('userFavorites')
          .doc(user.uid)
          .collection('pets')
          .doc(widget.petId);

      if (_isFavorite) {
        // Add to favorites
        await favoriteRef.set({
          'petId': widget.petId,
          'petName': pet.name,
          'petType': pet.type,
          'petBreed': pet.breed,
          'petImageUrl': pet.imageUrl,
          'addedAt': FieldValue.serverTimestamp(),
        });
      } else {
        // Remove from favorites
        await favoriteRef.delete();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isFavorite
                  ? '${pet.name} added to favorites'
                  : '${pet.name} removed from favorites'
          ),
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      // Revert state if operation failed
      setState(() {
        _isFavorite = !_isFavorite;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update favorites'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error updating favorites: $e');
    }
  }

  Future<void> _submitAdoptionRequest() async {
    final user = _auth.currentUser;
    if (user == null) {
      _showLoginRequiredDialog('submit adoption requests');
      return;
    }

    // Set loading state
    setState(() {
      _isSubmittingAdoption = true;
    });

    try {
      // Get user profile data
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      Map<String, dynamic> userData = {};

      if (userDoc.exists) {
        userData = userDoc.data() as Map<String, dynamic>;
      } else {
        // If user document doesn't exist, create basic profile
        userData = {
          'email': user.email,
          'displayName': user.displayName ?? 'Pet Lover',
          'phoneNumber': user.phoneNumber,
          'createdAt': FieldValue.serverTimestamp(),
        };

        // Save basic user profile
        await _firestore.collection('users').doc(user.uid).set(userData);
      }

      // Create adoption request
      final adoptionRequest = {
        'userId': user.uid,
        'userEmail': user.email,
        'userName': user.displayName ?? userData['displayName'] ?? 'Pet Lover',
        'userPhone': user.phoneNumber ?? userData['phoneNumber'] ?? '',
        'petId': pet.id,
        'petName': pet.name,
        'petType': pet.type,
        'petBreed': pet.breed,
        'petAge': pet.age,
        'petGender': pet.gender,
        'petImageUrl': pet.imageUrl,
        'shelterName': 'PawCare Pet Shelter', // From the UI
        'shelterLocation': '123 Pet Avenue, San Francisco', // From the UI
        'requestDate': FieldValue.serverTimestamp(),
        'status': 'pending', // Initial status
        'notes': '', // Optional field for admin notes
      };

      // Add to adoptionRequests collection
      await _firestore.collection('adoptionRequests').add(adoptionRequest);

      // Also add to user's adoptions subcollection for easy access from profile
      await _firestore
          .collection('users')
          .doc(user.uid)
          .collection('adoptionRequests')
          .add({
        'petId': pet.id,
        'petName': pet.name,
        'petType': pet.type,
        'petImageUrl': pet.imageUrl,
        'requestDate': FieldValue.serverTimestamp(),
        'status': 'pending',
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Adoption request sent!'),
          backgroundColor: Colors.green,
        ),
      );

    } catch (e) {
      // Show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to submit adoption request'),
          backgroundColor: Colors.red,
        ),
      );
      print('Error submitting adoption request: $e');
    } finally {
      // Reset loading state
      if (mounted) {
        setState(() {
          _isSubmittingAdoption = false;
        });
      }
    }
  }

  void _showLoginRequiredDialog(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Login Required'),
        content: Text(
          'You need to log in to $action. Would you like to log in now?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to login screen
              Navigator.pushNamed(context, '/login');
            },
            child: Text('Log In'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPetImageHeader(),
                _buildPetInfo(),
                _buildDivider(),
                _buildAboutSection(),
                _buildDivider(),
                _buildCharacteristicsSection(),
                _buildDivider(),
                _buildHealthSection(),
                _buildDivider(),
                _buildAdoptionCenterInfo(),
                SizedBox(height: 100), // Space for FAB
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildAdoptButton(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.red : null,
          ),
          onPressed: _toggleFavorite,
          tooltip: 'Favorite',
        ),
        IconButton(
          icon: Icon(Icons.share_outlined),
          onPressed: () {
            // Implement share functionality
          },
          tooltip: 'Share',
        ),
      ],
    );
  }

  Widget _buildPetImageHeader() {
    return Stack(
      children: [
        Hero(
          tag: 'pet-${pet.id}',
          child: Container(
            height: 300,
            width: double.infinity,
            child: Image.asset(
              pet.imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                );
              },
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          left: 0,
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(30),
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: pet.type == 'Dog'
                  ? Colors.blue[400]
                  : pet.type == 'Cat'
                  ? Colors.green[400]
                  : Colors.orange[400],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              pet.type,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPetInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  pet.name,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: pet.gender == 'Male' ? Colors.blue[50] : Colors.pink[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      pet.gender == 'Male' ? Icons.male : Icons.female,
                      color: pet.gender == 'Male' ? Colors.blue : Colors.pink,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      pet.gender,
                      style: TextStyle(
                        color: pet.gender == 'Male' ? Colors.blue : Colors.pink,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          Text(
            pet.breed,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(Icons.cake, '${pet.age} years'),
              SizedBox(width: 12),
              // Use estimated weight based on breed instead of missing property
              _buildInfoChip(Icons.straighten,
                  '${pet.type == 'Dog' ? '15-25' : '4-8'} kg'),
              SizedBox(width: 12),
              // Use breed info instead of missing color property
              _buildInfoChip(Icons.palette, pet.breed.split(' ').first),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              // Use shelter location instead of missing location property
              _buildInfoChip(Icons.location_on, 'San Francisco'),
              SizedBox(width: 12),
              // Use fixed text instead of missing adoption timeframe property
              _buildInfoChip(Icons.access_time, 'Ready for adoption'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 32,
      thickness: 8,
      color: Colors.grey[100],
    );
  }

  Widget _buildAboutSection() {
    // Create a description since it's missing from the model
    final description =
        '${pet.name} is a ${pet.age} year old ${pet.breed} ${pet.type.toLowerCase()} '
        'looking for a loving forever home. ${pet.gender == 'Male' ? 'He' : 'She'} is '
        'friendly, playful, and gets along well with ${pet.type == 'Dog' ? 'other dogs' : 'other animals'}. '
        '${pet.gender == 'Male' ? 'He' : 'She'} enjoys ${pet.type == 'Dog' ? 'walks in the park and playing fetch' : 'chasing toys and cuddling'}. '
        '${pet.name} would make a perfect companion for ${pet.type == 'Dog' ? 'an active family' : 'a calm household'}.';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About ${pet.name}',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12),
          Text(
            description,
            style: TextStyle(
              fontSize: 16,
              height: 1.5,
              color: Colors.grey[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCharacteristicsSection() {
    // Create default characteristics based on pet type
    final characteristics = [
      {'trait': 'Energy', 'level': pet.type == 'Dog' ? 4 : 3},
      {'trait': 'Friendliness', 'level': pet.age < 3 ? 5 : 4},
      {'trait': 'Trainability', 'level': pet.type == 'Dog' ? 4 : 2},
      {'trait': 'Grooming Needs', 'level': pet.breed.contains('hair') ? 4 : 3},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Characteristics',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...characteristics.map((trait) => _buildCharacteristicRow(
            trait['trait'] as String,
            trait['level'] as int,
          )),
        ],
      ),
    );
  }

  Widget _buildCharacteristicRow(String trait, int level) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              trait,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Row(
              children: List.generate(
                5,
                    (index) => Container(
                  margin: EdgeInsets.only(right: 4),
                  height: 12,
                  width: 40,
                  decoration: BoxDecoration(
                    color: index < level
                        ? Theme.of(context).primaryColor
                        : Colors.grey[300],
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthSection() {
    // Create default health info based on pet age and type
    final healthInfo = [
      {'icon': Icons.check_circle, 'text': 'Vaccinated', 'status': true},
      {'icon': Icons.medical_services, 'text': 'Neutered/Spayed', 'status': pet.age > 1},
      {'icon': Icons.favorite, 'text': 'Good Health', 'status': true},
      {'icon': Icons.pets, 'text': 'Microchipped', 'status': pet.type == 'Dog'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Health & Care',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: healthInfo.length,
            itemBuilder: (context, index) {
              final item = healthInfo[index];
              return Row(
                children: [
                  Icon(
                    item['icon'] as IconData,
                    color: item['status'] as bool
                        ? Theme.of(context).primaryColor
                        : Colors.grey,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item['text'] as String,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: item['status'] as bool
                            ? Colors.black87
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptionCenterInfo() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Adoption Center',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Theme.of(context).primaryColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.home,
                    color: Theme.of(context).primaryColor,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'PawCare Pet Shelter',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        '123 Pet Avenue, San Francisco',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                      SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 16,
                          ),
                          SizedBox(width: 4),
                          Text(
                            '4.8 (120 reviews)',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.call),
                  color: Theme.of(context).primaryColor,
                  onPressed: () {
                    // Implement call functionality
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdoptButton() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: _isSubmittingAdoption
            ? null
            : () {
          // Show adoption confirmation dialog
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Adopt ${pet.name}?'),
              content: Text(
                'You\'re about to start the adoption process for ${pet.name}. Our team will contact you to schedule a meeting and complete the necessary paperwork.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // Submit adoption request to Firebase
                    _submitAdoptionRequest();
                  },
                  child: Text('Confirm'),
                ),
              ],
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: _isSubmittingAdoption
            ? SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : Text(
          'Adopt ${pet.name}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}