import 'dart:convert';

import 'package:favorite_places/models/place.dart';
import 'package:favorite_places/screens/map.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;

class LocationInput extends StatefulWidget {
  LocationInput({super.key, required this.onSelectLocation});
  final void Function(PlaceLocation location) onSelectLocation;
  @override
  State<StatefulWidget> createState() {
    return _LocationInputState();
  }
}

class _LocationInputState extends State<LocationInput> {
  PlaceLocation? _pickedLocation;
  var _isGettingLocation = false;
  void _savePlace(double longtitude, double latitude) async {
    final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/geocode/json?latlng=$latitude,$longtitude&key=AIzaSyCPaVn5HO3sQb1fDW3k-ov8ph03GEk6VKY');
    final response = await http.get(url);
    final resData = json.decode(response.body);
    final address = resData['results'][0]['formatted_address'];
    setState(() {
      _isGettingLocation = false;
      _pickedLocation = PlaceLocation(
        longitude: longtitude,
        latitude: latitude,
        address: address,
      );
    });
    widget.onSelectLocation(_pickedLocation!);
  }

  String get locationImage {
    if (_pickedLocation == null) {
      return '';
    }
    final lng = _pickedLocation!.longitude;
    final lat = _pickedLocation!.latitude;
    return 'https://maps.googleapis.com/maps/api/staticmap?center=$lat,$lng=&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:A%7C$lat,$lng&key=AIzaSyCPaVn5HO3sQb1fDW3k-ov8ph03GEk6VKY';
  }

  void _getCurrentLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locationData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }
    setState(() {
      _isGettingLocation = true;
    });
    locationData = await location.getLocation();
    final lng = locationData.longitude;
    final lat = locationData.latitude;
    if (lat == null || lng == null) {
      return;
    }
    _savePlace(lng, lat);
  }

  void _selectOnMap() async {
    final pickedLocation =
        await Navigator.of(context).push<LatLng>(MaterialPageRoute(
      builder: (ctx) {
        return MapScreen();
      },
    ));
    if (pickedLocation == null) {
      return;
    }
    _savePlace(pickedLocation.longitude, pickedLocation.latitude);
  }

  @override
  Widget build(BuildContext context) {
    Widget previewContent = Text(
      'No Location Chosen',
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
            color: Theme.of(context).colorScheme.onBackground,
          ),
    );
    if (_isGettingLocation) {
      previewContent = CircularProgressIndicator();
    }
    if (_pickedLocation != null) {
      previewContent = Image.network(locationImage);
    }
    return Column(children: [
      Container(
        alignment: Alignment.center,
        height: 170,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            width: 1,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        child: previewContent,
      ),
      Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextButton.icon(
            onPressed: _getCurrentLocation,
            icon: Icon(Icons.location_on),
            label: Text(
              'Get Current Location',
            ),
          ),
          TextButton.icon(
            onPressed: _selectOnMap,
            icon: Icon(Icons.map),
            label: Text(
              'Select on Map',
            ),
          ),
        ],
      )
    ]);
  }
}
