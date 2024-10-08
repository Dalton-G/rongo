import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';

class CustomizedButton extends StatelessWidget {
  final String title;
  final bool isRoundButton;
  final IconData icon;
  final void Function() func;
  final Color color;
  final String tooltip;
  final double width;

  const CustomizedButton(
      {super.key,
      this.title = "",
      this.isRoundButton = false,
      this.icon = Icons.add,
      this.color = AppTheme.mainGreen,
      this.tooltip = "",
        this.width = 200,
      required this.func});

  @override
  Widget build(BuildContext context) {
    return TooltipVisibility(
      visible: tooltip == "" ? false : true,
      child: Tooltip(
        // textStyle: TextStyle(color: Colors.black),
        // decoration: BoxDecoration(borderRadius: BorderRadius.circular(15), color: Colors.grey.withOpacity(0.5)),
        triggerMode: TooltipTriggerMode.longPress,
        message: tooltip,
        child: GestureDetector(
          onTap: func,
          child: Container(
            alignment: Alignment.center,
            width: isRoundButton ? 50 : width,
            height: 50,
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
        ),
      ),
    );
  }
}

//Suzanne
class DefaultButton extends StatelessWidget {
  final Color backgroundColor;
  final void Function() func;
  final double roundedCorner;
  final String buttonText;
  const DefaultButton(
      {Key? key,
      required this.backgroundColor,
      required this.func,
      required this.roundedCorner,
      required this.buttonText})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: func,
      child: Container(
        width: 200,
        height: 60,
        padding: EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 15,
        ),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(
            roundedCorner,
          ),
        ),
        child: Center(
          child: Text(
            buttonText,
            style: AppTheme.whiteButtonText,
          ),
        ),
      ),
    );
  }
}

class RoundButton extends StatelessWidget {
  final Color color;
  final Color iconColor;
  final IconData icon;
  final void Function() func;
  const RoundButton({
    Key? key,
    required this.color,
    required this.iconColor,
    required this.icon,
    required this.func,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: func,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: AppTheme.bottomLightShadow),
        child: Center(
          child: Icon(
            icon,
            color: iconColor,
          ),
        ),
      ),
    );
  }
}
