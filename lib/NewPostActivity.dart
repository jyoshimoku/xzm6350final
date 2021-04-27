import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'dart:io';
import 'dart:math';
import 'package:xzm6350final/text_card.dart';
import 'package:xzm6350final/camera_screen.dart';
import 'package:xzm6350final/items.dart';
import 'package:xzm6350final/BrowsePostsActivity.dart';
// firebase
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

// camera
import 'package:camera/camera.dart';

// image
import 'package:image_picker/image_picker.dart';

class NewPostActivity extends StatefulWidget {
  static String id = 'new_post_screen';

  @override
  _NewPostActivityState createState() => _NewPostActivityState();
}

class _NewPostActivityState extends State<NewPostActivity> {
  PostData newPost = PostData();
  //String url;

  /// firebase
  // save data into cloud firestore
  final _firestore = Firestore.instance;

  // authentication
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  /// Add text editing controllers, to clear the text fields' values
  final _nameController = TextEditingController();
  final _originalController = TextEditingController();
  // final _salepriceController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();

    getCurrentUser();
  }

  /// Check to see if there is a current user who is signed in
  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
        // check the method
        print(loggedInUser.email);
      }
    } catch (e) {
      print(e);
    }
  }

  void messagesStream() async {
    await for (var snapshot in _firestore.collection('messages').snapshots()) {
      for (var message in snapshot.documents) {
        print(message.data);
      }
    }
  }

  void uploadImage() async {
    // make a image name
    var timeKey = new DateTime.now();
    int randomNumber = Random().nextInt(100000);
    String imageLocation = 'images${timeKey.toString()}/image$randomNumber.jpg';

    // Upload image to firebase.
    final StorageReference postImageRef =
    FirebaseStorage().ref().child(imageLocation);

    for (String image_path in newPost.pictures) {
      final StorageUploadTask uploadTask =
      postImageRef.putFile(File(image_path));

      //newPost.pictures.add(image_path);

      await uploadTask.onComplete;
      _addPathToDatabase(imageLocation);
      print("Image url = " + newPost.url);
    }
  }

  Future<void> _addPathToDatabase(String text) async {
    try {
      // Get image URL from firebase
      final ref = FirebaseStorage().ref().child(text);
      newPost.url = await ref.getDownloadURL();

      // Add location and url to database
      await _firestore.collection('items').document().setData({
        'url': newPost.url,
        'location': text,
        'title': newPost.title,
        'price': newPost.price,
        //'salePrice': newPost.salePrice,
        'description': newPost.description,
        'user': loggedInUser.email,
      });
    } catch (e) {
      print(e.message);
      showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              content: Text(e.message),
            );
          });
    }
  }

  /** Create a click button in the bottom of the application **/
  RaisedButton createButton({String buttonName}) {
    return RaisedButton(
      child: Text(
        buttonName,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _bodyStr = "Show menus";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hyer Garage Sale'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          children: <Widget>[
            /// Title
            TextCard(
              title: 'Title',
              hintText: 'What are you selling?',
              textIn: (newTitle) {
                newPost.title = newTitle;
              },
              price: false,
              numberKeyboard: false,
            ),

            /// Original Price
//            SizedBox(height: 16),
//            TextCard(
//              title: 'Original Price',
//              hintText: 'How much did you buy it?',
//              textIn: (oriValue) {
//                newPost.originalPrice = double.parse(oriValue);
//              },
//              price: true,
//              numberKeyboard: true,
//            ),
            /// Sale Price
            SizedBox(height: 16),
            TextCard(
              title: 'Price',
              hintText: 'Enter your selling price!',
              textIn: (newValue) {
                newPost.price = newValue;
              },
              price: true,
              numberKeyboard: true,
            ),
            SizedBox(height: 16),

            /// Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  SizedBox(height: 8),
                  Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  TextField(
                    // minLines: 1,
                    maxLines: 7,
                    decoration: InputDecoration(
                      filled: true,
                      hintText: 'Enter the description of the item',
                      hintStyle: TextStyle(
                        color: Colors.grey[600],
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onChanged: (value) {
                      newPost.description = value;
                    },
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length == 0
                        ? null
                        : Image.file(
                      File(newPost.pictures[0]),
                      height: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length <= 1
                        ? null
                        : Image.file(
                      File(newPost.pictures[1]),
                      height: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length <= 2
                        ? null
                        : Image.file(
                      File(newPost.pictures[2]),
                      height: 80,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(1.0, 2.0, 1.0, 2.0),
                    child: newPost.pictures.length <= 3
                        ? null
                        : Image.file(
                      File(newPost.pictures[3]),
                      height: 80,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueAccent,
        child: Icon(Icons.camera_alt),
        heroTag: 'picture',
        onPressed: () async {
          if (newPost.pictures.length == 4) {
            showErrorNotification(context, 'Please upload less than 4');
          } else {
            final cameras = await availableCameras();
            final camera = cameras.first;
            if (cameras == null || cameras.length == 0) {
              print('No Camera');
            }
            final result = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CameraScreen(camera: camera),
              ),
            );
            print(result);
            setState(() {
              newPost.pictures.add(result);
            });
          }
          //there is no camera on Simulator, cameras will be null，use NamedRoute instead
          //Navigator.pushNamed(context, CameraScreen.id);
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// pic button
      bottomNavigationBar: BottomAppBar(
        /// A circular hole is punched in the bottom navigation bar.
        /// The shape property of BottomAppBar determines the shape of the hole, and CircularNotchedRectangle implements a circular shape.
        shape: CircularNotchedRectangle(),
        child: Row(
          children: <Widget>[
            /// Cancel button
            FlatButton(
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                _nameController.clear();
                _originalController.clear();
                //_salepriceController.clear();
                _descriptionController.clear();
                Navigator.pop(context, 'Cancel');
              },
            ),


            SizedBox(),

            /// Post button
            RaisedButton(
              child: Text(
                'Post',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              shape: BeveledRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(7.0)),
              ),
              onPressed: () {
                //print('before upload' + url);
                try {
                  /// upload files to firebase itemName + originalPrice + salePrice + loggedInUser.email

                 // _firestore.collection('items').add({
                 //   'title': newPost.itemName,
                 //   'oriPrice': newPost.originalPrice,
                 //   'salePrice': newPost.salePrice,
                 //   'description': newPost.description,
                 //   'user': loggedInUser.email,
                 //   'image_path': newPost.url,
                 // });
                  uploadImage();
                  Navigator.pop(context, 'Post');
                } catch (e) {
                  print(e);
                }
              },
            ),
          ],

          /// Evenly divide the horizontal space of the bottom navigation bar
          mainAxisAlignment: MainAxisAlignment.spaceAround,
        ),
      ),
    );
  }

  void choiceAction(String choice) {
    print('working');
  }
}



void showErrorNotification(context, String title) {
  showModalBottomSheet(
    isScrollControlled: true,
    context: context,
    builder: (context) => SingleChildScrollView(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          Text(
            title,
            style: TextStyle(fontSize: 22.0),
          ),
          SizedBox(
            height: 20.0,
          ),
          FlatButton(
            color: Colors.lightBlueAccent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(30.0))),
            child: Text(
              'OK',
              style:
              TextStyle(color: Colors.grey, fontWeight: FontWeight.w700),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}