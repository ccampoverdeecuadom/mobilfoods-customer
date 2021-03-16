import 'dart:convert';

import 'package:flutter/cupertino.dart';
import '../models/field.dart';
import '../repository/field_repository.dart';
import '../models/filter.dart';

import 'package:mvc_pattern/mvc_pattern.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/helper.dart';
import '../models/category.dart';
import '../models/market.dart';
import '../models/product.dart';
import '../models/review.dart';
import '../models/slide.dart';
import '../repository/category_repository.dart';
import '../repository/market_repository.dart';
import '../repository/product_repository.dart';
import '../repository/settings_repository.dart';
import '../repository/slider_repository.dart';

class HomeController extends ControllerMVC {
  List<Category> categories = <Category>[];
  List<Slide> slides = <Slide>[];
  List<Market> topMarkets = <Market>[];
  List<Market> popularMarkets = <Market>[];
  List<Review> recentReviews = <Review>[];
  List<Product> trendingProducts = <Product>[];
  List<Field> fields = <Field>[];
  Filter filter;

  HomeController() {
    listenForTopMarkets();
    listenForSlides();
    listenForTrendingProducts();
    listenForCategories();
    listenForPopularMarkets();
    listenForRecentReviews();
    listenForFields();
  }

  Future<void> listenForFields() async {
    final Stream<Field> stream = await getFields();
    stream.listen((Field _field) {
      setState(
          ()  => fields.add(_field));
    }, onError: (a) {
      //print(a);
    }, onDone: () {});
  }

  Future<void> listenForSlides() async {
    final Stream<Slide> stream = await getSlides();
    stream.listen((Slide _slide) {
      setState(() => slides.add(_slide));
    }, onError: (a) {
      //print(a);
    }, onDone: () {});
  }

  Future<void> listenForCategories() async {
    final Stream<Category> stream = await getCategories();
    stream.listen((Category _category) {
      setState(() => categories.add(_category));
    }, onError: (a) {
      //print(a);
    }, onDone: () {});
  }

  Future<void> listenForTopMarkets() async {
    final Stream<Market> stream =
        await getNearMarkets(deliveryAddress.value, deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => topMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForPopularMarkets() async {
    final Stream<Market> stream =
        await getPopularMarkets(deliveryAddress.value);
    stream.listen((Market _market) {
      setState(() => popularMarkets.add(_market));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForRecentReviews() async {
    final Stream<Review> stream = await getRecentReviews();
    stream.listen((Review _review) {
      setState(() => recentReviews.add(_review));
    }, onError: (a) {}, onDone: () {});
  }

  Future<void> listenForTrendingProducts() async {
    final Stream<Product> stream =
        await getTrendingProducts(deliveryAddress.value);
    stream.listen((Product _product) {
      setState(() => trendingProducts.add(_product));
    }, onError: (a) {
      //print(a);
    }, onDone: () {});
  }

  void requestForCurrentLocation(BuildContext context) {
    OverlayEntry loader = Helper.overlayLoader(context);
    Overlay.of(context).insert(loader);
    setCurrentLocation().then((_address) async {
      deliveryAddress.value = _address;
      await refreshHome();
      loader.remove();
    }).catchError((e) {
      loader.remove();
    });
  }

  Future<void> refreshHome() async {
    setState(() {
      slides = <Slide>[];
      categories = <Category>[];
      topMarkets = <Market>[];
      popularMarkets = <Market>[];
      recentReviews = <Review>[];
      trendingProducts = <Product>[];
    });
    await listenForSlides();
    await listenForTopMarkets();
    await listenForTrendingProducts();
    await listenForCategories();
    await listenForPopularMarkets();
    await listenForRecentReviews();
  }

  Future<void> saveFilter(id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    filter = Filter.fromJSON(json.decode(prefs.getString('filter') ?? '{}'));
    Field field = new Field();
    field.id = id;
    List<Field> lista = <Field>[];
    lista.add(field);
    filter.fields = lista.toList();
    prefs.setString('filter', json.encode(filter.toMap()));
    this.refreshHome();
  }
}
