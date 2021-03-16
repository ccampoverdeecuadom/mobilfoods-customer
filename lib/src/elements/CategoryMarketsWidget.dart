import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../controllers/market_controller.dart';
import '../models/field.dart';
import 'package:mvc_pattern/mvc_pattern.dart';


class CategoryMarketsWidget extends StatefulWidget {
  final void Function(int) saveFilter;
  List<Field> fields;

  CategoryMarketsWidget({Key key, this.fields, this.saveFilter}) : super(key: key);

  @override
  _CategoryMarketsWidget createState() => _CategoryMarketsWidget();
}


// ignore: must_be_immutable
class _CategoryMarketsWidget extends StateMVC<CategoryMarketsWidget>  {
  MarketController _con;

  _CategoryMarketsWidget() : super(MarketController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    return  Flexible(
      child: ListView.builder(
              itemCount: widget.fields.length,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              scrollDirection: Axis.vertical,
              itemBuilder: (context, i) {
                return GestureDetector(
                  onTap: () {
                    widget.saveFilter(i);
                  },
                  child: Padding(
                    padding: EdgeInsets.all(5.0),
                    child: Stack(
                      children: <Widget>[
                        ClipRRect(
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                              bottomLeft: Radius.circular(10)),
                          child: CachedNetworkImage(
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            imageUrl: widget.fields.elementAt(i).image.url,
                            placeholder: (context, url) => Image.asset(
                              'assets/img/loading.gif',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 150,
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                        ),
                        Center(
                          heightFactor: 4,
                          child: Text(
                            widget.fields.elementAt(i).name,
                            style: TextStyle(
                                fontSize: 28.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
