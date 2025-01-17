import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';  // Import FirebaseAuth
import 'package:blood_donation/HomeScreen.dart';
class CreateRequestPage extends StatefulWidget {
  @override
  _CreateRequestPageState createState() => _CreateRequestPageState();
}

class _CreateRequestPageState extends State<CreateRequestPage> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _patientNameController = TextEditingController();
  final TextEditingController _contactNumberController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _neededDateController = TextEditingController();

  String _selectedBloodType = 'O-';
  final List<String> bloodTypes = ['O-', 'O+', 'A-', 'A+', 'B-', 'B+', 'AB-', 'AB+'];

  GoogleMapController? mapController;
  LatLng _initialPosition = LatLng(37.7749, -122.4194); // Default to San Francisco
  LatLng? _selectedLocation;

  // Fetch the current user from Firebase Authentication
  String? userId;

  @override
  void initState() {
    super.initState();
    _getCurrentUser(); // Get the current user when the page is initialized
  }

  Future<void> _getCurrentUser() async {
    // Get the current user ID from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userId = user?.uid;  // Save the user ID
    });
  }

  @override
  void dispose() {
    _patientNameController.dispose();
    _contactNumberController.dispose();
    _locationController.dispose();
    _neededDateController.dispose();
    super.dispose();
  }

  Future<void> _selectNeededDate(BuildContext context) async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (pickedDate != null) {
      _neededDateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location services are disabled.')));
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permission is denied.')));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Location permission is permanently denied.')));
        return;
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _initialPosition = LatLng(position.latitude, position.longitude);
        _locationController.text = "Lat: ${position.latitude}, Lng: ${position.longitude}";
      });

      mapController?.animateCamera(CameraUpdate.newLatLng(_initialPosition));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Future<void> _submitRequest() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('User not logged in!')));
        return;
      }

      try {
        // Add the request to Firestore
        await FirebaseFirestore.instance.collection('bloodRequests').add({
          'patientName': _patientNameController.text.trim(),
          'contactNumber': _contactNumberController.text.trim(),
          'location': _locationController.text.trim(),
          'bloodType': _selectedBloodType,
          'neededDate': _neededDateController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'userId': userId, // Save the userId along with the request
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request Created!')));

        // Navigate to HomeScreen using pushReplacement
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HomeScreen()), // Adjust the HomeScreen import as needed
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Blood Request')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Patient Name Field
              TextFormField(
                controller: _patientNameController,
                decoration: InputDecoration(labelText: 'Patient Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter patient name' : null,
              ),
              SizedBox(height: 10),
              // Contact Number Field
              TextFormField(
                controller: _contactNumberController,
                decoration: InputDecoration(labelText: 'Contact Number'),
                keyboardType: TextInputType.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter contact number' : null,
              ),
              SizedBox(height: 10),
              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) => value?.isEmpty ?? true ? 'Please enter location' : null,
              ),
              ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text('Get Current Location'),
              ),
              SizedBox(height: 10),
              // Blood Type Dropdown
              DropdownButtonFormField<String>(
                value: _selectedBloodType,
                onChanged: (newValue) => setState(() => _selectedBloodType = newValue!),
                items: bloodTypes.map((bloodType) {
                  return DropdownMenuItem(value: bloodType, child: Text(bloodType));
                }).toList(),
                decoration: InputDecoration(labelText: 'Blood Type'),
                validator: (value) => value == null ? 'Please select blood type' : null,
              ),
              SizedBox(height: 10),
              // Needed Date Field
              GestureDetector(
                onTap: () => _selectNeededDate(context),
                child: AbsorbPointer(
                  child: TextFormField(
                    controller: _neededDateController,
                    decoration: InputDecoration(labelText: 'Needed Date (Tap to select)'),
                    validator: (value) => value?.isEmpty ?? true ? 'Please select a date' : null,
                  ),
                ),
              ),
              SizedBox(height: 20),
              // Submit Button
              Center(
                child: ElevatedButton(
                  onPressed: _submitRequest,
                  child: Text('Submit Request'),
                ),
              ),
              SizedBox(height: 20),
              // Google Map
              Container(
                height: 300,
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _initialPosition,
                    zoom: 14,
                  ),
                  onMapCreated: (controller) => mapController = controller,
                  markers: _selectedLocation != null
                      ? {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: _selectedLocation!,
                      infoWindow: InfoWindow(title: 'Selected Location'),
                    ),
                  }
                      : {},  // Empty set when no location is selected
                  onTap: (LatLng location) {
                    print("Tapped at: ${location.latitude}, ${location.longitude}");  // Debugging
                    setState(() {
                      _selectedLocation = location;
                      _locationController.text = "Lat: ${location.latitude}, Lng: ${location.longitude}";
                    });
                  },
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
