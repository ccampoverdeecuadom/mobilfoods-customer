import 'package:flutter/material.dart';
import '../elements/EmptyMarketsWidget.dart';
import 'package:mvc_pattern/mvc_pattern.dart';
import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class MarketsWidget extends StatefulWidget {

  MarketsWidget({Key key}) : super(key: key);

  @override
  _MarketsWidgetState createState() => _MarketsWidgetState();
}


class _MarketsWidgetState extends StateMVC<MarketsWidget> {
  HomeController _con;
  final globalKey = GlobalKey<ScaffoldState>();

  _MarketsWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    final double widthPage = MediaQuery.of(context).size.width;

    return Scaffold(
      key: globalKey,
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.keyboard_return, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).accentColor,
        elevation: 0,
        centerTitle: true,
        title:  Image.asset(
        'assets/img/logo_header.png',
        height: 50,
        fit: BoxFit.cover,
      ),
        actions: <Widget>[
          new ShoppingCartButtonWidget(
              iconColor: Colors.white,
              labelColor: Theme.of(context).accentColor),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _con.refreshHome,
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.bookmark,
                    color: Theme.of(context).hintColor,
                  ),
                  title: Text(
                    'Promociones',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  subtitle: Text("Últimas Promociones",
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              Container(height: 100,
              child: ListView.builder(
                itemCount:6,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) {
                  double _marginLeft = 0;
                  (index == 0) ? _marginLeft = 20 : _marginLeft = 0;
                  return GestureDetector(onTap: () => {},
                    child: Container(
                      padding: EdgeInsets.all(10),
                       child:Image.network(
                        "https://media-cdn.tripadvisor.com/media/photo-s/10/f6/4c/16/thursday-2x1-micheladas.jpg", height: 100,),)
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15, left: 20, right: 20),
                child: ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.symmetric(vertical: 0),
                  leading: Icon(
                    Icons.stars,
                    color: Theme.of(context).hintColor,
                  ),
                  trailing: IconButton(
                    onPressed: () {
                      if (currentUser.value.apiToken == null) {
                        _con.requestForCurrentLocation(context);
                      } else {
                        var bottomSheetController =
                        globalKey.currentState.showBottomSheet<void>(
                              (context) => DeliveryAddressBottomSheetWidget(
                              scaffoldKey: globalKey),
                          shape: RoundedRectangleBorder(
                            borderRadius: new BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10)),
                          ),
                        );
                        bottomSheetController.closed.then((value) {
                          _con.refreshHome();
                        });
                      }
                    },
                    icon: Icon(
                      Icons.my_location,
                      color: Theme.of(context).hintColor,
                    ),
                  ),
                  title: Text(
                    'Establecimientos',
                    style: Theme.of(context).textTheme.headline4,
                  ),
                  subtitle: Text(
                    S.of(context).near_to +
                        " " +
                        (settingsRepo.deliveryAddress.value?.address ??
                            S.of(context).unknown),
                    style: Theme.of(context).textTheme.caption,
                  ),
                ),
              ),
              Flexible(
                  child:
                      _con.topMarkets.length == 0 ? EmptyMarketsWidget() :
                  CardsCarouselWidget(
                      marketsList: _con.topMarkets, heroTag: 'home_top_markets', isVertical: true)),
            ],
          ),
        ),
      ),
    );
  }

}