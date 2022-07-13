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

  FRTDBChatUtils(String refUrl) {
    _firebaseDatabase = FirebaseDatabase.instance.refFromURL(refUrl).child('user_chats');
  }

  /// Send message
  void sendMessage(String channelId, dynamic message, dynamic metaInfo) => _writeDB(channelId, message, metaInfo);

  /// Fetch chats
  void fetchMessage({String? channelId}) => _readDB(channelId!);

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

  /******************************************************************************************************************** */
  /// DB util fuction

  /// Write to DB
  void _writeDB(String channelId, dynamic message, dynamic metaInfo) async {
    /// Push the last message to
    await _firebaseDatabase.child(channelId).child('chats').push().set(message);

    /// Update the meta info of the chat.
    updateMetaInfo(channelId, message);
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
}
