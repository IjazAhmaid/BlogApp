import 'dart:io';

import 'package:blogapp/components/round_button.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool showSpinner = false;
  final postRef = FirebaseDatabase.instance.ref().child('Post');
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  File? _image;
  final picker = ImagePicker();
  TextEditingController titleContrller = TextEditingController();
  TextEditingController discriptionContrller = TextEditingController();
  void dialog(context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: SizedBox(
            height: 125,
            child: Column(
              children: [
                InkWell(
                  onTap: () {
                    getImagefromCamera();
                    Navigator.pop(context);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.camera),
                    title: Text('Camera'),
                  ),
                ),
                InkWell(
                  onTap: () {
                    getImageGallery();
                    Navigator.pop(context);
                  },
                  child: const ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Gallery'),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  Future getImageGallery() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        toastmessaging('No Image Selected');
      }
    });
  }

  Future getImagefromCamera() async {
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        toastmessaging('No Image Selected');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ModalProgressHUD(
      inAsyncCall: showSpinner,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('Upload Blog'),
        ),
        body: SingleChildScrollView(
            child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  dialog(context);
                },
                child: Center(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * .2,
                    width: MediaQuery.of(context).size.width * .9,
                    child: _image != null
                        ? ClipRect(
                            child: Image.file(
                              _image!.absolute,
                              height: 100,
                              width: 100,
                              fit: BoxFit.fill,
                            ),
                          )
                        : Container(
                            decoration: BoxDecoration(
                                color: Colors.grey.shade300,
                                borderRadius: BorderRadius.circular(10)),
                            width: 100,
                            height: 100,
                            child: const Icon(
                              Icons.camera_alt,
                              color: Colors.red,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              Form(
                  child: Column(
                children: [
                  TextFormField(
                    controller: titleContrller,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        labelText: 'Title',
                        hintText: 'Enter Post Title',
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal)),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  TextFormField(
                    minLines: 1,
                    maxLines: 5,
                    controller: discriptionContrller,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                        labelText: 'Discription',
                        hintText: 'Enter Discription of Post ',
                        border: OutlineInputBorder(),
                        hintStyle: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.normal)),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  RoundButton(
                      title: 'Upload ',
                      onPressed: () async {
                        setState(() {
                          showSpinner = true;
                        });
                        try {
                          int date = DateTime.now().millisecondsSinceEpoch;
                          firebase_storage.Reference ref = firebase_storage
                              .FirebaseStorage.instance
                              .ref('/blogapp$date');
                          UploadTask uploadTask = ref.putFile(_image!.absolute);
                          await Future.value(uploadTask);
                          var newUrl = await ref.getDownloadURL();
                          final User? user = _auth.currentUser;
                          postRef
                              .child('Post List')
                              .child(date.toString())
                              .set({
                            'pId': date.toString(),
                            'pImage': newUrl.toString(),
                            'pTime': date.toString(),
                            'pTitle': titleContrller.text.toString(),
                            'pDescription':
                                discriptionContrller.text.toString(),
                            'pEmail': user!.email.toString(),
                            'uid': user.uid.toString(),
                          }).then((value) {
                            toastmessaging('Post Published');
                            setState(() {
                              showSpinner = false;
                            });
                          }).onError((error, stackTrace) {
                            toastmessaging(error.toString());
                            setState(() {
                              showSpinner = false;
                            });
                          });
                        } catch (e) {
                          setState(() {
                            showSpinner = false;
                          });
                          toastmessaging(e.toString());
                        }
                      })
                ],
              ))
            ],
          ),
        )),
      ),
    );
  }

  void toastmessaging(String message) {
    Fluttertoast.showToast(
        msg: message.toString(),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.SNACKBAR,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.white,
        textColor: Colors.black,
        fontSize: 16.0);
  }
}
