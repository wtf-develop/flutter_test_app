import 'package:flutter/material.dart';

class MessageRow extends StatefulWidget {
  MessageRow({this.animationController});

  String _name = 'Leonid';
  String _text = "Hello";
  final AnimationController animationController;

  void setText(String user, String mess) {
    _name = user;
    _text = mess;
    strow?.setState(() {
      _name = user;
      _text = mess;
    });
  }

  _MessageRowState strow;

  @override
  _MessageRowState createState() {
    strow = _MessageRowState();
    return strow;
  }
}

class _MessageRowState extends State<MessageRow> {
  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(
          parent: widget.animationController, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Container(
          margin: EdgeInsets.only(top: 25.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(right: 16.0),
                child: CircleAvatar(child: Text(widget._name[0])),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(widget._name,
                        style: Theme.of(context).textTheme.headline6),
                    Container(
                      margin: EdgeInsets.only(top: 5.0),
                      child: Text(widget._text),
                    ),
                  ],
                ),
              ),
            ],
          )),
    );
  }
}
