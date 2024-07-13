import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';

class CustomizedButton extends StatelessWidget {
  final String title;
  final bool isRoundButton;
  final IconData icon;
  final void Function() func;
  final Color color;

  const CustomizedButton(
      {super.key,
      this.title = "",
      this.isRoundButton = false,
      this.icon = Icons.add,
      this.color = AppTheme.mainGreen,
      required this.func});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: func,
      child: Container(
        alignment: Alignment.center,
        width: isRoundButton ? 50 : 200,
        height: 50,
        padding: EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(25),

        ),
        child: isRoundButton
            ? Icon(
                icon,
                color: Colors.white,
              )
            : Text(
                title,
                style: AppTheme.buttonText(),
              ),
      ),
    );
  }
}
