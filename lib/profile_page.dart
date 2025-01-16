import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String bloodType = '';
  bool isLoading = true; // To track if data is loading

  @override
  void initState() {
    super.initState();
    _fetchProfileData();
  }

  // Fetch profile data from Firestore
  Future<void> _fetchProfileData() async {
    // Get the current user's UID (assuming you're using Firebase Authentication)
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      // Fetch user data from Firestore using the user ID (UID) as document ID
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (snapshot.exists) {
        setState(() {
          name = snapshot['name'] ?? '';
          address = snapshot['address'] ?? '';
          bloodType = snapshot['bloodType'] ?? '';
          isLoading = false; // Data has been loaded
        });
      } else {
        setState(() {
          isLoading = false; // No data, stop loading indicator
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No profile found!')));
      }
    }
  }

  // Save profile data to Firestore
  void _saveProfileData() async {
    if (_formKey.currentState!.validate()) {
      // Get the current user's UID
      User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        // Save data to Firestore using the user UID as the document ID
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': name,
          'address': address,
          'bloodType': bloodType,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile Saved!')));
        Navigator.pop(context);  // Go back to the previous screen after saving
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading indicator while data is loading
            : Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                initialValue: name,
                decoration: InputDecoration(labelText: 'Name'),
                onChanged: (value) => name = value,
                validator: (value) => value!.isEmpty ? 'Please enter your name' : null,
              ),
              TextFormField(
                initialValue: address,
                decoration: InputDecoration(labelText: 'Address'),
                onChanged: (value) => address = value,
                validator: (value) => value!.isEmpty ? 'Please enter your address' : null,
              ),
              TextFormField(
                initialValue: bloodType,
                decoration: InputDecoration(labelText: 'Blood Type'),
                onChanged: (value) => bloodType = value,
                validator: (value) => value!.isEmpty ? 'Please enter your blood type' : null,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveProfileData,
                child: Text('Save Changes'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Button background color
                  foregroundColor: Colors.white, // Text color
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
