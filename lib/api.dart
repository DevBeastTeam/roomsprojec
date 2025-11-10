import 'dart:convert';
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Upload file using Base64 encoded string (JSON body)
Future uploadFileBase64(
  XFile file, {
  required String token,
  String folderName = '',
  String fromDeviceName = 'roomsapp',

  bool isSecret = false,
}) async {
  final bytes = await file.readAsBytes();
  final base64String = base64Encode(
    bytes,
  ); // -> "iVBORw0KGgoAAAANSUhEUgAAAX...."

  final body = {
    "token": token,
    "folder_name": folderName,
    "is_secret": isSecret ? "1" : "0",
    "from_device_name": fromDeviceName,
    "file_base64": base64String,
  };

  final response = await http.post(
    Uri.parse('https://thelocalrent.com/link/api/upload_base64.php'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode(body),
  );

  debugPrint('media uploading response: ${response.statusCode}');
  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    return null;
  }
}
