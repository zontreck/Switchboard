import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class AlterWidget extends StatelessWidget {
  bool flush = false;
  bool roundedElement = true;
  bool squarePics = false;
  Color backgroundColor;
  Color textColor;

  AlterWidget({
    super.key,
    this.flush = true,
    this.roundedElement = true,
    this.squarePics = false,
    this.backgroundColor = Colors.grey,
    this.textColor = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: roundedElement ? null : BoxBorder.all(),
      margin: roundedElement ? null : EdgeInsetsGeometry.zero,
      color: backgroundColor,

      child: Row(
        children: [
          flush
              ? Image.network(
                  "https://api.systemswitchboard.com/avatar/null",
                  width: 75,
                )
              : Padding(
                  padding: EdgeInsetsGeometry.all(
                    (squarePics && !flush) ? 8 : 2,
                  ),
                  child: Card(
                    elevation: 8,
                    shape: squarePics ? BoxBorder.all() : null,
                    margin: squarePics ? EdgeInsets.zero : null,
                    child: Image.network(
                      "https://api.systemswitchboard.com/avatar/null",
                      width: 75,
                    ),
                  ),
                ),
          SizedBox(width: 8),
          Text(
            "Sample Alter",
            style: TextStyle(fontSize: 22, color: textColor),
          ),
        ],
      ),
    );
  }
}
