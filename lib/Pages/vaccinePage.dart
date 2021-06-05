import 'dart:async';
import 'dart:convert';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pa3/notifiler_model.dart';
import 'package:pa3/Tile.dart';
import 'package:pa3/Pages/NavigationPage.dart';

Future<VaccineData> fetchVaccine() async {
  final url =
      'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json';
  final response = await http.get(url);
  if (response.statusCode == 200) {
    final realtime = jsonDecode(response.body);
    var len = realtime.length;
    var KoreaIndex;
    int totalVaccine = 0;
    int fullyVaccine = 0;
    int dailyVaccine = 0;
    //find South Korea
    for (int i = 0; i < len; i++) {
      if (realtime[i]['country'] == "South Korea") {
        KoreaIndex = i;
        break;
      }
    }
    List<Vaccine> vaccinelist = [];
    for (int i = 0; i < len; i++) {
      vaccinelist.add(Vaccine.fromJson(realtime[i]));
    }

    var numOfDate = realtime[KoreaIndex]['data'].length;
    var latestDate = realtime[KoreaIndex]['data'][numOfDate - 1]['date'];

    //total vaccine
    var cnt = 0;
    for (int i = 0; i < len; i++) {
      int cntDate = vaccinelist[i].data.length;
      bool flag = false;
      bool flag1 = false;
      for (int j = cntDate - 1; j >= 0; j--) {
        //date가 일치할 시
        if (vaccinelist[i].data[j]['date'] == latestDate) {
          flag = true;
          //total_vaccinations 값이 존재할 때
          if (vaccinelist[i].data[j]['total_vaccinations'] != null) {
            totalVaccine += vaccinelist[i].data[j]['total_vaccinations'];
          }
          //total_vaccinations 값이 없을 경우 people_vaccinated or fully_vaccinated
          else {
            if (vaccinelist[i].data[j]['people_vaccinated'] != null) {
              totalVaccine += vaccinelist[i].data[j]['people_vaccinated'];
            } else if (vaccinelist[i].data[j]['people_fully_vaccinated'] !=
                null) {
              totalVaccine += vaccinelist[i].data[j]['people_fully_vaccinated'];
            }
          }
          //total full vacc, daily vacc 구하기
          flag1 = true;
          //fully_vaccinated
          if (vaccinelist[i].data[j]['people_fully_vaccinated'] != null) {
            if (vaccinelist[i].data[j]['people_fully_vaccinated'] == 0) {
              //값이 0일 경우 전날 데이터로 구하기
              if ((j - 1) >= 0 &&
                  vaccinelist[i].data[j - 1]['people_fully_vaccinated'] !=
                      null) {
                fullyVaccine +=
                vaccinelist[i].data[j-1]['people_fully_vaccinated'];
              } //이 날 값이 0인 경우 제외하므로 여기서 끝내도 ok
            } else
              fullyVaccine += vaccinelist[i].data[j]['people_fully_vaccinated'];
          }
          //daily vaccinated
          if (vaccinelist[i].data[j]['daily_vaccinations'] != null) {
            if (vaccinelist[i].data[j]['daily_vaccinations'] == 0) {
              if ((j - 1) >= 0 &&
                  vaccinelist[i].data[j]['daily_vaccinations'] != null) {
                dailyVaccine += vaccinelist[i].data[j-1]['daily_vaccinations'];
              }
            } else
              dailyVaccine += vaccinelist[i].data[j]['daily_vaccinations'];
          }
          break;
        }
      }
      //일치하는 date가 없을 경우 최신 date사용
      if (!flag) {
        //total_vaccinations 값이 존재할 때
        if (vaccinelist[i].data[cntDate - 1]['total_vaccinations'] != null) {
          totalVaccine +=
          vaccinelist[i].data[cntDate - 1]['total_vaccinations'];
        }
        //total_vaccinations 값이 없을 경우 people_vaccinated or fully_vaccinated
        else {
          if (vaccinelist[i].data[cntDate - 1]['people_vaccinated'] != null) {
            totalVaccine +=
            vaccinelist[i].data[cntDate - 1]['people_vaccinated'];
          } else if (vaccinelist[i].data[cntDate - 1]
          ['people_fully_vaccinated'] !=
              null) {
            totalVaccine +=
            vaccinelist[i].data[cntDate - 1]['people_fully_vaccinated'];
          }
        }
      }
      //최신 date 사용
      if (!flag1) {
        if (vaccinelist[i].data[cntDate - 1]['people_fully_vaccinated'] !=
            null) {
          //그 값이 0인경우 그 전날 데이터 사용하기
          if (vaccinelist[i].data[cntDate - 1]['people_fully_vaccinated'] ==
              0) {
            if ((cntDate - 2) >= 0 &&
                vaccinelist[i].data[cntDate - 2]['people_fully_vaccinated'] !=
                    null) {
              fullyVaccine +=
              vaccinelist[i].data[cntDate - 2]['people_fully_vaccinated'];
            }
          } else
            fullyVaccine +=
            vaccinelist[i].data[cntDate - 1]['people_fully_vaccinated'];
        } else {
          //최신 날짜에 fully_vaccinated가 없을 경우 그 전날꺼
          if ((cntDate - 2) >= 0 &&
              vaccinelist[i].data[cntDate - 2]['people_fully_vaccinated'] !=
                  null) {
            fullyVaccine +=
            vaccinelist[i].data[cntDate - 2]['people_fully_vaccinated'];
          } //0이거 없을경우 excluded
        }

        if (vaccinelist[i].data[cntDate - 1]['daily_vaccinations'] != null) {
          //그 값이 0인경우 그 전날 데이터 사용하기
          if (vaccinelist[i].data[cntDate - 1]['daily_vaccinations'] == 0) {
            if ((cntDate - 2) >= 0 &&
                vaccinelist[i].data[cntDate - 2]['daily_vaccinations'] !=
                    null) {
              dailyVaccine +=
              vaccinelist[i].data[cntDate - 2]['daily_vaccinations'];
            }
          } else
            dailyVaccine +=
            vaccinelist[i].data[cntDate - 1]['daily_vaccinations'];
        } else {
          //최신 날짜에 fully_vaccinated가 없을 경우 그 전날꺼
          if ((cntDate - 2) >= 0 &&
              vaccinelist[i].data[cntDate - 2]['daily_vaccinations'] != null) {
            dailyVaccine +=
            vaccinelist[i].data[cntDate - 2]['daily_vaccinations'];
          } //0이거 없을경우 excluded
        }
      }
    }
    return VaccineData(
        totalVaccine: totalVaccine.toString(),
        fullyVaccine: fullyVaccine.toString(),
        dailyVaccine: dailyVaccine.toString(),
        date: latestDate);
    //return Vaccine.fromJson(realtime);
  } else {
    throw Exception('Faile to load deathsPage');
  }
}

