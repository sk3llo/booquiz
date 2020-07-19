import 'dart:io';

import 'package:booquiz/blocs/blocs.dart';
import 'package:booquiz/blocs/login_bloc.dart';
import 'package:booquiz/models/userModel.dart';
import 'package:booquiz/tools/dimensions.dart';
import 'package:booquiz/tools/firebase/firestore_utils.dart';
import 'package:booquiz/tools/local_db/DatabaseHelper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/screenutil.dart';
import 'package:overlay_support/overlay_support.dart';

// BLOCS

LoginBloc loginBloc = LoginBloc();
MainScreenBloc mainScreenBloc = MainScreenBloc();
BookPageBloc bookPageBloc = BookPageBloc();


// DIMENSIONS / SIZE
final ScreenUtil mSize = ScreenUtil();
final Dimensions dimensions = Dimensions(); // For iPhone 6 750x1334

// OVERLAY
OverlaySupportEntry mOverlay;

// Platform
bool iosPlatform = Platform.isIOS;

// FIRESTORE / FIREBASE
UserModel currentUser;
FirebaseUser firebaseUser;
Firestore firestore = Firestore.instance;
CollectionReference usersRef = firestore.collection('USERS');
FirebaseAuth auth = FirebaseAuth.instance;
FirestoreUtils fUtils = FirestoreUtils();

bool bigScreen;

final DatabaseHelper dbHelper = DatabaseHelper.instance;

bookDebug(String fileName, String target, String type, String message){
    print('$fileName | $target | $type | $message');
}