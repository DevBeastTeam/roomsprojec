import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

/// Upload file using Base64 encoded string (JSON body)
Future uploadFileBase64(
  context,
  XFile file, {
  required String token,
  String folderName = '',
  String fromDeviceName = 'flutter',
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

  if (response.statusCode == 200) {
    var resp = jsonDecode(response.body);
    debugPrint(
      "👉 uploadFileBase64 response: $resp",
    ); // upload ka response check karne ke liye

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Image uploaded successfully!')),
    );
    return resp['link'];
  } else {
    print('Upload failed: ${response.statusCode}');
    print(response.body);
    return null;
  }
}

//  ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('❌ Image upload failed: $e')));