Future<VaccineList> fetchVaccineList() async {
  final url =
      'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json';
  final response = await http.get(url);
  List<double> list1 = [];
  List<double> list2 = [];
  List<double> list3 = [];
  List<double> list4 = [];
  if (response.statusCode == 200) {
    final realtime = jsonDecode(response.body);
    var len = realtime.length;
    var KoreaIndex;
    double totalVaccine = 0;
    double dailyVaccine = 0;
    for (int i = 0; i < len; i++) {
      if (realtime[i]['country'] == "South Korea") {
        KoreaIndex = i;
        break;
      }
    }
    List<Vaccine> vaccinelist = [];

    for (int i = 0; i < len; i++) {
      vaccinelist.add(Vaccine.fromJson(realtime[i]));
    }
    var numOfDate = realtime[KoreaIndex]['data'].length;
    var curDate = realtime[KoreaIndex]['data'][numOfDate - 1]['date'];
    //29일동안
    for (int i = 1; i <= 29; i++) {
      //date 맞추기
      var latestDate = realtime[KoreaIndex]['data'][numOfDate - i]['date'];
      totalVaccine = 0;
      dailyVaccine = 0;
      for (int j = 0; j < len; j++) {
        int cntDate = vaccinelist[j].data.length;
        bool flag = false;
        bool flag1 = false;
        for (int k = cntDate - 1; k >= 0; k--) {
          if (vaccinelist[j].data[k]['date'] == latestDate) {
            flag = true;
            //total_vaccinations 값이 존재할 때
            if (vaccinelist[j].data[k]['total_vaccinations'] != null) {
              totalVaccine += vaccinelist[j].data[k]['total_vaccinations'];
            }
            //total_vaccinations 값이 없을 경우 people_vaccinated or fully_vaccinated
            else {
              if (vaccinelist[j].data[k]['people_vaccinated'] != null) {
                totalVaccine += vaccinelist[j].data[k]['people_vaccinated'];
              } else if (vaccinelist[j].data[k]['people_fully_vaccinated'] !=
                  null) {
                totalVaccine +=
                vaccinelist[j].data[k]['people_fully_vaccinated'];
              }
            }
            //total full vacc, daily vacc 구하기
            flag1 = true;
            //daily vaccinated
            if (vaccinelist[j].data[k]['daily_vaccinations'] != null) {
              if (vaccinelist[j].data[k]['daily_vaccinations'] == 0) {
                if ((k - 1) >= 0 &&
                    vaccinelist[j].data[k]['daily_vaccinations'] != null) {
                  dailyVaccine += vaccinelist[j].data[k]['daily_vaccinations'];
                }
              } else
                dailyVaccine += vaccinelist[j].data[k]['daily_vaccinations'];
            }
            break;
          }
        }
        //일치하는 date가 없을 경우 최신 date사용
        if (!flag) {
          //total_vaccinations 값이 존재할 때
          if ((cntDate - i) >= 0 &&
              vaccinelist[j].data[cntDate - i]['total_vaccinations'] != null) {
            totalVaccine +=
            vaccinelist[j].data[cntDate - i]['total_vaccinations'];
          }
          //total_vaccinations 값이 없을 경우 people_vaccinated or fully_vaccinated
          else {
            if ((cntDate - i) >= 0 &&
                vaccinelist[j].data[cntDate - i]['people_vaccinated'] != null) {
              totalVaccine +=
              vaccinelist[j].data[cntDate - i]['people_vaccinated'];
            } else if ((cntDate - i) >= 0 &&
                vaccinelist[j].data[cntDate - i]['people_fully_vaccinated'] !=
                    null) {
              totalVaccine +=
              vaccinelist[j].data[cntDate - i]['people_fully_vaccinated'];
            }
          }
        }
        //최신 date 사용
        if (!flag1) {
          if ((cntDate - i) >= 0 &&
              vaccinelist[j].data[cntDate - i]['daily_vaccinations'] != null) {
            //그 값이 0인경우 그 전날 데이터 사용하기
            if ((cntDate - i) >= 0 &&
                vaccinelist[j].data[cntDate - i]['daily_vaccinations'] == 0) {
              if ((cntDate - i - 1) >= 0 &&
                  vaccinelist[j].data[cntDate - i - 1]['daily_vaccinations'] !=
                      null) {
                dailyVaccine +=
                vaccinelist[j].data[cntDate - i - 1]['daily_vaccinations'];
              }
            } else if ((cntDate - i) >= 0) {
              dailyVaccine +=
              vaccinelist[j].data[cntDate - i]['daily_vaccinations'];
            }
          } else {
            //최신 날짜에 fully_vaccinated가 없을 경우 그 전날꺼
            if ((cntDate - i - 1) >= 0 &&
                vaccinelist[j].data[cntDate - i - 1]['daily_vaccinations'] !=
                    null) {
              dailyVaccine +=
              vaccinelist[j].data[cntDate - i - 1]['daily_vaccinations'];
            } //0이거 없을경우 excluded
          }
        }
      }
      list3.add(totalVaccine);
      list4.add(dailyVaccine);
    }
    for (int i = 0; i < 7; i++) {
      list1.add(list3[i]);
      list2.add(list4[i]);
    }
    List<String> list0 = curDate.split('-');
    String tossDate = list0[0] + list0[1] + list0[2];
    double finalDate = double.parse(tossDate);
    int ddd = finalDate.toInt();
    return VaccineList(
        graph1Data: list1,
        graph2Data: list2,
        graph3Data: list3,
        graph4Data: list4,
        date: finalDate);
  } else {
    throw Exception('Faile to load deathsPage');
  }
}

