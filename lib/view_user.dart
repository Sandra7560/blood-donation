import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ViewUsersPage extends StatelessWidget {
  Future<List<DocumentSnapshot>> fetchUsersFromFirestore() async {
    // Assume 'users' is the collection where user data is stored
    var result = await FirebaseFirestore.instance.collection('users').get();
    return result.docs;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('View Users'),
        backgroundColor: Colors.red,
      ),
      body: FutureBuilder<List<DocumentSnapshot>>(
        future: fetchUsersFromFirestore(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No users found.'));
          }

          var users = snapshot.data!;
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index].data() as Map<String, dynamic>;
              return Card(
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(user['email'] ?? 'No Email'),
                  subtitle: Text(user['display_name'] ?? 'No Display Name'),
                  trailing: Icon(Icons.arrow_forward),
                  onTap: () {
                    // You can navigate to a user detail page
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
