import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
        height: 70,
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(
                  20.0),
              child: Icon(
                variableIcon[title],
                color: AppTheme.mainGreen,
              ),
            ),
            Column(
              mainAxisAlignment:
              MainAxisAlignment.start,
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets
                      .fromLTRB(
                      8.0, 10, 8, 0),
                  child: Text(title,
                      style: TextStyle(
                          fontSize: 12)),
                ),
                Wrap(
                  children: [Padding(
                    padding: const EdgeInsets
                        .fromLTRB(
                        8.0, 4, 8, 0),
                    child: Text(
                      softWrap: true,
                      toBeginningOfSentenceCase(output),
                      style: TextStyle(
                          fontWeight:
                          FontWeight.w500,
                          fontSize: 17),
                    ),
                  )],
                )
              ],
            )
          ],
        ),
        decoration: AppTheme.widgetDeco(),
      ),
    );
  }
}
