import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udp_hole/entity/data_objects.dart';

import 'model.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UDP-hole-punching-chat'),
      ),
      body: Consumer<UserListModel>(builder: (context, user, child) {
        Widget _buildRow(User user) {
          return ListTile(
            title: Text(
              user.visibleName,
            ),
            trailing: Icon(
              Icons.supervised_user_circle_rounded,
            ),
            onTap: () {
              //TODO navigation
              Navigator.pushNamed(context, '/chat');
            },
          );
        }

        Widget _buildUserList() {
          var arr = user.items;
          return ListView.builder(
              itemCount: arr.length,
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, i) {
                return _buildRow(arr[i]);
              });
        }

        return _buildUserList();
      }),
    );
  }
}
