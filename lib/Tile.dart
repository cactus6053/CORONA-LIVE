import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class HeaderTile extends StatelessWidget {
  String Country = 'Country';
  String totalVaccine = 'total';
  String fullyVaccine = 'fully';
  String dailyVaccine = 'daily';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      onTap: null,
      title: Row(
        children: <Widget>[
          Expanded(child: Text(Country, style: TextStyle(fontSize: 14))),
          Expanded(child: Text(totalVaccine,style: TextStyle(fontSize: 14))),
          Expanded(child: Text(fullyVaccine,style: TextStyle(fontSize: 14))),
        ],
      ),
      trailing: Text(dailyVaccine),
    );
    throw UnimplementedError();
  }
}

class HeaderCase extends StatelessWidget {
  String Country = 'Country';
  String totalVaccine = 'total cases';
  String fullyVaccine = 'daily cases';
  String dailyVaccine = 'total deaths';

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      onTap: null,
      title: Row(
        children: <Widget>[
          Expanded(child: Text(Country, style: TextStyle(fontSize: 14))),
          Expanded(child: Text(totalVaccine,style: TextStyle(fontSize: 14))),
          Expanded(child: Text(fullyVaccine,style: TextStyle(fontSize: 14))),
        ],
      ),
      trailing: Text(dailyVaccine),
    );
    throw UnimplementedError();
  }
}

class CountryTile extends StatelessWidget {
  CountryTile(this.Country, this.totalVaccine, this.fullyVaccine, this.dailyVaccine);

  String Country;
  String totalVaccine;
  String fullyVaccine;
  String dailyVaccine;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Row(
        children: <Widget>[
          Expanded(child: Text(Country,style: TextStyle(fontSize: 13))),
          Expanded(child: Text(totalVaccine,style: TextStyle(fontSize: 13))),
          Expanded(child: Text(fullyVaccine,style: TextStyle(fontSize: 13))),
        ],
      ),
      trailing: Text(dailyVaccine),
    );
    throw UnimplementedError();
  }
}

class Country {
  String name;
  int totalVaccined;
  int fullyVaccined;
  int dailyVaccined;

  Country(this.name, this.totalVaccined, this.fullyVaccined, this.dailyVaccined);
}