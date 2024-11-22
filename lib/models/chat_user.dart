class ChatUser {
  final String uid;
  final String name;
  final String email;
  final String imageURL;
  late DateTime lastActive;

  ChatUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.imageURL,
    required this.lastActive,
  });

  factory ChatUser.fromJSON(Map<String, dynamic> json) {
    return ChatUser(
      uid: json["uid"] ?? '', // Provide a default value if null
      name: json["name"] ?? 'Unknown', // Provide a default value if null
      email: json["email"] ?? 'No Email', // Provide a default value if null
      imageURL: json["image"] ?? 'https://example.com/default-image.png', // Provide a default value if null
      lastActive: json["last_active"] != null ? json["last_active"].toDate() : DateTime.now(), // Handle null case
    );
  }

  String lastDayActive() {
    return "${lastActive.month}/${lastActive.day}/${lastActive.year}";
  }

  bool wasRecentlyActive() {
    return DateTime.now().difference(lastActive).inHours < 2;
  }
}