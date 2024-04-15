// ignore_for_file: unused_local_variable, avoid_print, file_names, prefer_final_fields, constant_identifier_names
import 'dart:async';
import 'dart:convert';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:uuid/uuid.dart';

// -- x_types.dart --
enum XTypes {
  Query(0),
  U(1),
  UC(2),
  UD(3),
  UInsert(4),
  UInsertWithData(5),
  UUpdate(6),
  UDelete(7),
  P(8),
  V(9),
  FN(10);

  final int value;
  const XTypes(this.value);
}

class SignalR {
  static StreamController reciveEvent = StreamController<List<Map<String, dynamic>>>.broadcast(sync: true);
  static HubConnection? _hubConnection;
  static int _healthcareNumber = 99999999;
  static String _randomID = const Uuid().v4().split('-').first;
  static String _url = "https://upharmsigrsvr.azurewebsites.net/upharm?username=$_randomID&groupname=upsqlmanager&isclient=true";

  static initialize(int healthcareNumber, String id) {
    _healthcareNumber = healthcareNumber;
    _randomID = id;
    var serverUrl = _url;
    _hubConnection = HubConnectionBuilder().withUrl(serverUrl).build();

    _hubConnection!.on("AckMessage", ackMessage);
    _hubConnection!.on("ReceiveMessage", receiveMessage);
    _hubConnection!.on("ReceiveMessageList", receiveData);
  }

  static connectServer() async {
    await _hubConnection!.start();
    _hubConnection!.invoke('CheckConnected');
  }

  static void ackMessage(List<dynamic>? arguments) {
    String message = arguments?[0];
    bool isMsgMode = arguments?[1];

    if (!isMsgMode) {
      print(message);
    }
  }

  static receiveMessage(List<dynamic>? arguments) {
    String from = arguments?[0];
    String message = arguments?[1];
    bool silent = arguments?[2];
    jsonDecode(message);
  }

  static receiveData(List<dynamic>? arguments) {
    String from = arguments?[0];
    List<String> message = List<String>.from(arguments?[1] as List);
    bool silent = arguments?[2];
    List<Map<String, dynamic>> result = [];

    for (var element in message) {
      var map = jsonDecode(element);
      var rds = Map<String, dynamic>.from(map['Rds']);
      result.addAll(List<Map<String, dynamic>>.from(rds['Table']));
    }
    reciveEvent.add(result);
  }

  static sendquery(String sQuery) async {
    Map args = {};
    args['ParentName'] = null;
    args['name'] = 'QryOnline';
    args['fileName'] = 'QryOnline.sql';
    args['Qry'] = sQuery;
    args['xtype'] = XTypes.Query.name;
    args['IsAdminMode'] = false;
    args['SType'] = XTypes.Query.name;
    args['XType'] = XTypes.Query.index;

    if (_hubConnection == null || _hubConnection!.state == HubConnectionState.Disconnected) {
      await connectServer();
    }

    _hubConnection!.invoke('SendMessage', args: [_randomID, '$_healthcareNumber', json.encode(args), false]);
  }
}
