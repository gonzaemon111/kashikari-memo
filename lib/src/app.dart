import 'package:flutter/material.dart';
import 'components/list_component.dart';

// Stateless -> Stateが変化しない
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'かしかりメモ',
      home: ListComponent(),
    );
  }
}
