import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/common/repository/LocalStorage.dart';

import 'online_users.dart';
import 'repository.dart';

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

  UdpRepository _repo = UdpRepository();
  LocalStorage _localStorage = LocalStorage();
  OnlineUsers _lastUsersObject = OnlineUsers();

  static const _REPEAT_DELAY = 10000; //seconds

  void fetchOnlineUsers() {
    _repo.fetchOnlineUsers(
        _localStorage.getMyUniqId(), _localStorage.getContacts().getIdsOnly());
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
    await _repo.openConnection();
    //periodic request to server
    _timer = Timer.periodic(
        Duration(milliseconds: _REPEAT_DELAY), (Timer t) => fetchOnlineUsers());
    _lastUsersObject.openStream();
    _serverOnline = true;
    fetchOnlineUsers(); //inital request to server
    await _internal_serverLoop(); //infinit loop
    return Future.value();
  }

  void stopServer() {
    if (_serverOnline) {
      _serverOnline = false;
      List<Future> listFuture = [];
      _lastUsersObject.getList().forEach((user) {
        listFuture.add(_repo.sendClosedSignal(
            _localStorage.getMyUniqId(), user.ipv4, user.port));
      });
      _timer.cancel();
      _lastUsersObject.closeStream();
      Future.wait(listFuture).then((value) => _repo.closeConnection());
    }
  }

  Stream<List<User>> getUsersListStream() {
    return _lastUsersObject.getStream();
  }

  Future<void> _internal_serverLoop() async {
    while (_serverOnline) {
      await _repo.getConnection().listen((datagram) {
        if (_localStorage.getMyUniqId().length < 10) return;
        var str = String.fromCharCodes(datagram.data);
        dev.log(datagram.address.toString() + str);
        Map response = jsonDecode(str.substring(1));

        if (str.startsWith("L{")) {
          var ids = IdsRequest.fromJson(response);
          _repo.processListRequest(
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
          if (_serverOnline) _lastUsersObject.remove(ids.sender);
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
      } else {
        user.lan = false;
      }
    });
    _lastUsersObject.addAll(users.users);
    List<User> localUsers =
        users.users.where((userItem) => userItem.lan).toList();

    _localStorage.addContactsArr(localUsers.map((localUser) {
      return MyContact(localUser.id, "", localUser.ipv4, time, 0);
    }).toList());

    if (_serverOnline) _lastUsersObject.removeWithTimeout(_REPEAT_DELAY * 2);
    _lastUsersObject.getList().forEach((user) {
      if (user.updateAddress && (!user.lan)) {
        user.updateAddress = false;
        _repo.sendListRequest(
            _localStorage.getMyUniqId(), user.ipv4, user.port);
      }
    });
  }
}
