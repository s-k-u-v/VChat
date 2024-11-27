import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String senderID;
  final String senderEmail;
  final String receiverID;
  final String receiverName;
  final String message;
  final Timestamp timestamp;
  final String? fileUrl;

  Message({
    required this.senderID,
    required this.senderEmail,
    required this.receiverID,
    required this.receiverName,
    required this.message,
    required this.timestamp,
    this.fileUrl,
  });

  // conver to a map
  Map<String, dynamic> toMap() {
    return {
      'senderID': senderID,
      'senderEmail': receiverID,
      'receiverID': receiverID,
      'receieverName': receiverName,
      'message': message,
      'timestamp': timestamp,
      'fileUrl': fileUrl,
    };
  }
}
