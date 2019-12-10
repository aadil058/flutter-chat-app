class Message {
  String sender;
  String receiver;
  String timestamp;
  String data;

  Message({
    this.sender,
    this.receiver,
    this.timestamp,
    this.data
  });

  Message.fromJson(Map<String, dynamic> json) : sender = json['sender'], receiver = json['receiver'], timestamp = json['timestamp'], data = json['data']; 

  Map<String, dynamic> toJson() =>
    {
      'sender': sender,
      'receiver': receiver,
      'timestamp': timestamp,
      'data': data
    };
}