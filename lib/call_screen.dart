import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:video_call_webrtc/utils/createToastMsg.dart';
import 'constant.dart';
import 'get_it.dart';
import 'utils/ShowShareRoomIdDialog.dart';
import 'utils/circularBtn.dart';
import 'utils/showEnterRoomIdDialog.dart';
import 'service/signaling.dart';

class CallScreen extends StatefulWidget {
  const CallScreen({super.key, this.roomId});
  final String? roomId;
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  late final Signaling signaling;
  // late final RTCVideoRenderer _localRenderer;
  // late final RTCVideoRenderer _remoteRenderer;

  // String? roomId;
  TextEditingController textEditingController = TextEditingController(text: '');

  bool someOneJoin = false;
  bool isVideoOn = true;
  bool isAudioOn = true;
  // Future<void> initRender() async {
  //   _localRenderer = RTCVideoRenderer();
  //   _remoteRenderer = RTCVideoRenderer();
  //   await _localRenderer.initialize();
  //   await _remoteRenderer.initialize();
  // }

  @override
  void initState() {
    super.initState();
    signaling = getIt<Signaling>();
    // signaling.intialize();

    // initRender().then((value) {

    // signaling
    //     .openUserMedia(_localRenderer, _remoteRenderer)
    //     .then((value) => setState(() {}));
    // });
    signaling.onAddRemoteStream = ((stream) {
      // print("Neww Conecton")
      signaling.remoteRenderer!.srcObject = stream;
      someoneJoinTheRoom();
      // setState(() {});
    });
    signaling.onLeaveRemoteStream = (() {
      signaling.remoteRenderer!.srcObject = null;

      someoneLeaveTheRoom();
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (widget.roomId != null) {
        showShareRoomIdDailog(context, widget.roomId!);
      } else {
        showEnterRoomIdDialog(
          context,
        );
      }
    });
  }

  @override
  void dispose() {
    // _localRenderer.dispose();
    // _remoteRenderer.dispose();
    signaling.dispose();
    super.dispose();
  }

  someoneJoinTheRoom() {
    someOneJoin = true;
    createToastMsg("Your friend has join the call 💪");
    setState(() {});
  }

  someoneLeaveTheRoom() {
    someOneJoin = false;
    createToastMsg("Your friend leave the call 🔴");
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: bgColor,
      body: SingleChildScrollView(
        child: Stack(children: [
          SizedBox(
            width: size.width,
            height: size.height,
          ),

          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            decoration: const BoxDecoration(
                // color: Colors.white,
                ),
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                child: RTCVideoView(
                  signaling.remoteRenderer!,
                  objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitContain,
                  mirror: true,
                  filterQuality: FilterQuality.none,
                ),
              ),
            ),
          ),

          // Local Video
          // AnimatedPositioned(
          //   duration: const Duration(milliseconds: 700),
          //   top: someOneJoin ? MediaQuery.of(context).viewPadding.top + 10 : 0,
          //   bottom: someOneJoin ? size.height * 0.68 : 0,
          //   left: someOneJoin ? 10 : 0,
          //   // right: 0,
          //   child:
          AnimatedContainer(
            duration: const Duration(milliseconds: 700),
            height: someOneJoin ? 250 : size.height,
            // width: someOneJoin ? 300 : double.infinity,
            margin: someOneJoin
                ? EdgeInsets.only(
                    top: MediaQuery.of(context).viewPadding.top + 10,
                    right: 10,
                  )
                : EdgeInsets.zero,
            alignment: Alignment.topRight,
            decoration: const BoxDecoration(
                // boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 20)],
                ),
            child: AspectRatio(
              aspectRatio: 9 / 16,
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(someOneJoin ? 20 : 0),
                  topRight: Radius.circular(someOneJoin ? 20 : 0),
                  bottomLeft: Radius.circular(someOneJoin ? 20 : 30),
                  bottomRight: Radius.circular(someOneJoin ? 20 : 30),
                ),
                child: SizedBox(
                  child: RTCVideoView(
                    signaling.localRenderer!,
                    // objectFit: RTCVideoViewObjectFit.RTCVideoViewObjectFitCover,
                    filterQuality: FilterQuality.none,
                    // placeholderBuilder: (context) => Container(
                    //   padding: const EdgeInsets.all(20),
                    //   decoration: const BoxDecoration(
                    //     color: Colors.white,
                    //     shape: BoxShape.circle,
                    //   ),
                    //   child: const Icon(Iconsax.profile),
                    // ),
                    mirror: true,
                  ),
                ),
              ),
            ),
          ),
          // ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    colors: [
                      bgColor,
                      bgColor.withOpacity(0.5),
                      Colors.transparent
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    stops: const [0.2, 0.6, 0.9]),
                // color: Colors.white,
                // borderRadius: BorderRadius.only(
                //   topLeft: Radius.circular(20),
                //   topRight: Radius.circular(20),
                // ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      CircularBtn(
                        color: secondaryColor,
                        icon: Icon(
                          isAudioOn
                              ? Iconsax.microphone
                              : Iconsax.microphone_slash,
                          color: Colors.white,
                        ),
                        onPress: () {
                          isAudioOn = getIt<Signaling>().muteMic();
                          setState(() {});
                        },
                      ),
                      CircularBtn(
                        color: const Color(0xFF181c22),
                        icon: Icon(
                          isVideoOn ? Iconsax.video : Iconsax.video_slash,
                          color: Colors.white,
                        ),
                        onPress: () {
                          isVideoOn = getIt<Signaling>().stopVideo();
                          setState(() {});
                        },
                      ),
                      CircularBtn(
                        color: const Color(0xFFfc4438),
                        icon: const Icon(
                          Icons.call_end,
                          color: Colors.white,
                        ),
                        onPress: () async {
                          print("HangUP press ****************");
                          await getIt<Signaling>().hangUp();
                          Navigator.pop(context);
                        },
                      ),
                      CircularBtn(
                        color: const Color(0xFF181c22),
                        icon: const Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                        ),
                        onPress: () {
                          if (widget.roomId != null) {
                            showShareRoomIdDailog(context, widget.roomId!);
                          } else {
                            showEnterRoomIdDialog(
                              context,
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ]),
      ),
    );
  }
}
