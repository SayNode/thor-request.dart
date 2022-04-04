import 'dart:convert';

import 'package:http/http.dart' as http;

///Connect to VeChain
class Connect {
  //url of the VeChain node
  late String url;

  Connect(this.url);

  ///Takes a adress [adress] and returns te account status as a json
  Future<Map> getAccount(String adress, {String block = 'best'}) async {
    var headers = {
      'accept': 'application/json',
    };

    var params = {
      'revision':
          '0x003dc697f70205861a70fd3e52a24a542613b564bf6d8b7b4149c6b3ee6e015d',
    };
    //var query = params.entries.map((p) => '${p.key}=${p.value}').join('&');

    var u = Uri.parse('$url/accounts/$adress?revision=$block');
    var res = await http.get(u, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('http.get error: statusCode= ${res.statusCode}');
    }
    Map map = jsonDecode(res.body);
    return map;
  }

  ///returns VET blance in VEI
  Future<BigInt> getVetBalance(String adress) async {
    Map map = await getAccount(adress);
    String b = map['balance'];
    BigInt balance = BigInt.parse(b.substring(2), radix: 16);
    return balance;
  }

  ///returns the VTHO balance in Wei
  Future<BigInt> getVthoBalance(String adress) async {
    Map map = await getAccount(adress);
    String b = map['energy'];
    BigInt balance = BigInt.parse(b.substring(2), radix: 16);
    return balance;
  }

  Future<Map> getBlock({String block = 'best', bool expanded = false}) async {
    var headers = {
      'accept': 'application/json',
    };

    String e;
    if (expanded == true) {
      e = 'true';
    } else {
      e = 'false';
    }
    var u = Uri.parse('$url/blocks/$block?expanded=$e');
    var res = await http.get(u, headers: headers);
    Map map = jsonDecode(res.body);
    return map;
  }

  Future<BigInt> getChainTag() async {
    var block = await getBlock(block: '0');
    String p = block['id'];
    return BigInt.parse(p.substring(p.length - 2));
  }

  Future<Map> getTransaction(String transactionId) async {
    var headers = {
      'accept': 'application/json',
    };
    var u = Uri.parse('$url/transactions/$transactionId');
    var res = await http.get(u, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    }
    Map output = jsonDecode(res.body);
    return output;
  }

  postTransaction(String raw) async {
    var headers = {
      'accept': 'application/json',
      'Content-Type': 'application/json',
    };
    var data = '{"raw":"$raw"}';
    var u = Uri.parse('$url/transactions');
    var res = await http.post(u, headers: headers, body: data);
    if (res.statusCode != 200) {
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    }
  }

    Future<Map?> getTransactionReceipt(String transactionId) async {
    var headers = {
      'accept': 'application/json',
    };
    var u = Uri.parse('$url/transactions/$transactionId/receipt');
    var res = await http.get(u, headers: headers);
    if (res.statusCode != 200) {
      throw Exception('http.post error: statusCode= ${res.statusCode}');
    }
    Map output = jsonDecode(res.body);
    return output;
  }

  Stream<Map> ticker() async* {
    var i = 1;
    Map oldBlock = await getBlock();
    while (true) {
      Map newBlock = await getBlock();
      if (newBlock['id'] != oldBlock['id']) {
        oldBlock = newBlock;
        yield newBlock;
      } else {
        
      }
      
    }
  }

}
