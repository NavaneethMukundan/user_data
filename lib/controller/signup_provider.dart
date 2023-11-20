import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:user_collection/controller/util_provider.dart';
import 'package:user_collection/model/user_model.dart';
import 'package:user_collection/view/utilities/temp_image.dart';
import 'package:user_collection/view/screens/home/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class SignUpProvider extends ChangeNotifier {
  // input controllers
  final nameControl = TextEditingController();
  final emailControl = TextEditingController();
  final passwordControl = TextEditingController();
  final homeTownControl = TextEditingController();
  final contactControl = TextEditingController();

  // checking loading or not
  bool isLoading = false;

  // signup function
  signUp(ctx) async {
    bool isError = false;
    FirebaseAuth fb = FirebaseAuth.instance;
    FirebaseFirestore db = FirebaseFirestore.instance;
    final name = nameControl.text;
    final homeTown = homeTownControl.text;
    final email = emailControl.text;
    final password = passwordControl.text;
    final imageString = _imageToString;
    final contactNo = contactControl.text;
    if (name.isEmpty ||
        homeTown.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        password.length < 6 ||
        imageString == tempImg ||
        contactNo.isEmpty ||
        contactNo.length < 10) {
      return UtilProvider.showScaffoldMessege(ctx);
    }
    isLoading = true;
    notifyListeners();
    // here we create user with email and pwd
    await FirebaseAuth.instance
        .createUserWithEmailAndPassword(
            email: emailControl.text.trim().toString(),
            password: passwordControl.text.trim().toString())
        .then((value) {
      createUser(
        name: nameControl.text,
        email: emailControl.text,
        homeTown: homeTown,
        image: imageString,
        contactNo: contactNo,
      );
      // final docUser = FirebaseFirestore.instance.collection(email).doc();

      // final data = UserModel(
      //     name: name,
      //     email: email,
      //     homeTown: homeTown,
      //     image: imageString,
      //     contactNo: contactNo,
      //     id: docUser.id);
      // db.collection('user').doc(docUser.id).set(data.toJson());
    }).onError((error, stackTrace) {
      UtilProvider.showScaffoldMessege(ctx);
      if (error.toString().isNotEmpty) {
        isError = true;
      }
    });
    if (isError == true) {
      isLoading = false;
      notifyListeners();
      return UtilProvider.showScaffoldMessege(ctx);
    }
    Provider.of<UtilProvider>(ctx, listen: false).collectionName =
        emailControl.text;
    isLoading = false;
    notifyListeners();
    Navigator.of(ctx).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()));
  }

  // here we store user's data
  Future createUser({
    required String name,
    required String email,
    required String homeTown,
    required String image,
    required String contactNo,
  }) async {
    final docUser = FirebaseFirestore.instance.collection(email).doc();
    final user = UserModel(
        name: name,
        email: email,
        homeTown: homeTown,
        image: image,
        contactNo: contactNo,
        id: docUser.id);
    final json = user.toJson();
    await docUser.set(json);
  }

  // select user image
  String _imageToString = tempImg;
  get imageToString => _imageToString;
  set imageToString(val) => _imageToString = val;
  pickImage() async {
    final imageFromGallery =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (imageFromGallery == null) {
      return;
    }
    final bytes = File(imageFromGallery.path).readAsBytesSync();
    _imageToString = base64Encode(bytes);
    notifyListeners();
  }
}
