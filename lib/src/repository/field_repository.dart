import 'dart:convert';

import 'package:global_configuration/global_configuration.dart';
import 'package:http/http.dart' as http;
import '../models/address.dart';
import '../models/filter.dart';
import '../models/market.dart';

import '../helpers/helper.dart';
import '../models/field.dart';

Future<Stream<Field>> getFields() async {
  final String url = '${GlobalConfiguration().getString('api_base_url')}fields?orderBy=updated_at&sortedBy=desc';

  final client = new http.Client();
  final streamedRest = await client.send(http.Request('get', Uri.parse(url)));

  return streamedRest.stream
      .transform(utf8.decoder)
      .transform(json.decoder)
      .map((data) => Helper.getData(data))
      .expand((data) => (data as List))
      .map((data) {
    return Field.fromJSON(data);
  });
}


Future<Stream<Market>> getMarketsByField(Field _field) async {
  Uri uri = Helper.getUri('api/markets');
  Map<String, dynamic> _queryParams = {};
  Filter filter = new Filter();
  filter.fields = new List<Field>();
  filter.fields.add(_field);
  filter.delivery = false;
  filter.open = false;

  _queryParams['limit'] = '1000000';
  _queryParams.addAll(filter.toQuery());
  uri = uri.replace(queryParameters: _queryParams);
  try {
    final client = new http.Client();
    final streamedRest = await client.send(http.Request('get', uri));

    Stream<Market> streamMarket = streamedRest.stream
        .transform(utf8.decoder)
        .transform(json.decoder)
        .map((data) => Helper.getData(data))
        .expand((data) => (data as List))
        .map((data) {
      return Market.fromJSON(data);
    });
    return streamMarket;
  } catch (e) {
    //print(CustomTrace(StackTrace.current, message: uri.toString()).toString());
    return new Stream.value(new Market.fromJSON({}));
  }
}