import 'package:firebase_database/firebase_database.dart';
import 'package:logging/logging.dart';

/// Reatime Time Chat Solution
/// A solution to provide the real time chating between users.
///
/// [Firebase Realtime Database] is used as the backend database to store the chat data.
///
/// [DataBase Structure]
/// "user_chats"
///      |
///      |----[channel_id]
///      |        |
///      |        |----"meta"
///      |        |----"chats"
///      |        |       |
///      |        |       |----[messageId]
///      |        |       |         |
///      |        |       |         |----{message}
///
///

final log = Logger('ExampleLogger');

class FRTDBChatUtils {
  /// Firebase database instance
  late final DatabaseReference _firebaseDatabase;

  late final DatabaseReference firebaseDatabaseRef;

  FRTDBChatUtils(String refUrl) {
    _firebaseDatabase = FirebaseDatabase.instance.refFromURL(refUrl).child('user_chats');
    firebaseDatabaseRef = _firebaseDatabase;
  }

  /// Send message
  Future<String> sendMessage(String channelId, dynamic message, dynamic metaInfo) => _writeDB(channelId, message, metaInfo);

  /// Fetch chats
  Future<List<dynamic>> fetchMessage({String? channelId}) => _readDB(channelId!);

  /// Return a meta information for the given [channelId]
  Future<dynamic> metaInfo(String? channelId) async {
    dynamic metaData;

    await _firebaseDatabase.child(channelId!).child('meta').once().then((value) {
      metaData = value.snapshot.value;
    });

    log.info('Meta Info : $metaData');
    return metaData;
  }

  /// Set the meta to last pushed message.
  void updateMetaInfo(String channelId, dynamic metaInfo) async {
    await _firebaseDatabase.child(channelId).child('meta').set(metaInfo);
  }

  /// Check channel existence
  Future<bool> isChannelExists(String channelId) async {
    var data = await _firebaseDatabase.child(channelId).once();
    
    if(data.snapshot.exists) {
      return true;
    }

    log.info('Channel Exists : ${data.snapshot.exists}');
    return false;
  }

  Future<dynamic> chatListener(String channelId) async {
    dynamic data;
    firebaseDatabaseRef.child(channelId).child('chats').limitToLast(1) .onChildAdded.listen((event) {
      log.info('lastest chat : ${event.snapshot.value}');
      data = event.snapshot.value;
    });

    print("asdfd"+ data.toString());
    return data;
  }

  void sendFiles(String channelId, String chatId, dynamic file) {
    /// Push the last message to
    final messageReference = _firebaseDatabase.child(channelId).child('chats').child(channelId).child('files').push().set(file);

    /// Update the meta info of the chat.
    updateMetaInfo(channelId, 'File');
  }

  /******************************************************************************************************************** */
  /// DB util fuction

  /// Write to DB
  Future<String> _writeDB(String channelId, dynamic message, dynamic metaInfo) async {
    /// Push the last message to
    final messageReference = _firebaseDatabase.child(channelId).child('chats').push();
    
    /// Set message id
    message['message_id'] = messageReference.key; 
   
    /// Set message
    messageReference.set(message);

    /// Update the meta info of the chat.
    updateMetaInfo(channelId, message);

    return messageReference.key!;
  }

  /// Read DB
  Future<List<dynamic>> _readDB(String channelId) async {
    List<dynamic> chats = [];

    var snapshot = await _firebaseDatabase.child(channelId).child('chats').get();

    if (snapshot.exists) {
      for (var chat in snapshot.children) {
        chats.add(chat.value);
      }
    } else {
      log.shout('No data available.');
    }

    log.info('Total Chats : ${chats.length}');
    return chats;
  }

  /// Update message
  // void updateMessage() {
  //   _firebaseDatabase.
  // }
}
