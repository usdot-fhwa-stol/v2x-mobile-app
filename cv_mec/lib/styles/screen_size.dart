import 'package:flutter/material.dart';

double screenWidth(BuildContext context) => MediaQuery.of(context).size.width;
double screenHeight(BuildContext context) => MediaQuery.of(context).size.height;
double screenHeightPercentage(BuildContext context, {double percentage = 1}) => screenHeight(context) * percentage;
double screenWidthPercentage(BuildContext context, {double percentage = 1}) => screenWidth(context) * percentage;