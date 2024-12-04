import 'package:flutter/material.dart';

class IconGesture extends StatelessWidget {
  const IconGesture({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.onLongPress,
    this.onLongPressStart,
    this.onLongPressEnd,
    required this.color,
    this.iconSize,
    this.text = "",
    this.active = true,
  }) : super(key: key);

  final Widget icon;
  final Color color;
  final VoidCallback onPressed;
  final VoidCallback? onLongPress;
  final Function(LongPressStartDetails)? onLongPressStart;
  final Function(LongPressEndDetails)? onLongPressEnd;
  final double? iconSize;
  final String text; //must be "" if the widget displays an icon
  final bool active;

  @override
  Widget build(BuildContext context) {
    Widget _icon = icon;
    if (text != "") {
      double dbl = text.length > 2 ? 2.5 : 2;
      _icon = Text(text,
          style: TextStyle(
              fontSize: (iconSize ?? 0) / dbl,
              color: active ? color : Colors.grey[600]));
    }
    return GestureDetector(
      child: IconButton(
        icon: _icon,
        onPressed: active ? onPressed : () {},
        iconSize: iconSize ?? 24.0,
        color: active ? color : Colors.grey,
        splashColor: active ? Colors.grey : Colors.transparent,
      ),
      onLongPress: onLongPress,
      onLongPressStart: onLongPressStart,
      onLongPressEnd: onLongPressEnd,
    );
  }
}
