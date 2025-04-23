import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of adoption requests for the current user
  Stream<QuerySnapshot>? get adoptionRequestsStream {
    if (currentUser != null) {
      return _firestore
          .collection('adoptionRequests')
          .where('userId', isEqualTo: currentUser!.uid)
          .snapshots();
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.orangeAccent,
      ),
      body: currentUser == null
          ? _buildNotLoggedInView()
          : SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildUserInfoSection(),
            SizedBox(height: 24),
            _buildAdoptionRequestsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildNotLoggedInView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'You need to login to view your profile',
            style: TextStyle(fontSize: 18),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // Navigate to login screen
              // Navigator.pushNamed(context, '/login');
            },
            child: Text('Login'),
          ),
        ],
      ),
    );
  }

  Widget _buildUserInfoSection() {
    return Card(
      elevation: 4,
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'User Information',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: currentUser?.photoURL != null
                      ? NetworkImage(currentUser!.photoURL!)
                      : null,
                  child: currentUser?.photoURL == null
                      ? Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.grey.shade700,
                  )
                      : null,
                ),
                SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Email:',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      currentUser?.email ?? 'No email available',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (currentUser?.displayName != null) ...[
                      SizedBox(height: 8),
                      Text(
                        'Name:',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      Text(
                        currentUser!.displayName!,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdoptionRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'My Adoption Requests',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        StreamBuilder<QuerySnapshot>(
          stream: adoptionRequestsStream,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error loading adoption requests: ${snapshot.error}',
                  style: TextStyle(color: Colors.red),
                ),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'No adoption requests yet',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              );
            }

            // Sort the documents manually
            final docs = snapshot.data!.docs;
            try {
              docs.sort((a, b) {
                final aData = a.data() as Map<String, dynamic>;
                final bData = b.data() as Map<String, dynamic>;

                // Handle null requestDate safely
                final aTimestamp = aData['requestDate'] as Timestamp?;
                final bTimestamp = bData['requestDate'] as Timestamp?;

                if (aTimestamp == null && bTimestamp == null) return 0;
                if (aTimestamp == null) return 1;
                if (bTimestamp == null) return -1;

                // For descending order (newest first)
                return bTimestamp.compareTo(aTimestamp);
              });
            } catch (e) {
              print("Error sorting: $e");
              // Continue without sorting if there's an error
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: docs.length,
              itemBuilder: (context, index) {
                Map<String, dynamic> requestData;
                try {
                  requestData = docs[index].data() as Map<String, dynamic>;
                } catch (e) {
                  return _buildErrorRequestCard("Invalid request data");
                }

                // Display adoption request data directly
                return _buildAdoptionRequestCard(
                  requestData: requestData,
                  requestId: docs[index].id,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadingRequestCard() {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildErrorRequestCard(String message) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Text(message),
      ),
    );
  }

  Widget _buildAdoptionRequestCard({
    required Map<String, dynamic> requestData,
    required String requestId,
  }) {
    // Extract all the request data
    final petName = requestData['petName'] as String? ?? 'Unnamed Pet';
    final petType = requestData['petType'] as String? ?? 'Unknown';
    final petBreed = requestData['petBreed'] as String? ?? 'Unknown';
    final petAge = requestData['petAge']?.toString() ?? 'Unknown';
    final petGender = requestData['petGender'] as String? ?? 'Unknown';
    final petId = requestData['petId'] as String? ?? 'Unknown';
    final shelterName = requestData['shelterName'] as String? ?? 'Unknown';
    final shelterLocation = requestData['shelterLocation'] as String? ?? 'Unknown';
    final userEmail = requestData['userEmail'] as String? ?? 'Unknown';
    final status = requestData['status'] as String? ?? 'pending';
    final requestDate = _formatTimestamp(requestData['requestDate']);
    final petImageUrl = requestData['petImageUrl'] as String? ?? '';

    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pet image if available
          if (petImageUrl.isNotEmpty)
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(petImageUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),

          Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status chip
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      petName,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Chip(
                      label: Text(
                        status.toLowerCase(),
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: _getStatusColor(status),
                    ),
                  ],
                ),

                SizedBox(height: 12),

                // Pet information
                Card(
                  color: Colors.grey.shade100,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pet Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Type', petType),
                        _buildInfoRow('Breed', petBreed),
                        _buildInfoRow('Age', petAge),
                        _buildInfoRow('Gender', petGender),
                        _buildInfoRow('ID', petId),
                      ],
                    ),
                  ),
                ),

                // Shelter information
                Card(
                  color: Colors.grey.shade100,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Shelter Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Name', shelterName),
                        _buildInfoRow('Location', shelterLocation),
                      ],
                    ),
                  ),
                ),

                // Request information
                Card(
                  color: Colors.grey.shade100,
                  margin: EdgeInsets.only(bottom: 12),
                  child: Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Request Information',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 8),
                        _buildInfoRow('Request Date', requestDate),
                        _buildInfoRow('Email', userEmail),
                        _buildInfoRow('Request ID', requestId),
                      ],
                    ),
                  ),
                ),

                // Action buttons
                if (status.toLowerCase() == 'pending')
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          _cancelRequest(requestId);
                        },
                        child: Text(
                          'Cancel Request',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'pending':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  Future<void> _cancelRequest(String requestId) async {
    try {
      await _firestore.collection('adoptionRequests').doc(requestId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Adoption request cancelled')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to cancel request: $e')),
      );
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      DateTime dateTime = timestamp.toDate();
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
    } else if (timestamp is String) {
      return timestamp;
    }
    return 'Unknown date';
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}