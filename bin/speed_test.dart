import 'package:speed_test/speed_test.dart' as speed_test;
import 'dart:io';
import 'package:console/console.dart';
import 'dart:async';

void main(List<String> arguments) async {
  stdin.echoMode = false;
  stdin.lineMode = true;
  Console.init();
  Console.hideCursor();
  Console.write('\n');

  var loadingServer = Loading('\t  Server');
  var loadingISP = Loading('\t     ISP');
  var loadingLatency = Loading('\t Latency');
  var loadingDownload = Loading('\tDownload');
  var loadingUpload = Loading('\t  Upload');
  var response = await speed_test.run();

  loadingServer.result(response.server);
  loadingISP.result(response.isp);
  loadingLatency.result(response.latency);
  loadingDownload.result(response.download);
  loadingUpload.result(response.upload);

  Console.write('\n');
  exit(0);
}

class Loading {
  late Timer timer;
  late Function moveLine;
  String prefix;
  Loading(this.prefix) {
    var point = Console.getCursorPosition();
    var loadingCharacters = ['|', '/', '-', '\\'];
    var index = 1;
    moveLine = () => Console.moveCursor(row: point.row, column: point.column);
    Console.write(prefix + ' : ' + loadingCharacters[0] + '\n');
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      index = (index + 1) % loadingCharacters.length;
      moveLine();
      Console.setTextColor(Color.WHITE.id);
      Console.overwriteLine(prefix + ' : ');
      Console.setTextColor(Color.YELLOW.id);
      Console.write(loadingCharacters[index]);
      Console.resetTextColor();
    });
  }

  void result(String text) {
    timer.cancel();
    moveLine();
    Console.setTextColor(Color.WHITE.id);
    Console.write(prefix + ' : ');
    Console.setTextColor(Color.LIGHT_CYAN.id);
    Console.write(text);
    Console.resetTextColor();
  }
}
