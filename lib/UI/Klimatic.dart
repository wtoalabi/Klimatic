import 'package:flutter/material.dart';
import 'package:klimatic/util/utils.dart' as util;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

class Klimatic extends StatefulWidget {
  @override
  _KlimaticState createState() => _KlimaticState();
}

class _KlimaticState extends State<Klimatic> {
  Map<String, dynamic> data = {};
  String typedCity = "";
  String city = "Abuja";
  String cityInfo = "Abuja, Nigeria";
  num temp = 0.00;
  bool loading = false;
  String temp_description = "";

  Future goToSecondScreen(BuildContext context) async {
    Map result = await Navigator.of(context)
        .push(MaterialPageRoute<Map>(builder: (context) {
      return GetCityScreen();
    }));
    setState(() {
      city = result['name'] ?? "Not Found";
      cityInfo = result['cityInfo'];
      temp = result['cityTemp'];
      temp_description = result['description'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 9.0,
        title: Text("Klimatic"),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              return goToSecondScreen(context);
            },
            icon: Icon(Icons.menu),
          )
        ],
      ),
      body: Container(
        child: Stack(
          children: <Widget>[
            Image.asset(
              "assets/images/umbrella.png",
              fit: BoxFit.fill,
              height: 1299.0,
              width: 400.0,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  alignment: Alignment.topLeft,
                  child: Column(
                    children: <Widget>[
                      Container(
                        child: Text(city, style: cityStyle()),
                        alignment: Alignment.topLeft,
                        margin: EdgeInsets.only(bottom: 5.0),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        alignment: Alignment.topLeft,
                        decoration: BoxDecoration(color: Colors.white70),
                        child: Text(cityInfo, style: cityInfoStyle()),
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: <Widget>[
                      Image.asset("assets/images/light_rain.png"),
                      Text("${temp.toString()}\u2103", style: tempStyle()),
                      Text(temp_description, style: cityStyle()),
                    ],
                  ),
                ),
                Container()
              ],
            ),
          ],
        ),
      ),
    );
  }

  TextStyle tempStyle() {
    return TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        fontStyle: FontStyle.normal,
        fontSize: 49.0);
  }

  TextStyle cityInfoStyle() {
    return TextStyle(
        fontStyle: FontStyle.italic,
        fontSize: 15.3,
        fontWeight: FontWeight.w900,
        color: Colors.deepOrangeAccent);
  }
}

TextStyle cityStyle() {
  return TextStyle(
      color: Colors.white, fontSize: 35.0, fontWeight: FontWeight.bold);
}

class GetCityScreen extends StatefulWidget {
  @override
  _GetCityScreenState createState() => _GetCityScreenState();
}

class _GetCityScreenState extends State<GetCityScreen> {
  TextEditingController _cityController = TextEditingController();
  bool loading = false;
  Map cityData = {};
  String notFound = "";
  void getData() async {
    setState(() {
      loading = true;
      notFound = "";
    });
    String city = _cityController.text;
    String url =
        "https://api.openweathermap.org/data/2.5/weather?q=$city&2172797&appid=${util.appID}&units=imperial";
    http.get(url).then((v) {
      Map data = json.decode(v.body);
      if (data['cod'] != '404') {
        var lon = data['coord']['lon'];
        var lat = data['coord']['lat'];
        cityData['description'] =
            util.capitalize(data['weather'][0]['description']);
        cityData['name'] = data['name'];
        cityData['cityTemp'] = util.turnToCelsius(data['main']['temp']);
        getCityInfo(lon, lat);
      } else {
        setState(() {
          loading = false;
          notFound = "Not Found. Try another City";
        });
      }
    });
  }

  void getCityInfo(lon, lat) async {
    String url =
        "https://api.opencagedata.com/geocode/v1/json?key=1acaae8620f348c6bcd5a590d4c3267b&q=$lat%2C$lon&pretty=1";
    http.get(url).then((v) {
      setState(() {
        loading = false;
      });
      var data = json.decode(v.body);
      Map all = data['results'][0]['components'];
      cityData['cityInfo'] =
          "${all['county'] ?? all['neighbourhood']}, ${all['city'] + ',' ?? ""}  ${all['country']}";
      Navigator.pop(context, cityData);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Type City Name"),
      ),
      body: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: TextField(
                  controller: _cityController,
                  decoration:
                      InputDecoration(hintText: "Type the city to search"),
                ),
              ),
              loading
                  ? CircularProgressIndicator(
                      strokeWidth: 3.0,
                    )
                  : RaisedButton(
                      child: Text("Search..."),
                      color: Colors.lightBlueAccent,
                      onPressed: () {
                        return getData();
                      },
                    ),
            ],
          ),
          loading ? Text("Looking the city up...") : Text(""),
          Text(notFound, style: TextStyle(
            color: Colors.redAccent,
            fontWeight: FontWeight.bold

          ),),
        ],
      ),
    );
  }
}
