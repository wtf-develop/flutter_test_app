import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:udp/udp.dart';
import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/common/repository/LocalStorage.dart';

class NetworkClient {
  NetworkClient._privateConstructor();

  static final NetworkClient _instance = NetworkClient._privateConstructor();

  factory NetworkClient() {
    return _instance;
  }

  static final LocalStorage _localStorage = LocalStorage();

  static const _SERVER_PORT = 65002;
  static const _REPEAT_DELAY = 10000; //seconds
  static const _SERVER_DOMAIN = "wtf-dev.ru";
  static final _rnd=Random();

  Future<void> fetchOnlineUsers() async {
    if (_localStorage.getMyUniqId().length < 10) return Future.value();

    InternetAddress.lookup(_SERVER_DOMAIN).then((value) {
      if (value.length > 0) {
        IdsRequest ids = IdsRequest(_localStorage.getMyUniqId(),
            _localStorage.getContacts().getIdsOnly());
        _local_server.send(("L" + jsonEncode(ids.toJson())).codeUnits,
            Endpoint.unicast(value[_rnd.nextInt(value.length)%value.length], port: Port(_SERVER_PORT)));
      }
    });
    IdsRequest ids = IdsRequest(_localStorage.getMyUniqId(), []);
    _local_server.send(("L" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.broadcast(port: Port(_SERVER_PORT)));
    return Future.value();
  }

  Future<List<String>> getMessages() {
    return Future.delayed(Duration(milliseconds: 3000)).then((value) {
      return List<String>.generate(10, (i) => ("Message" + i.toString()));
    });
  }

  UDP _local_server;
  var _serverOnline = false;
  Timer _timer;

  Future<void> startServer() async {
    _local_server = await UDP.bind(Endpoint.any(port: Port(_SERVER_PORT)));

    //periodic request to server
    _timer = Timer.periodic(
        Duration(milliseconds: _REPEAT_DELAY), (Timer t) => fetchOnlineUsers());
    if (_streamOnline == null) {
      _streamOnline = _generateStream();
    }
    _serverOnline = true;
    fetchOnlineUsers(); //inital request to server
    await _serverLoop(); //infinit loop
    return Future.value();
  }

  List<User> _lastUsersList = [];

  void _addToStreamArr(User user, bool major) {
    var index = _lastUsersList.indexWhere((element) => element.id == user.id);
    if (index < 0) {
      user.updateAddress = true;
      _lastUsersList.add(user);
    } else {
      if ((_lastUsersList[index].ipv4 != user.ipv4) ||
          (_lastUsersList[index].port != user.port)) {
        _lastUsersList[index].updateAddress = true;
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

  StreamController _generateStream() => StreamController(
      onListen: () {
        if (_lastUsersList.isNotEmpty) {
          _streamOnline.add(_lastUsersList);
        }
      },
      sync: false);

  Stream<List<User>> getUsersListStream() {
    return _streamOnline.stream;
  }

  Future<void> _serverLoop() async {
    while (_serverOnline) {
      await _local_server.listen((datagram) {
        if (_localStorage.getMyUniqId().length < 10) return;
        var str = String.fromCharCodes(datagram.data);

        Map response = jsonDecode(str.substring(1));

        if (str.startsWith("L{")) {
          // Request from other clients to local app in local network
          var ids = IdsRequest.fromJson(response);
          if (ids.sender == _localStorage.getMyUniqId()) {
            //get packet from myself ignore it
            dev.log("Server get myself: " + datagram.address.toString() + str);
          } else {
            dev.log("Server get: " + str);
          }

          //send list with my device id
          _local_server.send(
              ("U" +
                      jsonEncode((UsersList(_localStorage.getMyUniqId(), [
                        User(_localStorage.getNickname(),
                            _localStorage.getMyUniqId(), "", 0)
                      ])).toJson()))
                  .codeUnits,
              Endpoint.unicast(datagram.address, port: Port(datagram.port)));
        } else if (str.startsWith("U{")) {
          // We receive response from server with list of online users
          var users = UsersList.fromJson(response);
          if (users.sender == _localStorage.getMyUniqId()) {
            dev.log(
                "Client receive myself: " + datagram.address.toString() + str);
          } else {
            dev.log("Client receive: " + str);
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
              .where((user) =>
                  (user.lastOnline >= (time - (_REPEAT_DELAY * 2) - 1)))
              .toList();
          _streamOnline?.add(_lastUsersList);
          _lastUsersList.forEach((user) {
            if (user.updateAddress) {
              user.updateAddress = false;
              IdsRequest ids = IdsRequest(_localStorage.getMyUniqId(), []);
              _local_server.send(
                  ("L" + jsonEncode(ids.toJson())).codeUnits,
                  Endpoint.unicast(InternetAddress(user.ipv4),
                      port: Port(_SERVER_PORT)));
            }
          });
        }
      }, timeout: Duration(seconds: 200));
    }
    return Future.value();
  }

  void stopServer() {
    _serverOnline = false;
    _timer.cancel();
    _streamOnline.close();
    _streamOnline = null;
  }
}
