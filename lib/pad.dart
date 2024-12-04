import 'package:flutter/material.dart';
import 'package:telecommande/info_button.dart';

class Pad extends StatelessWidget {
  const Pad(
      {super.key,
      required this.showInfoButton,
      required this.buttonColor,
      required this.sendOrder});
  final bool showInfoButton;
  final Color buttonColor;
  final void Function(String order) sendOrder;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: GestureDetector(
            child: Container(
              width: double.infinity,
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.all(Radius.circular(15)),
                color: buttonColor,
              ),
              child: Visibility(
                visible: showInfoButton,
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: const InfoButton(),
              ),
            ),
            onTap: () {
              sendOrder("ok");
            },
            onLongPress: () {
              sendOrder("red");
            },
            onDoubleTap: () {
              sendOrder("green");
            },
            onHorizontalDragEnd: (dragEndDetails) {
              if (dragEndDetails.primaryVelocity != null) {
                if (dragEndDetails.primaryVelocity! < 0) {
                  sendOrder("left");
                } else if (dragEndDetails.primaryVelocity! > 0) {
                  sendOrder("right");
                }
              }
            },
            onVerticalDragEnd: (dragEndDetails) {
              if (dragEndDetails.primaryVelocity != null) {
                if (dragEndDetails.primaryVelocity! < 0) {
                  sendOrder("up");
                } else if (dragEndDetails.primaryVelocity! > 0) {
                  sendOrder("down");
                }
              }
            }));
  }
}
