import '../models/address.dart';
import '../models/order_status.dart';
import '../models/payment.dart';
import '../models/product_order.dart';
import '../models/user.dart';
import '../repository/settings_repository.dart' as settingRepo;


class Order {
  String id;
  List<ProductOrder> productOrders;
  OrderStatus orderStatus;
  int orderStatusId;
  double tax;
  double deliveryFee;
  String hint;
  bool active;
  DateTime dateTime;
  User user;
  Payment payment;
  Address deliveryAddress;
  String identification;
  String nameInvoice;
  String phoneInvoice;
  String emailInvoice;
  String addressInvoice;
  String referencesDeliveryAddress;
  int driver_id;
  User driver;

  Order();

  Order.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      id = jsonMap['id'].toString();
      tax = jsonMap['tax'] != null ? jsonMap['tax'].toDouble() : 0.0;
      deliveryFee = jsonMap['delivery_fee'] != null ? jsonMap['delivery_fee'].toDouble() : 0.0;
      hint = jsonMap['hint'] != null ? jsonMap['hint'].toString() : '';
      orderStatusId = jsonMap['order_status_id'] != null ? jsonMap['order_status_id'] : 1;
      active = jsonMap['active'] ?? false;
      orderStatus = jsonMap['order_status'] != null ? OrderStatus.fromJSON(jsonMap['order_status']) : OrderStatus.fromJSON({});
      dateTime = DateTime.parse(jsonMap['updated_at']);
      user = jsonMap['user'] != null ? User.fromJSON(jsonMap['user']) : User.fromJSON({});
      deliveryAddress = jsonMap['delivery_address'] != null ? Address.fromJSON(jsonMap['delivery_address']) : Address.fromJSON({});
      payment = jsonMap['payment'] != null ? Payment.fromJSON(jsonMap['payment']) : Payment.fromJSON({});
      productOrders = jsonMap['product_orders'] != null ? List.from(jsonMap['product_orders']).map((element) => ProductOrder.fromJSON(element)).toList() : [];
      identification = jsonMap['identification'] != null ? jsonMap['identification'] : '';
      nameInvoice = jsonMap['nameInvoice'] != null ? jsonMap['nameInvoice'] : '';
      phoneInvoice = jsonMap['phoneInvoice'] != null ? jsonMap['phoneInvoice'] : '';
      emailInvoice = jsonMap['emailInvoice'] != null ? jsonMap['emailInvoice'] : '';
      addressInvoice = jsonMap['addressInvoice'] != null ? jsonMap['addressInvoice'] : '';
      referencesDeliveryAddress = jsonMap['references_delivery_address '] != null ? jsonMap['references_delivery_address '] : '';
      driver_id = jsonMap['driver_id'] != null ? jsonMap['driver_id'] : -1;
      driver = jsonMap['driver'] != null ? User.fromJSON(jsonMap['driver']) : User.fromJSON({});;
    } catch (e) {
      id = '';
      tax = 0.0;
      deliveryFee = 0.0;
      hint = '';
      orderStatusId = 1;
      active = false;
      orderStatus = OrderStatus.fromJSON({});
      dateTime = DateTime(0);
      user = User.fromJSON({});
      payment = Payment.fromJSON({});
      deliveryAddress = Address.fromJSON({});
      productOrders = [];
      identification = '';
      nameInvoice = '';
      phoneInvoice = '';
      emailInvoice = '';
      addressInvoice = '';
      driver_id = -1;
      print(e);
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["user_id"] = user?.id;
    map["order_status_id"] = orderStatus?.id;
    map["tax"] = tax;
    map['hint'] = hint;
    map["delivery_fee"] = deliveryFee;
    map["products"] = productOrders?.map((element) => element.toMap())?.toList();
    map["payment"] = payment?.toMap();
    map["identification"] = identification;
    map["name_invoice"] = nameInvoice;
    map["phone_invoice"] = phoneInvoice;
    map["email_invoice"] = emailInvoice;
    map["address_invoice"] = addressInvoice;
    map['references_delivery_address'] = referencesDeliveryAddress;
    map['driver_id'] = driver_id;
    if (!deliveryAddress.isLatLnUnknown()) {
      map["delivery_address_id"] = deliveryAddress?.id;
    }
    return map;
  }

  Map deliveredMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["order_status_id"] = 5;
    if (deliveryAddress?.id != null && deliveryAddress?.id != 'null') map["delivery_address_id"] = deliveryAddress.id;
    return map;
  }

  Map cancelMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    if (orderStatus?.id != null && orderStatus?.id == '1') map["active"] = false;
    return map;
  }

  bool canCancelOrder() {
    return this.active == true && this.orderStatus.id == '1'; // 1 for order received status
  }

  Map toInvoiceDataMap() {
    var map = new Map<String, dynamic>();
    map["id"] = id;
    map["order_status_id"] =  orderStatusId ?? 1;
    map["identification"] = identification;
    map["name_invoice"] = nameInvoice;
    map["phone_invoice"] = phoneInvoice;
    map["email_invoice"] = emailInvoice;
    map["address_invoice"] = addressInvoice;
    map['references_delivery_address'] = settingRepo.referencesDeliveryAddress;

    return map;
  }
}
