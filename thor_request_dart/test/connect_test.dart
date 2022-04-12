import 'package:flutter_test/flutter_test.dart';
import 'package:thor_request_dart/connect.dart';

void main() {
  //TODO: Write real test
  test('get account', () async {
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


  test('get block test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    Map a = await connect.getBlock(block: '0x0084f21562e046b1ae9aa70b6cd3b7bc2e8312f3961716ee3fcd58ce8bcb7392');
    expect(a['number'], 8712725);
  });


  test('get chain tag test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
    int a = await connect.getChainTag();
    expect(a, 39);
  });


//TODO: figure out how to test this
    test('ticker test', () async {
    Connect connect = Connect('https://testnet.veblocks.net');
  
  });

}
