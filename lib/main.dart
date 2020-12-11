import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:udp_hole/udp_connection/model.dart';

import 'view_chat/chat_screen.dart';
import 'view_chat/model.dart';
import 'view_friends/friends_list.dart';
import 'view_friends/model.dart';

void main() {
  //WidgetsFlutterBinding.ensureInitialized();
  runApp(
    FriendlyChatApp(),
  );
}

class FriendlyChatApp extends StatefulWidget {
  const FriendlyChatApp({
    Key key,
  }) : super(key: key);

  @override
  _FriendlyChatAppState createState() => _FriendlyChatAppState();
}

class _FriendlyChatAppState extends State<FriendlyChatApp>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  AppLifecycleState _lifecicle_state;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lifecicle_state == null) {
      didChangeAppLifecycleState(AppLifecycleState.resumed);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _lifecicle_state = state;
    switch (state) {
      case AppLifecycleState.resumed:
        UdpModel().startServer();
        break;
      case AppLifecycleState.paused:
        UdpModel().stopServer();
        break;
    }
    setState(() {
      _lifecicle_state = state;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (context) => UserListModel()),
          ChangeNotifierProvider(create: (context) => ChatModel()),
          //Provider(create: (context) => UdpModel()),
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
