import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _localVideoRenderer = RTCVideoRenderer();
  final _remoteVideoRenderer = RTCVideoRenderer();

  final sdpController = TextEditingController();
  bool _offer = false;

  late RTCPeerConnection _peerConnection;
  late final MediaStream _localStream;

  void initRenderers() async {
    await _localVideoRenderer.initialize();
  }

  _getUserMedia() async {
    final Map<String, dynamic> mediaConstraints = {
      'audio': true,
      'video': {
        'facingMode': 'user',
      }
    };

    MediaStream stream =
        await navigator.mediaDevices.getUserMedia(mediaConstraints);
    _localVideoRenderer.srcObject = stream;
    return stream;
  }

// ICE free Servers
  Map<String, dynamic> configuration = {
    "iceServers": [
      {"url": "stun:stun.l.google.com:19302"},
    ]
  };

  _createPeerConnecion() async {
//  SDP Constraints with the mandatory offer to receive audio/video set to true
    final Map<String, dynamic> offerSdpConstraints = {
      "mandatory": {
        "OfferToReceiveAudio": true,
        "OfferToReceiveVideo": true,
      },
      "optional": [],
    };
    _localStream = _getUserMedia();

    RTCPeerConnection pc =
        await createPeerConnection(configuration, offerSdpConstraints);
    pc.addStream(_localStream);

    pc.onIceCandidate = (e) {
      if (e.candidate != null) {
        print(json.encode({
          'candidate': e.candidate,
          'sdpMid': e.sdpMid,
          'sdpMlineIndex': e.sdpMLineIndex
        }));
      }
    };
    pc.onIceConnectionState = (e) {
      print(e);
    };

    pc.onAddStream = (stream) {
      print('addStream: ' + stream.id);
      _remoteVideoRenderer.srcObject = stream;
    };

    return pc;
  }

  void _createOffer() async {
    RTCSessionDescription description =
        await _peerConnection.createOffer({'offerToReceiveVideo': 1});
    var session = description.sdp.toString();
    print(json.encode(session));
    _offer = true;

    _peerConnection.setLocalDescription(description);
  }

  void _createAnswer() async {
    RTCSessionDescription description =
        await _peerConnection.createAnswer({'offerToReceiveVideo': 1});

    var session = description.sdp.toString();
    print(json.encode(session));

    _peerConnection.setLocalDescription(description);
  }

  void _setRemoteDescription() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');

    String sdp = session.toString();

    RTCSessionDescription description =
        RTCSessionDescription(sdp, _offer ? 'answer' : 'offer');
    print(description.toMap());

    await _peerConnection.setRemoteDescription(description);
  }

  void _addCandidate() async {
    String jsonString = sdpController.text;
    dynamic session = await jsonDecode('$jsonString');
    print(session['candidate']);
    dynamic candidate = RTCIceCandidate(
        session['candidate'], session['sdpMid'], session['sdpMlineIndex']);
    await _peerConnection.addCandidate(candidate);
  }

  @override
  void initState() {
    initRenderers();
    _createPeerConnecion().then((pc) {
      _peerConnection = pc;
    });
    // _getUserMedia();
    super.initState();
  }

  @override
  void dispose() async {
    await _localVideoRenderer.dispose();
    await _remoteVideoRenderer.dispose();
    sdpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Video Call with webrtc"),
        ),
        body: Column(
          children: [
            videoRenderers(),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: TextField(
                      controller: sdpController,
                      keyboardType: TextInputType.multiline,
                      maxLines: 4,
                      maxLength: TextField.noMaxLength,
                    ),
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _createOffer,
                      child: const Text("Offer"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _createAnswer,
                      child: const Text("Answer"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _setRemoteDescription,
                      child: const Text("Set Remote Description"),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ElevatedButton(
                      onPressed: _addCandidate,
                      child: const Text("Set Candidate"),
                    ),
                  ],
                )
              ],
            ),
          ],
        ));
  }

  SizedBox videoRenderers() => SizedBox(
        height: 210,
        child: Row(children: [
          Flexible(
            child: Container(
              key: Key('local'),
              margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: BoxDecoration(color: Colors.black),
              child: RTCVideoView(_localVideoRenderer),
            ),
          ),
          Flexible(
            child: Container(
              key: Key('remote'),
              margin: EdgeInsets.fromLTRB(5.0, 5.0, 5.0, 5.0),
              decoration: BoxDecoration(color: Colors.black),
              child: RTCVideoView(_remoteVideoRenderer),
            ),
          ),
        ]),
      );
}
