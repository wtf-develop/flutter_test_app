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

  Future<bool> init() {
    return SharedPreferences.getInstance().then((value) {
      _sharedPrefs = value;
      _my_uniq_id = _sharedPrefs.getString("uniq_id");
      _nick_name = _sharedPrefs.getString("nick_name") ?? "";
      getContacts();
      List<Future<bool>> list = [];
      if (_my_uniq_id == null) {
        final DeviceInfoPlugin deviceInfoPlugin = new DeviceInfoPlugin();
        try {
          if (Platform.isAndroid) {
            list.add(deviceInfoPlugin.androidInfo.then((value) {
              _my_uniq_id = value.androidId; //UUID for Android
              return Future.value(true);
            }));
          } else if (Platform.isIOS) {
            list.add(deviceInfoPlugin.iosInfo.then((value) {
              _my_uniq_id = value.identifierForVendor; //UUID for iOS
              return Future.value(true);
            }));
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
      return Future.wait(list).then((value) => Future.value(true));
    });
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

  void addContact(MyContact item, {needsave = true}) {
    var index =
        _dataContacts.contacts.indexWhere((element) => element.id == item.id);
    if (index > -1) {
      _dataContacts.contacts[index].lastOnline = item.lastOnline;
      _dataContacts.contacts[index].lastIp = item.lastIp;
    } else {
      _dataContacts.contacts.add(item);
    }
    if (needsave) storeContacts(_dataContacts);
  }

  void addContactsArr(List<MyContact> items) {
    if (items.isEmpty) {
      return;
    }
    items.forEach((element) {
      addContact(element, needsave: false);
    });
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
    if (ids.isEmpty) return;
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
