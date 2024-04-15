import 'dart:convert';
import 'dart:typed_data';
import 'package:upharm_common/src/sql/sqlconnection.dart';
import 'package:upharm_common/upharm_common.dart';

class SqlUpharm extends SqlConnection {
  static SqlUpharm _conn = SqlUpharm._internal();

  factory SqlUpharm() {
    return _conn;
  }

  SqlUpharm._internal() : super(_connectionString());

  static void reset() {
    _conn = SqlUpharm._internal();
  }

  connetion() async {
    await open();
    await execute('exec P_Security_KeyOpen \'${_getInformSecurityPw()}\'');
  }

  static String _connectionString() {
    return 'Data Source=${_getServerName()};Initial Catalog=AtPharm;Persist Security Info=True;User ID=sa;Password=${_getUserPw()};MultipleActiveResultSets=True;Connect Timeout=30;Application Name=Upharm';
  }

  static String _getServerName() {
    var serverPath = Registry.openPath(RegistryHive.localMachine, path: r'Software\WOW6432Node\UBCare\@Pharm\Start');
    return serverPath.getValueAsString('Server') ?? 'localhost';
  }

  static String _getUserPw() {
    var key = const AsciiEncoder().convert('abcdefghijklmnopqrstuvwx');
    var iv = List.filled(8, 0);
    var data = Uint8List.fromList([174, 204, 227, 23, 14, 65, 141, 182, 55, 191, 83, 17, 242, 62, 185, 87]);
    var des3CBC = DES3(key: key, mode: DESMode.CBC, iv: iv);
    var result = des3CBC.decrypt(data);
    return String.fromCharCodes(result, 0, result.length - 1);
  }

  static String _getInformSecurityPw() {
    try {
      var key = const AsciiEncoder().convert("abcdefghijklmnopqrstuvwx");
      var iv = List.filled(8, 0);
      var data = Uint8List.fromList([127, 219, 83, 70, 130, 78, 116, 26, 100, 211, 66, 182, 189, 37, 202, 73]);
      var des3CBC = DES3(key: key, mode: DESMode.CBC, iv: iv);
      var result = des3CBC.decrypt(data);
      return String.fromCharCodes(result, 0, result.length - 8);
    } on Exception {
      return '';
    }
  }
}
