import 'dart:async';

import 'package:udp_hole/common/entity/data_objects.dart';

class OnlineUsers {
  OnlineUsers._privateConstructor() {
    _streamOnline = _generateStream();
  }

  static final OnlineUsers _instance = OnlineUsers._privateConstructor();

  factory OnlineUsers() {
    return _instance;
  }

  List<UserMessage> _messagesList = [];
  StreamController<List<UserMessage>> _messagesStream =
      StreamController.broadcast(sync: false);

  List<User> _lastUsersList = [];
  StreamController<List<User>> _streamOnline;

  List<UserMessage> getMessages(String userId) {
    return _messagesList
        .where((element) => (element.from == userId || element.to == userId))
        .toList();
  }

  Stream<List<UserMessage>> getMessagesStream() => _messagesStream.stream;

  List<User> getList() => _lastUsersList;

  Stream<List<User>> getStream() => _streamOnline.stream;

  bool isNotEmpty() {
    return _lastUsersList.isNotEmpty;
  }

  bool isEmpty() {
    return _lastUsersList.isEmpty;
  }

  void removeWithTimeout(int timeout) {
    /*_lastUsersList = _lastUsersList
        .where((user) => (user.lastOnline >= (time - (_REPEAT_DELAY * 2) - 1)))
        .toList();*/
    var time = DateTime.now().millisecondsSinceEpoch;
    _lastUsersList
        .removeWhere((user) => (user.lastOnline < (time - timeout - 1)));
    _streamOnline?.add(_lastUsersList);
  }

  void remove(String id) {
    _lastUsersList.removeWhere((element) => element.id == id);
    _streamOnline?.add(_lastUsersList);
  }

  void addAll(List<User> users) {
    for (int i = 0; i < users.length; i++) {
      _add(users[i]);
    }
    _streamOnline?.add(_lastUsersList);
  }

  void _add(User user) {
    var index = _lastUsersList.indexWhere((element) => element.id == user.id);
    if (index < 0) {
      user.updateAddress = !user.lan;
      _lastUsersList.add(user);
    } else {
      if ((_lastUsersList[index].ipv4 != user.ipv4) ||
          (_lastUsersList[index].port != user.port)) {
        _lastUsersList[index].updateAddress = !user.lan;
      }
      if (user.lan) {
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

  void closeStream() {
    _streamOnline.close();
    _streamOnline = null;
  }

  void openStream() {
    if (_streamOnline == null) {
      _streamOnline = _generateStream();
    }
  }

  StreamController<List<User>> _generateStream() => StreamController(
      onListen: () {
        if (_lastUsersList != null && _lastUsersList.isNotEmpty) {
          _streamOnline.add(_lastUsersList);
        }
      },
      sync: false);
}
