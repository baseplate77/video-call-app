import 'package:flutter/material.dart';
import 'package:video_call_webrtc/get_it.dart';
import 'package:video_call_webrtc/service/signaling.dart';
import 'package:video_call_webrtc/utils/CustomBtn.dart';

showEnterRoomIdDialog(
  BuildContext context,
) async {
  String? roomId;

  showDialog(
      context: context,
      builder: (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            title: const Text("Enter Room ID"),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Room ID is require to connect the call bettween you and your friend. Make sure you copy paste the exacte ID, a small mistake will mistake will result not connection the call",
                ),
                TextFormField(
                  onChanged: (value) {
                    roomId = value;
                  },
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomBtn(
                    onPress: () async {
                      await getIt<Signaling>().joinRoom(roomId!);
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context, roomId);
                    },
                    text: "Join")
              ],
            ),
            // actions: [

            //   TextButton(
            //     onPressed: () async {
            //       await getIt<Signaling>().joinRoom(roomId!);
            //       Navigator.pop(context, roomId);
            //     },
            //     child: const Text("Join"),
            //   ),
            // ],
          ));
}
