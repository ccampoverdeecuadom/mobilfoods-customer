import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../controllers/market_controller.dart';
import '../models/field.dart';
import 'package:mvc_pattern/mvc_pattern.dart';


class CategoryMarketsGrid extends StatefulWidget {
  final void Function(int) saveFilter;
  List<Field> fields;

  CategoryMarketsGrid({Key key, this.fields, this.saveFilter}) : super(key: key);

  @override
  _CategoryMarketsGrid createState() => _CategoryMarketsGrid();
}


// ignore: must_be_immutable
class _CategoryMarketsGrid extends StateMVC<CategoryMarketsGrid>  {
  MarketController _con;


  _CategoryMarketsGrid() : super(MarketController()) {
    _con = controller;
  }

  @override
  Widget build(BuildContext context) {
    double heightBox = 350;
    return  Container(
      padding: EdgeInsets.all(7),
        child: GridView.builder(
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          itemCount: widget.fields.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            childAspectRatio: 0.7,
            crossAxisCount: 3,
            crossAxisSpacing: 5.0,
            mainAxisSpacing: 5.0,
          ),
          itemBuilder: (context, i) {
            return GestureDetector(
              onTap: () {
                widget.saveFilter(i);
              },
              child: Padding(
                padding: EdgeInsets.all(2.0),
                child: Stack(
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                          bottomRight: Radius.circular(10),
                          bottomLeft: Radius.circular(10)),
                      child: CachedNetworkImage(
                        height: heightBox,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        imageUrl: "https://hips.hearstapps.com/hmg-prod.s3.amazonaws.com/images/shopping-bag-full-of-fresh-vegetables-and-fruits-royalty-free-image-1128687123-1564523576.jpg",// widget.fields.elementAt(i).image.url,
                        placeholder: (context, url) => Image.asset(
                          'assets/img/loading.gif',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: heightBox,
                        ),
                        errorWidget: (context, url, error) =>
                            Icon(Icons.error),
                      ),
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.25),
                    ),
                    Positioned(
                      left: 5,
                      bottom: 5,
                      child: Text(
                      widget.fields.elementAt(i).name,
                      style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white),
                    ),),

                  ],
                ),
              ),
            );
          },
        ),
      );
      /*

      Flexible(
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

       */
  }



}
