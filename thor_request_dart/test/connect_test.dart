import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:thor_request_dart/connect.dart';
import 'package:nock/nock.dart';

void main() {
//setup fake http requests
  setUpAll(() {
    nock.init();
  });

  setUp(() {
    nock.cleanAll();
  });

  test('get account', () async {
    final interceptor = nock('https://testnet.veblocks.net/accounts')
        .get('/0x5034aa590125b64023a0262112b98d72e3c8e40e?revision=best')
      ..reply(
        200,
        "{\"balance\": \"0x238b7a0ad2db473db2\",\"energy\": \"0x45dc1717b278b81ba4e5af\",\"hasCode\": false}",
      );

    Connect connect = Connect('https://testnet.veblocks.net');
    Map a =
        await connect.getAccount('0x5034aa590125b64023a0262112b98d72e3c8e40e');

    expect(interceptor.isDone, true);
    expect(json.encode(a),
        "{\"balance\":\"0x238b7a0ad2db473db2\",\"energy\":\"0x45dc1717b278b81ba4e5af\",\"hasCode\":false}");
  });

  test('Vet balance test', () async {
    final interceptor = nock('https://testnet.veblocks.net/accounts')
        .get('/0x5034aa590125b64023a0262112b98d72e3c8e40e?revision=best')
      ..reply(
        200,
        "{\"balance\": \"0x238b7a0ad2db473db2\",\"energy\": \"0x45dc1717b278b81ba4e5af\",\"hasCode\": false}",
      );

    Connect connect = Connect('https://testnet.veblocks.net');
    BigInt a = await connect
        .getVetBalance('0x5034aa590125b64023a0262112b98d72e3c8e40e');
    expect(a, BigInt.parse("238b7a0ad2db473db2", radix: 16));
  });

  test('VTHO balance test', () async {
    final interceptor = nock('https://testnet.veblocks.net/accounts')
        .get('/0x5034aa590125b64023a0262112b98d72e3c8e40e?revision=best')
      ..reply(
        200,
        "{\"balance\": \"0x238b7a0ad2db473db2\",\"energy\": \"0x45dc1717b278b81ba4e5af\",\"hasCode\": false}",
      );

    Connect connect = Connect('https://testnet.veblocks.net');
    BigInt a = await connect
        .getVthoBalance('0x5034aa590125b64023a0262112b98d72e3c8e40e');
    expect(a, BigInt.parse("45dc1717b278b81ba4e5af", radix: 16));
  });

  test('get block test not expanded', () async {
    final interceptor =
        nock('https://testnet.veblocks.net/blocks/').get('best?expanded=false')
          ..reply(
            200,
            File("C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/block.json")
                .readAsStringSync(),
          );

    Connect connect = Connect('https://testnet.veblocks.net');
    Map expected = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/block.json")
        .readAsStringSync());
    Map a = await connect.getBlock(block: 'best');
    expect(json.encode(a), json.encode(expected));
  });

  test('get block test expanded', () async {
    final interceptor =
        nock('https://testnet.veblocks.net/blocks/').get('best?expanded=true')
          ..reply(
            200,
            File("C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/block-expanded.json")
                .readAsStringSync(),
          );

    Connect connect = Connect('https://testnet.veblocks.net');
    Map expected = json.decode(File(
            "C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/block-expanded.json")
        .readAsStringSync());
    Map a = await connect.getBlock(block: 'best', expanded: true);
    expect(json.encode(a), json.encode(expected));
  });

  test('get chain tag test', () async {
    final interceptor =
        nock('https://testnet.veblocks.net/blocks/').get('0?expanded=false')
          ..reply(
            200,
            File("C:/Users/SayNode/Documents/GitHub/thor-request.dart/thor_request_dart/test/json/blockZero.json")
                .readAsStringSync(),
          );


    Connect connect = Connect('https://testnet.veblocks.net');
    int a = await connect.getChainTag();
    expect(a, 39);
  });




//TODO: figure out how to test this
  test('ticker test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
  });
}
