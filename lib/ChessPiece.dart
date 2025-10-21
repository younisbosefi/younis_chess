import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Piece extends StatelessWidget {
  final String path;
  const Piece({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      path,
      width: 45,
      height: 45,
    );
  }
}
