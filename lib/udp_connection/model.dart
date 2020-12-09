import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/common/repository/LocalStorage.dart';

import 'client.dart';

class UdpModel {
  UdpModel._privateConstructor() {
    _localStorage.init().then((_) {
      startServer();
    });
  }

  static final UdpModel _instance = UdpModel._privateConstructor();

  factory UdpModel() {
    return _instance;
  }

  var repo = NetworkClient();
  static final LocalStorage _localStorage = LocalStorage();

  static const _REPEAT_DELAY = 10000; //seconds

  Future<void> fetchOnlineUsers() async {
    repo.fetchOnlineUsers(
        _localStorage.getMyUniqId(), _localStorage.getContacts().getIdsOnly());
    return Future.value();
  }

  Future<List<String>> getMessages() {
    return Future.delayed(Duration(milliseconds: 3000)).then((value) {
      return List<String>.generate(10, (i) => ("Message" + i.toString()));
    });
  }

  var _serverOnline = false;
  Timer _timer;

  Future<void> startServer() async {
    if (_localStorage.getMyUniqId().length < 10) return;
    if (_serverOnline) return Future.value();

    //periodic request to server
    _timer = Timer.periodic(
        Duration(milliseconds: _REPEAT_DELAY), (Timer t) => fetchOnlineUsers());
    if (_streamOnline == null) {
      _streamOnline = _generateStream();
    }
    _serverOnline = true;
    fetchOnlineUsers(); //inital request to server
    await _internal_serverLoop(); //infinit loop
    return Future.value();
  }

  void stopServer() {
    if (_serverOnline) {
      _serverOnline = false;
      _lastUsersList.forEach((user) {
        repo.sendClosedSignal(
            _localStorage.getMyUniqId(), user.ipv4, user.port);
      });
      _timer.cancel();
      _streamOnline.close();
      _streamOnline = null;
    }
  }

  List<User> _lastUsersList = [];

  void _addToStreamArr(User user, bool major) {
    var index = _lastUsersList.indexWhere((element) => element.id == user.id);
    if (index < 0) {
      user.updateAddress = !user.lan;
      _lastUsersList.add(user);
    } else {
      if ((_lastUsersList[index].ipv4 != user.ipv4) ||
          (_lastUsersList[index].port != user.port)) {
        _lastUsersList[index].updateAddress = !user.lan;
      }
      if (major) {
        _lastUsersList[index].ipv4 = user.ipv4;
        _lastUsersList[index].port = user.port;
      } else {
        if ((!_lastUsersList[index].lan) && (!user.lan)) {
          _lastUsersList[index].ipv4 = user.ipv4;
          _lastUsersList[index].port = user.port;
        }
      }
      _lastUsersList[index].lastOnline = user.lastOnline;
      _lastUsersList[index].publicName = user.publicName;
    }
  }

  StreamController<List<User>> _streamOnline = StreamController(sync: false);

  StreamController<List<User>> _generateStream() => StreamController(
      onListen: () {
        if (_lastUsersList.isNotEmpty) {
          _streamOnline.add(_lastUsersList);
        }
      },
      sync: false);

  Stream<List<User>> getUsersListStream() {
    return _streamOnline.stream;
  }

  Future<void> _internal_serverLoop() async {
    while (_serverOnline) {
      await repo.getConnection().listen((datagram) {
        if (_localStorage.getMyUniqId().length < 10) return;
        var str = String.fromCharCodes(datagram.data);
        dev.log(datagram.address.toString() + str);
        Map response = jsonDecode(str.substring(1));

        if (str.startsWith("L{")) {
          var ids = IdsRequest.fromJson(response);
          repo.processListRequest(
              _localStorage.getMyUniqId(),
              _localStorage.getNickname(),
              datagram.address,
              datagram.port,
              ids);
        } else if (str.startsWith("U{")) {
          _processUsersResponse(
              _localStorage.getMyUniqId(), datagram, response);
        } else if (str.startsWith("D{")) {
          var ids = IdsRequest.fromJson(response);
          _lastUsersList.removeWhere((element) => element.id == ids.sender);
          if (_serverOnline) _streamOnline?.add(_lastUsersList);
        }
      }, timeout: Duration(seconds: 200));
    }
    return Future.value();
  }

  void _processUsersResponse(
      String my_uid, Datagram datagram, Map<dynamic, dynamic> response) {
    // We receive response from server with list of online users
    var users = UsersList.fromJson(response);
    if (users.sender == my_uid) {
      dev.log("Client myself");
    } else {
      dev.log("Client");
    }

    var time = DateTime.now().millisecondsSinceEpoch;
    users.users.forEach((user) {
      user.lan = false;
      user.lastOnline = time;
      if (user.port == 0 && user.ipv4.length == 0) {
        user.ipv4 = datagram.address.address;
        user.port = datagram.port;
        user.lan = true;
        _addToStreamArr(user, true);
      } else {
        user.lan = false;
        _addToStreamArr(user, false);
      }
    });
    List<User> localUsers =
        users.users.where((userItem) => userItem.lan).toList();

    _localStorage.addContactsArr(localUsers.map((localUser) {
      return MyContact(localUser.id, "", localUser.ipv4, time, 0);
    }).toList());
    _lastUsersList = _lastUsersList
        .where((user) => (user.lastOnline >= (time - (_REPEAT_DELAY * 2) - 1)))
        .toList();
    if (_serverOnline) _streamOnline?.add(_lastUsersList);
    _lastUsersList.forEach((user) {
      if (user.updateAddress && (!user.lan)) {
        user.updateAddress = false;
        repo.sendListRequest(_localStorage.getMyUniqId(), user.ipv4, user.port);
      }
    });
  }
}
