import 'package:flutter/material.dart';

class PowerBarIndicator extends StatefulWidget {
  const PowerBarIndicator({super.key});

  @override
  State<PowerBarIndicator> createState() => _PowerBarIndicatorState();
}

class _PowerBarIndicatorState extends State<PowerBarIndicator> {
  double power = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      margin: const EdgeInsets.only(bottom: 50),
      width: 200,
      height: 10,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        color: Colors.grey.shade300,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Container(
          width: 200 * power,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
            color: power < 0.4
                ? Colors.green
                : (power < 0.8 ? Colors.orange : Colors.red),
          ),
        ),
      ),
    );
  }
}