Future<Vaccine3Table> fetchVaccine3rdTable() async {
  final url =
      'https://raw.githubusercontent.com/owid/covid-19-data/master/public/data/vaccinations/vaccinations.json';
  final response = await http.get(url);
  final realtime = jsonDecode(response.body);
  var len = realtime.length;
  var KoreaIndex;
  List<Vaccine3rdTable> list1 = [];
  List<Vaccine3rdTable> list2 = [];
  List<Vaccine3rdTable> list3 = [];
  if (response.statusCode == 200) {
    for (int i = 0; i < len; i++) {
      if (realtime[i]['country'] == "South Korea") {
        KoreaIndex = i;
        break;
      }
    }
    List<Vaccine> vaccinelist = [];
    for (int i = 0; i < len; i++) {
      vaccinelist.add(Vaccine.fromJson(realtime[i]));
    }
    var numOfDate = realtime[KoreaIndex]['data'].length;
    var latestDate = realtime[KoreaIndex]['data'][numOfDate - 1]['date'];
    bool flag = false;
    for (int i=0; i<len; i++) {
      int cntDate = vaccinelist[i].data.length;
      flag = false;
      for (int j = cntDate - 1; j >= 0; j--) {
        //최신 날짜
        if (vaccinelist[i].data[j]['date'] == latestDate){
          flag = true;
          String tempCountry = vaccinelist[i].country;
          String tempTotalVaccine = vaccinelist[i].data[j]['total_vaccinations']!=null ? vaccinelist[i].data[j]['total_vaccinations'].toString() : "null";
          String tempFullyVaccine = vaccinelist[i].data[j]['people_fully_vaccinated']!=null ? vaccinelist[i].data[j]['people_fully_vaccinated'].toString() : "null";
          String tempDailyVaccine = vaccinelist[i].data[j]['daily_vaccinations']!=null ? vaccinelist[i].data[j]['daily_vaccinations'].toString() : "null";
          list2.add(Vaccine3rdTable(country: tempCountry, totalVaccine: tempTotalVaccine, fullyVaccine: tempFullyVaccine, dailyVaccine: tempDailyVaccine));
          break;
        }
      }
      if(!flag){
        //가장 최신날짜 가져오기
        if(cntDate-1>=0) {
          String tempCountry = vaccinelist[i].country;
          String tempTotalVaccine = vaccinelist[i].data[cntDate -
              1]['total_vaccinations'] != null ? vaccinelist[i].data[cntDate -
              1]['total_vaccinations'].toString() : "null";
          String tempFullyVaccine = vaccinelist[i].data[cntDate -
              1]['people_fully_vaccinated'] != null ? vaccinelist[i].data[cntDate -
              1]['people_fully_vaccinated'].toString() : "null";
          String tempDailyVaccine = vaccinelist[i].data[cntDate -
              1]['daily_vaccinations'] != null ? vaccinelist[i].data[cntDate -
              1]['daily_vaccinations'].toString() : "null";
          list2.add(Vaccine3rdTable(country: tempCountry,
              totalVaccine: tempTotalVaccine,
              fullyVaccine: tempFullyVaccine,
              dailyVaccine: tempDailyVaccine));
        }
      }
    }
    for(int i=0;i<7;i++){
      list1.add(list2[i]);
    }
    for(int i=0;i<7;i++){
      int max = 0;
      int max_index = 0;
      for(int j=0;j<len - i;j++){
        if(list2[j].totalVaccine != "null"){
          if(int.parse(list2[j].totalVaccine) > max){
            max = int.parse(list2[j].totalVaccine);
            max_index = j;
          }
        }
      }
      list3.add(list2[max_index]);
      list2.removeAt(max_index);
    }

    return Vaccine3Table(countryList: list1, vaccineList: list3);

  } else{
    throw Exception('Faile to load deathsPage');
  }
}

