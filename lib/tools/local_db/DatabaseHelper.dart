import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:booquiz/models/loginCreds.dart';
import 'package:booquiz/tools/defs.dart';
import 'package:booquiz/tools/globals.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

// LOCAL SQL DATABASE
class DatabaseHelper {
  static final _databaseName = "MyDatabase.db";

  static final _databaseVersion = 1;

  // Strains
  static final strainTable = 'my_table';

  static final columnId = '_id';

  // LOGIN
  static final logInIdToken = 'fuckingGoogleIdToken';
  static final logInEmail = 'email';
  static final logInPassOrAccessToken = 'pass';
  static final logInProvider = 'provider';

//  // Tables
  static final logInTable = 'logIn';
//  static final googleTable = 'google';
//  static final emailPasswordTable = 'emailPassword';
//  static final fbTable = 'fb';
//  static final appleTable = 'apple';

//  // Google
//  static final columnGoogleAccessToken = 'GOOGLE_ACCESS_TOKEN';
//  static final columnGoogleIdToken = 'GOOGLE_ID_TOKEN';
//  static final columnGoogleEmail = 'GOOGLE_EMAIL';
//
//  // Apple
//  static final columnAppleIdentityToken = 'APPLE_ID_TOKEN';
//  static final columnAppleAuthCode = 'APPLE_AUTH_CODE';
//  static final columnAppleEmail = 'APPLE_EMAIL';
//
//  // Email / Pass
//  static final columnEmail = 'EMAIL';
//  static final columnPassword = 'PASSWORD';
//
//  // FB
//  static final columnFacebookAccessToken = 'FB';
//  static final columnFacebookEmail = 'FACEBOOK_EMAIL';

  // make this a singleton class
  DatabaseHelper._privateConstructor();

  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;

  Future<Database> get database async {
    if (_database != null) return _database;
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }

  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    // Create table for strains
//    await db.execute('''
//          CREATE TABLE $strainTable (
//            $columnId INTEGER PRIMARY KEY,
//            $columnRef TEXT NOT NULL,
//            $columnStrainName TEXT NOT NULL,
//            $columnSubtitle TEXT NOT NULL,
//            $columnTHC INTEGER NOT NULL,
//            $columnCBD INTEGER NOT NULL,
//            $columnCBN INTEGER NOT NULL,
//            $columnInfo TEXT NOT NULL,
//            $columnAromas TEXT NOT NULL,
//            $columnFlavors TEXT NOT NULL,
//            $columnEffects TEXT NOT NULL,
//            $columnMayRelieve TEXT NOT NULL,
//            $columnImgs TEXT NOT NULL,
//            $columnLikesAmount INTEGER NOT NULL,
//            $columnReviewsAmount INTEGER NOT NULL
//          )
//          ''');
//
//    // Create table for edibles
//    await db.execute('''
//          CREATE TABLE $ediblesTable (
//            $ediblesColumnId INTEGER PRIMARY KEY,
//            $ediblesTitle TEXT NOT NULL,
//            $ediblesDescription TEXT NOT NULL,
//            $ediblesImg TEXT NOT NULL,
//            $ediblesItemRef TEXT NOT NULL
//          )
//          ''');

    // Check
    await db.execute('''
         CREATE TABLE $logInTable (
           $logInEmail TEXT NOT NULL,
           $logInIdToken TEXT NOT NULL,
           $logInPassOrAccessToken TEXT NOT NULL,
           $logInProvider TEXT NOT NULL
    )
    ''');

//    // Google table
//    await db.execute('''
//          CREATE TABLE $googleTable (
//            $columnGoogleEmail TEXT NOT NULL,
//            $columnGoogleAccessToken TEXT NOT NULL,
//            $columnGoogleIdToken TEXT NOT NULL
//          )
//          ''');
//
//    // Create APPLE or Email/Password table
//    await db.execute('''
//          CREATE TABLE $appleTable (
//            $columnAppleEmail TEXT NOT NULL,
//            $columnAppleIdentityToken TEXT NOT NULL,
//            $columnAppleAuthCode TEXT NOT NULL
//          )
//          ''');
//
//    // Email/Password table
//    await db.execute('''
//          CREATE TABLE $emailPasswordTable (
//            $columnEmail TEXT NOT NULL,
//            $columnPassword TEXT NOT NULL,
//          )
//          ''');
//
//    // Create FB table
//    await db.execute('''
//          CREATE TABLE $fbTable (
//            $columnFacebookEmail TEXT NOT NULL,
//            $columnFacebookAccessToken TEXT NOT NULL
//          )
//          ''');
  }

  // Helper methods

  // Inserts a row in the database where each key in the Map is a column name
  // and the value is the column value. The return value is the id of the
  // inserted row.
  Future<int> insertFavorites(Map<String, dynamic> row, {bool edible = false}) async {
    Database db = await instance.database;
//    return await db.insert(edible ? ediblesTable : strainTable, row);
  }

  // All of the rows are returned as a list of maps, where each map is
  // a key-value list of columns.

  Future<List<Map<String, dynamic>>> queryAllFavorites({bool edible = false}) async {
    Database db = await instance.database;
//    return await db.query(edible ? ediblesTable : strainTable);
  }

  Future<bool> queryFavoriteByRef(String itemRef, {bool edible = false}) async {
    try {
      Database db = await instance.database;
      bool isInFavorites = false;
//      await db.query(edible ? ediblesTable : strainTable,
//          where: edible ? '$ediblesItemRef = ?' : '$columnRef = ?',
//          whereArgs: [itemRef]).then((list) {
//        if (list != null && list.isNotEmpty) {
//          isInFavorites = true;
//        } else {
//          isInFavorites = false;
//        }
//      });
      return isInFavorites;
    } catch (e) {
      bookDebug('DatabaseHelper', 'queryByItemLink', 'ERROR', '$e');
    }
  }

  // All of the methods (insert, query, update, delete) can also be done using
  // raw SQL commands. This method uses a raw query to give the row count.
  Future<int> queryFavoriteRowCount({bool edible = false}) async {
    try {
      Database db = await instance.database;
//      return Sqflite.firstIntValue(
//          await db.rawQuery('SELECT COUNT(*) FROM ${edible ? ediblesTable : strainTable}'));
    } catch (e) {
      bookDebug('DatabaseHelper', 'queryFavoriteRowCount', 'ERROR', '$e');
    }
  }

  // We are assuming here that the id column in the map is set. The other
  // column values will be used to update the row.
  Future<int> updateFavorite(Map<String, dynamic> row, {bool edible = false}) async {
    try {
      Database db = await instance.database;
      int id = row[columnId];
//      return await db.update(edible ? ediblesTable : strainTable, row,
//          where: edible ? '$ediblesColumnId = ?' : '$columnId = ?', whereArgs: [id]);
    } catch (e) {
      bookDebug('DatabaseHelper', 'updateFavorite', 'ERROR', '$e');
    }
  }

  // Deletes the row specified by the id. The number of affected rows is
  // returned. This should be 1 as long as the row exists.
  Future<int> deleteFavorite(int id, {bool edible = false}) async {
    try {
      Database db = await instance.database;
//      return await db.delete(strainTable,
//          where: edible ? '$ediblesColumnId = ?' : '$columnId = ?', whereArgs: [id]);
    } catch (e) {
      bookDebug('DatabaseHelper', 'deleteFavorite', 'ERROR', '$e');
    }
  }

