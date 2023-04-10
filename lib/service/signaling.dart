import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:video_call_webrtc/utils/createToastMsg.dart';

typedef StreamStateCallback = void Function(MediaStream stream);

class Signaling {
  Map<String, dynamic> configuration = {
    "sdpSemantics": "plan-b",
    'iceServers': [
      {
        'urls': [
          'stun:stun1.l.google.com:19302',
          'stun:stun2.l.google.com:19302'
        ]
      }
    ]
  };

  RTCVideoRenderer? localRenderer;
  RTCVideoRenderer? remoteRenderer;

  // RTCPeerConnection? peerConnection;
  List<RTCPeerConnection?> peerConnectionList = [];
  // List<RTCPeerConnection?> peerConnectionList = [];
  MediaStream? localStream;
  MediaStream? remoteStream;
  String? roomId;
  String? currentRoomText;
  StreamStateCallback? onAddRemoteStream;

  VoidCallback? onLeaveRemoteStream;

  intialize() async {
    localRenderer = RTCVideoRenderer();
    remoteRenderer = RTCVideoRenderer();
    await localRenderer!.initialize();
    await remoteRenderer!.initialize();
    await openUserMedia(localRenderer!, remoteRenderer!);
  }

  dispose() async {
    await localRenderer!.dispose();
    await remoteRenderer!.dispose();
    // await peerConnection!.dispose();
    await localStream!.dispose();
    if (remoteStream != null) {
      await remoteStream!.dispose();
    }
  }

