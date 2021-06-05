import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:pa3/notifiler_model.dart';
import 'package:pa3/Tile.dart';
import 'package:pa3/Pages/NavigationPage.dart';

Future<CasesData> fetchCases() async {
  final url = 'https://covid.ourworldindata.org/data/owid-covid-data.json';
  final response = await http.get(url);
  final List<Cases> caseslist = [];
  List<double> list1 = [];
  List<double> list2 = [];
  List<double> list3 = [];
  List<double> list4 = [];
  List<Case3rdTable> list5 = [];
  List<Case3rdTable> list6 = [];
  List<Case3rdTable> list7 = [];
  List<Case3rdTable> list8 = [];

  if (response.statusCode == 200) {
    final realtime = jsonDecode(response.body);
    realtime.values.forEach((k) => caseslist.add(Cases.fromJson(k)));
    var len = caseslist.length;
    var koreaIndex;
    var total_cases1 = 0.0;
    var total_deaths1 = 0.0;
    var daily_cases1 = 0.0;
    for(int i=0; i<len; i++){
      if(caseslist[i].location == "South Korea"){
        koreaIndex = i;
        break;
      }
    }
    var datelen = caseslist[koreaIndex].data.length;
    var latestDate = caseslist[koreaIndex].data[datelen-1]['date'];
    var korealatestDate = caseslist[koreaIndex].data[datelen-1]['date'];

    for(int i=0;i<len; i++){
      int cntDate = caseslist[i].data.length;
      bool flag = false;
      bool flag1 = false;
      for (int j = cntDate - 1; j >= 0; j--) {
        //date가 일치할 시
        if (caseslist[i].data[j]['date'] == latestDate) {
          flag = true;
          //total_cases 값이 존재할 때
          if (caseslist[i].data[j]['total_cases'] != null) {
            total_cases1 += caseslist[i].data[j]['total_cases'];
          }
          //total_cases 값이 없을 경우 그 전날 데이터 이용
          else {
            if ((j-1)>= 0 && caseslist[i].data[j-1]['total_cases'] != null) {
              total_cases1 += caseslist[i].data[j-1]['total_cases'];
            }
          }
          //total_deaths, daily vacc 구하기
          flag1 = true;
          //total_deaths
          if (caseslist[i].data[j]['total_deaths'] != null) {
            if (caseslist[i].data[j]['total_deaths'] == 0) {
              //값이 0일 경우 전날 데이터로 구하기
              if ((j - 1) >= 0 &&
                  caseslist[i].data[j - 1]['total_deaths'] !=
                      null) {
                total_deaths1 +=
                caseslist[i].data[j-1]['total_deaths'];
              } //이 날 값이 0인 경우 제외하므로 여기서 끝내도 ok
            } else
              total_deaths1 += caseslist[i].data[j]['total_deaths'];
          }
          //daily vaccinated
          if (caseslist[i].data[j]['new_cases'] != null) {
            if (caseslist[i].data[j]['new_cases'] == 0) {
              if ((j - 1) >= 0 &&
                  caseslist[i].data[j]['new_cases'] != null) {
                daily_cases1 += caseslist[i].data[j-1]['new_cases'];
              }
            } else
              daily_cases1 += caseslist[i].data[j]['new_cases'];
          }
          break;
        }
        if (!flag) {
          //total_vaccinations 값이 존재할 때
          if (caseslist[i].data[cntDate - 1]['total_cases'] != null) {
            total_cases1 +=
            caseslist[i].data[cntDate - 1]['total_cases'];
          }
          else {
            if ((cntDate-2)>=0 && caseslist[i].data[cntDate - 2]['total_cases'] != null) {
              total_cases1 +=
              caseslist[i].data[cntDate - 2]['total_cases'];
            }
          }
        }
        //최신 date 사용
        if (!flag1) {
          if (caseslist[i].data[cntDate - 1]['total_deaths'] !=
              null) {
            //그 값이 0인경우 그 전날 데이터 사용하기
            if (caseslist[i].data[cntDate - 1]['total_deaths'] ==
                0) {
              if ((cntDate - 2) >= 0 &&
                  caseslist[i].data[cntDate - 2]['total_deaths'] !=
                      null) {
                total_deaths1 +=
                caseslist[i].data[cntDate - 2]['total_deaths'];
              }
            } else
              total_deaths1 +=
              caseslist[i].data[cntDate - 1]['total_deaths'];
          } else {
            //최신 날짜에 fully_vaccinated가 없을 경우 그 전날꺼
            if ((cntDate - 2) >= 0 &&
                caseslist[i].data[cntDate - 2]['total_deaths'] !=
                    null) {
              total_deaths1 +=
              caseslist[i].data[cntDate - 2]['total_deaths'];
            } //0이거 없을경우 excluded
          }

          if (caseslist[i].data[cntDate - 1]['new_cases'] != null) {
            //그 값이 0인경우 그 전날 데이터 사용하기
            if (caseslist[i].data[cntDate - 1]['new_cases'] == 0) {
              if ((cntDate - 2) >= 0 &&
                  caseslist[i].data[cntDate - 2]['new_cases'] !=
                      null) {
                daily_cases1 +=
                caseslist[i].data[cntDate - 2]['new_cases'];
              }
            } else
              daily_cases1 +=
              caseslist[i].data[cntDate - 1]['new_cases'];
          } else {
            //최신 날짜에 fully_vaccinated가 없을 경우 그 전날꺼
            if ((cntDate - 2) >= 0 &&
                caseslist[i].data[cntDate - 2]['new_cases'] != null) {
              daily_cases1 +=
              caseslist[i].data[cntDate - 2]['new_cases'];
            } //0이거 없을경우 excluded
          }
        }
      }
    }
    var total_cases = 0.0;
    var daily_cases = 0.0;
    //29일동안
    for (int i = 1; i <= 29; i++) {
      var latestDate = caseslist[koreaIndex].data[datelen - i]['date'];
      total_cases = 0;
      daily_cases = 0;
      for (int j = 0; j < len; j++) {
        int cntDate = caseslist[j].data.length;
        bool flag = false;
        bool flag1 = false;
        for (int k = cntDate - 1; k >= 0; k--) {
          if (caseslist[j].data[k]['date'] == latestDate) {
            flag = true;
            //total_vaccinations 값이 존재할 때
            if (caseslist[j].data[k]['total_cases'] != null && caseslist[j].data[k]['total_cases']>0) {
              total_cases += caseslist[j].data[k]['total_cases'];
            }
            else {
              if ((k-1) >= 0 && caseslist[j].data[k-1]['total_cases'] != null) {
                total_cases += caseslist[j].data[k-1]['total_cases'];
              }
            }
            //total full vacc, daily vacc 구하기
            flag1 = true;
            //daily vaccinated
            if (caseslist[j].data[k]['new_cases'] != null) {
              if (caseslist[j].data[k]['new_cases'] == 0) {
                if ((k - 1) >= 0 &&
                    caseslist[j].data[k]['new_cases'] != null) {
                  daily_cases += caseslist[j].data[k]['new_cases'];
                }
              } else
                daily_cases += caseslist[j].data[k]['new_cases'];
            }
            break;
          }
        }
        //일치하는 date가 없을 경우 최신 date사용
        if (!flag) {
          //total_vaccinations 값이 존재할 때
          if ((cntDate - i) >= 0 &&
              caseslist[j].data[cntDate - i]['total_cases'] != null) {
            total_cases +=
            caseslist[j].data[cntDate - i]['total_cases'];
          }
          //total_vaccinations 값이 없을 경우 people_vaccinated or fully_vaccinated
          else {
            if ((cntDate - i -1) >= 0 &&
                caseslist[j].data[cntDate - i-1]['total_cases'] != null) {
              total_cases +=
              caseslist[j].data[cntDate - i-1]['total_cases'];
            } /*else if ((cntDate - i-) >= 0 &&
                caseslist[j].data[cntDate - i]['total_cases'] !=
                    null) {
              total_cases +=
              caseslist[j].data[cntDate - i]['total_cases'];
            }*/
          }
        }
        //최신 date 사용
        if (!flag1) {
          if ((cntDate - i) >= 0 &&
              caseslist[j].data[cntDate - i]['new_cases'] != null) {
            //그 값이 0인경우 그 전날 데이터 사용하기
            if ((cntDate - i) >= 0 &&
                caseslist[j].data[cntDate - i]['new_cases'] == 0) {
              if ((cntDate - i - 1) >= 0 &&
                  caseslist[j].data[cntDate - i - 1]['new_cases'] !=
                      null) {
                daily_cases +=
                caseslist[j].data[cntDate - i - 1]['new_cases'];
              }
            } else if ((cntDate - i) >= 0) {
              daily_cases +=
              caseslist[j].data[cntDate - i]['new_cases'];
            }
          } else {
            //최신 날짜에 fully_vaccinated가 없을 경우 그 전날꺼
            if ((cntDate - i - 1) >= 0 &&
                caseslist[j].data[cntDate - i - 1]['new_cases'] !=
                    null) {
              daily_cases +=
              caseslist[j].data[cntDate - i - 1]['new_cases'];
            } //0이거 없을경우 excluded
          }
        }
      }
      list3.add(total_cases);
      list4.add(daily_cases);
    }
    for (int i = 0; i < 7; i++) {
      list1.add(list3[i]);
      list2.add(list4[i]);
    }
    List<String> list0 = korealatestDate.split('-');
    String tossDate = list0[0] + list0[1] + list0[2];
    double finalDate = double.parse(tossDate);
    bool flag = false;
    for (int i=0; i<len; i++) {
      int cntDate = caseslist[i].data.length;
      flag = false;
      for (int j = cntDate - 1; j >= 0; j--) {
        //최신 날짜
        if (caseslist[i].data[j]['date'] == latestDate){
          flag = true;
          String tempCountry = caseslist[i].location;
          String tempTotalCases = caseslist[i].data[j]['total_cases']!=null ? caseslist[i].data[j]['total_cases'].toInt().toString() : "null";
          String tempTotalDeaths = caseslist[i].data[j]['total_deaths']!=null ? caseslist[i].data[j]['total_deaths'].toInt().toString() : "null";
          String tempDailyCases = caseslist[i].data[j]['new_cases']!=null ? caseslist[i].data[j]['new_cases'].toInt().toString() : "null";
          list6.add(Case3rdTable(country: tempCountry, totalCases: tempTotalCases, totalDeaths: tempTotalDeaths, dailyCases: tempDailyCases));
          list8.add(Case3rdTable(country: tempCountry, totalCases: tempTotalCases, totalDeaths: tempTotalDeaths, dailyCases: tempDailyCases));
          break;
        }
      }
      if(!flag){
        //가장 최신날짜 가져오기
        if(cntDate-1>=0) {
          String tempCountry = caseslist[i].location;
          String tempTotalCases = caseslist[i].data[cntDate -
              1]['total_cases'] != null ? caseslist[i].data[cntDate -
              1]['total_cases'].toInt().toString() : "null";
          String tempTotalDeaths = caseslist[i].data[cntDate -
              1]['total_deaths'] != null ? caseslist[i].data[cntDate -
              1]['total_deaths'].toInt().toString() : "null";
          String tempDailyCases = caseslist[i].data[cntDate -
              1]['new_cases'] != null ? caseslist[i].data[cntDate -
              1]['new_cases'].toInt().toString() : "null";
          list6.add(Case3rdTable(country: tempCountry, totalCases: tempTotalCases, totalDeaths: tempTotalDeaths, dailyCases: tempDailyCases));
          list8.add(Case3rdTable(country: tempCountry, totalCases: tempTotalCases, totalDeaths: tempTotalDeaths, dailyCases: tempDailyCases));
        }
      }
    }
    for(int i=0;i<7;i++){
      int max = 0;
      int max_index = 0;
      for(int j=0;j<list6.length;j++){
        if(list6[j].totalCases != "null"){
          if(int.parse(list6[j].totalCases) > max){
            max = int.parse(list6[j].totalCases);
            max_index = j;
          }
        }
      }
      list7.add(list6[max_index]);
      list6.removeAt(max_index);
    }
    for(int i=0;i<7;i++){
      int max = 0;
      int max_index = 0;
      for(int j=0;j<list8.length;j++){
        if(list8[j].totalDeaths != "null"){
          if(int.parse(list8[j].totalDeaths) > max){
            max = int.parse(list8[j].totalDeaths);
            max_index = j;
          }
        }
      }
      list5.add(list8[max_index]);
      list8.removeAt(max_index);
    }
    return CasesData(totalcases: total_cases1.toInt().toString(), totaldeaths: total_deaths1.toInt().toString(),
        dailycases: daily_cases1.toInt().toString(), date: latestDate,graph1Data: list1,
        graph2Data: list2,
        graph3Data: list3,
        graph4Data: list4,
        date1: finalDate,
        caseList: list7, deathList: list5
    );
  } else {
    throw Exception('Faile to load deathsPage');
  }
}

