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

  AppLifecycleState _lifecycleState;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_lifecycleState == null) {
      didChangeAppLifecycleState(AppLifecycleState.resumed);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == _lifecycleState) {
      return;
    }
    switch (state) {
      case AppLifecycleState.resumed:
        UdpModel().startServer();
        break;
      case AppLifecycleState.paused:
        UdpModel().stopServer();
        break;
      default:
        return;
    }
    _lifecycleState = state;

    /*setState(() {
      _lifecycleState = state;
    });*/
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
          theme: ThemeData(
              fontFamily: 'Montserrat',
              brightness: Brightness.dark,
              backgroundColor: Color(0xff0e151b),
              scaffoldBackgroundColor: Color(0xff0e151b),
              accentColor: Colors.amber,
              colorScheme: ColorScheme.dark()),
          title: 'UDP chat',
          initialRoute: '/',
          routes: {
            '/': (context) => FriendsList(),
            '/chat': (context) => ChatScreen(),
          },
        ));
  }
}