class Vaccine {
  final country;
  final iso_code;
  final List data;

  Vaccine(
      {@required this.country, @required this.iso_code, @required this.data});

  factory Vaccine.fromJson(Map<String, dynamic> json) {
    return Vaccine(
        country: json['country'],
        iso_code: json['iso_code'],
        data: json['data']);
  }
}

class VaccineList {
  final List<double> graph1Data;
  final List<double> graph2Data;
  final List<double> graph3Data;
  final List<double> graph4Data;
  final double date;

  VaccineList(
      {@required this.graph1Data,
        @required this.graph2Data,
        @required this.graph3Data,
        @required this.graph4Data,
        @required this.date});
}

class VaccineData {
  final totalVaccine;
  final fullyVaccine;
  final dailyVaccine;
  final date;

  VaccineData(
      {@required this.totalVaccine,
        @required this.fullyVaccine,
        @required this.dailyVaccine,
        @required this.date});
}

class Vaccine3Table {
  final List countryList;
  final List vaccineList;

  Vaccine3Table ({
    @required this.countryList,
    @required this.vaccineList,
  });
}

class Vaccine3rdTable {
  final country;
  final totalVaccine;
  final fullyVaccine;
  final dailyVaccine;

  Vaccine3rdTable({
    @required this.country,
    @required this.totalVaccine,
    @required this.fullyVaccine,
    @required this.dailyVaccine,
  });
}

