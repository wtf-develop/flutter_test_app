import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:math';

import 'package:udp/udp.dart';
import 'package:udp_hole/common/entity/data_objects.dart';

class NetworkClient {
  NetworkClient._privateConstructor();

  static final NetworkClient _instance = NetworkClient._privateConstructor();

  factory NetworkClient() {
    return _instance;
  }

  static const _clientId = "itwasme7";

  static const _SERVER_PORT = 65002;

  Future<List<User>> fetchOnlineUsers() async {
    IdsRequest ids =
        IdsRequest(_clientId, ["jtwhe1", "jtwhe2", "jtwhe3", "jtwhe4"]);
    await _local_server.send(("L" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.broadcast(port: Port(_SERVER_PORT)));
  }

  Future<List<String>> getMessages() {
    return Future.delayed(Duration(milliseconds: 3000)).then((value) {
      return List<String>.generate(10, (i) => ("Message" + i.toString()));
    });
  }

  UDP _local_server;
  var _serverOnline = false;
  Timer _timer;
  var _rnd = new Random();

  void startServer() async {
    _local_server = await UDP.bind(Endpoint.any(port: Port(_SERVER_PORT)));
    _timer =
        Timer.periodic(Duration(seconds: 10), (Timer t) => fetchOnlineUsers());
    _serverOnline = true;
    await _serverLoop(); //infinit loop
  }

  StreamController<List<User>> _streamOnline =
      StreamController.broadcast(sync: false);

  Stream<List<User>> getUsersListStream() {
    return _streamOnline.stream;
  }

  Future<void> _serverLoop() async {
    while (_serverOnline) {
      await _local_server.listen((datagram) {
        var str = String.fromCharCodes(datagram.data);

        Map response = jsonDecode(str.substring(1));

        if (str.startsWith("L{")) {
          /// request from other clients to local app in local network
          var ids = IdsRequest.fromJson(response);
          if (ids.sender == _clientId) {
            //get packet from myself ignore it
            dev.log("Server get myself: " + datagram.address.toString() + str);
          } else {
            dev.log("Server get: " + str);
          }

          var start = _rnd.nextInt(15);
          var users = List<User>.generate(30, (i) {
            var index = i + start;
            return User(index.toString() + "HelloIdname",
                "Address in Internet".substring(index%20) + index.toString(), 3333 + index);
          });
          //send list with users
          _local_server.send(
              ("U" + jsonEncode((UsersList(_clientId, users)).toJson()))
                  .codeUnits,
              Endpoint.unicast(datagram.address, port: Port(datagram.port)));
        } else if (str.startsWith("U{")) {
          ///we receive response from server with list of online users

          var users = UsersList.fromJson(response);
          if (users.sender == _clientId) {
            dev.log(
                "Client receive myself: " + datagram.address.toString() + str);
          } else {
            dev.log("Client receive: " + str);
          }
          _streamOnline.add(users.users);
        }
      }, timeout: Duration(seconds: 200));
    }
    return Future.value();
  }

  void stopServer() {
    _serverOnline = false;
    _timer.cancel();
  }
}
