import 'package:customer/src/elements/SearchBarWidget.dart';
import 'package:customer/src/repository/settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_countdown_timer/countdown_timer_controller.dart';
import 'package:flutter_countdown_timer/current_remaining_time.dart';
import 'package:flutter_countdown_timer/flutter_countdown_timer.dart';
import '../../generated/l10n.dart';

class PreLaunchWidget extends StatefulWidget {
  PreLaunchWidget({
    Key key,
  }) : super(key: key);

  @override
  _PreLaunchWidgetState createState() {
    return new _PreLaunchWidgetState();
  }
}

class _PreLaunchWidgetState extends State<PreLaunchWidget> {
  CountdownTimerController controller;

  //int endTime = DateTime.now().millisecondsSinceEpoch +
  //    Duration(days: , hours: 0, seconds: 10).inMilliseconds;

  int endTime = setting.value.preLaunchDate.millisecondsSinceEpoch;

  @override
  void initState() {
    super.initState();
    controller = CountdownTimerController(endTime: endTime, onEnd: onEnd);
  }

  @override
  Widget build(BuildContext context) {
    double heightBoxes = 100;
    return Column(
      children: [
        CountdownTimer(
          controller: controller,
          widgetBuilder: (_, CurrentRemainingTime time) {
            if (time == null) {
              initSettings();
            }
            return Column(
              children: [
                Container(
                  child: Image.asset(
                    'assets/img/gif_launcher.gif',
                    fit: BoxFit.cover,
                  ),
                ),
                new Align(
                  alignment: Alignment.bottomRight,
                  child: GridView.count(
                    crossAxisCount: 4,
                    scrollDirection: Axis.vertical,
                    shrinkWrap: true,
                    children: [
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(S.of(context).days,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .fontFamily)),
                            time == null ? SizedBox(height: 0,):
                            Text(time.days.toString() == 'null' ? '0' : time.days.toString(),
                                style: TextStyle(
                                    fontSize: 33,
                                    color: Colors.white,
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .fontFamily)),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 1, right: 1),
                        height: heightBoxes,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(S.of(context).hours,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .fontFamily)),
                            time== null ? SizedBox(height: 0,):
                            Text(time.hours.toString()== 'null' ? '0' : time.hours.toString() ,
                                style: TextStyle(
                                    fontSize: 33,
                                    color: Colors.white,
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .fontFamily)),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 1, right: 1),
                        height: heightBoxes,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(S.of(context).minutes,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .fontFamily)),
                            time == null ? SizedBox(height: 0,):
                            Text(time.min.toString() == 'null' ? '0' : time.min.toString(),
                                style: TextStyle(
                                    fontSize: 33,
                                    color: Colors.white,
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .fontFamily)),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 1, right: 1),
                        height: heightBoxes,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                      Container(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(S.of(context).seconds,
                                style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white.withOpacity(0.9),
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .bodyText1
                                        .fontFamily)),
                            time == null ? SizedBox(height: 0,):
                            Text(time.sec.toString() == 'null' ? '0' : time.sec.toString(),
                                style: TextStyle(
                                    fontSize: 33,
                                    color: Colors.white,
                                    fontFamily: Theme.of(context)
                                        .textTheme
                                        .headline2
                                        .fontFamily)),
                          ],
                        ),
                        margin: EdgeInsets.only(left: 1, right: 1),
                        height: heightBoxes,
                        decoration: BoxDecoration(
                          color: Theme.of(context).accentColor,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.25),
                              spreadRadius: 5,
                              blurRadius: 7,
                              offset:
                                  Offset(0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            );

            // Text(
            //  'days: [ ${time.days} ], hours: [ ${time.hours} ], min: [ ${time.min} ], sec: [ ${time.sec} ]');
          },
        ),
      ],
    );
  }

  void onEnd() {
    print('onEnd');
  }
}
