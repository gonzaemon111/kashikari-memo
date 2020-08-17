import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import '../models/form_model.dart';

class InputFormComponent extends StatefulWidget {
  //引数の追加
  final DocumentSnapshot document;
  
  InputFormComponent(this.document);

  @override
  _InputFormState createState() => _InputFormState();
}

class _InputFormState extends State<InputFormComponent> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FormModel _data = FormModel();

  void _setLendOrRent(String value){
    setState(() {
      _data.borrowOrLend = value;
    });
  }

  Future <DateTime> _selectTime(BuildContext context) {
    return showDatePicker(
        context: context,
        initialDate: _data.date,
        firstDate: DateTime(_data.date.year - 2),
        lastDate: DateTime(_data.date.year + 2)
    );
  }

  @override
  Widget build(BuildContext context) {
    //編集データの作成
    DocumentReference _mainReference;
    _mainReference = Firestore.instance.collection('kashikari-memo').document();
    bool deleteFlg = false;
    if (widget.document != null) {
      //引数で渡したデータがあるかどうか
      print(_data.date);
      if(_data.user == null && _data.stuff == null) {
        _data.borrowOrLend = widget.document['borrowOrLend'];
        _data.user = widget.document['user'];
        _data.stuff = widget.document['stuff'];
        _data.date = widget.document['date'].toDate();
      }
      _mainReference = Firestore.instance.collection('kashikari-memo').
      document(widget.document.documentID);
      deleteFlg = true;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('かしかり入力'),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.save),
              onPressed: () {
                print("保存ボタンを押しました");
                // _formKey.currentState.validate() で次の項目で実装するvalidatorを呼び出す
                if (_formKey.currentState.validate()) {
                  // _formKey.currentState.save() で次の項目で実装するonSavedを呼び出します。
                  _formKey.currentState.save();
                  print(_formKey);
                  print(_data);
                  _mainReference.setData(
                      {
                        'borrowOrLend': _data.borrowOrLend,
                        'user': _data.user,
                        'stuff': _data.stuff,
                        'date': _data.date
                      }
                  );
                  Navigator.pop(context);
                }
              }
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () {
              print("削除ボタンを押しました");
            },
          ),
        ],
      ),
      body: SafeArea(
        child:
        Form(
          // key: _formKey は、フォーム全体に対する制御を行う
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20.0),
            children: <Widget>[

              RadioListTile(
                value: "borrow",
                groupValue: _data.borrowOrLend,
                title: Text("借りた"),
                onChanged: (String value){
                  print("借りたをタッチしました");
                  _setLendOrRent(value);
                },
              ),
              RadioListTile(
                  value: "lend",
                  groupValue: _data.borrowOrLend,
                  title: Text("貸した"),
                  onChanged: (String value) {
                    print("貸したをタッチしました");
                    _setLendOrRent(value);
                  }
              ),

              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.person),
                  hintText: '相手の名前',
                  labelText: 'Name',
                ),
                onSaved: (String value) {
                  _data.user = value;
                },
                // ignore: missing_return
                validator: (value) {
                  if (value.isEmpty) {
                    return '名前は必須入力項目です';
                  }
                },
                initialValue: _data.user,
              ),

              TextFormField(
                decoration: const InputDecoration(
                  icon: const Icon(Icons.business_center),
                  hintText: '借りたもの、貸したもの',
                  labelText: 'loan',
                ),
                onSaved: (String value) {
                  _data.stuff = value;
                },
                // ignore: missing_return
                validator: (value) {
                  if (value.isEmpty) {
                    return '借りたもの、貸したものは必須入力項目です';
                  }
                },
                initialValue: _data.stuff,
              ),

              Padding(
                padding: const EdgeInsets.only(top:8.0),
                child: Text("締め切り日：${_data.date.toString().substring(0,10)}"),
              ),

              RaisedButton(
                child: const Text("締め切り日変更"),
                onPressed: (){
                  print("締め切り日変更をタッチしました");
                  _selectTime(context).then((time){
                    if(time != null && time != _data.date){
                      setState(() {
                        _data.date = time;
                      });
                    }
                  });
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}