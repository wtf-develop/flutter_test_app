import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
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
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SpinKitRipple(
              color: Theme.of(context).accentColor, //hintColor,
              size: 40.0,
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
                child: Text(
              'UDP-hole-punching-chat',
              overflow: TextOverflow.fade,
            )),
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
              Navigator.pushNamed(context, '/chat', arguments: {'id': user.id});
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
                  'https://wtf-dev.ru/udp.jpg',
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
          //return Center(child: CircularProgressIndicator());
          return Center(
              child: SpinKitFadingCube(
            color: Theme.of(context).accentColor,
            size: 80.0,
          ));
        } else {
          return _buildUserList();
        }
      }),
    );
  }
}
