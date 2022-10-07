import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

List<String> matchQuery = [];

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: Text('Fetch Data in list'),
          actions: [
            IconButton(
              onPressed: () {
                // method to show the search bar
                showSearch(
                    context: context,
                    // delegate to customize the search bar
                    delegate: CustomSearchDelegate());
              },
              icon: const Icon(Icons.search),
            )
          ],
        ),
        body: MainListView(),
      ),
    );
  }
}

class home {
  int srno;
  String firstname;
  String lastname;
  // String studentSubject;

  home({
    required this.srno,
    required this.firstname,
    required this.lastname,
  });

  factory home.fromJson(Map<String, dynamic> json) {
    return home(
      srno: json['srno'],
      firstname: json['first name'],
      lastname: json['last name'],
    );
  }
}

class MainListView extends StatefulWidget {
  MainListViewState createState() => MainListViewState();
}

class MainListViewState extends State {
  final apiURL = Uri.parse('http://192.168.155.54/university/Info.php');

  Future<List<home>> fetchStudents() async {
    var response = await http.get(apiURL);

    if (response.statusCode == 200) {
      final items = json.decode(response.body).cast<Map<String, dynamic>>();
      for (var item in items) {
        matchQuery.add(item['first name'].toString());
      }
      // for (var it in matchQuery) {
      //   print(it);
      // }
      List<home> studentList = items.map<home>((json) {
        return home.fromJson(json);
      }).toList();

      return studentList;
    } else {
      throw Exception('Failed to load data from Server.');
    }
  }

  navigateToNextActivity(BuildContext context, int dataHolder) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SecondScreenState(dataHolder.toString())));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<home>>(
      future: fetchStudents(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return Center(child: CircularProgressIndicator());

        return ListView(
          children: snapshot.data!
              .map((data) => Column(
                    // Sl.add(data.firstname);
                    children: <Widget>[
                      GestureDetector(
                        onTap: () {
                          navigateToNextActivity(context, data.srno);
                        },
                        child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                  padding: EdgeInsets.fromLTRB(20, 5, 0, 5),
                                  child: Text(data.firstname,
                                      style: TextStyle(fontSize: 21),
                                      textAlign: TextAlign.left))
                            ]),
                      ),
                      Divider(color: Colors.black),
                    ],
                  ))
              .toList(),
        );
      },
    );
  }
}

class SecondScreenState extends StatefulWidget {
  final String idHolder;
  SecondScreenState(this.idHolder);
  @override
  State<StatefulWidget> createState() {
    return SecondScreen(this.idHolder);
  }
}

class SecondScreen extends State<SecondScreenState> {
  final String srno;

  SecondScreen(this.srno);

  // API URL
  var url = Uri.parse('http://192.168.155.54/university/Info.php');

  Future<List<home>> fetchStudent() async {
    var data = {'id': int.parse(srno)};

    var response = await http.post(url, body: json.encode(data));

    if (response.statusCode == 200) {
      print(response.statusCode);

      final items = json.decode(response.body).cast<Map<String, dynamic>>();

      List<home> studentList = items.map<home>((json) {
        return home.fromJson(json);
      }).toList();

      return studentList;
    } else {
      throw Exception('Failed to load data from Server.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
            appBar: AppBar(
                title: Text('Showing Selected Item Details'),
                automaticallyImplyLeading: true,
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context, false),
                )),
            body: FutureBuilder<List<home>>(
              future: fetchStudent(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return Center(child: CircularProgressIndicator());

                return ListView(
                  children: snapshot.data!
                      .map((data) => Column(
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {
                                  print(data.firstname);
                                },
                                child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 20, 0, 10),
                                          child: Text(
                                              'ID = ' + data.srno.toString(),
                                              style: TextStyle(fontSize: 21))),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Text(
                                              'Name = ' + data.firstname,
                                              style: TextStyle(fontSize: 21))),
                                      Padding(
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 10),
                                          child: Text(
                                              'Phone Number = ' +
                                                  data.lastname.toString(),
                                              style: TextStyle(fontSize: 21))),
                                      Padding(
                                        padding:
                                            EdgeInsets.fromLTRB(0, 0, 0, 10),
                                      ),
                                    ]),
                              )
                            ],
                          ))
                      .toList(),
                );
              },
            )));
  }
}

class CustomSearchDelegate extends SearchDelegate {
  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        onPressed: () {
          query = '';
        },
        icon: Icon(Icons.clear),
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<String> Srch = [];
    for (var item in matchQuery) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        matchQuery.add(item);
      }
    }
    return ListView.builder(
      itemCount: Srch.length,
      itemBuilder: (context, index) {
        var result = Srch[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // TODO: implement buildSuggestions
    List<String> Srch = [];
    for (var item in matchQuery) {
      if (item.toLowerCase().contains(query.toLowerCase())) {
        Srch.add(item);
      }
    }
    // index = Srch.length;
    return ListView.builder(
      itemCount: Srch.length,
      itemBuilder: (context, index) {
        var result = Srch[index];
        return ListTile(
          title: Text(result),
        );
      },
    );
  }
}
