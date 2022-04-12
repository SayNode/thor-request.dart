import 'package:thor_request_dart/contract.dart';
import 'package:thor_devkit_dart/utils.dart';



//
Map injectDecodedReturn(
    Map emulateResponse, Contract contract, String functionName) {
  if (emulateResponse['reverted']) {
    return emulateResponse;
  }
  if (!emulateResponse['data'] || (emulateResponse['data'] == '0x')) {
    return emulateResponse;
  }
  var function = contract.getFunctionByName(functionName, true);

  //TODO: check if this line is correct
  emulateResponse['decoded'] =
      function.decode(hexToBytes((emulateResponse["data"])));

      
  return emulateResponse;
}
