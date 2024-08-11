import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screen/home/homepage.dart';
import '../utils/theme/theme.dart';

class AddItemWidget extends StatelessWidget {
  const AddItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        child: GestureDetector(
          onTap: (() {
            Navigator.popUntil(context, ModalRoute.withName('/homepage'));
            Provider.of<IndexProvider>(context, listen: false)
                .setSelectedIndex(3);
          }),
          child: Container(
            decoration: AppTheme.widgetDeco(),
            padding: const EdgeInsets.all(15),
            child: const SizedBox(
              height: 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [Icon(Icons.add_outlined), Text("Add new item")],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AddItemWidgetWithPrompt extends StatelessWidget {
  final String nullPrompting;

  const AddItemWidgetWithPrompt({super.key, required this.nullPrompting});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AddItemWidget(),
        Padding(
          padding: EdgeInsets.only(
              top: (MediaQuery.of(context).size.height * 0.48) - 135),
          child: Center(child: Text(nullPrompting ?? "")),
        ),
      ],
    );
  }
}