class Cases {
  final location;
  final List data;

  Cases(
      {@required this.location, @required this.data});

  factory Cases.fromJson(Map<String, dynamic> json) {
    return Cases(
        location: json['location'],
        data: json['data']);
  }
}

class CasesData {
  final totalcases;
  final totaldeaths;
  final dailycases;
  final date;
  final List<double> graph1Data;
  final List<double> graph2Data;
  final List<double> graph3Data;
  final List<double> graph4Data;
  final double date1;
  final List caseList;
  final List deathList;

  CasesData(
      {@required this.totalcases,
        @required this.totaldeaths,
        @required this.dailycases,
        @required this.date,
        @required this.graph1Data,
        @required this.graph2Data,
        @required this.graph3Data,
        @required this.graph4Data,
        @required this.date1,
        @required this.caseList,
        @required this.deathList,
      });
}

class Case3rdTable {
  final country;
  final totalCases;
  final totalDeaths;
  final dailyCases;

  Case3rdTable({
    @required this.country,
    @required this.totalCases,
    @required this.totalDeaths,
    @required this.dailyCases,
  });
}

class cases extends StatelessWidget {
  String logid;
  String cur_page = 'Cases/Deaths Page';

  cases({Key key, this.logid}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return MaterialApp(
      title: '2015311771 KangGyeongUn',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => casePage(logid: logid, cur_page: cur_page),
        '/navi' : (context) => NavigationPage(logid: logid, previousPage: cur_page),
      },
      initialRoute: '/',
    );
    throw UnimplementedError();
  }
}

