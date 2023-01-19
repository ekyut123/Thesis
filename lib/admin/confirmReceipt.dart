import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_users/admin/messages.dart';
import 'package:intl/intl.dart';

// ignore: must_be_immutable
class ConfirmReceipt extends StatelessWidget {
  ConfirmReceipt(
      {super.key,
      required this.filepath,
      required this.businessname,
      required this.userUid});
  String filepath;
  final String businessname;
  String userUid;

  int dv = 0;
  //day
  String dy = "";
  int intdy = 0;
  //month
  String month = "";
  String nummonth = "";
  int intmonth = 0;
  //year
  String yr = "";
  //get date
  String date = "";
  UploadTask? uploadTask;
  Future uploadFile() async {
    dv = 0;
    //day
    dy = DateFormat.d().format(DateTime.now());
    intdy = int.tryParse(dy) ?? dv;
    //month
    month = DateFormat.MMM().format(DateTime.now());
    //year
    yr = DateFormat.y().format(DateTime.now());
    date = '$yr, $intdy $month';
    final path = '$businessname/Receipts/$intdy $month, $yr';
    final file = File(filepath);
    final ref = FirebaseStorage.instance.ref().child(path);
    uploadTask = ref.putFile(file);
    final snapshot = await uploadTask!.whenComplete(() {});

    final urlDownload = await snapshot.ref.getDownloadURL();
    await saveUrl(urlDownload, date);
  }

  Future saveUrl(String urlDownload, String date) async {
    User? user = FirebaseAuth.instance.currentUser;
    final businessid = user!.uid;
    final docReceipt = FirebaseFirestore.instance
        .collection('BusinessList')
        .doc(userUid)
        .collection('Receipt')
        .doc();
    final json = {
      'date': date,
      'receipt': urlDownload,
      'confirmed': false,
      'id': docReceipt.id,
      'businessid': businessid
    };
    await docReceipt.set(json);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 30, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .popAndPushNamed('/paymenthistory');
                        },
                        child: const Text(
                          "Cancel",
                          style: TextStyle(color: Colors.grey),
                        )),
                    TextButton(
                        onPressed: () {
                          uploadFile();
                        },
                        child: const Text("Send",
                            style: TextStyle(color: Colors.green)))
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                child: Image.file(
                  File(filepath),
                  height: MediaQuery.of(context).size.height * 0.7,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
