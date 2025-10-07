import 'dart:convert';

import 'package:get_storage/get_storage.dart';

class GetStorageData {
  String loginData = "loginData";
  String type = "type";
  String saveData = "SaveData";
  String userName = "useName";
  String userEmailId = "userEmailId";
  String userIdKey = "user_id";
  String tokenKey = "token";
  String deviceId = "device_id";
  String isPinCreated = "is_pin_created";

  saveString(String key, value) async {
    final box = GetStorage();
    return box.write(key, value);
  }

  readString(String key) {
    final box = GetStorage();
    if (box.hasData(key)) {
      return box.read(key);
    } else {
      return null;
    }
  }

  saveBoolean({
    required String key,
    required bool value,
  }) async {
    final box = GetStorage();
    return box.write(key, value);
  }

  bool readBoolean({required String key}) {
    bool isValue = false;
    final box = GetStorage();

    if (box.hasData(key)) {
      isValue = box.read(key) ?? false;
    }
    return isValue;
  }

  bool containKey(String key) {
    final box = GetStorage();
    return box.hasData(key);
  }



  String? getUserId() {
    final box = GetStorage();
    return box.read(userIdKey);
  }


  removeData(String key) async {
    final box = GetStorage();
    return box.remove(key);
  }

  saveObject(String key, value) {
    final box = GetStorage();
    String allData = jsonEncode(value);
    box.write(key, allData);
  }

  readObject(String key) {
    final box = GetStorage();
    var result = box.read(key);
    return jsonDecode(result);
  }

  removeLoginData() {
    removeData(loginData);
    removeData(userIdKey);
    removeData(tokenKey);
  }

  removeAllData() async {
    await removeData(loginData);
    await removeData(type);
    await removeData(saveData);
    await removeData(userName);
    await removeData(userEmailId);
    await removeData(userIdKey);
    await removeData(tokenKey);
    await removeData(isPinCreated);

    removeLoginData();
  }
}
