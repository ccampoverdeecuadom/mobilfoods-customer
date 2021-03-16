import 'dart:convert';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:global_configuration/global_configuration.dart';
import 'src/elements/notification_plugin.dart';
import 'package:pusher_websocket_flutter/pusher.dart';


import 'generated/l10n.dart';
import 'route_generator.dart';
import 'src/helpers/app_config.dart' as config;
import 'src/models/order.dart';
import 'src/models/route_argument.dart';
import 'src/models/setting.dart';
import 'src/repository/settings_repository.dart' as settingRepo;
import 'src/repository/user_repository.dart' as userRepo;

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext context) {
    return super.createHttpClient(context)..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initFirebase();
  await GlobalConfiguration().loadFromAsset("configurations");
  //print(CustomTrace(StackTrace.current, message: "base_url: ${GlobalConfiguration().getString('base_url')}"));
  //print(CustomTrace(StackTrace.current, message: "api_base_url: ${GlobalConfiguration().getString('api_base_url')}"));
  HttpOverrides.global = new MyHttpOverrides();
  runApp(MyApp());
}

initFirebase() async {
  await Firebase.initializeApp();
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
//  /// Supply 'the Controller' for this application.
//  MyApp({Key key}) : super(con: Controller(), key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  NotificationPlugin notificationPlugin;
  Channel channel;


  @override
  void initState() {
    settingRepo.initSettings();
    settingRepo.getCurrentLocation();
    userRepo.getCurrentUser();
    super.initState();
    initPusher();
    notificationPlugin = new NotificationPlugin();
  }


  Future<void> initPusher() async {
    try {
     //  await Pusher.init("dd1f605388a449d95737", PusherOptions(cluster: "mt1"), // Dev
      await Pusher.init("748edca4f57534084863", PusherOptions(cluster: "mt1"), //Prod
          enableLogging: true);
    } on PlatformException catch (e) {
      print(e.message);
    }

    //Connected
    Pusher.connect(onConnectionStateChange: (x) async {
      print('***********Conected***********');
      print(x.currentState);
    }, onError: (x) {
      print('***********Error***********');
      print(x.message);
    });

    //subscribe
    channel = await Pusher.subscribe('orders');

    //bind
    channel.bind('App\\Events\\OrderStatusUpdated', (e) async{

      String x = userRepo.currentUser.value.id;
      Order _order = Order.fromJSON(jsonDecode(e.data)['order']);
      int y = jsonDecode(e.data)['order']['user_id'];
      if(x == y.toString()){
        notificationPlugin.setOnNotificationClick((payload)=>{
        Navigator.of(context).pushNamed('/Tracking', arguments: RouteArgument(id: _order.id))
        });
        await notificationPlugin.showNotificationWithAttachment(_order);
      }
    });

  }


  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: settingRepo.setting,
        builder: (context, Setting _setting, _) {
          return MaterialApp(
              navigatorKey: settingRepo.navigatorKey,
              title: _setting.appName,
              initialRoute: '/Splash',
              onGenerateRoute: RouteGenerator.generateRoute,
              debugShowCheckedModeBanner: false,
              locale: _setting.mobileLanguage.value,
              localizationsDelegates: [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              theme: _setting.brightness.value == Brightness.light
                  ? ThemeData(
                      fontFamily: 'ProductSans',
                      primaryColor: Colors.white,
                      floatingActionButtonTheme: FloatingActionButtonThemeData(elevation: 0, foregroundColor: Colors.white),
                      brightness: Brightness.light,
                      accentColor: config.Colors().mainColor(1),
                      dividerColor: config.Colors().accentColor(0.1),
                      focusColor: config.Colors().accentColor(1),
                      hintColor: config.Colors().secondColor(1),
                      textTheme: TextTheme(
                        headline5: TextStyle(fontSize: 22.0, color: config.Colors().secondColor(1), height: 1.3),
                        headline4: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: config.Colors().secondColor(1), height: 1.3),
                        headline3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().secondColor(1), height: 1.3),
                        headline2: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: config.Colors().mainColor(1), height: 1.4),
                        headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w300, color: config.Colors().secondColor(1), height: 1.4),
                        subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: config.Colors().secondColor(1), height: 1.3),
                        headline6: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: config.Colors().mainColor(1), height: 1.3),
                        bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1), height: 1.2),
                        bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: config.Colors().secondColor(1), height: 1.3),
                        caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: config.Colors().accentColor(1), height: 1.2),
                      ),
                    )
                  : ThemeData(
                      fontFamily: 'ProductSans',
                      primaryColor: Color(0xFF252525),
                      brightness: Brightness.dark,
                      scaffoldBackgroundColor: Color(0xFF2C2C2C),
                      accentColor: config.Colors().mainDarkColor(1),
                      dividerColor: config.Colors().accentColor(0.1),
                      hintColor: config.Colors().secondDarkColor(1),
                      focusColor: config.Colors().accentDarkColor(1),
                      textTheme: TextTheme(
                        headline5: TextStyle(fontSize: 22.0, color: config.Colors().secondDarkColor(1), height: 1.3),
                        headline4: TextStyle(fontSize: 20.0, fontWeight: FontWeight.w700, color: config.Colors().secondDarkColor(1), height: 1.3),
                        headline3: TextStyle(fontSize: 22.0, fontWeight: FontWeight.w700, color: config.Colors().secondDarkColor(1), height: 1.3),
                        headline2: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w700, color: config.Colors().mainDarkColor(1), height: 1.4),
                        headline1: TextStyle(fontSize: 26.0, fontWeight: FontWeight.w300, color: config.Colors().secondDarkColor(1), height: 1.4),
                        subtitle1: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w500, color: config.Colors().secondDarkColor(1), height: 1.3),
                        headline6: TextStyle(fontSize: 17.0, fontWeight: FontWeight.w700, color: config.Colors().mainDarkColor(1), height: 1.3),
                        bodyText2: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1), height: 1.2),
                        bodyText1: TextStyle(fontSize: 15.0, fontWeight: FontWeight.w400, color: config.Colors().secondDarkColor(1), height: 1.3),
                        caption: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w300, color: config.Colors().secondDarkColor(0.6), height: 1.2),
                      ),
                    ));
        });
  }
}
