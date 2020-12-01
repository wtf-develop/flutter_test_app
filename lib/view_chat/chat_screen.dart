import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'message_row.dart';
import 'model.dart';

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  final _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  void _handleSubmitted(String text, ChatModel chat) {
    _textController.clear();

    chat.add("Me", text);
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

  Widget _buildMessage(DataMessage data, index) {
    /*if ((index < _view_messages.length) && (_view_messages[index] != null)) {
      _view_messages[index].text=data.message;
      return _view_messages[index];
    }*/
    MessageRow message = MessageRow(
      text: data.message,
      animationController: AnimationController(
        duration: const Duration(milliseconds: 2000),
        vsync: this,
      ),
    );
    message.animationController.forward();
    //_view_messages.insert(index, message);
    return message;
  }

  void initState() {
    super.initState();
    Provider.of<ChatModel>(context, listen: false).getMessages();
  }

  @override
  void dispose() {
    for (MessageRow message in _view_messages) {
      message.animationController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Chat'),
        elevation: Theme.of(context).platform == TargetPlatform.iOS ? 1.5 : 1.5,
      ),
      body: Consumer<ChatModel>(
        builder: (context, chat, child) {
          return Column(
            children: [
              Flexible(
                child: ListView.builder(
                  padding: EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (_, int index) =>
                      _buildMessage(chat.getOneMessage(index), index),
                  itemCount: chat.chatSize(),
                ),
              ),
              Divider(height: 1.0),
              Container(
                decoration: BoxDecoration(color: Theme.of(context).cardColor),
                child: _buildTextComposer(chat),
              ),
            ],
          );
        },
      ),
    );
  }
}
