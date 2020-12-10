import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udp_hole/common/entity/data_objects.dart';
import 'package:udp_hole/udp_connection/model.dart';

import 'model.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    Provider.of<UserListModel>(context, listen: false).updateFromServer();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _notification;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _notification = state;
    switch (state) {
      case AppLifecycleState.resumed:
        Provider.of<UdpModel>(context, listen: false).startServer();
        break;
      case AppLifecycleState.paused:
        Provider.of<UdpModel>(context, listen: false).stopServer();
        break;
    }
    //setState(() { _notification = state; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('UDP-hole-punching-chat'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 1.5 : 1.5,
      ),
      body: Consumer<UserListModel>(builder: (context, user, child) {
        //generate each row in list
        Widget _buildRow(User user) {
          return ListTile(
            title: Text(
              user.visibleName,
            ),
            trailing: Icon(
              Icons.supervised_user_circle_rounded,
            ),
            onTap: () {
              Navigator.pushNamed(context, '/chat');
            },
          );
        }

        //create dynamic list for big item count
        Widget _buildUserList() {
          var arr = user.items;
          return ListView.builder(
              itemCount: arr.length,
              padding: EdgeInsets.all(16.0),
              itemBuilder: (context, i) {
                return _buildRow(arr[i]);
              });
        }

        if (user.items.isEmpty && user.requestInProgress) {
          return Center(child: CircularProgressIndicator());
        } else {
          return _buildUserList();
        }
      }),
    );
  }
}
