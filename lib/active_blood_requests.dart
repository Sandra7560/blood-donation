import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'blood_request_detail_page.dart';  // Import the detailed view page

class ActiveBloodRequestsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    return Scaffold(
      appBar: AppBar(title: Text('Active Blood Requests')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('bloodRequests')
            .where('userId', isNotEqualTo: userId) // Exclude the current user's requests
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
            return Center(child: Text('No active blood requests.'));
          }

          return ListView.builder(
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final requestId = request.id;
              return ListTile(
                title: Text(request['patientName'] ?? 'No Name'),
                subtitle: Text(
                    '${request['bloodType'] ?? 'No Blood Type'}, Needed by: ${request['neededDate'] ?? 'No Date'}'),
                trailing: Icon(Icons.arrow_forward_ios),
                onTap: () {
                  // Navigate to the detailed view page
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BloodRequestDetailPage(requestId: requestId),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
