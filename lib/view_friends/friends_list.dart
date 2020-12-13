import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udp_hole/common/entity/data_objects.dart';

import 'model.dart';

class FriendsList extends StatefulWidget {
  @override
  _FriendsListState createState() => _FriendsListState();
}

class _FriendsListState extends State<FriendsList> {
  @override
  void initState() {
    Provider.of<UserListModel>(context, listen: false).updateFromServer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          children: [
            Container(
              child: Icon(Icons.supervised_user_circle_outlined),
              padding: EdgeInsets.only(right: 15.0),
            ),
            Text('UDP-hole-punching-chat'),
          ],
        ),
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
              color: user.lan ? Colors.green[900] : Colors.cyan[800],
            ),
            onTap: () {
              Navigator.pushNamed(context, '/chat');
            },
          );
        }

        //create dynamic list for big item count
        Widget _buildUserList() {
          var arr = user.items;
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://wtf-dev.ru/sync/login/img/back.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView.builder(
                itemCount: arr.length,
                padding: EdgeInsets.all(16.0),
                itemBuilder: (context, i) {
                  return _buildRow(arr[i]);
                }),
          );
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
