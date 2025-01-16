import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuth

class MyBloodRequestPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Fetch the current user from Firebase Authentication
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text('My Blood Requests')),
        body: Center(child: Text('User not logged in.')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('My Blood Requests'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .where('userId', isEqualTo: userId) // Filter by userId
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final requests = snapshot.data!.docs;
          if (requests.isEmpty) {
            return Center(child: Text('No blood requests found.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              return ListTile(
                title: Text(request['patientName'] ?? 'No Name'),
                subtitle: Text(request['bloodType'] ?? 'No Blood Type'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(request['neededDate'] ?? 'No Date'),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () async {
                        // Confirm deletion
                        bool? confirmDelete = await _showDeleteConfirmationDialog(context);
                        if (confirmDelete == true) {
                          // Delete the request from Firestore
                          await FirebaseFirestore.instance
                              .collection('bloodRequests')
                              .doc(request.id) // Using the document ID to delete the specific document
                              .delete();

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request Deleted!')));
                        }
                      },
                    ),
                  ],
                ),
                onTap: () {
                  // Handle tap (e.g., navigate to details)
                },
              );
            },
          );
        },
      ),
    );
  }

  // Function to show the delete confirmation dialog
  Future<bool?> _showDeleteConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Request'),
          content: Text('Are you sure you want to delete this blood request?'),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
