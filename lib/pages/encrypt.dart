import 'dart:convert';

import 'package:encrypt/encrypt.dart' as encrypt;

// Function to encrypt data using AES encryption with PKCS7 padding
String encryptDataAES(String data) {
  final key = encrypt.Key.fromUtf8('0101010101010101');
  final iv = encrypt.IV.fromLength(16); // AES block size is 16 bytes
  final encrypter = encrypt.Encrypter(
    encrypt.AES(
      key,
      mode: encrypt.AESMode.ecb, // Using ECB mode
      //padding: encrypt.Padding.pkcs5, // Using PKCS7 padding
    ),
  );

  final encryptedData = encrypter.encrypt(data, iv: iv);
  return encryptedData.base64;
}


String decryptDataAES(String encryptedData) {
  try {
    final key = encrypt.Key.fromUtf8('0101010101010101');
    final encrypter = encrypt.Encrypter(
      encrypt.AES(
        key,
        mode: encrypt.AESMode.ecb, // Using ECB mode
      ),
    );

    // Decode the base64-encoded data
    final decodedData = base64Decode(encryptedData.trim()); // Use base64Decode function

    // Convert the decoded data into an Encrypted object
    final encrypted = encrypt.Encrypted(decodedData);

    // Decrypt the encrypted data
    final decryptedData = encrypter.decrypt(encrypted);
    return decryptedData;
  } catch (e) {
    return ''; // or handle the error appropriately
  }
}
