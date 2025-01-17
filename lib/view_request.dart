import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date

class ViewBloodRequestsPage extends StatefulWidget {
  @override
  _ViewBloodRequestsPageState createState() => _ViewBloodRequestsPageState();
}

class _ViewBloodRequestsPageState extends State<ViewBloodRequestsPage> {
  // Fetch all blood requests from Firestore
  Future<List<DocumentSnapshot>> fetchBloodRequests() async {
    var result = await FirebaseFirestore.instance.collection('bloodRequests').get();
    return result.docs;
  }

  // Fetch the email of the user who created the request
  Future<String> fetchUserEmail(String userId) async {
    try {
      var userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      return userDoc.data()?['email'] ?? 'Unknown Email';
    } catch (e) {
      return 'Unknown Email';
    }
  }

  // Delete a blood request from Firestore
  Future<void> deleteBloodRequest(String requestId) async {
    try {
      await FirebaseFirestore.instance.collection('bloodRequests').doc(requestId).delete();
      print('Request with ID $requestId deleted successfully!');
    } catch (e) {
      print('Error deleting request with ID $requestId: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Blood Requests'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchBloodRequests(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No blood requests found.'));
          }

          var bloodRequests = snapshot.data!;
          return SingleChildScrollView( // Ensure the list is scrollable
            child: Column(
              children: bloodRequests.map((doc) {
                var request = doc.data() as Map<String, dynamic>;
                var requestId = doc.id;
                var userId = request['userId'] ?? ''; // Add default empty string
                var patientName = request['patientName'] ?? 'Unknown Patient';
                var bloodType = request['bloodType'] ?? 'Unknown Blood Type';
                var contactNumber = request['contactNumber'] ?? 'Unknown Contact';
                var location = request['location'] ?? 'Unknown Location';
                var neededDate = request['neededDate'] ?? 'Unknown Date';

                // Safely handle createdAt timestamp
                var createdAt = request['createdAt'] != null
                    ? (request['createdAt'] as Timestamp).toDate()
                    : DateTime.now();
                var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

                return FutureBuilder<String>(
                  future: fetchUserEmail(userId),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    var userEmail = userSnapshot.data ?? 'Unknown Email';

                    return Card(
                      margin: EdgeInsets.all(8.0),
                      child: ListTile(
                        title: Text('Patient: $patientName'),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Blood Type: $bloodType'),
                            Text('Contact: $contactNumber'),
                            Text('Location: $location'),
                            Text('Needed Date: $neededDate'),
                            Text('Request Date: $formattedDate'),
                            Text('Requested by: $userEmail'),
                          ],
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () async {
                            bool? confirmDelete = await showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text('Confirm Delete'),
                                content: Text('Are you sure you want to delete this request?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, false),
                                    child: Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () => Navigator.pop(context, true),
                                    child: Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );

                            if (confirmDelete == true) {
                              await deleteBloodRequest(requestId);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Request deleted successfully')),
                              );
                              setState(() {}); // Refresh the UI
                            }
                          },
                        ),
                      ),
                    );
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
