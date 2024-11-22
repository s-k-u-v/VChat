// Packages
import 'package:flutter/material.dart';
// Importing the file where MessageType is defined

// Define MessageType if not already defined
enum MessageType {
  text,
  image,
  unknown,
}

class CustomListViewTile extends StatelessWidget {
  final double height;
  final String title;
  final String subtitle;
  final String imagePath;
  final bool isActive;
  final bool isSelected;
  final Function onTap;

  const CustomListViewTile({
    super.key, 
    required this.height,
    required this.title,
    required this.subtitle,
    required this.imagePath,
    required this.isActive,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      trailing: isSelected ? Icon(Icons.check, color: Colors.white) : null,
      onTap: () => onTap(),
      minVerticalPadding: height * 0.20,
      leading: CircleAvatar(
        backgroundImage: NetworkImage(imagePath),
        radius: height / 4,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: Colors.white54,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }
}