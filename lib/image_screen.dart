import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  State<ImageScreen> createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  late ImagePicker _imagePicker;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _imagePicker = ImagePicker();
    getImageUrlFromFirestore().then((imageUrl) async {
      print('GOT THE IMAGE - ' + imageUrl.toString());
      if (imageUrl != null) {
          String tempDir = (await getTemporaryDirectory()).path;
          String tempFileName = DateTime.now().millisecondsSinceEpoch.toString() + '.jpg';
          String tempFilePath = '$tempDir/$tempFileName';
          http.Response response = await http.get(Uri.parse(imageUrl));
          if (response.statusCode == 200) {
            File tempFile = File(tempFilePath);
            await tempFile.writeAsBytes(response.bodyBytes);
            _selectedImage = tempFile;
            print('Temporary file generated: $tempFilePath');
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Last Image Fetched Successfully",
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'SF Compact',
                    fontWeight: FontWeight.bold,
                  ),
                ))
            );
          } else {
            print('Failed to download file');
          }
          setState(() { });
      }
    });
  }

  Future<String?> getImageUrlFromFirestore() async {
    try {
      DocumentSnapshot<Map<String, dynamic>> snapshot =
      await FirebaseFirestore.instance.collection('images').doc('latestImage').get();
      if (snapshot.exists) {
        return snapshot.data()?['imageURL'];
      }
      return null;
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }

  Future<void> _openCamera() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        _cropImage();
      });
    }
  }

  Future<void> pickImage() async {
    try {
      final image = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() {
        _selectedImage = imageTemp;
        _cropImage(); // Call _cropImage after selecting the image
      });
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future<void> _cropImage() async {
    if (_selectedImage != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: _selectedImage!.path,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
        ],
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Crop',
            cropGridColor: Colors.black,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(title: 'Crop'),
        ],
      );

      if (cropped != null) {
        setState(() {
          _selectedImage = File(cropped.path);
        });
      }
    }
  }

  Future<void> uploadImage() async {
    if(_selectedImage== null){
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("SELECT AN IMAGE FIRST",
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'SF Compact',
          fontWeight: FontWeight.bold,
        ),
        ))
      );
      return;
    }

    try {
      if (_selectedImage != null) {
        final storageRef = FirebaseStorage.instance.ref().child('latest_image.jpg');
        await storageRef.putFile(File(_selectedImage!.path));
        final downloadURL = await storageRef.getDownloadURL();

        await FirebaseFirestore.instance
            .collection('images')
            .doc('latestImage')
            .set({'imageURL': downloadURL});

        print("IMAGE STORED");
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("IMAGE STORED",
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'SF Compact',
                fontWeight: FontWeight.bold,
              ),
            ))
        );
      }

    } catch (error) {
      print('Error storing data: $error');
    }

  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: Stack(
              children: [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Align(
            alignment: Alignment.topLeft,
            child: GestureDetector(
              onTap: (){
                Navigator.pop(context);
              },
              child: Container(
                margin: EdgeInsets.only(left: 20),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  color: Colors.black,
                      size: 20,
                ),
              ),
            ),
          ),
          buildGestureDetector(context),
          buildAspectRatio(),
          buildSaveButton(),
        ],
      ),
    ],
            )));
  }

  GestureDetector buildSaveButton() {
    return GestureDetector(
          onTap: () async {
              await uploadImage();
          },
          child: Container(
              height: 60,
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(20)
              ),
              child: Center(
                child: Text("SAVE",
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SF Compact',
                  fontSize: 20,
                  fontWeight: FontWeight.bold
                ),
                ),
              ),
          ),
        );
  }

  AspectRatio buildAspectRatio() {
    return AspectRatio(
          aspectRatio: 1,
          child: Container(
              width: double.maxFinite,
              margin: EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),),
              child: Center(
                child: _selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.file(
                          _selectedImage!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : Center(
                        child: Text(
                          "NO IMAGE SELECTED",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'SF Compact',
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                      ),
              ),
          ),
        );
  }

  GestureDetector buildGestureDetector(BuildContext context) {
    return GestureDetector(
          onTap: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: Container(
                      height: 200,
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () async {
                                await _openCamera();
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                width: double.maxFinite,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: Text(
                                    "OPEN CAMERA",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SF Compact',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () async {
                                await pickImage();
                                Navigator.pop(context);
                              },
                              child: Container(
                                height: 50,
                                decoration: BoxDecoration(
                                  color: Colors.lightBlueAccent,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                width: double.maxFinite,
                                margin: EdgeInsets.symmetric(horizontal: 20),
                                child: Center(
                                  child: Text(
                                    "SELECT FROM GALLERY",
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'SF Compact',
                                        fontWeight: FontWeight.bold,
                                        fontSize: 20),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
          },
          child: Container(
              height: 100,
              width: 200,
              decoration: BoxDecoration(
                color: Colors.lightBlueAccent,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: Text("UPLOAD IMAGE",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'SF Compact',
                  fontWeight: FontWeight.bold,
                  fontSize: 20
                ),
                ),
              ),
          ),
        );
  }
}
