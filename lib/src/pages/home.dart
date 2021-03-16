import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/src/elements/PreLaunchWidget.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../elements/CategoryMarketsWidget.dart';
import '../elements/CircularLoadingWidget.dart';
import '../models/route_argument.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../../generated/l10n.dart';
import '../controllers/home_controller.dart';
import '../elements/CardsCarouselWidget.dart';
import '../elements/CaregoriesCarouselWidget.dart';
import '../elements/DeliveryAddressBottomSheetWidget.dart';
import '../elements/GridWidget.dart';
import '../elements/HomeSliderWidget.dart';
import '../elements/ProductsCarouselWidget.dart';
import '../elements/ReviewsListWidget.dart';
import '../elements/SearchBarWidget.dart';
import '../elements/ShoppingCartButtonWidget.dart';
import '../repository/settings_repository.dart' as settingsRepo;
import '../repository/user_repository.dart';

class HomeWidget extends StatefulWidget {
  final GlobalKey<ScaffoldState> parentScaffoldKey;

  HomeWidget({Key key, this.parentScaffoldKey}) : super(key: key);

  @override
  _HomeWidgetState createState() => _HomeWidgetState();
}

class _HomeWidgetState extends StateMVC<HomeWidget> {
  HomeController _con;
  bool enableRegisterButton;

  _HomeWidgetState() : super(HomeController()) {
    _con = controller;
  }

  @override
  void initState() {
    super.initState();
    verifyLocationIsLoaded();
    enableRegisterButton = false;
  }

