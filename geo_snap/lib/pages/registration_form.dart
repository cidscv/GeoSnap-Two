import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as Path;
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'package:geo_snap/backend/user.dart';
import 'package:geo_snap/backend/user_model.dart';

class RegistrationForm extends StatefulWidget {
  RegistrationForm({Key key}) : super(key: key);

  @override
  _RegistrationFormState createState() => _RegistrationFormState();
}

class _RegistrationFormState extends State<RegistrationForm> {
  final _formKey = GlobalKey<FormState>();
  final _apiKey = 'AIzaSyCLJNwky_bW2TdHeeHCtGyQyLapahFZDWI';
  String _username;
  String _password;
  String _email;
  String _location;
  FirebaseAuth auth = FirebaseAuth.instance;
  String error = "";
  File _image;
  String imageurl;
  LocationResult _pickedLocation;
  List<String> _longAddress;
  String _city;
  String _province;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                Text(
                  FlutterI18n.translate(context, "register.email"),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (String value) {
                    _email = value;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                Text(
                  FlutterI18n.translate(context, "register.username"),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                TextField(
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (String value) {
                    _username = value;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                Text(
                  FlutterI18n.translate(context, "register.password"),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.white70),
                    ),
                  ),
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  onChanged: (String value) {
                    _password = value;
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 50.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                Text(
                  FlutterI18n.translate(context, "register.location"),
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
                _pickedLocation != null
                    ? Text(
                        _location,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      )
                    : SizedBox.shrink(),
                TextButton(
                  onPressed: () async {
                    LocationResult result = await showLocationPicker(
                      context,
                      _apiKey,
                      initialCenter: LatLng(43.9458, -78.8960),
                      countries: ['CA'],
                      automaticallyAnimateToCurrentLocation: true,
                      myLocationButtonEnabled: true,
                      requiredGPS: true,
                      layersButtonEnabled: true,
                    );
                    print("result = $result");
                    setState(() {
                      _pickedLocation = result;
                      _longAddress = _pickedLocation.address.split(', ');
                      _city = _longAddress[_longAddress.length - 3];
                      _province =
                          _longAddress[_longAddress.length - 2].split(' ')[0];
                      _location = '$_city, $_province';
                    });
                  },
                  child: Text('Select Location'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10.0,
            ),
            child: CircleAvatar(
              radius: 30,
              child: IconButton(
                icon: _image != null
                    ? ClipOval(
                        child: Image.file(
                          _image,
                          fit: BoxFit.cover,
                          width: 240.0,
                          height: 240.0,
                        ),
                      )
                    : Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 30,
                      ),
                onPressed: () {
                  _addPicOrTakePic(context);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10.0),
            child: RaisedButton(
              color: Colors.blueGrey,
              child: Text(
                FlutterI18n.translate(context, "register.register"),
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                if (_email != null && _password != null && _image != null) {
                  _register();
                  _verifyemail();
                  uploadFile();
                } else {
                  final snackBar = SnackBar(
                    content: Text(
                      FlutterI18n.translate(context, "register.error"),
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    backgroundColor: Colors.blueGrey.withOpacity(0.85),
                  );
                  Scaffold.of(context).showSnackBar(snackBar);
                  print("Must include username, password, and an image");
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addPicOrTakePic(BuildContext context) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
              color: Colors.blueGrey[900],
              height: 150,
              child: Column(children: <Widget>[
                ListTile(
                  leading: Icon(
                    Icons.photo_camera,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Take a picture from camera",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    _takePhoto();
                    Navigator.of(context).pop();
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.photo_library,
                    color: Colors.white,
                  ),
                  title: Text(
                    "Choose from photo library",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onTap: () {
                    _showPhotos();
                    Navigator.of(context).pop();
                  },
                )
              ]));
        });
  }

  _showPhotos() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  _takePhoto() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  Future uploadFile() async {
    await firebase_storage.FirebaseStorage.instance
        .ref('image/${Path.basename(_image.path)}')
        .putFile(_image);
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('image/${Path.basename(_image.path)}')
        .getDownloadURL();
    setState(() {
      imageurl = downloadURL;
      _createUsername();
    });
  }

  Future _register() async {
    try {
      // ignore: unused_local_variable
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: _email, password: _password);
      print('User registered!');
      final snackBar = SnackBar(
        content: Text(
          FlutterI18n.translate(context, "register.success"),
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueGrey.withOpacity(0.85),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
        final snackBar = SnackBar(
          content: Text(
            FlutterI18n.translate(context, "register.weak"),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueGrey.withOpacity(0.85),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
        final snackBar = SnackBar(
          content: Text(
            FlutterI18n.translate(context, "register.account"),
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.blueGrey.withOpacity(0.85),
        );
        Scaffold.of(context).showSnackBar(snackBar);
      } else {
        print('Failed with error code: ${e.code}');
        print(e.message);
      }
    } catch (e) {
      print(e);
    }
  }

  Future _createUsername() async {
    User user = FirebaseAuth.instance.currentUser;
    await user.updateProfile(displayName: _username, photoURL: imageurl);
    GeoSnapUser newGeoSnapUser = GeoSnapUser(
      user: user,
      description: "",
      location: _location,
      postsURL: [],
    );
    final _model = UserModel();
    _model.addUser(newGeoSnapUser);
    Navigator.pop(context);
  }

  Future _verifyemail() async {
    User user = FirebaseAuth.instance.currentUser;

    if (!user.emailVerified) {
      await user.sendEmailVerification();
    }
  }
}