class vaccine extends StatelessWidget {
  String logid;
  String cur_page = 'Vaccine Page';

  vaccine({Key key, this.logid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: '2015311771 KangGyeongUn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => vaccinePage(logid: logid, cur_page: cur_page),
        '/navi' : (context) => NavigationPage(logid: logid, previousPage: cur_page),
      },
      initialRoute: '/',
    );
    throw UnimplementedError();
  }
}

class vaccinePage extends StatelessWidget {
  String logid;
  String cur_page = 'Vaccine Page';

  vaccinePage({Key key, this.logid, this.cur_page}) : super(key: key);
  Future<Vaccine> futureVaccine;
  bool check = false;

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      body: Center(
          child: ChangeNotifierProvider(
            create: (_) => StatelessNotifier(),
            child: Consumer<StatelessNotifier>(
              builder: (_,model,__) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    FutureBuilder(
                      future: fetchVaccine(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final totalVaccine = snapshot.data.totalVaccine;
                          final fullyVaccine = snapshot.data.fullyVaccine;
                          final dailyVaccine = snapshot.data.dailyVaccine;
                          final date = snapshot.data.date;
                          return Container(
                            width: 360,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        'Total Vacc.',
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        'Parsed latest date',
                                        textAlign: TextAlign.right,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        totalVaccine + ' people',
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        date,
                                        textAlign: TextAlign.right,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        'Total fully Vacc.',
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        'Daily Vacc.',
                                        textAlign: TextAlign.right,
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 40,
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        fullyVaccine + ' people',
                                        textAlign: TextAlign.left,
                                      ),
                                    ),
                                    SizedBox(
                                      width: 135,
                                      child: Text(
                                        dailyVaccine + ' people',
                                        textAlign: TextAlign.right,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    Text('\n'),
                    FutureBuilder(
                      future: fetchVaccineList(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final List<double> graph1List = snapshot.data.graph1Data;
                          final List<double> graph2List = snapshot.data.graph2Data;
                          final List<double> graph3List = snapshot.data.graph3Data;
                          final List<double> graph4List = snapshot.data.graph4Data;
                          final double latestDate = snapshot.data.date;
                          return Container(
                            width: 360,
                            decoration: BoxDecoration(
                              border: Border.all(
                                width: 2,
                                color: Colors.grey,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: <Widget>[
                                Row(
                                  children: <Widget>[
                                    FlatButton(
                                        onPressed: () {
                                          model.setGraphNum = 1;
                                        },
                                        child: Text(
                                          'Graph1',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        )),
                                    FlatButton(
                                        onPressed: () {
                                          model.setGraphNum = 2;
                                        },
                                        child: Text(
                                          'Graph2',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        )),
                                    FlatButton(
                                        onPressed: () {
                                          model.setGraphNum = 3;
                                        },
                                        child: Text(
                                          'Graph3',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        )),
                                    FlatButton(
                                        onPressed: () {
                                          model.setGraphNum = 4;
                                        },
                                        child: Text(
                                          'Graph4',
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        )),
                                  ],
                                ),
                                Divider(
                                  thickness: 2,
                                  color: Colors.grey,
                                ),
                                AspectRatio(
                                  aspectRatio: 3 / 2,
                                  child: Container(
                                    child: Padding(
                                      padding: EdgeInsets.symmetric(
                                          vertical: 10, horizontal: 20),
                                      child: LineChart(
                                        model.isNum==1 ? graph1Chart(graph1List, latestDate) :
                                        model.isNum==2 ? graph2Chart(graph2List, latestDate) :
                                        model.isNum==3 ? graph3Chart(graph3List, latestDate) :
                                        graph4Chart(graph4List, latestDate),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    ),
                    Text('\n'),
                    FutureBuilder(
                        future: fetchVaccine3rdTable(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final List<Vaccine3rdTable> list3_1 = snapshot.data.countryList;
                            final List<Vaccine3rdTable> list3_2 = snapshot.data.vaccineList;
                            return Container(
                              width: 360,
                              decoration: BoxDecoration(
                                border: Border.all(
                                  width: 2,
                                  color: Colors.grey,
                                ),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                children: <Widget>[
                                  Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 170,
                                        child: FlatButton(
                                            onPressed: () {
                                              model.setValid = true;
                                            },
                                            child: Text(
                                              'Country_name',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            )),
                                      ),
                                      SizedBox(
                                        width: 170,
                                        child: FlatButton(
                                            onPressed: () {
                                              model.setValid = false;
                                            },
                                            child: Text(
                                              'Total_vacc',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            )),
                                      ),
                                    ],
                                  ),
                                  Divider(
                                    thickness: 2,
                                    color: Colors.grey,
                                  ),
                                  Container(
                                    height: 150,
                                    child: ListView.builder(
                                      padding: EdgeInsets.all(0),
                                      scrollDirection: Axis.vertical,
                                      itemCount: 8,
                                      itemBuilder: (BuildContext context, int i) {
                                        if(i==0) return HeaderTile();
                                        if(model.isValid){
                                          return CountryTile(list3_1[i-1].country, list3_1[i-1].totalVaccine,
                                              list3_1[i-1].fullyVaccine, list3_1[i-1].dailyVaccine);
                                        }
                                        else{
                                          return CountryTile(list3_2[i-1].country, list3_2[i-1].totalVaccine,
                                              list3_2[i-1].fullyVaccine, list3_2[i-1].dailyVaccine);
                                        }
                                      },
                                    ),

                                  )
                                ],
                              ),
                            );
                          } else if (snapshot.hasError) {
                            return Text("${snapshot.error}");
                          }
                          return CircularProgressIndicator();
                        }
                    )

                  ],
                );
              },
            ),
          )
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:(){
          Navigator.pushReplacement(context, new MaterialPageRoute(
              builder: (context) => new NavigationPage(logid: logid, previousPage: cur_page))
          );
        },
        tooltip: 'back',
        child: Icon(Icons.list),
      ),
    );
    throw UnimplementedError();
  }
}

LineChartData graph1Chart(List<double> list, double date) {
  int stringdate = date.toInt() % 10000;
  int month = stringdate ~/ 100;
  int day = stringdate % 100;
  List<String> monthlist = [];
  List<String> daylist = [];
  String date1 = "",
      date2 = "",
      date3 = "",
      date4 = "",
      date5 = "",
      date6 = "",
      date7 = "";
  //date1
  for (int i = 0; i < 7; i++) {
    String mm = "";
    String dd = "";
    if (month < 10)
      mm = '0' + month.toString();
    else
      mm = month.toString();
    if (day < 10)
      dd = '0' + day.toString();
    else
      dd = day.toString();
    monthlist.add(mm);
    daylist.add(dd);
    day--;
    if (day <= 0) {
      month--;
      if (month < 0) month = 12;
      if (month == 1 ||
          month == 3 ||
          month == 5 ||
          month == 7 ||
          month == 8 ||
          month == 10 ||
          month == 12) {
        day = 31;
      } else if (month == 2)
        day = 28;
      else
        day = 30;
    }
  }
  date1 = monthlist[0] + '-' + daylist[0];
  date2 = monthlist[1] + '-' + daylist[1];
  date3 = monthlist[2] + '-' + daylist[2];
  date4 = monthlist[3] + '-' + daylist[3];
  date5 = monthlist[4] + '-' + daylist[4];
  date6 = monthlist[5] + '-' + daylist[5];
  date7 = monthlist[6] + '-' + daylist[6];

  return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 15,
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return date7;
              case 2:
                return date6;
              case 3:
                return date5;
              case 4:
                return date4;
              case 5:
                return date3;
              case 6:
                return date2;
              case 7:
                return date1;
            }
            return '';
          },
          margin: 0,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            switch (value.toInt()) {
              case 6000000000:
                return '6B';
              case 7000000000:
                return '7B';
              case 8000000000:
                return '8B';
              case 9000000000:
                return '9B';
            }
            return '';
          },
          margin: 20,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 1,
      maxX: 7,
      minY: 6000000000,
      maxY: 9000000000,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(7, list[0]),
            FlSpot(6, list[1]),
            FlSpot(5, list[2]),
            FlSpot(4, list[3]),
            FlSpot(3, list[4]),
            FlSpot(2, list[5]),
            FlSpot(1, list[6]),
          ],
          isCurved: false,
          colors: [
            const Color(0xff2196f3),
          ],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
        )
      ]);
}

