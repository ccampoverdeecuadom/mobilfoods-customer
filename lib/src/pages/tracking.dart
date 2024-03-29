import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:customer/src/pages/testchat.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../generated/l10n.dart';
import '../controllers/tracking_controller.dart';
import '../elements/CircularLoadingWidget.dart';
import '../elements/ProductOrderItemWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../helpers/helper.dart';
import '../models/route_argument.dart';
import '../repository/user_repository.dart' as userRepo;
import 'chat.dart';

class TrackingWidget extends StatefulWidget {
  final RouteArgument routeArgument;
  final FirebaseFirestore fireStore = FirebaseFirestore.instance;

  TrackingWidget({Key key, this.routeArgument}) : super(key: key);

  @override
  _TrackingWidgetState createState() => _TrackingWidgetState();
}

class _TrackingWidgetState extends StateMVC<TrackingWidget>
    with SingleTickerProviderStateMixin {
  TrackingController _con;
  TabController _tabController;
  int _tabIndex = 0;
  String driverId;

  _TrackingWidgetState() : super(TrackingController()) {
    _con = controller;
  }

  @override
  void initState() {
    _con.listenForOrder(orderId: widget.routeArgument.id);
    _con.createUser();
    _tabController =
        TabController(length: 2, initialIndex: _tabIndex, vsync: this);
    _tabController.addListener(_handleTabSelection);
    super.initState();
  }

  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _tabIndex = _tabController.index;
      });
    }
  }

  Future getDocs() async {
    print("22222");
    QuerySnapshot querySnapshot = await widget.fireStore.collection("users").get();
    for (int i = 0; i < querySnapshot.docs.length; i++) {
      if(querySnapshot.docs[i].data()["id"] != userRepo.currentUser.value.id){
        driverId = querySnapshot.docs[i].data()["id"];
        print("Driver Id" + driverId);
      }

    }
  }

  @override
  Widget build(BuildContext context) {
    //final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent, accentColor: Theme.of(context).accentColor);
    final theme = Theme.of(context).copyWith(dividerColor: Colors.transparent);
    return Scaffold(
        bottomNavigationBar: Container(
          width: MediaQuery.of(context).size.width,
          height: 135,
          padding: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                  topRight: Radius.circular(20), topLeft: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                    color: Theme.of(context).focusColor.withOpacity(0.15),
                    offset: Offset(0, -2),
                    blurRadius: 5.0)
              ]),
          child: _con.order == null || _con.orderStatus.isEmpty
              ? CircularLoadingWidget(height: 120)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Text(S.of(context).how_would_you_rate_this_market,
                        style: Theme.of(context).textTheme.subtitle1),
                    Text(
                        S
                            .of(context)
                            .click_on_the_stars_below_to_leave_comments,
                        style: Theme.of(context).textTheme.caption),
                    SizedBox(height: 5),
                    FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/Reviews',
                            arguments: RouteArgument(
                                id: _con.order.id, heroTag: "market_reviews"));
                      },
                      padding: EdgeInsets.symmetric(vertical: 5),
                      shape: StadiumBorder(),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: Helper.getStarsList(
                            double.parse(_con
                                .order.productOrders[0].product.market.rate),
                            size: 35),
                      ),
                    ),
                  ],
                ),
        ),
        body: _con.order == null || _con.orderStatus.isEmpty
            ? CircularLoadingWidget(height: 400)
            : CustomScrollView(slivers: <Widget>[
                SliverAppBar(
                  snap: true,
                  floating: true,
                  centerTitle: true,
                  title: Text(
                    S.of(context).orderDetails,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .merge(TextStyle(letterSpacing: 1.3)),
                  ),
                  actions: <Widget>[
                    new ShoppingCartButtonWidget(
                        iconColor: Theme.of(context).hintColor,
                        labelColor: Theme.of(context).accentColor),
                  ],
                  backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                  elevation: 0,
                  bottom: TabBar(
                      controller: _tabController,
                      indicatorSize: TabBarIndicatorSize.label,
                      labelPadding: EdgeInsets.symmetric(horizontal: 15),
                      unselectedLabelColor: Theme.of(context).accentColor,
                      labelColor: Theme.of(context).primaryColor,
                      indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: Theme.of(context).accentColor),
                      tabs: [
                        Tab(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.2),
                                    width: 1)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(S.of(context).details),
                            ),
                          ),
                        ),
                        Tab(
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(
                                    color: Theme.of(context)
                                        .accentColor
                                        .withOpacity(0.2),
                                    width: 1)),
                            child: Align(
                              alignment: Alignment.center,
                              child: Text(S.of(context).tracking_order),
                            ),
                          ),
                        ),
                      ]),
                ),
                SliverList(
                  delegate: SliverChildListDelegate([
                    Offstage(
                      offstage: 0 != _tabIndex,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 30),
                        child: Column(children: [
                          Stack(
                          alignment: AlignmentDirectional.topCenter,
                          children: <Widget>[
                            Opacity(
                              opacity: _con.order.active ? 1 : 0.4,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: <Widget>[
                                  Container(
                                    margin: EdgeInsets.only(top: 14),
                                    padding:
                                        EdgeInsets.only(top: 20, bottom: 5),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                          .primaryColor
                                          .withOpacity(0.9),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Theme.of(context)
                                                .focusColor
                                                .withOpacity(0.1),
                                            blurRadius: 5,
                                            offset: Offset(0, 2)),
                                      ],
                                    ),
                                    child: Theme(
                                      data: theme,
                                      child: ExpansionTile(
                                        initiallyExpanded: true,
                                        title: Column(
                                          children: <Widget>[
                                            Text(
                                                '${S.of(context).order_id}: #${_con.order.id}'),
                                            Text(
                                              DateFormat('dd-MM-yyyy | HH:mm')
                                                  .format(_con.order.dateTime),
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                          ],
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                        ),
                                        trailing: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: <Widget>[
                                            Helper.getPrice(
                                                Helper.getTotalOrdersPrice(
                                                    _con.order),
                                                context,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .headline4),
                                            Text(
                                              '${_con.order.payment.method}',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            )
                                          ],
                                        ),
                                        children: <Widget>[
                                          Column(
                                              children: List.generate(
                                            _con.order.productOrders.length,
                                            (indexProduct) {
                                              return ProductOrderItemWidget(
                                                  heroTag: 'my_order',
                                                  order: _con.order,
                                                  productOrder: _con
                                                      .order.productOrders
                                                      .elementAt(indexProduct));
                                            },
                                          )),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                vertical: 10, horizontal: 20),
                                            child: Column(
                                              children: <Widget>[
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        S
                                                            .of(context)
                                                            .delivery_fee,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    ),
                                                    Helper.getPrice(
                                                        _con.order.deliveryFee,
                                                        context,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1)
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        '${S.of(context).tax} (${_con.order.tax}%)',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    ),
                                                    Helper.getPrice(
                                                        Helper.getTaxOrder(
                                                            _con.order),
                                                        context,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .subtitle1)
                                                  ],
                                                ),
                                                Row(
                                                  children: <Widget>[
                                                    Expanded(
                                                      child: Text(
                                                        S.of(context).total,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .bodyText1,
                                                      ),
                                                    ),
                                                    Helper.getPrice(
                                                        Helper
                                                            .getTotalOrdersPrice(
                                                                _con.order),
                                                        context,
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .headline4)
                                                  ],
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  Container(
                                    child: Wrap(
                                      alignment: WrapAlignment.end,
                                      children: <Widget>[
                                        if (_con.order.canCancelOrder())
                                          FlatButton(
                                            onPressed: () {
                                              showDialog(
                                                context: context,
                                                builder:
                                                    (BuildContext context) {
                                                  // return object of type Dialog
                                                  return AlertDialog(
                                                    title: Wrap(
                                                      spacing: 10,
                                                      children: <Widget>[
                                                        Icon(Icons.report,
                                                            color:
                                                                Colors.orange),
                                                        Text(
                                                          S
                                                              .of(context)
                                                              .confirmation,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .orange),
                                                        ),
                                                      ],
                                                    ),
                                                    content: Text(S
                                                        .of(context)
                                                        .areYouSureYouWantToCancelThisOrder),
                                                    contentPadding:
                                                        EdgeInsets.symmetric(
                                                            horizontal: 30,
                                                            vertical: 25),
                                                    actions: <Widget>[
                                                      FlatButton(
                                                        child: new Text(
                                                          S.of(context).yes,
                                                          style: TextStyle(
                                                              color: Theme.of(
                                                                      context)
                                                                  .hintColor),
                                                        ),
                                                        onPressed: () {
                                                          _con.doCancelOrder();
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                      FlatButton(
                                                        child: new Text(
                                                          S.of(context).close,
                                                          style: TextStyle(
                                                              color: Colors
                                                                  .orange),
                                                        ),
                                                        onPressed: () {
                                                          Navigator.of(context)
                                                              .pop();
                                                        },
                                                      ),
                                                    ],
                                                  );
                                                },
                                              );
                                            },
                                            textColor:
                                                Theme.of(context).hintColor,
                                            child: Wrap(
                                              children: <Widget>[
                                                Text(
                                                    S.of(context).cancelOrder +
                                                        " ",
                                                    style:
                                                        TextStyle(height: 1.3)),
                                                Icon(Icons.clear)
                                              ],
                                            ),
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 20),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              height: 28,
                              width: 160,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(100)),
                                  color: _con.order.active
                                      ? Theme.of(context).accentColor
                                      : Colors.redAccent),
                              alignment: AlignmentDirectional.center,
                              child: Text(
                                _con.order.active
                                    ? '${_con.order.orderStatus.status}'
                                    : S.of(context).canceled,
                                maxLines: 1,
                                overflow: TextOverflow.fade,
                                softWrap: false,
                                style: Theme.of(context)
                                    .textTheme
                                    .caption
                                    .merge(TextStyle(
                                        height: 1,
                                        color: Theme.of(context).primaryColor)),
                              ),
                            ),

                            ],),
                            _con.order.orderStatusId == 5 ? Column(children: [SizedBox(height: 20), Text("La orden finalizo")],):
                            _con.order.driver == null || _con.order.driver.name == "" ? Column(children: [SizedBox(height: 20), Text("Aun no se asigna un repartidor")],):
                            Column(children: [
                              SizedBox(height: 20),
                              Text("Repartidor Asignado"),
                              SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            "Repartidor",
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.caption,
                                          ),
                                          Text(
                                            _con.order.driver.name,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        disabledColor: Theme.of(context).focusColor.withOpacity(0.4),
                                        //onPressed: () {
//                                    Navigator.of(context).pushNamed('/Profile',
//                                        arguments: new RouteArgument(param: _con.order.deliveryAddress));
                                        //},
                                        child: Icon(
                                          Icons.person,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Ubicación del Conductor',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.caption,
                                          ),
                                          Text(
                                            "Seguimiento del Pedido",
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 20),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        disabledColor: Theme.of(context).focusColor.withOpacity(0.4),
                                        onPressed: () {
                                          Navigator.of(context).pushNamed(
                                              '/TrackingRoundsman',
                                              arguments: RouteArgument(param: _con));
                                        },
                                        child: Icon(
                                          Icons.directions,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Teléfono',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.caption,
                                          ),
                                          Text(
                                            _con.order.driver.phone??'Sin número',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          launch("tel:${_con.order.driver.phone??099999999}");
                                        },
                                        child: Icon(
                                          Icons.call,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 7),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Text(
                                            'Comunicate con el repartidor',
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.caption,
                                          ),
                                          Text(
                                            _con.order.driver.name,
                                            overflow: TextOverflow.ellipsis,
                                            style: Theme.of(context).textTheme.bodyText1,
                                          ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    SizedBox(
                                      width: 42,
                                      height: 42,
                                      child: FlatButton(
                                        padding: EdgeInsets.all(0),
                                        onPressed: () {
                                          driverId = _con.order.driver.id;
                                          print("Driver id" + driverId);
                                          //getDocs();
                                          //var document = widget.fireStore.collection('users').doc(userRepo.currentUser.value.id);
                                          //var id = document.id;
                                          //Navigator.of(context).pushNamed('/Chating',  arguments: RouteArgument() );
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Chat(peerId: driverId)));
                                        },
                                        child: Icon(
                                          Icons.chat,
                                          color: Theme.of(context).primaryColor,
                                          size: 24,
                                        ),
                                        color: Theme.of(context).accentColor.withOpacity(0.9),
                                        shape: StadiumBorder(),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20),
                            ],)
                          ],

                        ),
                      ),
                    ),
                    Offstage(
                      offstage: 1 != _tabIndex,
                      child: Column(
                        children: <Widget>[
                          Padding(
                              padding: const EdgeInsets.all(15),
                              child: _con.order.driver == null || _con.order.driver.deviceToken == null ?
                              Text("Aun no se ha asignado un Conductor") :
                                  _con.order.orderStatus.id == '5' ? SizedBox(height: 0,) :
                              Container(
                                padding: EdgeInsets.only(
                                    left: 20, right: 20, top: 15),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                ),
                                child: GestureDetector(
                                  onTap: () => {
                                    Navigator.of(context).pushNamed(
                                        '/TrackingRoundsman',
                                        arguments: RouteArgument(param: _con))
                                  },
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            color:
                                                Theme.of(context).accentColor),
                                        child: Icon(
                                          Icons.place,
                                          color: Colors.white,
                                          size: 38,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text("Seguir en Mapa",
                                                style: TextStyle(
                                                    color: Theme.of(context)
                                                        .accentColor,
                                                    fontSize: 20))
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              )),
                          Padding(
                            padding: const EdgeInsets.only(
                                bottom: 12, left: 12, right: 12),
                            child: Theme(
                              data: ThemeData(
                                primaryColor: Theme.of(context).accentColor,
                              ),
                              child: Stepper(
                                physics: ClampingScrollPhysics(),
                                controlsBuilder: (BuildContext context,
                                    {VoidCallback onStepContinue,
                                    VoidCallback onStepCancel}) {
                                  return SizedBox(height: 0);
                                },
                                steps: _con.getTrackingSteps(context),
                                currentStep: int.tryParse(
                                        this._con.order.orderStatus.id) -
                                    1,
                              ),
                            ),
                          ),
                          _con.order.deliveryAddress?.address != null
                              ? Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 15),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).primaryColor,
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        height: 55,
                                        width: 55,
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(5)),
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.light
                                                    ? Colors.black38
                                                    : Theme.of(context)
                                                        .backgroundColor),
                                        child: Icon(
                                          Icons.place,
                                          color: Theme.of(context).primaryColor,
                                          size: 38,
                                        ),
                                      ),
                                      SizedBox(width: 15),
                                      Flexible(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(
                                              _con.order.deliveryAddress
                                                      ?.description ??
                                                  "",
                                              overflow: TextOverflow.fade,
                                              softWrap: false,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .subtitle1,
                                            ),
                                            Text(
                                              _con.order.deliveryAddress
                                                      ?.address ??
                                                  S.of(context).unknown,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 3,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .caption,
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              : SizedBox(height: 0),
                        ],
                      ),
                    ),
                  ]),
                )
              ]));
  }
}
