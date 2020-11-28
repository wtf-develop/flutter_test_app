import 'dart:collection';

import 'package:flutter/foundation.dart';
import 'package:udp_hole/entity/data_objects.dart';

class UserListModel extends ChangeNotifier {
  final List<User> _items = [
    User("Hello name", "Ip address", 3333),
    User("Good bye", "192.168.0.xxx", 8888)
  ];

  UnmodifiableListView<User> get items => UnmodifiableListView(_items);

  void add(User item) {
    _items.add(item);
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }

  void removeAll() {
    _items.clear();
    // This call tells the widgets that are listening to this model to rebuild.
    notifyListeners();
  }
}
