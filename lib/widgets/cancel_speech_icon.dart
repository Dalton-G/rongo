import 'package:flutter/material.dart';

import '../utils/theme/theme.dart';

class CancelSpeechIcon extends StatelessWidget {
  const CancelSpeechIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.delete_forever),
        const SizedBox(
          height: 5,
        ),
        Icon(
          Icons.arrow_drop_up_rounded,
          color: AppTheme.mainGreen.withAlpha(30),
        ),
        Icon(
          Icons.arrow_drop_up_rounded,
          color: AppTheme.mainGreen.withAlpha(60),
        ),
        Icon(
          Icons.arrow_drop_up_rounded,
          color: AppTheme.mainGreen.withAlpha(120),
        ),
        Icon(
          Icons.arrow_drop_up_rounded,
          color: AppTheme.mainGreen.withAlpha(180),
        ),
        Icon(
          Icons.arrow_drop_up_rounded,
          color: AppTheme.mainGreen.withAlpha(250),
        ),
      ],
    );
  }
}
