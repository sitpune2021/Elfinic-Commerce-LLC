import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:google_fonts/google_fonts.dart';

class AmiriText extends StatelessWidget {
  final String text;
  final double fontSize;
  final FontWeight fontWeight;
  final Color color;
  final double height;
  final int maxLines;
  final double minFontSize;
  final TextAlign textAlign;

  const AmiriText(
      this.text, {
        super.key,
        this.fontSize = 18,
        this.fontWeight = FontWeight.bold,
        this.color = Colors.black,
        this.height = 1.4,
        this.maxLines = 3,
        this.minFontSize = 12,
        this.textAlign = TextAlign.start,
      });

  @override
  Widget build(BuildContext context) {
    return AutoSizeText(
      text,
      style: GoogleFonts.amiri(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        height: height,
      ),
      maxLines: maxLines,
      minFontSize: minFontSize,
      overflow: TextOverflow.ellipsis,
      textAlign: textAlign,
    );
  }
}
