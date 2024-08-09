import 'package:flutter/material.dart';
import 'package:rongo/utils/theme/theme.dart';

class SquareContainer extends StatelessWidget {
  final Color backgroundColor;
  final double roundedCorner;
  final double height, width;
  final Widget? child;
  final bool withPadding;

  const SquareContainer({
    Key? key,
    required this.backgroundColor,
    required this.roundedCorner,
    required this.height,
    required this.width,
    this.child,
    this.withPadding = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(roundedCorner),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: Offset(0, 4),
            blurRadius: 4,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: SizedBox(
          height: withPadding ? height * 0.8 : height,
          width: withPadding ? width * 0.8 : width,
          child: child,
        ),
      ),
    );
  }
}