  verifyLocationIsLoaded() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('delivery_address')) {
      settingsRepo.getCurrentLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: new IconButton(
          icon: new Icon(Icons.sort, color: Theme.of(context).hintColor),
          onPressed: () => widget.parentScaffoldKey.currentState.openDrawer(),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: ValueListenableBuilder(
          valueListenable: settingsRepo.setting,
          builder: (context, value, child) {
            return enableRegisterButton
                ? SizedBox(
                    width: MediaQuery.of(context).size.width - 40,
                    child: FlatButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/SignUp');
                      },
                      disabledColor:
                          Theme.of(context).focusColor.withOpacity(0.5),
                      padding: EdgeInsets.symmetric(vertical: 14),
                      color: Theme.of(context).accentColor,
                      shape: StadiumBorder(),
                      child: Text(
                        S.of(context).register,
                        textAlign: TextAlign.start,
                        style: Theme.of(context).textTheme.bodyText1.merge(
                            TextStyle(color: Theme.of(context).primaryColor)),
                      ),
                    ),
                  )
                : Text(
                    value.appName ?? S.of(context).home,
                    style: Theme.of(context)
                        .textTheme
                        .headline6
                        .merge(TextStyle(letterSpacing: 1.3)),
                  );
          },
        ),
        actions: enableRegisterButton
            ? <Widget>[]
            : <Widget>[
                new ShoppingCartButtonWidget(
                    iconColor: Theme.of(context).hintColor,
                    labelColor: Theme.of(context).accentColor),
                Container(
                  width: 30,
                  height: 30,
                  margin: EdgeInsetsDirectional.only(start: 0, end: 20),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(300),
                    onTap: () {
                      if (currentUser.value.apiToken == null) {
                        _con.requestForCurrentLocation(context);
                      } else {
                        var bottomSheetController = widget
                            .parentScaffoldKey.currentState
                            .showBottomSheet(
                          (context) => DeliveryAddressBottomSheetWidget(
                              scaffoldKey: widget.parentScaffoldKey),
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
                    child: Icon(
                      Icons.location_pin,
                      color: Theme.of(context).hintColor,
                      size: 28,
                    ),
                  ),
                ),
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
            children: List.generate(
                settingsRepo.setting.value.homeSections.length, (index) {
              String _homeSection =
                  settingsRepo.setting.value.homeSections.elementAt(index);
              switch (_homeSection) {
                case 'pre_launch':
                  setState(() {
                    enableRegisterButton = true;
                  });
                  return PreLaunchWidget();
                case 'category_of_markets':
                  return this._con.fields.isEmpty
                      ? CircularLoadingWidget(height: 150)
                      : CategoryMarketsWidget(
                          fields: _con.fields,
                          saveFilter: (int i) => {saveFilter(i)},
                        );
                case 'slider':
                  return HomeSliderWidget(slides: _con.slides);
                case 'search':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: SearchBarWidget(
                      onClickFilter: (event) {
                        widget.parentScaffoldKey.currentState.openEndDrawer();
                      },
                    ),
                  );
                case 'top_markets_heading':
                  return Padding(
                    padding: const EdgeInsets.only(
                        top: 15, left: 20, right: 20, bottom: 10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                S.of(context).top_markets,
                                style: Theme.of(context).textTheme.headline4,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.fade,
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                if (currentUser.value.apiToken == null) {
                                  _con.requestForCurrentLocation(context);
                                } else {
                                  var bottomSheetController = widget
                                      .parentScaffoldKey.currentState
                                      .showBottomSheet(
                                    (context) =>
                                        DeliveryAddressBottomSheetWidget(
                                            scaffoldKey:
                                                widget.parentScaffoldKey),
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
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: settingsRepo
                                              .deliveryAddress.value?.address ==
                                          null
                                      ? Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.1)
                                      : Theme.of(context).accentColor,
                                ),
                                child: Text(
                                  S.of(context).delivery,
                                  style: TextStyle(
                                      color: settingsRepo.deliveryAddress.value
                                                  ?.address ==
                                              null
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                            SizedBox(width: 7),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  settingsRepo.deliveryAddress.value?.address =
                                      null;
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 6, horizontal: 10),
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5)),
                                  color: settingsRepo
                                              .deliveryAddress.value?.address !=
                                          null
                                      ? Theme.of(context)
                                          .focusColor
                                          .withOpacity(0.1)
                                      : Theme.of(context).accentColor,
                                ),
                                child: Text(
                                  S.of(context).pickup,
                                  style: TextStyle(
                                      color: settingsRepo.deliveryAddress.value
                                                  ?.address !=
                                              null
                                          ? Theme.of(context).hintColor
                                          : Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (settingsRepo.deliveryAddress.value?.address != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 12),
                            child: Text(
                              S.of(context).near_to +
                                  " " +
                                  (settingsRepo.deliveryAddress.value?.address),
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ),
                      ],
                    ),
                  );
                case 'top_markets':
                  return CardsCarouselWidget(
                      marketsList: _con.topMarkets,
                      isVertical: false,
                      heroTag: 'home_top_markets');
                case 'trending_week_heading':
                  return ListTile(
                    dense: true,
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    leading: Icon(
                      Icons.trending_up,
                      color: Theme.of(context).hintColor,
                    ),
                    title: Text(
                      S.of(context).trending_this_week,
                      style: Theme.of(context).textTheme.headline4,
                    ),
                    subtitle: Text(
                      S.of(context).clickOnTheProductToGetMoreDetailsAboutIt,
                      maxLines: 2,
                      style: Theme.of(context).textTheme.caption,
                    ),
                  );
                case 'trending_week':
                  return ProductsCarouselWidget(
                      productsList: _con.trendingProducts,
                      heroTag: 'home_product_carousel');
                case 'categories_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.category,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).product_categories,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'categories':
                  return CategoriesCarouselWidget(
                    categories: _con.categories,
                  );
                case 'popular_heading':
                  return Padding(
                    padding:
                        const EdgeInsets.only(left: 20, right: 20, bottom: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 0),
                      leading: Icon(
                        Icons.trending_up,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).most_popular,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'popular':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridWidget(
                      marketsList: _con.popularMarkets,
                      heroTag: 'home_markets',
                    ),
                  );
                case 'recent_reviews_heading':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 20),
                      leading: Icon(
                        Icons.recent_actors,
                        color: Theme.of(context).hintColor,
                      ),
                      title: Text(
                        S.of(context).recent_reviews,
                        style: Theme.of(context).textTheme.headline4,
                      ),
                    ),
                  );
                case 'recent_reviews':
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: ReviewsListWidget(reviewsList: _con.recentReviews),
                  );
                default:
                  return SizedBox(height: 0);
              }
            }),
          ),
        ),
      ),
    );
  }

  saveFilter(int i) {
    _con.saveFilter(_con.fields.elementAt(i).id);
    Navigator.of(context).pushNamed('/Markets',
        arguments: RouteArgument(id: _con.fields.elementAt(i).id));
  }
}
