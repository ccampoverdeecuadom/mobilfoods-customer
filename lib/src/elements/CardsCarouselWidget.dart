import 'package:flutter/material.dart';

import '../elements/CardsCarouselLoaderWidget.dart';
import '../models/market.dart';
import '../models/route_argument.dart';
import 'CardWidget.dart';

// ignore: must_be_immutable
class CardsCarouselWidget extends StatefulWidget {
  List<Market> marketsList;
  String heroTag;
  bool isVertical;

  CardsCarouselWidget({Key key, this.marketsList, this.heroTag, this.isVertical}) : super(key: key);

  @override
  _CardsCarouselWidgetState createState() => _CardsCarouselWidgetState();
}

class _CardsCarouselWidgetState extends State<CardsCarouselWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return widget.marketsList.isEmpty
        ? CardsCarouselLoaderWidget()
        : Container(
             height: widget.isVertical ? MediaQuery.of(context).size.height * 0.7 : 288,
            child: ListView.builder(
              scrollDirection: widget.isVertical ? Axis.vertical : Axis.horizontal,
              itemCount: widget.marketsList.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushNamed('/Details',
                        arguments: RouteArgument(
                          id: widget.marketsList.elementAt(index).id,
                          heroTag: widget.heroTag,
                        ));
                  },
                  child: CardWidget(market: widget.marketsList.elementAt(index), heroTag: widget.heroTag),
                );
              },
            ),
          );
  }
}
