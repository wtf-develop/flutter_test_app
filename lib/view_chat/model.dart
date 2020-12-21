import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/common/repository/LocalStorage.dart';
import 'package:udp_hole/view_chat/repository.dart';

class ChatModel extends ChangeNotifier {
  final List<UserMessage> _messages = List<UserMessage>();
  bool _canSend = false;
  final MessagesListRepo _repo = MessagesListRepo();

  bool get canSend => _canSend;

  UnmodifiableListView<UserMessage> get messages =>
      UnmodifiableListView(_messages);

  int chatSize() => _messages.length;

  UserMessage getOneMessage(int index) => _messages[index];

  String _userId;

  void setId(String id) {
    _userId = id;
  }

  void getMessages() {
    _messages.addAll(_repo.getMessages(_userId));
    _repo.subscribeMessage(_localStorage.getMyUniqId(),_userId).listen((message) {
      _messages.insert(0, message);
      notifyListeners();
    });
  }

  LocalStorage _localStorage = LocalStorage();

  void add(String message) {
    var userMessage =
        UserMessage(_localStorage.getMyUniqId(), _userId, message, 0, 0);
    _messages.insert(0, userMessage);
    _repo.sendMessage(userMessage);
    _canSend = false;
    notifyListeners();
  }

  void removeAll() {
    if (_messages.isNotEmpty) {
      _messages.clear();
      _canSend = false;
      notifyListeners();
    }
  }

  void activeSend(bool sendState) {
    if (sendState != _canSend) {
      _canSend = sendState;
      notifyListeners();
    }
  }
}
