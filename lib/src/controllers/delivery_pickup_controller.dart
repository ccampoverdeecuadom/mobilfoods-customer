import 'package:customer/src/repository/order_repository.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../helpers/helper.dart';
import '../models/address.dart';
import '../repository/market_repository.dart';
import '../repository/settings_repository.dart';

import '../../generated/l10n.dart';
import '../models/address.dart' as model;
import '../models/payment_method.dart';
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import '../repository/cart_repository.dart' as cartRepo;
import 'cart_controller.dart';

class DeliveryPickupController extends CartController {
  GlobalKey<ScaffoldState> scaffoldKey;
  model.Address deliveryAddress;
  PaymentMethodList list;

  DeliveryPickupController(bool _hasDeliveryFee) : super(_hasDeliveryFee) {
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    super.listenForCarts();
    listenForDeliveryAddress();
    //print(settingRepo.deliveryAddress.value.toMap());
  }

  void listenForDeliveryAddress() async {
    this.deliveryAddress = settingRepo.deliveryAddress.value;
    getDeliveryFeeByAddress(this.deliveryAddress);
  }

  void addAddress(model.Address address) async {
    userRepo.addAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        this.deliveryAddress = value;
        getDeliveryFeeByAddress(this.deliveryAddress);
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).new_address_added_successfully),
      ));
    });
  }

  void updateAddress(model.Address address) {
    userRepo.updateAddress(address).then((value) {
      setState(() {
        settingRepo.deliveryAddress.value = value;
        this.deliveryAddress = value;
        getDeliveryFeeByAddress(this.deliveryAddress);
      });
    }).whenComplete(() {
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).the_address_updated_successfully),
      ));
    });
  }

  PaymentMethod getPickUpMethod() {
    return list.pickupList.elementAt(0);
  }

  PaymentMethod getDeliveryMethod() {
    return list.pickupList.elementAt(1);
  }

  void toggleDelivery() {
    list.pickupList.forEach((element) {
      if (element != getDeliveryMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getDeliveryMethod().selected = !getDeliveryMethod().selected;
    });
  }

  void togglePickUp() {
    list.pickupList.forEach((element) {
      if (element != getPickUpMethod()) {
        element.selected = false;
      }
    });
    setState(() {
      getPickUpMethod().selected = !getPickUpMethod().selected;
    });
  }

  PaymentMethod getSelectedMethod() {
    bool isMethodSelected = isSelectedMethod();
    if (!isMethodSelected) {
      Fluttertoast.showToast(
        msg: "Selecciona un método de Pago",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
      );
      return null;
    }
      PaymentMethod paymentMethodSelected = list.pickupList.firstWhere((element) => element.selected);
      return paymentMethodSelected;
  }

  bool isSelectedMethod(){
    bool isMethodSelected = false;
    list.pickupList.forEach((element) {
      if(element.selected) isMethodSelected = true;
    });
    return isMethodSelected;
  }

  @override
  void goCheckout(BuildContext context) {
    Navigator.of(context).pushNamed(getSelectedMethod().route);
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      settingRepo.deliveryAddress.value = _address;
      await refreshDeliveryPickup();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> refreshDeliveryPickup() async {
    setState(() {
      this.deliveryAddress = settingRepo.deliveryAddress.value;
      getDeliveryFeeByAddress(this.deliveryAddress);
    });
    listenForCarts();
    listenForDeliveryAddress();
  }

  Future<double> getDeliveryFeeByAddress(Address _address) async {

    if (_address != null) if (!_address.isLatLnUnknown())
      cartRepo.getDeliveryFee(_address, currentMarketId).then((value) =>
        setState(() {
          this.deliveryFee = value.price;
          settingRepo.calculate = value;
        })
      );
    else
      setState(() {
        this.deliveryFee = 0;
      });
    else
      setState(() {
        this.deliveryFee = 0;
      });
  }

  updateReferencesDeliveryAddress(String references) {
    settingRepo.referencesDeliveryAddress = references;
    print(settingRepo.referencesDeliveryAddress);
  }
}
