class MetaInfo {
  String? uuid;
  String? messageType;
  String? message;
  String? time;

  MetaInfo({required this.uuid, required this.message, required this.time});

  MetaInfo.fromJson(Map<String, dynamic> json) {
    uuid = json['sender_id'];
    messageType = json['message_type'];
    message = json['message'];
    time = json['publish_at'];
  }

  Map<String, dynamic> toJson() => {
    "uuid": uuid,
    "message_type": messageType,
    "message": message,
    "time": time,
  };
}
