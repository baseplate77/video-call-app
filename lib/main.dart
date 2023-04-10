import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wakelock/wakelock.dart';

import 'create_meeting_screen.dart';
import 'get_it.dart';
import 'service/signaling.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  await Wakelock.enable();
  await Firebase.initializeApp(
      // options: const FirebaseOptions(
      //   apiKey: "AIzaSyCQvu1m2EMJJgYw8IW_SsZza0c3kYckcEM",
      //   appId: "1:941013704086:web:913941c68c3322cf1bd1b7",
      //   messagingSenderId: "941013704086",
      //   projectId: "video-call-rtc-4ff4e",
      // ),
      );
  setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: GoogleFonts.poppinsTextTheme().copyWith(),
      ),
      // home: const MyHomePage(),
      // home: const CallScreen(),
      home: const CreateMeetingScreen(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Signaling signaling = Signaling();
  final RTCVideoRenderer _localRenderer = RTCVideoRenderer();
  final RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
  String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  @override
  void initState() {
    _localRenderer.initialize();
    _remoteRenderer.initialize();

    _remoteRenderer.addListener(() {
      print("this is from reomteRenderer listiner");
    });
    signaling.onAddRemoteStream = ((stream) {
      _remoteRenderer.srcObject = stream;
      setState(() {});
    });

    super.initState();
  }

  @override
  void dispose() {
    _localRenderer.dispose();
    _remoteRenderer.dispose();
    signaling.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Welcome to Flutter Explained - WebRTC"),
      ),
      body: Column(
        children: [
          const SizedBox(height: 8),
          SizedBox(
            height: 40,
            child: ListView(
              // mainAxisAlignment: MainAxisAlignment.center,
              shrinkWrap: true,
              scrollDirection: Axis.horizontal,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    await signaling.openUserMedia(
                        _localRenderer, _remoteRenderer);
                    setState(() {});
                  },
                  child: const Text("Open camera & microphone"),
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  onPressed: () async {
                    roomId = await signaling.createRoom();
                    textEditingController.text = roomId!;
                    setState(() {});
                  },
                  child: const Text("Create room"),
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    // Add roomId
                    // signaling.joinRoom(
                    //   textEditingController.text,
                    //   _remoteRenderer,
                    // );
                  },
                  child: const Text("Join room"),
                ),
                const SizedBox(
                  width: 8,
                ),
                ElevatedButton(
                  onPressed: () {
                    // signaling.hangUp(_localRenderer);
                  },
                  child: const Text("Hangup"),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: RTCVideoView(_localRenderer, mirror: true)),
                  Expanded(child: RTCVideoView(_remoteRenderer)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Join the following Room: "),
                Flexible(
                  child: TextFormField(
                    controller: textEditingController,
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
