import 'dart:convert';
import 'package:crypto/crypto.dart';

String generateChatRoomId(String adminId, String userId) {
  final ids = [adminId, userId];
  ids.sort(); // Sort the IDs to ensure consistent chat room IDs
  final concatenatedIds = ids.join('_');
  final bytes = utf8.encode(concatenatedIds);
  final hash = sha1.convert(bytes);
  return hash.toString();
}
