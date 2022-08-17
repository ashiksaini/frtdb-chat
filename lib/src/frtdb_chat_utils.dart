import 'package:firebase_database/firebase_database.dart';
import 'package:frtdb_chat/src/services/repository.dart';
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
    ApiRepository();
    _firebaseDatabase = FirebaseDatabase.instance.refFromURL(refUrl);
    firebaseDatabaseRef = _firebaseDatabase;
  }

  /// Send message
  Future<String> sendMessage(String channelId, dynamic message, dynamic metaInfo) => _writeDB(channelId, message, metaInfo);

  /// Fetch chats
  Future<List<dynamic>> fetchMessage({String? channelId}) => _readDB(channelId!);

  /// Mark Online
  Future<List<dynamic>> markOnline({String? channelId, String? uuid}) async {
    try {
      await _firebaseDatabase.child('user_chats').child(channelId!).child('meta').child('presence').push().set(uuid);
      DataSnapshot snapshot = await _firebaseDatabase.child('user_chats').child(channelId).child('meta').child('presence').get();

      if(snapshot.exists) {
        return snapshot.children.toList();
      } else {
        return [];
      }
    } catch (error) {
      print("Error : $error");
      rethrow;
    }
  }

  /// For Unread Msg
  // Future<List<dynamic>> unreadMessagesCount() async {
  //   try {

  //   } catch (error) {
  //     print("Error : $error");
  //     rethrow;
  //   }
  // }

  /// Return a meta information for the given [channelId]
  Future<dynamic> metaInfo(String? channelId) async {
    try {
      dynamic metaData;

      await _firebaseDatabase.child('user_chats').child(channelId!).child('meta').once().then((value) {
        metaData = value.snapshot.value;
      });

      print('Meta Info : $metaData');
      return metaData;
    } catch(error) {
      print('Error: $error');
      rethrow;
    }
  }

  /// Set the meta to last pushed message.
  void updateMetaInfo(String channelId, dynamic metaInfo) async {
    try {
      await _firebaseDatabase.child('user_chats').child(channelId).child('meta').set(metaInfo);
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  /// Check channel existence
  Future<bool> isChannelExists(String channelId) async {
    var data = await _firebaseDatabase.child('user_chats').child(channelId).once();

    if (data.snapshot.exists) {
      return true;
    }

    log.info('Channel Exists : ${data.snapshot.exists}');
    return false;
  }

  /// Send notification
  Future<dynamic> sendNotification({String? token, dynamic? message}) async {
    try {
      dynamic result = await ApiRepository.sendNotification(token!, message!);

      return result;
    } catch(error) {
      print('Error: $error');
      rethrow;
    }
  }

  /// Fetch more chats
  Future<List<dynamic>> fetchMoreMessage({String? channelId, String? lastMessageId}) async {
    List<dynamic> chats = [];
    var snapshot = await _firebaseDatabase.child('user_chats').child(channelId!).child('chats').endBefore(lastMessageId).limitToLast(5).get();

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

  /******************************************************************************************************************** */
  /// DB util fuction

  /// Write to DB
  Future<String> _writeDB(String channelId, dynamic message, dynamic metaInfo) async {
    try {
      /// Push the last message to
      final messageReference = _firebaseDatabase.child('user_chats').child(channelId).child('chats').push();

      /// Set message id
      message['message_id'] = messageReference.key;

      /// Set message
      messageReference.set(message);

      /// Update the meta info of the chat.
      updateMetaInfo(channelId, message);

      return messageReference.key!;
    } catch (error) {
      print('Error: $error');
      rethrow;
    }
  }

  /// Read DB
  Future<List<dynamic>> _readDB(String channelId) async {
    try {
      var snapshot = await _firebaseDatabase.child('user_chats').child(channelId).child('chats').get();

      if (snapshot.exists) {
        print('Total Chats : ${snapshot.children.length}');
        return snapshot.children.toList();
      } else {
        print('No data available.');
        return [];
      }
    } catch (error) {
      print('Error : $error');
      rethrow;
    }
  }
}
