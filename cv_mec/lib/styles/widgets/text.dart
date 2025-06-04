import 'package:cv_mec/styles/text_styles.dart';
import 'package:flutter/material.dart';

class CVMECText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final TextAlign textAlign;

  const CVMECText.styleOne(this.text, {this.textAlign = TextAlign.left}) : style = style_one;
  const CVMECText.styleTwo(this.text, {this.textAlign = TextAlign.left}) : style = style_two;
  const CVMECText.styleThree(this.text, {this.textAlign = TextAlign.left}) : style = style_three;
  const CVMECText.styleFour(this.text, {this.textAlign = TextAlign.left}) : style = style_four;
  const CVMECText.styleFive(this.text, {this.textAlign = TextAlign.left}) : style = style_five;
  const CVMECText.body(this.text, {this.textAlign = TextAlign.left, this.style = style_body});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: style,
      textAlign: textAlign,
    );
  }
}

class ClickableText extends StatelessWidget {
  final String text;
  final TextStyle style;
  final Function()? onTap;

  ClickableText({
    Key? key,
    required this.text,
    required this.onTap,
    this.style = underlined_style_two,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Text(text, style: style),
    );
  }
}
