import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:frtdb_chat/frtdb_chat.dart';
import 'package:logging/logging.dart';

final log = Logger('ExampleLogger');

void main() async {
  /// Define a logger...
  Logger.root.level = Level.ALL; // defaults to Level.INFO

  /// Listen a log...
  Logger.root.onRecord.listen((record) {
    if (kDebugMode) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    }
  });

  /// Init flutter binding...
  WidgetsFlutterBinding.ensureInitialized();

  /// Init firebase app...
  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late FRTDBChatUtils _firebaseDatabase;

  @override
  void initState() {
    super.initState();

    _firebaseDatabase = FRTDBChatUtils('https://fir-chat-a0a69-default-rtdb.firebaseio.com/');

    var message = {
      "sender_id": 8440,
      "sender_name": 'Ashik Saini',
      "receiver_id": 8441,
      "receiver_name": 'Pankaj Jain',
      "message_type": 'text',
      "message": "ni adfasdfad afsdfasdfa aana",
      "receipt": 'read',
      "time": '100000000',
      "message_id": '',
    };

    var metaInfo = {
      'uuid' : message['sender_id'],
      'time' : message['time'],
      'message' : message['message']
    };

    _firebaseDatabase.sendMessage("8440-8441", message, metaInfo);
    // _firebaseDatabase.metaInfo('8440-8441');

    getChats();

    // _firebaseDatabase.chatListener('8440-8441');

  }

  getChats() async {
    _firebaseDatabase.firebaseDatabaseRef.child('8440-8441').child('chats').limitToLast(1) .onChildAdded.listen((event) {
      log.info('lastest chat : ${event.snapshot.value}');
      // data = event.snapshot.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold();
  }
}
