class Calculate {
  double price;
  String duration;
  String distance;

  Calculate();

  Calculate.fromJSON(Map<String, dynamic> jsonMap) {
    try {
      price = double.parse(jsonMap['price'].toString());
      duration = jsonMap['duration'].toString();
      distance = jsonMap['distance'].toString();
    } catch (e) {
      price = 0.0;
      duration = '0.0';
      distance = '0.0';
    }
  }

  Map toMap() {
    var map = new Map<String, dynamic>();
    map["price"] = price;
    map["duration"] = duration;
    map["distance"] = distance;
    return map;
  }
}
