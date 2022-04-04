import 'package:flutter_test/flutter_test.dart';
import 'package:thor_request_dart/connect.dart';

import 'package:thor_request_dart/thor_request_dart.dart';

void main() {
  //TODO: Write real test
  test('a test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Map a =
        await connect.getAccount('0x5034aa590125b64023a0262112b98d72e3c8e40e');
    print(a);
  });

//TODO: Write real test
  test('Vet balance test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    BigInt a = await connect
        .getVetBalance('0x5034aa590125b64023a0262112b98d72e3c8e40e');
    print(a);
  });

  //TODO: Write real test
  test('VTHO balance test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    BigInt a = await connect
        .getVthoBalance('0x5034aa590125b64023a0262112b98d72e3c8e40e');
    print(a);
  });

  //TODO: Write real test
  test('get block test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Map a = await connect.getBlock();
    print(a);
  });

    //TODO: Write real test
  test('get chain tag test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    BigInt a = await connect.getChainTag();
    print(a);
  });
}

