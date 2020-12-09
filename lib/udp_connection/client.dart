import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:udp/udp.dart';
import 'package:udp_hole/common/entity/data_objects.dart';

class NetworkClient {
  static const _SERVER_PORT = 65002;
  static const _SERVER_DOMAIN = "wtf-dev.ru";

  NetworkClient._privateConstructor() {
    UDP
        .bind(Endpoint.any(port: Port(_SERVER_PORT)))
        .then((value) => _local_server = value);
  }

  static final NetworkClient _instance = NetworkClient._privateConstructor();

  factory NetworkClient() {
    return _instance;
  }

  static final _rnd = Random();
  UDP _local_server = null;

  Future<void> fetchOnlineUsers(String my_uid, List<String> ids_list) async {
    if (my_uid.length < 10) return Future.value();

    InternetAddress.lookup(_SERVER_DOMAIN).then((value) {
      if (value.length > 0) {
        IdsRequest ids = IdsRequest(my_uid, ids_list);
        _local_server?.send(
            ("L" + jsonEncode(ids.toJson())).codeUnits,
            Endpoint.unicast(value[_rnd.nextInt(value.length) % value.length],
                port: Port(_SERVER_PORT)));
      }
    });

    IdsRequest ids = IdsRequest(my_uid, []);
    _local_server?.send(("L" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.broadcast(port: Port(_SERVER_PORT)));
    return Future.value();
  }

  UDP getConnection() => _local_server;

  void processListRequest(String my_uid, String my_nick,
      InternetAddress address, int port, IdsRequest ids) {
    if (ids.sender == my_uid) {
      dev.log("Server myself");
    } else {
      dev.log("Server");
    }

    _local_server.send(
        ("U" +
                jsonEncode((UsersList(my_uid, [User(my_nick, my_uid, "", 0)]))
                    .toJson()))
            .codeUnits,
        Endpoint.unicast(address, port: Port(port)));
  }

  void sendListRequest(String my_uid, String ip, int port) {
    IdsRequest ids = IdsRequest(my_uid, []);
    _local_server.send(("L" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.unicast(InternetAddress(ip), port: Port(port)));
  }

  void sendClosedSignal(String my_uid, String ip, int port) {
    IdsRequest ids = IdsRequest(my_uid, []);
    _local_server.send(("D" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.unicast(InternetAddress(ip), port: Port(port)));
  }
}
