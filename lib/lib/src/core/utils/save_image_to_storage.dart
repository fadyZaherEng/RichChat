import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:rich_chat_copilot/lib/src/data/source/local/single_ton/firebase_single_ton.dart';

Future<String> saveImageToStorage(File file, reference) async {
  Reference ref = FirebaseSingleTon.storage.ref(reference);
  UploadTask uploadTask = ref.putFile(file);
  TaskSnapshot taskSnapshot = await uploadTask;
  String downloadUrl = await taskSnapshot.ref.getDownloadURL();
  return downloadUrl;
}