import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String name;
  final String photoURL;
  final String bio;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.name,
    required this.photoURL,
    required this.bio,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 25,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // icon
                CircleAvatar(
                  backgroundImage: NetworkImage(photoURL), // Use the image URL
                  radius: 25, // Adjust the size as needed
                ),

                const SizedBox(width: 20),

                Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
                children: [
                  Text(
                    name,
                    style: TextStyle(fontWeight: FontWeight.bold), // Make name bold
                  ),
                  if (bio.isNotEmpty) // Show bio only if it is not empty
                    Text(
                      bio,
                      style: TextStyle(color: Colors.grey), // Style for bio
                    ),
                ],
              ),
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
