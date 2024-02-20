// ignore_for_file: use_key_in_widget_constructors, camel_case_types, prefer_const_constructors

import 'package:flutter/material.dart';
import 'main.dart';

class history extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blueAccent,
        title: Text('Historique'),
      ),
      body: Center(
        child: Text(
          'Contenu de la nouvelle page',
          style: TextStyle(fontSize: 24.0),
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.blueAccent,
        child: IconTheme(data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                    tooltip: 'Open navigation menu',
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (context) => MyHomePage(title: "Scanne ton poisson !")));
                    },
                    icon: const Icon(Icons.home)
                ),
                IconButton(
                  tooltip: 'History',
                  onPressed: (){},
                  icon: const Icon(Icons.menu),
                ),
              ],
            )),
      ),
    );
  }
}
