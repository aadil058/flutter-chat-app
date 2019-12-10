import 'package:chat_app/Datalayer/Chat.dart';
import 'package:chat_app/Datalayer/Message.dart';
import 'package:chat_app/Datalayer/User.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:chat_app/BLoC/bloc.dart';

class DatabaseBloc implements Bloc {

  List<Chat> chats;
  List<User> users;

  Chat chatById(String chatId) {
    return chats.firstWhere((chat) => chat.id == chatId);
  }

  User userWhereIdEqualTo(String id) {
    return users.firstWhere((u) => u.id == id);
  }

  dynamic searchUsers() async {
    if(users == null) 
      users = List<User>();

    try {
      QuerySnapshot data = await Firestore.instance.collection('users').getDocuments();
      users.clear();
      for(int i = 0; i < data.documents.length; ++i) {
        User user = User(id: data.documents[i].documentID, name: data.documents[i].data['name'], phone: data.documents[i].data['phone'], email: data.documents[i].data['email']);
        users.add(user);
      }

      return users;
    } 
    catch(err) {
      print(err);
    }
  }

  List<Message> messagesList(dynamic messages) {
    List<Message> messagesFinal = List<Message>();
    for(int i = 0; i < messages.length; ++i) {
      Message message = Message(sender: messages[i]['sender'], receiver: messages[i]['receiver'], timestamp: messages[i]['timestamp'], data: messages[i]['data']);
      messagesFinal.add(message);
    }
    return messagesFinal;
  }

  dynamic getChats(String myId) async {
    if(chats == null) 
      chats = List<Chat>();

    try {
      QuerySnapshot data = await Firestore.instance.collection('chats').where('participants', arrayContains: myId).getDocuments();
      chats.clear();
      for(int i = 0; i < data.documents.length; ++i) {
        List<String> participants = List<String>();
        List<String> names = List<String>();

        for(int j = 0; j < data.documents[i].data['participants'].length; ++j)
          participants.add(data.documents[i].data['participants'][j].toString());

        for(int j = 0; j < data.documents[i].data['names'].length; ++j)
          names.add(data.documents[i].data['names'][j]);

        String adminId = data.documents[i].data['adminId'];
        String adminName = data.documents[i].data['adminName'];

        Chat chat = Chat(id: data.documents[i].documentID, participants: participants, names: names, adminId: adminId, adminName: adminName, messages: messagesList(data.documents[i].data['messages']));
        chats.add(chat);
      }

      return chats;
    } 
    catch(err) {
      print(err);
    }
  }

  dynamic filterUserAndChat(String text, String currentUserId) async {
    if(text == "" || text == null)
      return List<User>();

    List<User> fetchedUsers = await searchUsers();
    return fetchedUsers.where((u) => u.name.toLowerCase().contains(text.toLowerCase()) && u.id != currentUserId).toList();
  }

  dynamic createChat(List<String> participants, List<String> names, List<Message> messages) async {
    DocumentReference chatReference = await Firestore.instance.collection('chats')
      .add({
        'participants': participants,
        'names': names,
        'messages': messages.map((item) => item.toJson()).toList(),
        'adminId' : null,
        'adminName': null
      });

    if(chats == null)
      chats = List<Chat>();

    chats.add(Chat(id: chatReference.documentID, participants: participants, names: names, messages: messages, adminId: null, adminName: null));

    return chats.last;
  }
  
  dynamic addMessage(String chatId, String sender, String receiver, String msg) async {
    Chat chat = chats.firstWhere((chat) => chat.id == chatId);
    int index = chats.indexOf(chat);
    chats[index].messages.add(Message(data: msg, sender: sender, receiver: receiver, timestamp: DateTime.now().millisecondsSinceEpoch.toString()));

    await Firestore.instance.collection('chats').document(chatId).updateData({
      'messages': chats[index].messages.map((item) => item.toJson()).toList(),
    });
  }

  dynamic addLocalMessage(DocumentSnapshot snapshot) {
    List<String> participants = List<String>();
    List<String> names = List<String>();

    for(int i = 0; i < snapshot.data['participants'].length; ++i)
      participants.add(snapshot.data['participants'][i].toString());

    for(int i = 0; i < snapshot.data['names'].length; ++i)
      names.add(snapshot.data['names'][i].toString());

    String adminId = snapshot.data['adminId'];
    String adminName = snapshot.data['adminName'];

    Chat newChat = Chat(id: snapshot.documentID, participants: participants, adminId: adminId, adminName: adminName, names: names, messages: messagesList(snapshot.data['messages']));

    Chat chat;
    try { chat = chats.firstWhere((chat) => chat.id == snapshot.documentID); }
    catch(err) {}

    int index = chats.indexOf(chat);
    if(index == -1)
      chats.add(newChat);
    else
      chats[index] = newChat;
  }

  dynamic createGroup(List<String> participants, List<String> names, String adminId, String adminName, List<Message> messages) async {
    DocumentReference chatReference = await Firestore.instance.collection('chats')
      .add({
        'participants': participants,
        'names': names,
        'messages': messages.map((item) => item.toJson()).toList(),
        'adminId': adminId,
        'adminName': adminName
      });

    if(chats == null)
      chats = List<Chat>();

    chats.add(Chat(id: chatReference.documentID, participants: participants, names: names, messages: messages, adminId: adminId, adminName: adminName));

    return chats.last;
  }

  dynamic editGroup(String groupId, List<String> participants, List<String> names) async {
    await Firestore.instance.collection('chats')
      .document(groupId)
      .updateData({
        "participants": participants,
        "names": names
      });

    if(chats == null)
      chats = List<Chat>();
    else {
      int index = chats.indexWhere((c) => c.id == groupId);
      chats[index].participants = participants;
      chats[index].names = names;
    }
  }

  @override
  void dispose() {}
}
