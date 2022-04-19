
import 'package:thor_request_dart/contract.dart';

class Clause {
  late Map clause;
  String? functionName;
  late BigInt value;
  late bool isCall;
  Contract? contract;

  Clause(String to,
      {this.contract,
      this.functionName,
      List? functionParameters,
      BigInt? value}) {
    if (value == null) {
      this.value = BigInt.zero;
    }
    isCall = contract != null && functionName != null;

    if (isCall) {
      var f = contract!.getFunctionByName(functionName!);

      //FIXME: can functionParameters be null?
      var data = f.encode(functionParameters!);

      clause = {"to": to, "value": value.toString(), "data": data};
    } else {
      clause = {"to": to, "value": value.toString(), "data": "0x"};
    }
  }
}
