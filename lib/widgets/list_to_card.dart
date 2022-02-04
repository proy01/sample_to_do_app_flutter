import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import '../main.dart';

class ListToCard extends StatefulWidget {
  final Function parentState;

  const ListToCard({Key? key, required this.parentState}) : super(key: key);

  @override
  _ListToCardState createState() => _ListToCardState();
}

class _ListToCardState extends State<ListToCard> {
  bool switchState = false;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10)
          ),
          child: Row(
            children: [
              const Icon(Icons.list),
              Switch(
                value: switchState,
                onChanged: (value) {
                  setState(() {
                    switchState = value;
                    globalView = !globalView;
                    widget.parentState();
                  });
                },
                activeColor: Colors.indigo,
                activeTrackColor: Colors.lightBlueAccent,
              ),
              const Icon(Icons.crop_square_sharp),
            ],
          ),
        ),
      ],
    );
  }
}