import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:customer/src/controllers/profile_controller.dart';
import 'package:customer/src/repository/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mvc_pattern/mvc_pattern.dart';

import '../models/user.dart';
import 'CircularLoadingWidget.dart';

class ProfileAvatarWidget extends StatefulWidget {

  final User user;
  final Function dataUpdated;
  final bool isUploadingImage;
  final String imageUrl;
  ProfileAvatarWidget({
    Key key,
    this.user, this.dataUpdated, this.isUploadingImage, this.imageUrl,
  }) : super(key: key);

  @override
  _ProfileAvatarWidgetState createState() {
    return new _ProfileAvatarWidgetState();
  }
}
class _ProfileAvatarWidgetState extends State<ProfileAvatarWidget>{

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 30),
      decoration: BoxDecoration(
        color: Theme.of(context).accentColor,
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(30), bottomRight: Radius.circular(30)),
      ),
      child: Column(
        children: <Widget>[
          Container(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
              SizedBox(
                width: 50,
                height: 50,
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    widget.dataUpdated();
                  },
                  child: Icon(Icons.camera_alt, color: Theme.of(context).primaryColor),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                ),
              ),
                ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(300)),
                  child:
                  widget.isUploadingImage ? CircularLoadingWidget(height: 50,) :
                  CachedNetworkImage(
                    height: 135,
                    width: 135,
                    fit: BoxFit.cover,
                    imageUrl: widget.imageUrl,
                    placeholder: (context, url) => Image.asset(
                      'assets/img/loading.gif',
                      fit: BoxFit.cover,
                      height: 135,
                      width: 135,
                    ),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              SizedBox(
                width: 50,
                height: 50,
                child: FlatButton(
                  padding: EdgeInsets.all(0),
                  onPressed: () {
                    Navigator.of(context).pushNamed('/Settings');
                  },
                  child: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  color: Theme.of(context).accentColor,
                  shape: StadiumBorder(),
                ),
              ),
              ],
            ),
          ),
          Text(
            widget.user.name,
            style: Theme.of(context).textTheme.headline5.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
          Text(
            widget.user.address == null ? "Dirección" :
            widget.user.address,
            style: Theme.of(context).textTheme.caption.merge(TextStyle(color: Theme.of(context).primaryColor)),
          ),
        ],
      ),
    );
  }
}
