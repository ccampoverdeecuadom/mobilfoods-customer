import 'package:flutter/material.dart';

import '../../generated/l10n.dart';
import '../models/cart.dart';
import '../models/coupon.dart';
import '../models/credit_card.dart';
import '../models/order.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../repository/order_repository.dart' as orderRepo;
import '../repository/settings_repository.dart' as settingRepo;
import '../repository/user_repository.dart' as userRepo;
import 'cart_controller.dart';

class CheckoutController extends CartController {
  Payment payment;
  CreditCard creditCard = new CreditCard();
  bool loading = true;
  Order orderAdded;


  CheckoutController() : super(false){
    this.scaffoldKey = new GlobalKey<ScaffoldState>();
    listenForCreditCard();
  }

  void listenForCreditCard() async {
    creditCard = await userRepo.getCreditCard();
    setState(() {});
  }

  @override
  void onLoadingCartDone() {
    if (payment != null) addOrder(carts);
    super.onLoadingCartDone();
  }

  void addOrder(List<Cart> carts) async {
    Order _order = new Order();
    _order.productOrders = new List<ProductOrder>();
    _order.tax = carts[0].product.market.defaultTax;
    _order.deliveryFee = payment.method == 'Pay on Pickup' ? 0 : settingRepo.calculate.price;
    OrderStatus _orderStatus = new OrderStatus();
    _orderStatus.id = '1'; // TODO default order status Id
    _order.orderStatus = _orderStatus;
    _order.deliveryAddress = settingRepo.deliveryAddress.value;
    _order.hint = ' ';
    _order.referencesDeliveryAddress = settingRepo.referencesDeliveryAddress;
    carts.forEach((_cart) {
      ProductOrder _productOrder = new ProductOrder();
      _productOrder.quantity = _cart.quantity;
      _productOrder.price = _cart.product.price;
      _productOrder.product = _cart.product;
      _productOrder.options = _cart.options;
      _order.productOrders.add(_productOrder);
    });
    orderRepo.addOrder(_order, this.payment).then((value) async {
      settingRepo.coupon = new Coupon.fromJSON({});
      return value;
    }).then((value) {
      if (value is Order) {
        setState(() {
          loading = false;
          orderAdded = value;
        });
      }
    });
  }

  void updateCreditCard(CreditCard creditCard) {
    userRepo.setCreditCard(creditCard).then((value) {
      setState(() {});
      scaffoldKey?.currentState?.showSnackBar(SnackBar(
        content: Text(S.of(context).payment_card_updated_successfully),
      ));
    });
  }
}