  Future<String> createRoom() async {
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc();

    print('Create PeerConnection with configuration: $configuration');

    // peerConnection = await createPeerConnection(configuration);
    await newPeerConnection(roomRef);

    // registerPeerConnectionListeners();

    // localStream?.getTracks().forEach((track) {
    //   peerConnection?.addTrack(track, localStream!);
    // });

    // Code for collecting ICE candidates below

    // var callerCandidatesCollection = roomRef.collection('callerCandidates');
    // peerConnection?.onIceCandidate = (RTCIceCandidate candidate) {
    //   print('Got candidate: ${candidate.toMap()}');
    //   callerCandidatesCollection.add(candidate.toMap());
    // };

    // Finish Code for collecting ICE candidate

    // Add code for creating a room

    // RTCSessionDescription offer = await peerConnection!.createOffer();
    // await peerConnection!.setLocalDescription(offer);
    // print('Created offer: $offer');

    // Map<String, dynamic> roomWithOffer = {'offer': offer.toMap()};

    // await roomRef.set(roomWithOffer);

    roomId = roomRef.id;
    print('New room created with SDK offer. Room ID: $roomId');
    currentRoomText = 'Current room is $roomId - You are the caller!';
    // Created a Room

    // peerConnection?.onTrack = (RTCTrackEvent event) {
    //   print('Got remote track: ${event.streams[0]}');

    //   event.streams[0].getTracks().forEach((track) {
    //     print('Add a track to the remoteStream $track');
    //     remoteStream?.addTrack(track);
    //   });
    // };

    // Listening for remote session description below
    roomRef.snapshots().listen((snapshot) async {
      print('Got updated room: ${snapshot.data()}');

      Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
      if (data != null && data['answer'] != null) {
        var answer = RTCSessionDescription(
          data['answer']['sdp'],
          data['answer']['type'],
        );

        print("Someone tried to connect");
        await peerConnectionList.last!.setRemoteDescription(answer);
        await newPeerConnection(roomRef);
      }
      if (data != null && data['call_status'] == "ended") {
        onLeaveRemoteStream!.call();
      }
    });
    // Listening for remote session description above

    // Listen for remote Ice candidates below
    roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
      snapshot.docChanges.forEach((change) {
        if (change.type == DocumentChangeType.added) {
          Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
          print('Got new remote ICE candidate: ${jsonEncode(data)}');
          peerConnectionList.last!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        }
      });
    });

    // Listen for remote ICE candidates above

    return roomId!;
  }

  // listnerToRoomForAnswer(String roomId) async {
  //   FirebaseFirestore db = FirebaseFirestore.instance;
  //   DocumentReference roomRef = db.doc("rooms/$roomId");
  //   roomRef.snapshots().listen((snapshot) async {
  //     print('Got updated room: ${snapshot.data()}');

  //     Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
  //     print("data type : ${data['answer']['type']}");
  //     if (peerConnectionList.last?.getRemoteDescription() != null &&
  //         data['answer'] != null) {
  //       var answer = RTCSessionDescription(
  //         data['answer']['sdp'],
  //         data['answer']['type'],
  //       );

  //       print("Someone tried to connect");
  //       await peerConnectionList.last!.setRemoteDescription(answer);
  //     }
  //   });
  //   // Listening for remote session description above

  //   // Listen for remote Ice candidates below
  //   roomRef.collection('calleeCandidates').snapshots().listen((snapshot) {
  //     snapshot.docChanges.forEach((change) {
  //       if (change.type == DocumentChangeType.added) {
  //         Map<String, dynamic> data = change.doc.data() as Map<String, dynamic>;
  //         print('Got new remote ICE candidate: ${jsonEncode(data)}');
  //         peerConnectionList.last!.addCandidate(
  //           RTCIceCandidate(
  //             data['candidate'],
  //             data['sdpMid'],
  //             data['sdpMLineIndex'],
  //           ),
  //         );
  //       }
  //     });
  //   });
  //   // Listen for remote ICE candidates above
  // }

  Future<void> joinRoom(String eRoomId) async {
    roomId = eRoomId;
    FirebaseFirestore db = FirebaseFirestore.instance;
    DocumentReference roomRef = db.collection('rooms').doc(roomId);
    var roomSnapshot = await roomRef.get();

    print('Got room ${roomSnapshot.exists}');

    if (roomSnapshot.exists) {
      print('Create PeerConnection with configuration: $configuration');
      final peerConnection = await createPeerConnection(configuration);

      registerPeerConnectionListeners(peerConnection);

      localStream?.getTracks().forEach((track) {
        peerConnection?.addTrack(track, localStream!);
      });

      // Code for collecting ICE candidates below
      var calleeCandidatesCollection = roomRef.collection('calleeCandidates');
      peerConnection!.onIceCandidate = (RTCIceCandidate candidate) {
        if (candidate == null) {
          print('onIceCandidate: complete!');
          return;
        }
        print('onIceCandidate: ${candidate.toMap()}');
        calleeCandidatesCollection.add(candidate.toMap());
      };
      // Code for collecting ICE candidate above

      peerConnection?.onTrack = (RTCTrackEvent event) {
        print('Got remote track: ${event.streams[0]}');
        event.streams[0].getTracks().forEach((track) {
          print('Add a track to the remoteStream: $track');
          remoteStream?.addTrack(track);
        });
      };

      // Code for creating SDP answer below
      var data = roomSnapshot.data() as Map<String, dynamic>;
      print('Got offer $data');
      var offer = data['offer'];
      await peerConnection?.setRemoteDescription(
        RTCSessionDescription(offer['sdp'], offer['type']),
      );
      var answer = await peerConnection!.createAnswer();
      print('Created Answer $answer');

      await peerConnection!.setLocalDescription(answer);

      Map<String, dynamic> roomWithAnswer = {
        'answer': {'type': answer.type, 'sdp': answer.sdp},
        'call_status': "started",
      };

      await roomRef.update(roomWithAnswer);
      // Finished creating SDP answer

      // Listening for remote ICE candidates below
      roomRef.collection('callerCandidates').snapshots().listen((snapshot) {
        snapshot.docChanges.forEach((document) {
          var data = document.doc.data() as Map<String, dynamic>;
          print(data);
          print('Got new remote ICE candidate: $data');
          peerConnection!.addCandidate(
            RTCIceCandidate(
              data['candidate'],
              data['sdpMid'],
              data['sdpMLineIndex'],
            ),
          );
        });
      });

      roomRef.snapshots().listen((snapshot) {
        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        if (data != null && data['call_status'] == "ended") {
          onLeaveRemoteStream!.call();
        }
      });
    }
  }

  Future<RTCPeerConnection> newPeerConnection(DocumentReference roomRef) async {
    final peerConnection = await createPeerConnection(
      configuration,
    );

    registerPeerConnectionListeners(peerConnection);

    localStream?.getTracks().forEach((track) {
      peerConnection.addTrack(track, localStream!);
    });
    var callerCandidatesCollection = roomRef.collection('callerCandidates');

    peerConnection.onIceCandidate = (RTCIceCandidate candidate) {
      print('Got candidate: ${candidate.toMap()}');
      callerCandidatesCollection.add(candidate.toMap());
    };

    peerConnection.onTrack = (RTCTrackEvent event) {
      print('Got remote track: ${event.streams[0]}');

      event.streams[0].getTracks().forEach((track) {
        print('Add a track to the remoteStream $track');
        remoteStream?.addTrack(track);
      });
    };
    final offer = await peerConnection.createOffer();
    await peerConnection.setLocalDescription(offer);

    final roomWithOffer = <String, dynamic>{
      'offer': offer.toMap(),
      "call_status": "started"
    };
    await roomRef.set(roomWithOffer);

    peerConnectionList.add(peerConnection);
    return peerConnection;
  }

  Future<void> openUserMedia(
    RTCVideoRenderer localVideo,
    RTCVideoRenderer remoteVideo,
  ) async {
    var stream = await navigator.mediaDevices
        .getUserMedia({'video': true, 'audio': true});

    localVideo.srcObject = stream;
    localStream = stream;

    remoteVideo.srcObject = await createLocalMediaStream('key');
  }

  Future<void> hangUp() async {
    // For DEMO
    List<MediaStreamTrack> tracks = localRenderer!.srcObject!.getTracks();
    for (var track in tracks) {
      track.stop();
    }

    if (remoteStream != null) {
      remoteStream!.getTracks().forEach((track) => track.stop());
    }
    // if (peerConnection != null) peerConnection!.close();

    print("************ roomid : $roomId");
    if (roomId != null) {
      var db = FirebaseFirestore.instance;
      var roomRef = db.collection('rooms').doc(roomId);
      roomRef.update({
        "call_status": "ended",
      });
      // var calleeCandidates = await roomRef.collection('calleeCandidates').get();
      // calleeCandidates.docs.forEach((document) => document.reference.delete());

      // var callerCandidates = await roomRef.collection('callerCandidates').get();
      // callerCandidates.docs.forEach((document) => document.reference.delete());

      // await roomRef.delete();
    }

    // localStream!.dispose();
    // remoteStream?.dispose();
  }

