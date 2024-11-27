import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String name;
  final String photoURL;
  final void Function()? onTap;

  const UserTile({
    super.key,
    required this.name,
    required this.photoURL,
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
        child: Row(
          children: [
            // icon
            CircleAvatar(
              backgroundImage: NetworkImage(photoURL), // Use the image URL
              radius: 20, // Adjust the size as needed
            ),

            const SizedBox(width: 20),

            // user name
            Text(name),
          ],
        ),
      ),
    );
  }
}
