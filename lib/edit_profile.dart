import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  String name = '';
  String address = '';
  String bloodType = '';

  // Function to save the updated data
  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      // Here you would normally save the updated data to Firestore or any other backend
      // For now, just show a success message
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Profile Updated!')));
      Navigator.pop(context);  // Navigate back to the ProfilePage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
                onPressed: _saveProfile,
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
