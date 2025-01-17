import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'blood_request_detail_page.dart'; // Import the detailed view page

class ActiveBloodRequestsPage extends StatefulWidget {
  @override
  _ActiveBloodRequestsPageState createState() =>
      _ActiveBloodRequestsPageState();
}

class _ActiveBloodRequestsPageState extends State<ActiveBloodRequestsPage> {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  String searchQuery = ''; // To store the search input

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Active Blood Requests'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: InputDecoration(
                labelText: 'Search by Blood Type',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value.trim().toUpperCase(); // Normalize input
                });
              },
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bloodRequests')
                  .where('userId',
                  isNotEqualTo: userId) // Exclude the current user's requests
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final requests = snapshot.data!.docs.where((doc) {
                  // Filter the results based on the search query
                  final bloodType =
                  (doc['bloodType'] ?? '').toString().toUpperCase();
                  return searchQuery.isEmpty || bloodType.contains(searchQuery);
                }).toList();

                if (requests.isEmpty) {
                  return Center(child: Text('No matching blood requests.'));
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
                            builder: (context) =>
                                BloodRequestDetailPage(requestId: requestId),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
