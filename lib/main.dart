import 'dart:io';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyHomePage());
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key}) : super(key: key);
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<File> imageFile;
  File _image;
  String result = '';
  ImagePicker imagePicker;
  BarcodeDetector barcodeDetector;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    imagePicker = ImagePicker();
    barcodeDetector = FirebaseVision.instance.barcodeDetector();
  }

  _imgFromCamera() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.camera);
    _image = File(pickedFile.path);
    doBarcodeScanning();
    setState(() {
      _image;
    });
  }

  _imgFromGallery() async {
    PickedFile pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    _image = File(pickedFile.path);
    doBarcodeScanning();
    setState(() {
      _image;
    });
  }

  doBarcodeScanning() async {
    final FirebaseVisionImage visionImage = FirebaseVisionImage.fromFile(_image);
    final List<Barcode> barcodes = await barcodeDetector.detectInImage(visionImage);
    for (Barcode barcode in barcodes) {
      final Rect boundingBox = barcode.boundingBox;
      final List<Offset> cornerPoints = barcode.cornerPoints;

      final String rawValue = barcode.rawValue;

      final BarcodeValueType valueType = barcode.valueType;
      result +=barcode.toString()+"\n";
      // See API reference for complete list of supported types
      switch (valueType) {
        case BarcodeValueType.wifi:
          final String ssid = barcode.wifi.ssid;
          final String password = barcode.wifi.password;
          final BarcodeWiFiEncryptionType type = barcode.wifi.encryptionType;
          break;
        case BarcodeValueType.url:
          final String title = barcode.url.title;
          final String url = barcode.url.url;
          break;

      }
      setState(() {
        result;
      });
    }
  }
  @override
  void dispose() {
    barcodeDetector?.close();
    super.dispose();
  }




  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('images/wall2.jpg'), fit: BoxFit.cover),
          ),
          child: Column(
            children: [
              SizedBox(
                width: 100,
              ),
              Container(
                margin: EdgeInsets.only(top: 100),
                child: Stack(children: <Widget>[
                  Stack(children: <Widget>[
                    Center(
                      child: Image.asset(
                        'images/sframe.jpg',
                        height: 220,
                        width: 220,
                      ),
                    ),
                  ]),
                  Center(
                    child: FlatButton(
                      onPressed: _imgFromGallery,
                      onLongPress: _imgFromCamera,
                      child: Container(
                        margin: EdgeInsets.only(top: 15),
                        child: _image != null
                            ? Image.file(
                                _image,
                                width: 195,
                                height: 193,
                                fit: BoxFit.fill,
                              )
                            : Container(
                                width: 140,
                                height: 150,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.grey[800],
                                ),
                              ),
                      ),
                    ),
                  ),
                ]),
              ),
              Container(
                margin: EdgeInsets.only(top: 20),
                child: Text(
                  '$result',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'finger_paint', fontSize: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
