import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

createToastMsg(String msg) async {
  await Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: Colors.red,
    textColor: Colors.white,
    fontSize: 16.0,
  );
}
