import 'dart:collection';

import 'package:flutter/material.dart';
import 'package:udp_hole/view_chat/repository.dart';

class DataMessage {
  String from, message;

  DataMessage(this.from, this.message);
}

class ChatModel extends ChangeNotifier {
  final List<DataMessage> _messages = List<DataMessage>();
  bool _canSend = false;
  final MessagesListRepo _repo = MessagesListRepo();

  bool get canSend => _canSend;

  UnmodifiableListView<DataMessage> get messages =>
      UnmodifiableListView(_messages);

  int chatSize() => _messages.length;

  DataMessage getOneMessage(int index) => _messages[index];

  void getMessages() {
    _repo.getMessages().then((value) {
      value.forEach((element) {
        _messages.add(DataMessage("Other", element));
      });
      notifyListeners();
    });
  }

  void add(String from, String message) {
    _messages.insert(0, DataMessage(from, message));
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
