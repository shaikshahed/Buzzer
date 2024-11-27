import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BuzzNotification extends StatefulWidget {
  final String name;
  final String phoneNumber;
  const BuzzNotification(
      {super.key, required this.name, required this.phoneNumber});

  @override
  State<BuzzNotification> createState() => _BuzzNotificationState();
}

class _BuzzNotificationState extends State<BuzzNotification> {
  int _timerValue = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    startTimer();
  }

  void startTimer() {
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      setState(() {
        if (_timerValue > 0) {
          _timerValue--;
        } else {
          // Timer reached 0, execute function to set boolean value to false
          Navigator.of(context).pop();
          _timer!.cancel(); // Cancel the timer
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 450,
      decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20), topRight: Radius.circular(20))),
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SvgPicture.asset(
              "assets/images/bellLogo.svg",
              width: 80,
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              widget.name,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            Text(
              "+91${widget.phoneNumber}",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF8B8B8B),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            const Text(
              "Buzzed you!",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: ButtonStyle(
                padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 40, vertical: 14)),
                shadowColor: WidgetStateProperty.all(
                    const Color.fromRGBO(255, 255, 255, 0.469)),
                elevation: WidgetStateProperty.all(18),
                backgroundColor: WidgetStateProperty.all(
                  const Color(0xFFC0C0C0),
                ),
              ),
              child: const Text(
                "Close",
                style: TextStyle(color: Colors.white, fontSize: 20),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Text(
              "Automatically closes in ${_timerValue}sec",
              style: const TextStyle(color: Color(0xFF9E9E9E), fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
