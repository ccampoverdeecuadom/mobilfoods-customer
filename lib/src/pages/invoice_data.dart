import 'package:customer/src/controllers/invoice_data_controller.dart';
import 'package:customer/src/models/order.dart';
import 'package:customer/src/models/order_status.dart';
import 'package:customer/src/repository/user_repository.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../../src/helpers/app_config.dart' as config;

class InvoiceDataWidget extends StatefulWidget {
  final Order order;
  VoidCallback onChanged;

  InvoiceDataWidget({this.order, this.onChanged});

  @override
  _InvoiceDataState createState() => _InvoiceDataState();
}

class _InvoiceDataState extends StateMVC<InvoiceDataWidget> {
  InvoiceDataController _con;
  GlobalKey<FormState> _invoiceDataFormKey = new GlobalKey<FormState>();

  _InvoiceDataState() : super(InvoiceDataController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(child: Form(
        key: _invoiceDataFormKey,
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 50,
            ),
            new ListTile(
              leading: const Icon(Icons.credit_card),
              title: new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(
                  hintText: '9999999999',
                  labelText: "CI/RUC",
                ),
                initialValue: currentUser.value.ci,
                validator: (input) => input.trim().length < 10
                    ? S.of(context).not_a_valid_ci_ruc
                    : null,
                onSaved: (input) => widget.order.identification = input,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.person),
              title: new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(
                  hintText: 'Charlie Greencamp',
                  labelText: S.of(context).full_name,
                ),
                initialValue: currentUser.value.name,
                validator: (input) => input.trim().length < 3
                    ? S.of(context).not_a_valid_full_name
                    : null,
                onSaved: (input) => widget.order.nameInvoice = input,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.phone),
              title: new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(
                  hintText: '0999999999',
                  labelText: S.of(context).phone,
                ),
                initialValue: currentUser.value.phone,
                validator: (input) => input.trim().length < 6
                    ? S.of(context).not_a_valid_phone
                    : null,
                onSaved: (input) => widget.order.phoneInvoice = input,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.email),
              title: new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.emailAddress,
                decoration: getInputDecoration(hintText: 'johndo@gmail.com', labelText: S.of(context).email_address,),
                initialValue: currentUser.value.email,
                validator: (input) => !input.contains('@') ? S.of(context).not_a_valid_email : null,
                onSaved: (input) => widget.order.emailInvoice = input,
              ),
            ),
            new ListTile(
              leading: const Icon(Icons.location_city),
              title: new TextFormField(
                style: TextStyle(color: Theme.of(context).hintColor),
                keyboardType: TextInputType.text,
                decoration: getInputDecoration(hintText: 'Quito', labelText: S.of(context).address,),
                initialValue: currentUser.value.address,
                validator: (input) => input.trim().length < 3 ? S.of(context).not_a_valid_address : null,
                onSaved: (input) => widget.order.addressInvoice = input,
              ),
            ),
            const Divider(
              height: 4.0,
            ),
            FlatButton(
                onPressed: _submit,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18.0),
                    side: BorderSide(color: config.Colors().mainColor(1))),
                child: Text(S.of(context).confirm_data))
          ],
        )),);
  }

  InputDecoration getInputDecoration({String hintText, String labelText}) {
    return new InputDecoration(
      hintText: hintText,
      labelText: labelText,
      hintStyle: Theme.of(context).textTheme.bodyText1.merge(
            TextStyle(color: Theme.of(context).focusColor),
          ),
      enabledBorder: UnderlineInputBorder(
          borderSide:
              BorderSide(color: Theme.of(context).hintColor.withOpacity(0.2))),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Theme.of(context).hintColor)),
      floatingLabelBehavior: FloatingLabelBehavior.auto,
      labelStyle: Theme.of(context).textTheme.bodyText1.merge(
            TextStyle(color: Theme.of(context).hintColor),
          ),
    );
  }
  void _submit() {
    if (_invoiceDataFormKey.currentState.validate()) {
      _invoiceDataFormKey.currentState.save();
      if(widget.order.orderStatus == null || widget.order.orderStatus.id == null) {
        OrderStatus _orderStatus = new OrderStatus();
        _orderStatus.id = '1'; // TODO default order status Id
        widget.order.orderStatus = _orderStatus;
      }
      _con.updateOrderWithInvoiceData(widget.order);
      widget.onChanged();
    }
  }
}