LineChartData graph2Chart(List<double> list, double date) {
  int stringdate = date.toInt() % 10000;
  int month = stringdate ~/ 100;
  int day = stringdate % 100;
  List<String> monthlist = [];
  List<String> daylist = [];
  String date1 = "",
      date2 = "",
      date3 = "",
      date4 = "",
      date5 = "",
      date6 = "",
      date7 = "";
  //date1
  for (int i = 0; i < 7; i++) {
    String mm = "";
    String dd = "";
    if (month < 10)
      mm = '0' + month.toString();
    else
      mm = month.toString();
    if (day < 10)
      dd = '0' + day.toString();
    else
      dd = day.toString();
    monthlist.add(mm);
    daylist.add(dd);
    day--;
    if (day <= 0) {
      month--;
      if (month < 0) month = 12;
      if (month == 1 ||
          month == 3 ||
          month == 5 ||
          month == 7 ||
          month == 8 ||
          month == 10 ||
          month == 12) {
        day = 31;
      } else if (month == 2)
        day = 28;
      else
        day = 30;
    }
  }
  date1 = monthlist[0] + '-' + daylist[0];
  date2 = monthlist[1] + '-' + daylist[1];
  date3 = monthlist[2] + '-' + daylist[2];
  date4 = monthlist[3] + '-' + daylist[3];
  date5 = monthlist[4] + '-' + daylist[4];
  date6 = monthlist[5] + '-' + daylist[5];
  date7 = monthlist[6] + '-' + daylist[6];

  return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return date7;
              case 2:
                return date6;
              case 3:
                return date5;
              case 4:
                return date4;
              case 5:
                return date3;
              case 6:
                return date2;
              case 7:
                return date1;
            }
            return '';
          },
          margin: 0,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            switch (value.toInt()) {
              case 100000000:
                return '100M';
              case 125000000:
                return '125M';
              case 150000000:
                return '150M';
            }
            return '';
          },
          margin: 20,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 1,
      maxX: 7,
      minY: 100000000,
      maxY: 150000000,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(7, list[0]),
            FlSpot(6, list[1]),
            FlSpot(5, list[2]),
            FlSpot(4, list[3]),
            FlSpot(3, list[4]),
            FlSpot(2, list[5]),
            FlSpot(1, list[6]),
          ],
          isCurved: false,
          colors: [
            const Color(0xff2196f3),
          ],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
        )
      ]);
}

