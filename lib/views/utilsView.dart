import 'package:flutter/material.dart';

class VisibleActivityIndicator extends StatelessWidget{

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
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)
    ),
        ),
      ));
  }

}