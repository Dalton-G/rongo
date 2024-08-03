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
        data = ["Total Item", "$num", "lib/images/totalitem.png"];
        break;
      case "soon":
        data = ["Expire Soon", "$num", "lib/images/expiresoon.png"];
        color = Colors.yellowAccent;
        break;
      case "expired":
        data = ["Expired Item", "$num", "lib/images/expireditem.png"];
        color = Colors.redAccent;
        break;
      case "new":
        data = ["New Item", "$num", "lib/images/newitem.png"];
    }
    ;
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, left: 10, right: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Center(
            child: Text(
              data[0],
              style: TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Stack(
            children: [
              SizedBox(height: 70, width: 80, child: Image.asset(data[2])),
              Padding(
                padding: const EdgeInsets.only(left: 60.0,top: 5),
                child: Container(

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: AppTheme.backgroundWhite.withOpacity(0.5),
                  ),
                  child: Center(
                    child: Text(
                      data[1],
                      style: TextStyle(
                          fontSize: 30,
                          color: color,
                          fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
