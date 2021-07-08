import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:geo_snap/backend/user.dart';

import 'package:geo_snap/pages/profile_page.dart';

import 'dart:io';

import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as Path;

import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The 'Edit' page is used to edit user profile information such as  *
 * their username, location, bio, and profile picture.               *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

// ignore: must_be_immutable
class EditPage extends StatefulWidget {
  EditPage({Key key, this.currentUser}) : super(key: key);

  GeoSnapUser currentUser;

  @override
  _EditPageState createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  User user = FirebaseAuth.instance.currentUser;

  String _location = currentUser != null ? currentUser.location : "";
  String _description = currentUser != null ? currentUser.description : "";

  String _username = currentUser != null ? currentUser.user.displayName : "";

  String _profileImage = currentUser != null ? currentUser.user.photoURL : "";

  File _image;

  final _apiKey = 'AIzaSyCLJNwky_bW2TdHeeHCtGyQyLapahFZDWI';
  LocationResult _pickedLocation;
  List<String> _longAddress;
  String _city;
  String _province;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("Edit Profile")),
        actions: [
          TextButton(
            child: Text("Done",
                style: TextStyle(color: Colors.white, fontSize: 15)),
            onPressed: () {
              print("Saved");
              print("$_username, $_location, $_description, $_profileImage");
              user
                  .updateProfile(
                      displayName: _username, photoURL: _profileImage)
                  .whenComplete(() {
                currentUser.location = _location;
                currentUser.description = _description;
                Navigator.pop(context, currentUser);
              });
            },
          )
        ],
      ),
      body: Center(
        child: ListView(
          //shrinkWrap: true,
          children: <Widget>[
            _editPage(context, currentUser),
          ],
        ),
      ),
    );
  }

  Widget _editPage(BuildContext context, GeoSnapUser currentUser) {
    Future uploadFile() async {
      await firebase_storage.FirebaseStorage.instance
          .ref('image/${Path.basename(_image.path)}')
          .putFile(_image);
      String downloadURL = await firebase_storage.FirebaseStorage.instance
          .ref('image/${Path.basename(_image.path)}')
          .getDownloadURL();

      _profileImage = downloadURL;
    }

    _showPhotos() async {
      // ignore: deprecated_member_use
      File image = await ImagePicker.pickImage(
          source: ImageSource.gallery, imageQuality: 50);

      _image = image;
      uploadFile();
    }

    _takePhoto() async {
      // ignore: deprecated_member_use
      File image = await ImagePicker.pickImage(
          source: ImageSource.camera, imageQuality: 50);

      _image = image;
      uploadFile();
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

    return Container(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Center(
              child: CircleAvatar(
                radius: 40,
                backgroundImage: NetworkImage(
                  _profileImage,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Center(
                child: TextButton(
                  child: Text(
                    "Change Profile Picture",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  onPressed: () {
                    print("Change Profile Pic");
                    _addPicOrTakePic(context);
                  },
                ),
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "Username:",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      height: 20,
                      width: 200,
                      child: TextField(
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _username,
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        onChanged: (String value) {
                          _username = value;
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      "Location:",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                      height: 20,
                      width: 200,
                      child: TextFormField(
                        readOnly: true,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: _location,
                          hintStyle: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 20),
                        ),
                        onTap: () async {
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
                            _province = _longAddress[_longAddress.length - 2]
                                .split(' ')[0];
                            _location = '$_city, $_province';
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text("Bio:",
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 20))),
                Padding(
                    padding: const EdgeInsets.all(15),
                    child: SizedBox(
                        height: 20,
                        width: 200,
                        child: TextField(
                          style: TextStyle(color: Colors.white),
                          decoration: InputDecoration(
                            hintText: _description,
                            hintStyle: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 20),
                          ),
                          onChanged: (String value) {
                            _description = value;
                          },
                        )))
              ],
            )),
          ],
        ));
  }
}
