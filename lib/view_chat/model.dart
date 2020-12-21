import 'dart:async';
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


  StreamSubscription<UserMessage> _current_subscription;
  void getMessages(String id) {
    _userId = id;
    _messages.addAll(_repo.getMessages(_userId));
    if(_current_subscription!=null){
      _current_subscription.cancel();
    }
    _current_subscription=_repo.subscribeMessage(_localStorage.getMyUniqId(),_userId).listen((message) {
      _messages.insert(0, message);
      notifyListeners();
    });
  }

  void closeSubscription(){
    if(_current_subscription!=null){
      _current_subscription.cancel();
    }
    _current_subscription=null;

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
