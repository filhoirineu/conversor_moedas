import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:async';

import 'dart:convert';

//http: ^0.12.0+2

const request = "https://api.hgbrasil.com/finance?key=2ad66757";
void main() {
  runApp(MaterialApp(
    home: Home(),
    theme: ThemeData(
        /*
        hintColor: Colors.amber,
        primaryColor: Colors.amber,
        */
        inputDecorationTheme: InputDecorationTheme(
      enabledBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
      focusedBorder:
          OutlineInputBorder(borderSide: BorderSide(color: Colors.amber)),
      hintStyle: TextStyle(color: Colors.amber),
    )),
  ));
}

Future<Map> getData() async {
  http.Response response = await http.get(request);
  return json.decode(response.body);
}

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final realController = TextEditingController();
  final dolarController = TextEditingController();
  final euroController = TextEditingController();

  double dolar;
  double euro;

  void _clearAll() {
    realController.text = "";
    dolarController.text = "";
    euroController.text = "";
  }

  void realChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double real = double.parse(text);
    dolarController.text = (real / dolar).toStringAsFixed(2);
    euroController.text = (real / euro).toStringAsFixed(2);
  }

  void dolarChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double dolar = double.parse(text);
    realController.text = (dolar * this.dolar).toStringAsFixed(2);
    euroController.text = (dolar * this.dolar / euro).toStringAsFixed(2);
  }

  void euroChanged(String text) {
    if (text.isEmpty) {
      _clearAll();
    }
    double euro = double.parse(text);
    realController.text = (euro * this.euro).toStringAsFixed(2);
    dolarController.text = (euro * this.euro / dolar).toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        title: Text("\$ CONVERSOR DE MOEDAS \$"),
        backgroundColor: Colors.amber,
        centerTitle: true,
      ),
      body: FutureBuilder<Map>(
        future: getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Text("Carregando dados...",
                    style: TextStyle(color: Colors.amber)),
              );
            default:
              if (snapshot.hasError) {
                return Center(
                  child: Text("Erro ao carregar os dados...",
                      style: TextStyle(color: Colors.amber)),
                );
              } else if (!snapshot.data["valid_key"] &&
                  snapshot.data["error"]) {
                return Center(
                    child: Text(
                  "Problema ao obter dados! - " + snapshot.data["message"],
                  style: TextStyle(color: Colors.amber),
                  textAlign: TextAlign.center,
                ));
              } else {
                dolar = snapshot.data["results"]["currencies"]["USD"]["buy"];
                euro = snapshot.data["results"]["currencies"]["EUR"]["buy"];

                return SingleChildScrollView(
                    padding: EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Icon(
                          Icons.monetization_on,
                          color: Colors.amber,
                          size: 50,
                        ),
                        Divider(),
                        buildTextField(
                            "Reais", "R\$", realController, realChanged),
                        Divider(),
                        buildTextField(
                            "Dólares", "US\$", dolarController, dolarChanged),
                        Divider(),
                        buildTextField(
                            "Euros", "EUR\$", euroController, euroChanged),
                      ],
                    ));
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(String lable, String prefix,
    TextEditingController controler, Function function) {
  return TextField(
    keyboardType: TextInputType.number,
    controller: controler,
    onChanged: function,
    decoration: InputDecoration(
      labelText: lable,
      labelStyle: TextStyle(color: Colors.amber),
      border: OutlineInputBorder(),
      prefixText: prefix,
      prefixStyle: TextStyle(color: Colors.amber),
    ),
  );
}
