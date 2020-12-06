import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;

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

  Future<void> fetchOnlineUsers() async {
    if (_localStorage.getMyUniqId().length < 10) return Future.value();
    IdsRequest ids = IdsRequest(
        _localStorage.getMyUniqId(), _localStorage.getContacts().getIdsOnly());
    /*await _local_server.send(
        ("L" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.unicast(InternetAddress("wtf-dew.ru"),
            port: Port(_SERVER_PORT)));*/

    ids = IdsRequest(_localStorage.getMyUniqId(), []);
    await _local_server.send(("L" + jsonEncode(ids.toJson())).codeUnits,
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

  void startServer() async {
    _local_server = await UDP.bind(Endpoint.any(port: Port(_SERVER_PORT)));

    //periodic request to server
    _timer =
        Timer.periodic(Duration(seconds: 10), (Timer t) => fetchOnlineUsers());
    _serverOnline = true;
    fetchOnlineUsers(); //inital request to server
    await _serverLoop(); //infinit loop
  }

  static List<User> _lastUsersList = [];
  StreamController<List<User>> _streamOnline;

  Stream<List<User>> getUsersListStream() {
    return _streamOnline.stream;
  }

  Future<void> _serverLoop() async {
    _streamOnline = StreamController(
        onListen: () {
          if (_lastUsersList != null) {
            _streamOnline.add(_lastUsersList);
          }
        },
        sync: false);
    while (_serverOnline) {
      await _local_server.listen((datagram) {
        if (_localStorage.getMyUniqId().length < 10) return;
        var str = String.fromCharCodes(datagram.data);

        Map response = jsonDecode(str.substring(1));

        if (str.startsWith("L{")) {
          /// request from other clients to local app in local network
          var ids = IdsRequest.fromJson(response);
          if (ids.sender == _localStorage.getMyUniqId()) {
            //get packet from myself ignore it
            dev.log("Server get myself: " + datagram.address.toString() + str);
          } else {
            dev.log("Server get: " + str);
          }

          var users = [
            User(
                _localStorage.getNickname(), _localStorage.getMyUniqId(), "", 0)
          ];
          //send list with users
          _local_server.send(
              ("U" +
                      jsonEncode((UsersList(_localStorage.getMyUniqId(), users))
                          .toJson()))
                  .codeUnits,
              Endpoint.unicast(datagram.address, port: Port(datagram.port)));
        } else if (str.startsWith("U{")) {
          ///we receive response from server with list of online users
          var users = UsersList.fromJson(response);
          if (users.sender == _localStorage.getMyUniqId()) {
            dev.log(
                "Client receive myself: " + datagram.address.toString() + str);
          } else {
            dev.log("Client receive: " + str);
          }
          _lastUsersList = users.users;
          _streamOnline?.add(users.users);
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
