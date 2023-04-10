import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:video_call_webrtc/call_screen.dart';
import 'package:video_call_webrtc/get_it.dart';
import 'package:video_call_webrtc/service/signaling.dart';
import 'package:video_call_webrtc/utils/CustomBtn.dart';
import 'package:video_call_webrtc/utils/ShowShareRoomIdDialog.dart';
import 'package:video_call_webrtc/utils/showEnterRoomIdDialog.dart';

import 'constant.dart';

class CreateMeetingScreen extends StatefulWidget {
  const CreateMeetingScreen({super.key});

  @override
  State<CreateMeetingScreen> createState() => _CreateMeetingScreenState();
}

class _CreateMeetingScreenState extends State<CreateMeetingScreen> {
  String? roomId;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.transparent,
                    bgColor,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              child: Image.asset("assets/demo.png"),
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                CustomBtn(
                  onPress: () async {
                    final signaling = getIt<Signaling>();

                    // initialze the Video Render frist
                    await signaling.intialize();
                    roomId = await signaling.createRoom();
                    if (roomId != null) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => CallScreen(roomId: roomId!)));
                    }
                  },
                  text: "Start a Call",
                ),
                CustomBtn(
                  color: secondaryColor,
                  onPress: () async {
                    await getIt<Signaling>().intialize();
                    // showEnterRoomIdDialog(context, remoteVideoRender)
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CallScreen(),
                      ),
                    );
                  },
                  text: "Join Call",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
