import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './input_form_component.dart';

class ListComponent extends StatefulWidget {
  @override
  _MyList createState() => _MyList();
}

class _MyList extends State<ListComponent> {

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("リスト画面"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: StreamBuilder<QuerySnapshot>(
            // stream: は、非同期で取得するデータ
            stream: Firestore.instance.collection('kashikari-memo').snapshots(),
            // builder: は stream: に変化があったときに呼び出される。
            // 今回は、データを取得するまで'Loadingと表示する'
            // 取得したら、ListView.builderにデータを渡す。
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
              if (!snapshot.hasData) return const Text('Loading...');
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                padding: const EdgeInsets.only(top: 10.0),
                itemBuilder: (context, index) => _buildListItem(context, snapshot.data.documents[index]),
              );
            }
        ),
      ),
      floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.add),
          onPressed: () {
            print("新規作成ボタンを押しました");
            Navigator.push(
              context,
              MaterialPageRoute(
                  settings: const RouteSettings(name: "/new"),
                  builder: (BuildContext context) => InputFormComponent(null)
              ),
            );
          }
      ),
    );
  }

  Widget _buildListItem(BuildContext context, DocumentSnapshot document){
    return Card(
      child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.android),
              title: Text("【 " + (document['borrowOrLend'] == "lend"?"貸": "借") +" 】"+ document['stuff']),
              subtitle: Text('期限 ： ' + document['date'].toString().substring(0,10) + "\n相手 ： " + document['user']),
            ),
            // ignore: deprecated_member_use
            ButtonTheme.bar(
                child: ButtonBar(
                  children: <Widget>[
                    FlatButton(
                        child: const Text("編集"),
                        onPressed: ()
                        {
                          print("編集ボタンを押しました");
                          // 編集ボタンの処理
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                settings: const RouteSettings(name: "/edit"),
                                builder: (BuildContext context) => InputFormComponent(document)
                            ),
                          );
                        }
                    ),
                  ],
                )
            ),
          ]
      ),
    );
  }
}

