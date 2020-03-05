import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geocoder/geocoder.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:location/location.dart';
import 'package:camera/camera.dart';

// A screen that allows users to take a picture using a given camera
class TakePictureScreen extends StatefulWidget {
  @override
  TakePictureScreenState createState() => TakePictureScreenState();
}

class TakePictureScreenState extends State<TakePictureScreen> {
  String formattedDate =
      DateFormat('kk:mm:ss \n EEE d MMM').format(DateTime.now());

  Future<String> getUserLocation() async {
    //call this async method from whereever you need

    LocationData myLocation;
    String error;
    Location location = new Location();
    try {
      myLocation = await location.getLocation();
    } on PlatformException catch (e) {
      if (e.code == 'PERMISSION_DENIED') {
        error = 'please grant permission';
        print(error);
      }
      if (e.code == 'PERMISSION_DENIED_NEVER_ASK') {
        error = 'permission denied- please enable it from app settings';
        print(error);
      }
      myLocation = null;
    }
    // currentLocation = myLocation;
    final coordinates =
        new Coordinates(myLocation.latitude, myLocation.longitude);
    var addresses =
        await Geocoder.local.findAddressesFromCoordinates(coordinates);
    var first = addresses.first;
    var lokasi =
        "${first.locality}, ${first.adminArea},${first.subLocality}, ${first.subAdminArea},${first.addressLine}, ${first.featureName},${first.thoroughfare}, ${first.subThoroughfare}";
    return lokasi;
  }

  // var lokasiSaya = await getUserLocation();

  File _image;

  Future getImage() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    super.initState();

    getUserLocation();
  }

  Widget getData(params) {
    if (_image == null) {
      return Column(
        children: <Widget>[
          Center(
              child: Text(
            formattedDate,
            style: TextStyle(fontSize: 30),
            textAlign: TextAlign.center,
          )),
          Text(
            params ?? "kosong",
            style: TextStyle(fontSize: 18),
          )
        ],
      );
    }
    return Column(
      children: <Widget>[
        Center(
            child: Text(
          formattedDate,
          style: TextStyle(fontSize: 30),
          textAlign: TextAlign.center,
        )),
        Image.file(
          _image, 
          fit:BoxFit.fill
          ),
        Text(
            params ?? "kosong",
            style: TextStyle(fontSize: 18),
        ),
        Center(
          child: RaisedButton(
            onPressed: () {},
            color: Colors.greenAccent,
            child: Text(
              "Kirim",
              style: TextStyle(fontSize: 22),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(title: Text('Take a picture')),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        onPressed: () {
          getImage();
        },
      ),
      body: SingleChildScrollView(
              child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: FutureBuilder(
            future: getUserLocation(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              return new Container(
                child: getData(snapshot.data),
              );
            },
          ),
        ),
      ),
    );
  }
}
