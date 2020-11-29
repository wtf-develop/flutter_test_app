import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:udp_hole/common/entity/data_objects.dart';

import 'repository.dart';

class UserListModel extends ChangeNotifier {
  final List<User> _items = List<User>();
  var _requestInProgress = false;
  final UserListRepo _repo = UserListRepo();

  void updateFromServer() {
    _requestInProgress = true;
    _repo.getOnlineUsers().then((value) {
      _requestInProgress = false;
      update(value);
    });
  }

  UnmodifiableListView<User> get items => UnmodifiableListView(_items);

  bool get requestInProgress => _requestInProgress;

  void add(User item) {
    _items.add(item);
    notifyListeners();
  }

  void removeAll() {
    if (_items.isNotEmpty) {
      _items.clear();
      notifyListeners();
    }
  }

  void update(List<User> updatedList) {
    List<int> indexes = [];
    List<User> new_users = [];
    var changed = false;
    //check current list for unexisting users
    for (var i = 0; i < _items.length; i++) {
      if (updatedList
              .indexWhere((element) => (element.compareTo(_items[i]) == 0)) <
          0) {
        indexes.add(i);
      }
    }
    if (indexes.length > 0) {
      //remove unexisting users
      for (var i = indexes.length - 1; i >= 0; i--) {
        _items.removeAt(indexes[i]);
      }
      changed = true;
    }
    //add new users from server
    for (var i = 0; i < updatedList.length; i++) {
      if (_items.indexWhere(
              (element) => (element.compareTo(updatedList[i]) == 0)) <
          0) {
        _items.add(updatedList[i]);
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }
}
