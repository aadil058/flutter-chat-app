import 'Message.dart';

class Chat {
  String id;
  List<String> participants;
  List<String> names;
  List<Message> messages;
  String adminId;
  String adminName;

  Chat({
    this.id,
    this.participants,
    this.names,
    this.messages,
    this.adminId,
    this.adminName
  });
}