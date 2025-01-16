import 'package:flutter/material.dart';
import 'sign_in.dart';
import 'view_user.dart';
import 'view_request.dart';
class AdminDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Admin Dashboard'),
        backgroundColor: Colors.red, // Set the app bar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome message
            Text(
              'Welcome Admin',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Button Section for various admin actions
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              shrinkWrap: true, // Prevents grid from taking up extra space
              children: [
                // View all blood requests
                _adminButton(
                  context,
                  'View Blood Requests',
                  Icons.request_page,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewBloodRequestsPage()),
                        );
                  },
                ),

                // View Users
                _adminButton(
                  context,
                  'View Users',
                  Icons.people,
                      () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ViewUsersPage()),
                        );
                  },
                ),

              ],
            ),

            SizedBox(height: 20),
            // Log out button
            ElevatedButton(
              onPressed: () {
                // Handle logout (Sign out admin)
                // FirebaseAuth.instance.signOut();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Redirect to login
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red, // Use backgroundColor instead of primary
              ),
              child: Text('Log Out'),
            ),
          ],
        ),
      ),
    );
  }

  // Helper method for creating buttons
  Widget _adminButton(BuildContext context, String text, IconData icon, Function onPressed) {
    return GestureDetector(
      onTap: () => onPressed(),
      child: Card(
        color: Colors.red[100],
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: Colors.red,
                size: 40,
              ),
              SizedBox(height: 10),
              Text(
                text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
