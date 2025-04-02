import 'package:flutter/material.dart';

Widget buildNavButton(
    BuildContext context,
    String imagePath,
    Widget page,
    Type currentPageType,
    ) {
  bool isSelected = page.runtimeType == currentPageType;

  return InkWell(
    onTap: () {
      if (!isSelected) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => page));
      }
    },
    child: Container(
      width: 50,
      height: 50,
      decoration: const BoxDecoration(color: Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Image.asset(
          imagePath,
          width: 40,
          height: 40,
          color: isSelected ? Colors.blue : Colors.white,
          fit: BoxFit.contain,
        ),
      ),
    ),
  );
}
