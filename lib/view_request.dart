import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting date

class ViewBloodRequestsPage extends StatelessWidget {
  // Fetch blood requests from Firestore
  Future<List<DocumentSnapshot>> fetchBloodRequests() async {
    var result = await FirebaseFirestore.instance.collection('bloodRequests').get();
    return result.docs;
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
          return ListView.builder(
            itemCount: bloodRequests.length,
            itemBuilder: (context, index) {
              var request = bloodRequests[index].data() as Map<String, dynamic>;

              // Format timestamp to a readable date
              var createdAt = (request['createdAt'] as Timestamp).toDate();
              var formattedDate = DateFormat('yyyy-MM-dd HH:mm:ss').format(createdAt);

              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Patient: ${request['patientName']}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Blood Type: ${request['bloodType']}'),
                      Text('Contact: ${request['contactNumber']}'),
                      Text('Location: ${request['location']}'),
                      Text('Needed Date: ${request['neededDate']}'),
                      Text('Request Date: $formattedDate'),
                    ],
                  ),
                  trailing: Icon(Icons.request_page),
                  onTap: () {
                    // Navigate to detailed view or perform any other action
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
