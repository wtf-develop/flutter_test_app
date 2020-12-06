import 'dart:convert';
import 'dart:io';

import 'package:device_info/device_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:udp_hole/common/entity/data_objects.dart';

import '../utils.dart';

class LocalStorage {
  LocalStorage._privateConstructor();

  static final LocalStorage _instance = LocalStorage._privateConstructor();

  factory LocalStorage() {
    return _instance;
  }

  SharedPreferences _sharedPrefs;

  _generateUUID() => (DateTime.now().year - 2020).toString() + randomString(15);

  init() async {
    if (_sharedPrefs == null) {
      _sharedPrefs = await SharedPreferences.getInstance();
    }
    _my_uniq_id = _sharedPrefs.getString("uniq_id");
    _nick_name = _sharedPrefs.getString("nick_name") ?? "default";
    if (_my_uniq_id == null) {
      final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
      try {
        if (Platform.isAndroid) {
          var build = await deviceInfoPlugin.androidInfo;
          _my_uniq_id = build.androidId; //UUID for Android
        } else if (Platform.isIOS) {
          var data = await deviceInfoPlugin.iosInfo;
          _my_uniq_id = data.identifierForVendor; //UUID for iOS
        }
      } on Exception {
        _my_uniq_id = _generateUUID();
      }
      if (_my_uniq_id == null || _my_uniq_id.length < 12) {
        _my_uniq_id = _generateUUID();
      }
      _my_uniq_id = _my_uniq_id.toLowerCase();
      _sharedPrefs.setString("uniq_id", _my_uniq_id);
    }
  }

  String _nick_name = "";

  String getNickname() {
    return _nick_name;
  }

  String setNickName(String s) {
    _nick_name = s;
    _sharedPrefs.setString("nick_name", _nick_name);
    return getNickname();
  }

  String _my_uniq_id;

  String getMyUniqId() {
    return _my_uniq_id ?? "";
  }

  MyContactsList _dataContacts;

  MyContactsList getContacts() {
    if (_dataContacts == null) {
      var stored = _sharedPrefs.getString("MyContacts") ?? "{}";
      _dataContacts = MyContactsList.fromJson(jsonDecode(stored));
    }
    return _dataContacts;
  }

  void addContact(MyContact item) {
    _dataContacts.contacts.add(item);
    storeContacts(_dataContacts);
  }

  void addContactsArr(List<MyContact> items) {
    _dataContacts.contacts.addAll(items);
    storeContacts(_dataContacts);
  }

  void removeContact(String id) {
    var index =
        _dataContacts.contacts.indexWhere((element) => element.id == id);
    if (index > -1) {
      _dataContacts.contacts.removeAt(index);
      storeContacts(_dataContacts);
    }
  }

  void removeContactsArr(List<String> ids) {
    var needSave = false;
    for (int i = 0; i < ids.length; i++) {
      var index =
          _dataContacts.contacts.indexWhere((element) => element.id == ids[i]);
      if (index > -1) {
        _dataContacts.contacts.removeAt(index);
        needSave = true;
      }
    }
    if (needSave) storeContacts(_dataContacts);
  }

  void storeContacts(MyContactsList data) async {
    _dataContacts = data;
    jsonEncode(data.toJson());
    _sharedPrefs.setString("MyContacts", jsonEncode(data.toJson()));
  }
}