LineChartData graph3Chart(List<double> list, double date) {
  int stringdate = date.toInt() % 10000;
  int month = stringdate ~/ 100;
  int day = stringdate % 100;
  List<String> monthlist = [];
  List<String> daylist = [];
  String date1 = "",
      date2 = "",
      date3 = "",
      date4 = "",
      date5 = "";
  //date1
  for (int i = 0; i < 7; i++) {
    String mm = "";
    String dd = "";
    if (month < 10)
      mm = '0' + month.toString();
    else
      mm = month.toString();
    if (day < 10)
      dd = '0' + day.toString();
    else
      dd = day.toString();
    monthlist.add(mm);
    daylist.add(dd);
    day = day - 7;
    if (day <= 0) {
      month--;
      if (month < 0) month = 12;
      if (month == 1 ||
          month == 3 ||
          month == 5 ||
          month == 7 ||
          month == 8 ||
          month == 10 ||
          month == 12) {
        day += 31;
      } else if (month == 2)
        day += 28;
      else
        day += 30;
    }
  }
  date1 = monthlist[0] + '-' + daylist[0];
  date2 = monthlist[1] + '-' + daylist[1];
  date3 = monthlist[2] + '-' + daylist[2];
  date4 = monthlist[3] + '-' + daylist[3];
  date5 = monthlist[4] + '-' + daylist[4];

  return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return date5;
              case 8:
                return date4;
              case 15:
                return date3;
              case 22:
                return date2;
              case 29:
                return date1;
            }
            return '';
          },
          margin: 0,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            switch (value.toInt()) {
              case 4000000000:
                return '4B';
              case 5000000000:
                return '5B';
              case 6000000000:
                return '6B';
              case 7000000000:
                return '7B';
              case 8000000000:
                return '8B';
              case 9000000000:
                return '9B';
            }
            return '';
          },
          margin: 20,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 1,
      maxX: 29,
      minY: 4000000000,
      maxY: 9000000000,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(1, list[28]), FlSpot(2, list[27]), FlSpot(3, list[26]), FlSpot(4, list[25]),
            FlSpot(5, list[24]), FlSpot(6, list[23]), FlSpot(7, list[22]), FlSpot(8, list[21]),
            FlSpot(9, list[20]), FlSpot(10, list[19]), FlSpot(11, list[18]), FlSpot(12, list[17]),
            FlSpot(13, list[16]), FlSpot(14, list[15]), FlSpot(15, list[14]), FlSpot(16, list[13]),
            FlSpot(17, list[12]), FlSpot(18, list[11]), FlSpot(19, list[10]), FlSpot(20, list[9]),
            FlSpot(21, list[8]), FlSpot(22, list[7]), FlSpot(23, list[6]), FlSpot(24, list[5]),
            FlSpot(25, list[4]), FlSpot(26, list[3]), FlSpot(27, list[2]), FlSpot(28, list[1]),
            FlSpot(29, list[0]),
          ],
          isCurved: false,
          colors: [
            const Color(0xff2196f3),
          ],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
        )
      ]);
}

