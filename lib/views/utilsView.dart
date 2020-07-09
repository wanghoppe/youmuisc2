import 'dart:io';

import 'package:flutter/material.dart';

Size textSize(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

class VisibleActivityIndicator extends StatelessWidget {
  final bool visible;

  VisibleActivityIndicator({@required this.visible});

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visible,
        child: ClipRRect(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          child: Container(
            height: 54.0,
            width: 54.0,
            padding: EdgeInsets.all(15.0),
            color: Colors.black.withOpacity(0.3),
            child: CircularProgressIndicator(
                valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
          ),
        ));
  }
}

class CustomBoxShadow extends BoxShadow {
  final BlurStyle blurStyle;

  const CustomBoxShadow({
    Color color = const Color(0xFF000000),
    Offset offset = Offset.zero,
    double blurRadius = 0.0,
    double spreadRadius = 0.0,
    this.blurStyle = BlurStyle.normal,
  }) : super(
            color: color,
            offset: offset,
            blurRadius: blurRadius,
            spreadRadius: spreadRadius);

  @override
  Paint toPaint() {
    final Paint result = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(this.blurStyle, blurSigma);
    assert(() {
      if (debugDisableShadows) result.maskFilter = null;
      return true;
    }());
    return result;
  }
}

class CustomListTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String imgUrl;
  final bool networkImg;
  final VoidCallback morePressed;
  final bool cropCircle;
  final String heroIdx;

  const CustomListTile(
      {Key key,
      this.title,
      this.subtitle,
      this.imgUrl,
      this.networkImg,
      this.morePressed,
      this.cropCircle,
      this.heroIdx})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final fromNet = networkImg ?? false;
    final widgetImg = Hero(
        tag: heroIdx,
        child: fromNet ? Image.network(imgUrl) : Image.file(File(imgUrl)));

    return ListTile(
      dense: true,
//      isThreeLine: true,
      leading: Container(
          width: 80,
          child: cropCircle ? ClipOval(child: widgetImg) : widgetImg),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyText1,
        maxLines: 2,
      ),
      subtitle: Text(
        subtitle,
        style: Theme.of(context).textTheme.bodyText2,
        maxLines: 1,
      ),
      trailing: Container(
        width: 30,
//        color: Colors.black,
        child: IconButton(
          iconSize: 24,
          icon: Icon(Icons.more_vert),
          onPressed: morePressed,
        ),
      ),
    );
  }
}

class GeneralActivityIndicatorContainer extends StatelessWidget {
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return Visibility(
        visible: visible ?? true,
        child: Container(
            height: 128,
            child: const Center(
                child: CircularProgressIndicator(
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white70),
            ))));
  }

  GeneralActivityIndicatorContainer({this.visible});
}