// play / pause Audio Track
  bool muteMic() {
    if (localStream != null) {
      bool enabled = localStream!.getAudioTracks()[0].enabled;
      localStream!.getAudioTracks()[0].enabled = !enabled;
      return localStream!.getAudioTracks()[0].enabled;
    }
    createToastMsg("No Media to Mute");
    return true;
  }

// play pause Video track
  bool stopVideo() {
    if (localStream != null) {
      bool enabled = localStream!.getVideoTracks()[0].enabled;
      localStream!.getVideoTracks()[0].enabled = !enabled;
      return localStream!.getVideoTracks()[0].enabled;
    }
    createToastMsg("Local Media is not Define");
    return true;
  }

  void registerPeerConnectionListeners(RTCPeerConnection? peerConnection) {
    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE gathering state changed: $state');
    };

    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print('Connection state change: $state');
    };

    peerConnection?.onSignalingState = (RTCSignalingState state) {
      print('Signaling state change: $state');
    };

    peerConnection?.onIceGatheringState = (RTCIceGatheringState state) {
      print('ICE connection state change: $state');
    };

    peerConnection?.onAddStream = (MediaStream stream) {
      print("Add remote stream : ${stream.id}");
      onAddRemoteStream?.call(stream);
      remoteStream = stream;
    };

    peerConnection?.onRemoveStream = (MediaStream stream) {
      print("remove Stream : ${stream.id}");
      if (remoteStream != null) onLeaveRemoteStream?.call();
      // remoteStream = null;
    };

    peerConnection?.onSignalingState = (state) {
      print("Signaling state : ${state.toString()}");
    };
    peerConnection?.onConnectionState = (RTCPeerConnectionState state) {
      print("Connect state : ${state.toString()}");
      if (state == RTCPeerConnectionState.RTCPeerConnectionStateDisconnected ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateFailed ||
          state == RTCPeerConnectionState.RTCPeerConnectionStateClosed) {
        if (remoteStream != null && remoteRenderer != null) {
          onLeaveRemoteStream?.call();
        }
      }
    };
    // peerConnection?.on;
  }
}
