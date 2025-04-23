import 'package:flutter/material.dart';
import 'pet_model.dart';
import 'pet_details_screen.dart';

class PetListScreen extends StatefulWidget {
  @override
  _PetListScreenState createState() => _PetListScreenState();
}

class _PetListScreenState extends State<PetListScreen> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Dogs', 'Cats', 'Others'];
  bool _isLoading = false;
  String _searchQuery = '';
  String _sortBy = 'Newest';
  RangeValues _ageRange = RangeValues(0, 10);
  String _selectedGender = 'Any';

  // Initialize pet service
  final PetService _petService = PetService();

  List<Pet> get filteredPets {
    // Start with all pets
    List<Pet> pets = _petService.getAllPets();

    // Apply type filter
    if (_selectedFilter != 'All') {
      // Convert 'Dogs' to 'Dog', 'Cats' to 'Cat' for filtering
      String filterType = _selectedFilter.endsWith('s')
          ? _selectedFilter.substring(0, _selectedFilter.length - 1)
          : _selectedFilter;
      pets = pets.where((pet) => pet.type == filterType).toList();
    }

    // Apply search query if exists
    if (_searchQuery.isNotEmpty) {
      pets = pets.where((pet) =>
      pet.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          pet.breed.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    // Apply age filter
    pets = pets.where((pet) =>
    pet.age >= _ageRange.start && pet.age <= _ageRange.end
    ).toList();

    // Apply gender filter
    if (_selectedGender != 'Any') {
      pets = pets.where((pet) => pet.gender == _selectedGender).toList();
    }

    // Apply sorting
    return _petService.sortPets(pets, _sortBy);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildSimpleAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Find Your New Best Friend',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '${filteredPets.length} pets available for adoption',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 16),
                  _buildSearchBar(),
                  SizedBox(height: 16),
                  _buildFilterChips(),
                ],
              ),
            ),
          ),
          _isLoading
              ? SliverFillRemaining(
            child: Center(
              child: CircularProgressIndicator(),
            ),
          )
              : filteredPets.isEmpty
              ? SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.pets,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No pets found',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Try changing your filter',
                    style: TextStyle(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          )
              : SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.75,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              delegate: SliverChildBuilderDelegate(
                    (context, index) {
                  return _buildPetCard(filteredPets[index]);
                },
                childCount: filteredPets.length,
              ),
            ),
          ),
        ],
      ),
      // Removed the floatingActionButton
    );
  }

  Widget _buildSimpleAppBar() {
    return SliverAppBar(
      floating: true,
      // Removed the title "PawCare"
      // Removed notification and favorite buttons
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search pets by name, breed...',
          prefixIcon: Icon(Icons.search),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 12),
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = filter == _selectedFilter;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = filter;
                });
              },
              backgroundColor: Colors.grey[200],
              selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
              checkmarkColor: Theme.of(context).primaryColor,
              labelStyle: TextStyle(
                color: isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.black,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPetCard(Pet pet) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PetDetailsScreen(petId: pet.id),
          ),
        );
      },
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Hero(
                      tag: 'pet-${pet.id}',
                      child: Image.asset(
                        pet.imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: Icon(
                              Icons.pets,
                              size: 50,
                              color: Colors.grey[400],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: pet.type == 'Dog'
                            ? Colors.blue[400]
                            : pet.type == 'Cat'
                            ? Colors.orange[400]
                            : Colors.orange[400],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        pet.type,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
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
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Icon(
                          pet.gender == 'Male' ? Icons.male : Icons.female,
                          size: 16,
                          color: pet.gender == 'Male' ? Colors.blue : Colors.pink,
                        ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      pet.breed,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.cake,
                          size: 14,
                          color: Theme.of(context).primaryColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          '${pet.age} ${pet.age == 1 ? 'year' : 'years'}',
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterBottomSheet() {
    return StatefulBuilder(
      builder: (context, setState) {
        return Container(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Filter & Sort',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Reset filters
                      setState(() {
                        _selectedFilter = 'All';
                        _ageRange = RangeValues(0, 10);
                        _sortBy = 'Newest';
                        _selectedGender = 'Any';
                      });

                      // Update parent state
                      this.setState(() {});
                    },
                    child: Text('Reset'),
                  ),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Pet Type',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _filters.map((filter) {
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _selectedFilter == filter,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });

                      // Update parent state
                      this.setState(() {});
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                'Age',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Row(
                children: [
                  Text('${_ageRange.start.round()} years'),
                  Expanded(
                    child: RangeSlider(
                      values: _ageRange,
                      min: 0,
                      max: 10,
                      divisions: 10,
                      labels: RangeLabels(
                        _ageRange.start.round().toString(),
                        _ageRange.end.round().toString(),
                      ),
                      onChanged: (RangeValues values) {
                        setState(() {
                          _ageRange = values;
                        });
                      },
                      onChangeEnd: (RangeValues values) {
                        // Update parent state when dragging ends
                        this.setState(() {});
                      },
                    ),
                  ),
                  Text('${_ageRange.end.round()} years'),
                ],
              ),
              SizedBox(height: 16),
              Text(
                'Gender',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Any', 'Male', 'Female'].map((gender) {
                  return ChoiceChip(
                    label: Text(gender),
                    selected: _selectedGender == gender,
                    onSelected: (selected) {
                      setState(() {
                        _selectedGender = gender;
                      });

                      // Update parent state
                      this.setState(() {});
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              Text(
                'Sort By',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['Newest', 'Oldest', 'A-Z', 'Z-A'].map((sort) {
                  return ChoiceChip(
                    label: Text(sort),
                    selected: _sortBy == sort,
                    onSelected: (selected) {
                      setState(() {
                        _sortBy = sort;
                      });

                      // Update parent state
                      this.setState(() {});
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: Text('Apply Filters'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}