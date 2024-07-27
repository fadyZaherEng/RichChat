import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseSingleTon {

  FirebaseSingleTon._();

  static final FirebaseSingleTon _instance = FirebaseSingleTon._();

  factory FirebaseSingleTon() => _instance;

  final FirebaseAuth _auth = FirebaseAuth.instance;

  static FirebaseAuth get auth => _instance._auth;

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  static FirebaseFirestore get db => _instance._db;

  final FirebaseStorage _storage = FirebaseStorage.instance;

  static FirebaseStorage get storage => _instance._storage;
}