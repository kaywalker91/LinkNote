import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

Future<void> initHive() async {
  await Hive.initFlutter();

  const secureStorage = FlutterSecureStorage();
  var encodedKey = await secureStorage.read(key: 'hive_encryption_key');
  if (encodedKey == null) {
    final key = Hive.generateSecureKey();
    encodedKey = base64UrlEncode(key);
    await secureStorage.write(key: 'hive_encryption_key', value: encodedKey);
  }
  final encryptionKey = base64Url.decode(encodedKey);
  final cipher = HiveAesCipher(encryptionKey);

  await Hive.openBox<String>('settings', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>('links', encryptionCipher: cipher);
  await Hive.openBox<Map<dynamic, dynamic>>(
    'collections',
    encryptionCipher: cipher,
  );
  await Hive.openBox<Map<dynamic, dynamic>>(
    'notifications',
    encryptionCipher: cipher,
  );
  await Hive.openBox<String>('search_history', encryptionCipher: cipher);
}