LineChartData graph4Chart(List<double> list, double date) {
  int stringdate = date.toInt() % 10000;
  int month = stringdate ~/ 100;
  int day = stringdate % 100;
  List<String> monthlist = [];
  List<String> daylist = [];
  String date1 = "",
      date2 = "",
      date3 = "",
      date4 = "",
      date5 = "";
  //date1
  for (int i = 0; i < 7; i++) {
    String mm = "";
    String dd = "";
    if (month < 10)
      mm = '0' + month.toString();
    else
      mm = month.toString();
    if (day < 10)
      dd = '0' + day.toString();
    else
      dd = day.toString();
    monthlist.add(mm);
    daylist.add(dd);
    day = day - 7;
    if (day <= 0) {
      month--;
      if (month < 0) month = 12;
      if (month == 1 ||
          month == 3 ||
          month == 5 ||
          month == 7 ||
          month == 8 ||
          month == 10 ||
          month == 12) {
        day += 31;
      } else if (month == 2)
        day += 28;
      else
        day += 30;
    }
  }
  date1 = monthlist[0] + '-' + daylist[0];
  date2 = monthlist[1] + '-' + daylist[1];
  date3 = monthlist[2] + '-' + daylist[2];
  date4 = monthlist[3] + '-' + daylist[3];
  date5 = monthlist[4] + '-' + daylist[4];

  return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey,
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 25,
          getTitles: (value) {
            switch (value.toInt()) {
              case 1:
                return date5;
              case 8:
                return date4;
              case 15:
                return date3;
              case 22:
                return date2;
              case 29:
                return date1;
            }
            return '';
          },
          margin: 0,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTitles: (value) {
            switch (value.toInt()) {
              case 50000000:
                return '50M';
              case 75000000:
                return '75M';
              case 100000000:
                return '100M';
              case 125000000:
                return '125M';
              case 150000000:
                return '150M';
            }
            return '';
          },
          margin: 20,
        ),
      ),
      borderData: FlBorderData(
        show: false,
      ),
      minX: 1,
      maxX: 29,
      minY: 50000000,
      maxY: 150000000,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(1, list[28]), FlSpot(2, list[27]), FlSpot(3, list[26]), FlSpot(4, list[25]),
            FlSpot(5, list[24]), FlSpot(6, list[23]), FlSpot(7, list[22]), FlSpot(8, list[21]),
            FlSpot(9, list[20]), FlSpot(10, list[19]), FlSpot(11, list[18]), FlSpot(12, list[17]),
            FlSpot(13, list[16]), FlSpot(14, list[15]), FlSpot(15, list[14]), FlSpot(16, list[13]),
            FlSpot(17, list[12]), FlSpot(18, list[11]), FlSpot(19, list[10]), FlSpot(20, list[9]),
            FlSpot(21, list[8]), FlSpot(22, list[7]), FlSpot(23, list[6]), FlSpot(24, list[5]),
            FlSpot(25, list[4]), FlSpot(26, list[3]), FlSpot(27, list[2]), FlSpot(28, list[1]),
            FlSpot(29, list[0]),
          ],
          isCurved: false,
          colors: [
            const Color(0xff2196f3),
          ],
          barWidth: 2,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
        )
      ]);
}

