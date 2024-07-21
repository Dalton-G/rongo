import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:rongo/utils/theme/theme.dart';

import '../utils/utils.dart';

class ItemVariableWidget extends StatelessWidget {
  final String output;
  final String title;
  const ItemVariableWidget({super.key, required this.output, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          8.0, 20, 8, 0),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 17, horizontal: 20),
        decoration: AppTheme.widgetDeco(),

        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Icon(
              variableIcon[title],
              color: AppTheme.mainGreen,
            ),
            SizedBox(width: 20,),
            Flexible(
              child: Column(
                mainAxisAlignment:
                MainAxisAlignment.start,
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: TextStyle(
                          fontSize: 12)),
                  SizedBox(height: 7,),
                  Text(
                    softWrap: true,
                    toBeginningOfSentenceCase(output),
                    style: TextStyle(
                      color: Colors.black87,
                        fontWeight:
                        FontWeight.w500,
                        fontSize: 17),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
