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

  Future<void> startServer() async {
    _local_server = await UDP.bind(Endpoint.any(port: Port(_SERVER_PORT)));

    //periodic request to server
    _timer =
        Timer.periodic(Duration(seconds: 10), (Timer t) => fetchOnlineUsers());
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
      _lastUsersList.add(user);
    } else {
      if (major) {
        _lastUsersList[index].ipv4 = user.ipv4;
        _lastUsersList[index].port = user.port;
      }

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

          users.users.forEach((user) {
            user.lan=false;
            if (user.port == 0 && user.ipv4.length == 0) {
              user.ipv4 = datagram.address.address;
              user.port = datagram.port;
              user.lan=true;
              _addToStreamArr(user, true);
            }else{
              user.lan=false;
              _addToStreamArr(user, false);
            }
          });
          /*List<User> localUsers = users.users.where((user) {
            return user.lan;
          });

          _localStorage.addContactsArr(localUsers.map((localUser) {
            return MyContact(localUser.id, "", localUser.ipv4,
                DateTime.now().millisecondsSinceEpoch, 0);
          }));*/
          _streamOnline?.add(_lastUsersList);
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
