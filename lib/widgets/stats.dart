import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';

class Stats extends StatelessWidget {
  final String stats;
  final int num;

  Stats({super.key, required this.stats, required this.num});

  @override
  Widget build(BuildContext context) {
    List data = [];
    Color color = AppTheme.mainGreen;
    switch (stats) {
      case "total":
        data = ["Total Items", "$num", "lib/images/roastchicken.png"];
        break;
      case "soon":
        data = ["Expires Soon", "$num", "lib/images/cheese.png"];
        color = AppTheme.mainGreen;
        break;
      case "expired":
        data = ["Expired Items", "$num", "lib/images/expiredfruits.png"];
        color = AppTheme.mainGreen;
        break;
      case "new":
        data = ["New Items", "$num", "lib/images/jelly.png"];
    }

    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            data[0],
            style: TextStyle(
                fontSize: 14, color: color, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),

          // Image
          Image.asset(data[2], height: 60, width: 80),

          // Number
          Text(
            data[1],
            style: TextStyle(
              fontSize: 16,
              color: color,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
