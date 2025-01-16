import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class BloodRequestDetailPage extends StatefulWidget {
  final String requestId;

  BloodRequestDetailPage({required this.requestId});

  @override
  _BloodRequestDetailPageState createState() =>
      _BloodRequestDetailPageState();
}

class _BloodRequestDetailPageState extends State<BloodRequestDetailPage> {
  LatLng? _location;
  bool _loadingLocation = true;
  LatLng? _userLocation;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _getLocation();
  }

  // Get user's current location
  Future<void> _getUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      setState(() {
        _userLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      print("Error fetching user location: $e");
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error fetching user location: $e'),
      ));
    }
  }

  // Fetch location coordinates from Firestore location string
  Future<void> _getLocation() async {
    try {
      final requestDoc = await FirebaseFirestore.instance
          .collection('bloodRequests')
          .doc(widget.requestId)
          .get();

      final locationString = requestDoc['location'] ?? ''; // Get the location string

      if (locationString.isNotEmpty) {
        // Extract latitude and longitude from the string
        final regex = RegExp(r'Lat: ([\d\.-]+), Lng: ([\d\.-]+)');
        final match = regex.firstMatch(locationString);

        if (match != null) {
          final latitude = double.parse(match.group(1)!);
          final longitude = double.parse(match.group(2)!);

          setState(() {
            _location = LatLng(latitude, longitude);
            _loadingLocation = false;
          });

          // Add a marker for the request location
          _markers.add(Marker(
            markerId: MarkerId('requestLocation'),
            position: _location!,
            infoWindow: InfoWindow(title: 'Request Location'),
          ));

          // Fetch directions if user location is available
          if (_userLocation != null) {
            _getDirections();
          }
        } else {
          setState(() {
            _loadingLocation = false;
          });
          print("Could not parse location string: $locationString");
        }
      } else {
        setState(() {
          _loadingLocation = false;
        });
        print("Location field is empty.");
      }
    } catch (e) {
      setState(() {
        _loadingLocation = false;
      });
      print("Error fetching location: $e");
    }
  }

  // Fetch directions using Google Directions API
  Future<void> _getDirections() async {
    if (_userLocation == null || _location == null) {
      print("User location or request location is null.");
      return;
    }

    final String apiKey = "AIzaSyD5PCIn-wRDNo8ewQyP1bJL8AovmWot1BI";
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_userLocation!.latitude},${_userLocation!.longitude}&destination=${_location!.latitude},${_location!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      final List<dynamic> steps = data['routes'][0]['legs'][0]['steps'];

      _polylineCoordinates.clear();
      for (var step in steps) {
        _polylineCoordinates.add(LatLng(
          step['start_location']['lat'],
          step['start_location']['lng'],
        ));
        _polylineCoordinates.add(LatLng(
          step['end_location']['lat'],
          step['end_location']['lng'],
        ));
      }

      setState(() {
        _polylines.add(Polyline(
          polylineId: PolylineId('route'),
          points: _polylineCoordinates,
          color: Colors.blue,
          width: 5,
        ));
      });
    } else {
      print('Failed to fetch directions');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to fetch directions'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Blood Request Details')),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('bloodRequests')
            .doc(widget.requestId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final request = snapshot.data;
          if (request == null || !request.exists) {
            return Center(child: Text('Request not found.'));
          }

          final patientName = request['patientName'] ?? 'No Name';
          final bloodType = request['bloodType'] ?? 'No Blood Type';
          final neededDate = request['neededDate'] ?? 'No Date';
          final contactNumber = request['contactNumber'] ?? 'No Contact';
          final location = request['location'] ?? 'No Location';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Patient Name: $patientName', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Blood Type: $bloodType', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Needed by: $neededDate', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Contact Number: $contactNumber', style: TextStyle(fontSize: 18)),
                SizedBox(height: 10),
                Text('Location: $location', style: TextStyle(fontSize: 18)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _getDirections,
                  child: Text('Get Directions'),
                ),
                SizedBox(height: 20),
                _loadingLocation
                    ? Center(child: CircularProgressIndicator())
                    : _location == null
                    ? Center(child: Text('Could not fetch location coordinates'))
                    : Container(
                  height: 300,
                  child: GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: _location!,
                      zoom: 14,
                    ),
                    markers: _markers,
                    polylines: _polylines,
                    onMapCreated: (GoogleMapController controller) {},
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
