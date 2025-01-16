import 'package:flutter/material.dart';
import 'profile_page.dart'; // Import ProfilePage for navigation
import 'sign_in.dart'; // Import the SignIn page for logout
import 'create_request.dart'; // Import the CreateRequest page
import 'my_blood_request.dart'; // Import the page for displaying your blood requests
import 'active_blood_requests.dart'; // Import the page for other active blood requests

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Colors.red, // Customize the app bar color
      ),
      body: Container(
        color: Colors.red, // Set the background color to red
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Add your logo or image here
              Image.asset(
                'assets/images/app_logo.png', // Path to your image in assets
                height: 150, // Adjust height
                width: 150, // Adjust width
              ),
              SizedBox(height: 20), // Add some spacing
              // Text below the image
              Text(
                'Your Blood Can Save Lives',
                style: TextStyle(color: Colors.white, fontSize: 20),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.red, // Set the color for the BottomAppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
          children: [
            // Profile Icon
            IconButton(
              icon: Icon(Icons.account_circle),
              iconSize: 36.0, // Increase icon size
              color: Colors.white,
              onPressed: () {
                // Navigate to the Profile Page (to create or edit profile)
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            // Create Request Icon
            IconButton(
              icon: Icon(Icons.add_box),
              iconSize: 36.0, // Increase icon size
              color: Colors.white,
              onPressed: () {
                // Navigate to Create Request page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CreateRequestPage()),
                );
              },
            ),
            // My Blood Request Button
            IconButton(
              icon: Icon(Icons.list),
              iconSize: 36.0, // Increase icon size
              color: Colors.white,
              onPressed: () {
                // Navigate to My Blood Requests page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => MyBloodRequestPage()),
                );
              },
            ),
            // Other Active Blood Requests Button
            IconButton(
              icon: Icon(Icons.search),
              iconSize: 36.0, // Increase icon size
              color: Colors.white,
              onPressed: () {
                // Navigate to Other Active Blood Requests page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ActiveBloodRequestsPage()),
                );
              },
            ),
            // Logout Icon
            IconButton(
              icon: Icon(Icons.exit_to_app),
              iconSize: 36.0, // Increase icon size
              color: Colors.white,
              onPressed: () {
                // Navigate to SignIn screen for logout
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()), // Navigate to Login Screen
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
