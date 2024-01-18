import 'package:flutter/material.dart';

class NumericStepButton extends StatefulWidget {
  ///  This class is used to create a stateful widget for choosing numbers
  final int minValue;
  final int maxValue;

  final ValueChanged<int> onChanged;

  NumericStepButton({Key? key, this.minValue = 0, this.maxValue = 10, required this.onChanged}) : super(key: key);

  @override
  State<NumericStepButton> createState() {
    return _NumericStepButtonState();
  }
}

class _NumericStepButtonState extends State<NumericStepButton> {
  /// State class for number picker widget

  int counter = 1;

  @override
  Widget build(BuildContext context) {
    ///    Builds number picker widget

    return Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            icon: Icon(
              Icons.remove,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
            iconSize: 32.0,
            onPressed: () {
              setState(() {
                if (counter > widget.minValue) {
                  counter--;
                }
                widget.onChanged(counter);
              });
            },
          ),
          Text(
            '$counter',
            textAlign: TextAlign.center,
          ),
          IconButton(
            icon: Icon(
              Icons.add,
            ),
            padding: EdgeInsets.symmetric(vertical: 4.0, horizontal: 18.0),
            iconSize: 32.0,
            onPressed: () {
              setState(() {
                if (counter < widget.maxValue) {
                  counter++;
                }
                widget.onChanged(counter);
              });
            },
          ),
        ],
      ),
    );
  }
}
