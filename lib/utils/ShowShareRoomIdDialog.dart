import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';
import 'CustomBtn.dart';
import 'createToastMsg.dart';

void showShareRoomIdDailog(BuildContext context, String roomId) async {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      title: const Text('Share this Room Id with your friends'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'This room ID can be used anyone to join you in you call, make sure you friend have this app install or you can also  login in using the website. Just enter the Room ID and Press Join Call',
          ),
          const SizedBox(
            height: 10,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: const BoxDecoration(color: Color(0xFFF6F1E9)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(roomId, overflow: TextOverflow.ellipsis),
                IconButton(
                    padding: EdgeInsets.zero,
                    splashRadius: 1,
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: roomId));
                      await createToastMsg("Room ID Copy to Clipboard");
                    },
                    icon: const Icon(Iconsax.copy))
              ],
            ),
          ),
          const SizedBox(
            height: 30,
          ),
          CustomBtn(
            onPress: () async {
              Share.share(roomId);
            },
            text: "Share",
          )
        ],
      ),
      // actions: [
      //   TextButton(
      //     onPressed: () {},
      //     child: Text("Share"),
      //   ),
      // ],
    ),
  );
}
