import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import 'package:geo_snap/backend/posts.dart';
import 'package:geo_snap/backend/user.dart';
import 'package:geo_snap/backend/user_model.dart';

import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as Path;
import 'package:google_map_location_picker/google_map_location_picker.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
 * The 'Add Snapshot' page allows users to upload their photos               *
 * from either they're camera library or take a new photo to upload.         *
 * This is one of the main features of the app. Users create a new post      *
 * with their photo, a title, and a location. Once complete, the users photo * 
 * will appear on the homepage for other users to view and like.             *
 * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * */

class AddSnap extends StatefulWidget {
  AddSnap({Key key, this.title}) : super(key: key);

  final String title;
  @override
  _AddSnapState createState() => _AddSnapState();
}

class _AddSnapState extends State<AddSnap> {
  final _formKey = GlobalKey<FormState>();
  final _apiKey = 'AIzaSyCLJNwky_bW2TdHeeHCtGyQyLapahFZDWI';
  File _image;
  String _title;
  String _imageurl;
  User user = FirebaseAuth.instance.currentUser;
  GeoSnapUser currentUser;
  LocationResult _pickedLocation;
  List<String> _longAddress;
  String _city;
  String _province;
  String _location;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: _form(context),
    );
  }

  Widget _form(BuildContext context) {
    final _model = UserModel();
    if (currentUser == null) {
      _model.getGeoSnapUser(user).whenComplete(() {
        currentUser = _model.currentUser;
        setState(() {
          _location = currentUser.location;
        });
      });
    }

    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                child: Text(
                  "Title:",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextField(
                    decoration: InputDecoration(
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
                    ),
                    onChanged: (String value) {
                      setState(() {
                        _title = value;
                      });
                    },
                  ),
                ),
              ),
            ]),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(children: [
              Container(
                child: Text(
                  "Location:",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: TextFormField(
                    readOnly: true,
                    decoration: InputDecoration(
                      hintText: _location,
                      hintStyle: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                    ),
                    style: TextStyle(
                      color: Colors.white,
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
                        _province =
                            _longAddress[_longAddress.length - 2].split(' ')[0];
                        _location = '$_city, $_province';
                      });
                    },
                  ),
                ),
              ),
            ]),
          ),
          Expanded(
              flex: 1,
              child: _image != null
                  ? Image.file(_image)
                  : Container(
                      child: Icon(
                      Icons.camera_alt,
                      color: Colors.white,
                      size: 50,
                    ))),
          Center(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  RaisedButton(
                      color: Colors.blueGrey[200],
                      child: Text("Add Picture"),
                      onPressed: () {
                        _addPicOrTakePic(context);
                      }),
                  _image != null && _title != null && _imageurl == null
                      ? RaisedButton(
                          color: Colors.blueGrey[200],
                          child: Text("Upload Snap"),
                          onPressed: () {
                            uploadFile();
                          },
                        )
                      : Container(),
                  _imageurl != null
                      ? RaisedButton(
                          color: Colors.blueGrey[200],
                          child: Text("Post Snap"),
                          onPressed: () {
                            Post newpost = Post(
                              title: _title,
                              imageURL: _imageurl,
                              numlikes: 0,
                              location: _location,
                            );
                            currentUser.postsURL.add(_imageurl);
                            _model.addPost(currentUser, currentUser.postsURL);
                            Navigator.of(context).pop(newpost);
                          },
                        )
                      : Container(),
                ]),
          )
        ],
      ),
    );
  }

  /* 
   * _addPicOrTakePic(...) function opens a bottom sheet showing the two options
   * of adding a photo to a new post, either by opening the camera app on the users
   * phone and allowing a new photo to be taken, or opening the users photo library
   * and allowing them to select a photo they have already taken. This function calls
   * either _showPhotos() or _takePhoto() depending on the option the user selects.
   */
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

  /*
   * _showPhotos() function opens users photo library and sets 
   * the new posts picture to the photo that the user selects,
   * by setting _image to the image file.
   */
  _showPhotos() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  /*
   * _takePhoto() functions opens the camera app on the users
   * phone and allows the user to take a new photo and sets the
   * new posts picture to the photo that the user takes, by setting
   * _image to the image file.
   */
  _takePhoto() async {
    // ignore: deprecated_member_use
    File image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);
    setState(() {
      _image = image;
    });
  }

  /*
   * uploadFile() functions uploads the photo to the firebase storage
   * database and then sets the image URL of the new post to the location
   * of the photo in the firebase storage, by setting imageurl to the
   * downloadURL of the file. 
  */
  Future uploadFile() async {
    await firebase_storage.FirebaseStorage.instance
        .ref('image/${Path.basename(_image.path)}')
        .putFile(_image);
    String downloadURL = await firebase_storage.FirebaseStorage.instance
        .ref('image/${Path.basename(_image.path)}')
        .getDownloadURL();
    setState(() {
      _imageurl = downloadURL;
    });
  }
}
