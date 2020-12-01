import 'package:flutter/material.dart';

class MessageRow extends StatelessWidget {
  MessageRow({this.text}); // NEW
  final String text;
  String _name = 'Leonid';

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 25.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(right: 16.0),
              child: CircleAvatar(child: Text(_name[0])),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_name, style: Theme.of(context).textTheme.headline6),
                Container(
                  margin: EdgeInsets.only(top: 5.0),
                  child: Text(text),
                ),
              ],
            ),
          ],
        ));
  }
}
