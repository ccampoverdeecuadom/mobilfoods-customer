import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/src/models/address.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../generated/l10n.dart';
import '../helpers/helper.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../repository/order_repository.dart';
import '../repository/user_repository.dart';
import '../repository/user_repository.dart' as userRepo;

class TrackingController extends ControllerMVC {
  Order order;
  List<OrderStatus> orderStatus = <OrderStatus>[];
  GlobalKey<ScaffoldState> scaffoldKey;
  SharedPreferences prefs;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;


  TrackingController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  void listenForOrder({String orderId, String message}) async {
    final Stream<Order> stream = await getOrder(orderId);
    stream.listen((Order _order) {
      setState(() {
        order = _order;
      });
    }, onError: (a) {
      //print(a);
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).verify_your_internet_connection),
      ));
    }, onDone: () {
      listenForOrderStatus();
      if (message != null) {
        scaffoldKey?.currentState?.showSnackBar(SnackBar(
          content: Text(message),
        ));
      }
    });
  }

  // method to create user on firestore when there is a active order
  void createUser() async {
    //final QuerySnapshot result =
    //await FirebaseFirestore.instance.collection('users').where('id', isEqualTo: firebaseUser.uid).get();

    // creamos el usuario en la base
    //userRepo.getCurrentUser();
    //FirebaseFirestore fireStore = FirebaseFirestore.instance;
    //fireStore.collection('locations').doc(currentUser.value.id).set({

    fireStore.collection('users').doc(userRepo.currentUser.value.id).set({
      'name': userRepo.currentUser.value.name,
      'id': userRepo.currentUser.value.id,
      'createdAt': DateTime.now().millisecondsSinceEpoch.toString(),
      'chattingWith': null
    }).catchError((onError) {
      print("ERROR ....");
      print(onError);
    });

    await prefs.setString('id', userRepo.currentUser.value.id);
    await prefs.setString('nickname', userRepo.currentUser.value.name);


  }

  void listenForOrderStatus() async {
    final Stream<OrderStatus> stream = await getOrderStatus();
    stream.listen((OrderStatus _orderStatus) {
      setState(() {
        orderStatus.add(_orderStatus);
      });
    }, onError: (a) {}, onDone: () {});
  }

  List<Step> getTrackingSteps(BuildContext context) {
    List<Step> _orderStatusSteps = [];
    this.orderStatus.forEach((OrderStatus _orderStatus) {
      _orderStatusSteps.add(Step(
        state: StepState.complete,
        title: Text(
          _orderStatus.status,
          style: Theme.of(context).textTheme.subtitle1,
        ),
        subtitle: order.orderStatus.id == _orderStatus.id
            ? Text(
                '${DateFormat('HH:mm | yyyy-MM-dd').format(order.dateTime)}',
                style: Theme.of(context).textTheme.caption,
                overflow: TextOverflow.ellipsis,
              )
            : SizedBox(height: 0),
        content: SizedBox(
            width: double.infinity,
            child: Text(
              '${Helper.skipHtml(order.hint)}',
            )),
        isActive: (int.tryParse(order.orderStatus.id)) >= (int.tryParse(_orderStatus.id)),
      ));
    });
    return _orderStatusSteps;
  }

  Future<void> refreshOrder() async {
    order = new Order();
    listenForOrder(message: S.of(context).tracking_refreshed_successfuly);
  }

  void doCancelOrder() {
    cancelOrder(this.order).then((value) {
      setState(() {
        this.order.active = false;
      });
    }).catchError((e) {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(e),
      ));
    }).whenComplete(() {
      orderStatus = [];
      listenForOrderStatus();
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).orderThisorderidHasBeenCanceled(this.order.id)),
      ));
    });
  }

  bool canCancelOrder(Order order) {
    return order.active == true && order.orderStatus.id == 1;
  }

}
