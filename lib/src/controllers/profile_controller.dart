import 'dart:convert';
import 'dart:io';

import 'package:customer/src/models/user.dart';
import 'package:customer/src/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../models/order.dart';
import '../repository/order_repository.dart';

class ProfileController extends ControllerMVC {
  List<Order> recentOrders = [];
  GlobalKey<ScaffoldState> scaffoldKey;
  String imageUri;
  bool isUploadingImage;

  ProfileController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForRecentOrders();
  }

  void listenForRecentOrders({String message}) async {
    final Stream<Order> stream = await getRecentOrders();
    stream.listen((Order _order) {
      setState(() {
        recentOrders.add(_order);
      });
    }, onError: (a) {
      //print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  Future<void> refreshProfile() async {
    recentOrders.clear();
    listenForRecentOrders(message: S.of(context).orders_refreshed_successfuly);
  }

  updateProfileImage(File image) async{
    String uuid = await uploadImage(image);
    if(uuid == null) {
    setState(() => isUploadingImage = false);
      return;
    }
    currentUser.value.avatar = uuid;
    update(currentUser.value).then((value) =>
        setState(() => {
          imageUri = value.image.url,
          isUploadingImage = false
        })
    );
  }
}
