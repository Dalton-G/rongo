import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';

//Suzanne

class SquareContainer extends StatelessWidget {
  final Color backgroundColor;
  final double roundedCorner;
  final double height, width;
  final Widget? child;

  const SquareContainer({
    Key? key,
    required this.backgroundColor,
    required this.roundedCorner,
    required this.height,
    required this.width,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(roundedCorner),
      ),
      child: Center(
        child: SizedBox(
          height: height * 0.8,
          width: width * 0.8,
          child: child,
        ),
      ),
    );
  }
}
