import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Loader extends StatelessWidget {
  final double screenHeight;
  const Loader({
    super.key,
    this.screenHeight = 00,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color.fromARGB(67, 0, 0, 0),
      width: SizeUtils.width(context),
      height: screenHeight != 0 ? screenHeight : SizeUtils.height(context),
      child: Center(
          child: LoadingAnimationWidget.discreteCircle(
              color: Colors.black,
              secondRingColor: const Color(0xFFEA3799),
              thirdRingColor: Colors.green,
              size: 40)),
    );
  }
}

class SizeUtils {
  static double width(BuildContext context) =>
      MediaQuery.of(context).size.width;

  static double height(BuildContext context) =>
      MediaQuery.of(context).size.height;
}