class casePage extends StatelessWidget {
  String logid;
  String cur_page;

  casePage({Key key, this.logid, this.cur_page}) : super(key: key);
  Future<Cases> futureVaccine;
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
                      future: fetchCases(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          final totalcases = snapshot.data.totalcases;
                          final totaldeaths = snapshot.data.totaldeaths;
                          final dailycases = snapshot.data.dailycases;
                          final date = snapshot.data.date;
                          final List<double> graph1List = snapshot.data.graph1Data;
                          final List<double> graph2List = snapshot.data.graph2Data;
                          final List<double> graph3List = snapshot.data.graph3Data;
                          final List<double> graph4List = snapshot.data.graph4Data;
                          final double latestDate = snapshot.data.date1;
                          final List<Case3rdTable> list3_1 = snapshot.data.caseList;
                          final List<Case3rdTable> list3_2 = snapshot.data.deathList;
                          return Column(
                            children: [
                              Container(
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
                                            'Total Cases.',
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
                                            totalcases + ' people',
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
                                            'Total Deaths.',
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 135,
                                          child: Text(
                                            'Daily Cases.',
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
                                            totaldeaths + ' people',
                                            textAlign: TextAlign.left,
                                          ),
                                        ),
                                        SizedBox(
                                          width: 135,
                                          child: Text(
                                            dailycases + ' people',
                                            textAlign: TextAlign.right,
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Text('\n'),
                              Container(
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
                                              model.setcaseNum = 1;
                                            },
                                            child: Text(
                                              'Graph1',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            )),
                                        FlatButton(
                                            onPressed: () {
                                              model.setcaseNum = 2;
                                            },
                                            child: Text(
                                              'Graph2',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            )),
                                        FlatButton(
                                            onPressed: () {
                                              model.setcaseNum = 3;
                                            },
                                            child: Text(
                                              'Graph3',
                                              style: TextStyle(
                                                color: Colors.blue,
                                              ),
                                            )),
                                        FlatButton(
                                            onPressed: () {
                                              model.setcaseNum = 4;
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
                                            model.iscase==1 ? graph1Chart(graph1List, latestDate) :
                                            model.iscase==2 ? graph2Chart(graph2List, latestDate) :
                                            model.iscase==3 ? graph3Chart(graph3List, latestDate) :
                                            graph4Chart(graph4List, latestDate),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Text('\n'),
                              Container(
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
                                                model.setcaseValid = true;
                                              },
                                              child: Text(
                                                'Total Cases',
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                ),
                                              )),
                                        ),
                                        SizedBox(
                                          width: 170,
                                          child: FlatButton(
                                              onPressed: () {
                                                model.setcaseValid = false;
                                              },
                                              child: Text(
                                                'Total Deaths',
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
                                          if(i==0) return HeaderCase();
                                          if(model.iscaseValid){
                                            return CountryTile(list3_1[i-1].country, list3_1[i-1].totalCases,
                                                list3_1[i-1].dailyCases, list3_1[i-1].totalDeaths);
                                          }
                                          else{
                                            return CountryTile(list3_2[i-1].country, list3_2[i-1].totalCases,
                                                list3_2[i-1].dailyCases, list3_2[i-1].totalDeaths);
                                          }
                                        },
                                      ),

                                    )
                                  ],
                                ),
                              )
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Text("${snapshot.error}");
                        }
                        return CircularProgressIndicator();
                      },
                    ),
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
              case 500000000:
                return '500M';
              case 550000000:
                return '550M';
              case 600000000:
                return '600M';
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
      minY: 500000000,
      maxY: 600000000,
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
              case 1000000:
                return '1M';
              case 1500000:
                return '1.5M';
              case 2000000:
                return '2M';
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
      minY: 1000000,
      maxY: 2000000,
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
              case 450000000:
                return '450M';
              case 500000000:
                return '500M';
              case 550000000:
                return '550M';
              case 600000000:
                return '600M';
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
      minY: 450000000,
      maxY: 600000000,
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
              case 1000000:
                return '1M';
              case 2000000:
                return '2M';
              case 3000000:
                return '3M';
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
      minY: 1000000,
      maxY: 3000000,
      lineBarsData: [
        LineChartBarData(
          spots: [
            FlSpot(1, list[28]), FlSpot(2, list[27]), FlSpot(3, list[26]), FlSpot(4, list[25]),
            FlSpot(5, list[24]), FlSpot(6, list[23]), FlSpot(7, list[22]), FlSpot(8, list[21]),
            FlSpot(9, list[20]), FlSpot(10, list[19]), FlSpot(11, list[18]), FlSpot(12, list[17]),
            FlSpot(13, list[16]), FlSpot(14, list[15]), FlSpot(15, list[14]), FlSpot(16, list[13]),
            FlSpot(17, list[12]), FlSpot(18, list[11]), FlSpot(19, list[10]), FlSpot(20, list[9]),
            FlSpot(21, list[8]), FlSpot(22, list[7]), FlSpot(23, list[6]), FlSpot(24, list[5]),
            FlSpot(25, list[4]), FlSpot(26, list[3]), FlSpot(27, list[2]), FlSpot(28, list[4]),
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

