import 'dart:convert';
import 'dart:io';

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

  ///[block] enter block id or number, [expanded] returned block data should be expanded
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

  ///returns chaintag
  Future<int> getChainTag() async {
    var block = await getBlock(block: '0');
    String p = block['id'];
    return int.parse(p.substring(p.length - 2), radix: 16);
  }

  ///get transaction data of trnsaction with id [transactionId]
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

  ///post a new transaction with raw payload [raw]
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

  ///get transaction recipt of transaction with id [transactionId]
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

  ///stream output of best block
  Stream<Map> ticker() async* {
    var i = 1;
    Map oldBlock = await getBlock();
    while (true) {
      Map newBlock = await getBlock();
      if (newBlock['id'] != oldBlock['id']) {
        oldBlock = newBlock;
        yield newBlock;
      } else {
        sleep(const Duration(seconds: 1));
      }
    }
  }

  Future<List<Map>> emulate(Map body, {String block = 'best'}) async {
    //TODO: check if this url is correct
    var u = Uri.parse('$url/accounts/*?revision=$block');
    var headers = {
      "accept": "application/json",
      "Content-Type": "application/json"
    };
    var res = await http.post(u, headers: headers, body: body);
    if (res.statusCode == 200) {
      throw Exception("HTTP error: ${res.statusCode} ${res.reasonPhrase}");
    }

    //TODO: fill rest of methode
  }
}
