
import 'package:customer/src/models/order.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../repository/order_repository.dart' as orderRepo;


class InvoiceDataController extends ControllerMVC {
  GlobalKey<ScaffoldState> scaffoldKey;

  InvoiceDataController() {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
  }

  updateOrderWithInvoiceData(Order order) {
    orderRepo.updateOrder(order);
  }

}