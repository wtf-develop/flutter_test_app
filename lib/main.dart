import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'common/network/client.dart';
import 'view_chat/chat_screen.dart';
import 'view_chat/model.dart';
import 'view_friends/friends_list.dart';
import 'view_friends/model.dart';

void main() {
  runApp(
    FriendlyChatApp(),
  );
  NetworkClient().startServer();
}

class FriendlyChatApp extends StatelessWidget {
  const FriendlyChatApp({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserListModel()),
          ChangeNotifierProvider(create: (context) => ChatModel()),
        ],
        child: MaterialApp(
          title: 'UDP chat',
          initialRoute: '/',
          routes: {
            // When navigating to the "/" route, build the FirstScreen widget.
            '/': (context) => FriendsList(),
            // When navigating to the "/second" route, build the SecondScreen widget.
            '/chat': (context) => ChatScreen(),
          },
        ));
  }
}
