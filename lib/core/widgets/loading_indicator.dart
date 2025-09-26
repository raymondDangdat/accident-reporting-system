import 'package:flutter/cupertino.dart';

class LoadingAnimation extends StatelessWidget {
  final Color? color;
  const LoadingAnimation({super.key,
    this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CupertinoActivityIndicator(
        color: color,
      ),
    );
  }
}
