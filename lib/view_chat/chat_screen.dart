import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'package:udp_hole/common/entity/data_objects.dart';

import 'message_row.dart';
import 'model.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  Map data;

  void _handleSubmitted(String text, ChatModel chat) {
    _textController.clear();
    chat.add(text);
    _focusNode.requestFocus();
  }

  Widget _buildTextComposer(ChatModel chat) {
    return IconTheme(
      data: IconThemeData(color: Theme.of(context).accentColor),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(children: [
          Flexible(
            child: TextField(
              controller: _textController,
              onChanged: (String text) {
                chat.activeSend(text.length > 0);
              },
              onSubmitted:
                  chat.canSend ? (text) => _handleSubmitted(text, chat) : null,
              decoration: InputDecoration.collapsed(hintText: 'Send a message'),
              focusNode: _focusNode,
            ),
          ),
          Container(
              margin: EdgeInsets.symmetric(horizontal: 4.0),
              child: Theme.of(context).platform == TargetPlatform.iOS
                  ? CupertinoButton(
                      child: Text('Send'),
                      onPressed: chat.canSend
                          ? () => _handleSubmitted(_textController.text, chat)
                          : null,
                    )
                  : IconButton(
                      icon: const Icon(Icons.send),
                      onPressed: chat.canSend
                          ? () => _handleSubmitted(_textController.text, chat)
                          : null,
                    ))
        ]),
      ),
    );
  }

  List<MessageRow> _view_messages = [];

  Widget _buildMessage(int totalCount, UserMessage data, index) {
    if (totalCount <= _view_messages.length) {
      if ((_view_messages[index] != null)) {
        /////_view_messages[index].setText(data.from, data.message);
        return _view_messages[index];
      }
    }
    MessageRow message = MessageRow(
      name: data.from,
      text: data.message,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 400),
        vsync: this,
      ),
    );
    message.animationController.forward();
    _view_messages.insert(0, message);
    return message;
  }

  ChatModel chatModel;

  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    for (int index = 0; index < _view_messages.length; index++) {
      MessageRow message = _view_messages[index];
      message.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (data == null) {
      data = ModalRoute.of(context).settings.arguments;
      Provider.of<ChatModel>(context, listen: false).setId(data['id']);
      Provider.of<ChatModel>(context, listen: false).getMessages();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(5.0),
              child: SpinKitWanderingCubes(
                color: Theme.of(context).accentColor,
                size: 25.0,
                duration: Duration(seconds: 5),
              ),
            ),
            SizedBox(
              width: 20.0,
            ),
            Expanded(
                child: Text(
              data['id'],
              overflow: TextOverflow.fade,
            )),
          ],
        ),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 1.5 : 1.5,
      ),
      body: Consumer<ChatModel>(
        builder: (context, chat, child) {
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: CachedNetworkImageProvider(
                  'https://wtf-dev.ru/udp.jpg',
                ),
                fit: BoxFit.cover,
              ),
            ),
            child: Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    padding: EdgeInsets.all(8.0),
                    reverse: true,
                    itemBuilder: (_, int index) => _buildMessage(
                        chat.chatSize(), chat.getOneMessage(index), index),
                    itemCount: chat.chatSize(),
                  ),
                ),
                Divider(height: 1.0),
                Container(
                  decoration: BoxDecoration(color: Theme.of(context).cardColor),
                  child: _buildTextComposer(chat),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
