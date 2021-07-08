import 'maps/error.dart';

import 'maps/result.dart';
import 'package:flutter/material.dart';

class PlacesSearchMap extends StatefulWidget {
  final String keyword;
  PlacesSearchMap(this.keyword);

  @override
  State<PlacesSearchMap> createState() {
    return _PlacesSearchMap();
  }
}

class _PlacesSearchMap extends State<PlacesSearchMap> {
  // ignore: unused_field
  static const String _API_KEY = '{{YOU_API_KEY_HERE}}';
  // ignore: unused_field
  static double latitude = 40.7484405;
  // ignore: unused_field
  static double longitude = -73.9878531;
  // ignore: unused_field
  static const String baseUrl =
      "https://maps.googleapis.com/maps/api/place/nearbysearch/json";

  Error error;
  List<Result> places;
  bool searching = true;
  String keyword;

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }

  // ignore: unused_element
  void _handleResponse(data) {
    // bad api key or otherwise
    if (data['status'] == "REQUEST_DENIED") {
      setState(() {
        error = Error.fromJson(data);
      });
      // success
    } else if (data['status'] == "OK") {
    } else {
      print(data);
    }
  }
}