//  Future<int> deleteFavoriteByItemLink(StrainItemModel post, {bool edible = false}) async {
//    try {
//      // Remove from firestore
//      Database db = await instance.database;
//      return await db.delete(edible ? ediblesTable : strainTable,
//          where: edible ? '$ediblesItemRef = ?' : '$columnRef = ?', whereArgs: [post.docRef]);
//    } catch (e) {
//      bookDebug('DatabaseHelper', 'deleteFavoriteByItemLink', 'ERROR', '$e');
//    }
//  }

  Future deleteAllFavorites() async {
    try {
      Database db = await instance.database;
//      await db.query(ediblesTable).then((data) async {
//        for (var i in data) {
//          if (data != null && data.isNotEmpty)
//            await db
//                .delete(ediblesTable, where: '$ediblesColumnId = ?', whereArgs: [i[ediblesColumnId]]);
//        }
//      });

      return await db.query(strainTable).then((data) async {
        for (var i in data) {
          await db.delete(strainTable, where: '$columnId = ?', whereArgs: [i[columnId]]);
        }
      });
    } catch (e) {
      bookDebug('DatabaseHelper', 'deleteAllFavorites', 'ERROR', '$e');
    }
  }

//  Future<bool> saveGoogleLoginCreds(GoogleSignInCredentials creds) async {
//    Database db = await instance.database;
//    await db.insert(googleTable, {
//      columnGoogleAccessToken: creds.accessToken,
//      columnGoogleIdToken: creds.idToken,
//      columnGoogleEmail: creds.email
//    });
//  }
//
//  Future<bool> saveFacebookLoginCreds(FacebookSignInCredentials creds) async {
//    Database db = await instance.database;
//    await db.insert(googleTable, {
//      columnFacebookAccessToken: creds.accessToken,
//      columnFacebookEmail: creds.email,
//    });
//  }
//
//  Future<bool> saveEmailPassLoginCreds(String email, String password) async {
//    Database db = await instance.database;
//    await db.insert(emailPasswordTable, {
//      columnEmail: email,
//      columnPassword: password,
//    });
//  }
  
  Future<bool> saveLoginCreds(String email, String passwordOrAccessToken, String provider, {String idToken}) async {
    try {
      Database db = await instance.database;
      // Check if logged in already
      LogInCreds checkLogIn = await checkLogin();

//      if (checkLogIn == null) {

        if (provider == googleProvider){
          await db.insert(logInTable, {
            logInEmail: email,
            logInIdToken: idToken ?? '',
            logInPassOrAccessToken: passwordOrAccessToken ?? '',
            logInProvider: provider ?? '' // GOOGLE, FB, APPLE, EMAIL
          });
        } else {
          await db.insert(logInTable, {
            logInEmail: email,
            logInIdToken: '',
            logInPassOrAccessToken: passwordOrAccessToken ?? '',
            logInProvider: provider ?? '' // GOOGLE, FB, APPLE, EMAIL
          });
        }
        return true;
//      } else {
//        // User already in the DB
//        return false;
//      }
    } catch (e) {
      bookDebug('DatabaseHelper', 'saveLoginCreds', 'ERROR', '$e');
      return false;
    }
  }

  // Returns null if no login found
  Future<LogInCreds> checkLogin() async {
    try {
      Database db = await instance.database;
      var data = await db.query(logInTable);
      if (data != null && data.isNotEmpty)
        return LogInCreds.fromRow(data[0]);
    } catch (e) {
      bookDebug('DatabaseHelper', 'checkLogin', 'ERROR', '$e');
      return null;
    }

  }

  Future<bool> eraseLogin() async {
    try {
      Database db = await instance.database;
      await db.delete(logInTable);
      bookDebug('DatabaseHelper', 'eraseLogin', 'INFO', 'Successfully erased login data.');
      return true;
    } catch (e){
      bookDebug('DatabaseHelper', 'eraseLogin', 'ERROR', '$e');
      return false;
    }
  }
  
  
  
}
