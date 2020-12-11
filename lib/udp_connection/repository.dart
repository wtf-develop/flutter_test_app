import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import 'dart:math';

import 'package:udp/udp.dart';
import 'package:udp_hole/common/entity/data_objects.dart';

class UdpRepository {
  static const _SERVER_PORT = 65002;
  static const _SERVER_DOMAIN = "wtf-dev.ru";

  UdpRepository._privateConstructor() {
    openConnection();
  }

  static final UdpRepository _instance = UdpRepository._privateConstructor();

  factory UdpRepository() {
    return _instance;
  }

  void closeConnection() {
    _local_server?.close();
    _local_server = null;
  }

  Future openConnection() async {
    if (_local_server != null) {
      return;
    }
    return UDP
        .bind(Endpoint.any(port: Port(_SERVER_PORT)))
        .then((value) => _local_server = value)
        .then((value) => Future.value());
  }

  static final _rnd = Random();
  UDP _local_server = null;

  void fetchOnlineUsers(String my_uid, List<String> ids_list) {
    if (my_uid.length < 10) return;

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
  }

  UDP getConnection() => _local_server;

  Future<int> processListRequest(String my_uid, String my_nick,
      InternetAddress address, int port, IdsRequest ids) {
    if (ids.sender == my_uid) {
      dev.log("Server myself");
    } else {
      dev.log("Server");
    }

    return _local_server.send(
        ("U" +
                jsonEncode((UsersList(my_uid, [User(my_nick, my_uid, "", 0)]))
                    .toJson()))
            .codeUnits,
        Endpoint.unicast(address, port: Port(port)));
  }

  Future<int> sendListRequest(String my_uid, String ip, int port) {
    IdsRequest ids = IdsRequest(my_uid, []);
    return _local_server.send(("L" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.unicast(InternetAddress(ip), port: Port(port)));
  }

  Future<int> sendClosedSignal(String my_uid, String ip, int port) {
    IdsRequest ids = IdsRequest(my_uid, []);
    return _local_server.send(("D" + jsonEncode(ids.toJson())).codeUnits,
        Endpoint.unicast(InternetAddress(ip), port: Port(port)));
  }

  Future<int> sendOpenSignal(
      String my_uid, String my_nick, String ip, int port) {
    return _local_server.send(
        ("U" +
                jsonEncode((UsersList(my_uid, [User(my_nick, my_uid, "", 0)]))
                    .toJson()))
            .codeUnits,
        Endpoint.unicast(InternetAddress(ip), port: Port(port)));
  }
}
