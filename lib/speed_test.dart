import 'dart:io';
import 'package:archive/archive_io.dart';
import 'package:http/http.dart' as http;
import 'package:shell/shell.dart';

const defaultBinaryVersion = '1.0.0';

Future<String> decompileZip(String path) async {
  final file = File(path);
  var bytes = await file.readAsBytes();
  var archive = ZipDecoder().decodeBytes(bytes);
  final folderPath = file.parent.path + '/test/';
  extractArchiveToDisk(archive, folderPath);
  return folderPath;
}

Future<File> downloadFile(String url) async {
  var file = File('${Directory.systemTemp.path}/speedtest-file.zip');
  if (!file.existsSync()) {
    file.writeAsBytes(await http.readBytes(Uri.parse(url)));
  }
  return file;
}

String getSpeedTestDownloadUrl() {
  const binaryLocation = 'https://install.speedtest.net/app/cli/ookla-speedtest-#v-#p';
  var platformPreference = getOperatingSystemPreferences();
  return binaryLocation.replaceFirst('#v', defaultBinaryVersion).replaceFirst('#p', platformPreference['pkg']!);
}

Map<String, String> getOperatingSystemPreferences() {
  switch (Platform.operatingSystem) {
    case 'macos':
      return {
        'platform': 'darwin',
        'arch': 'x64',
        'pkg': 'macosx.tgz',
        'bin': 'macosx',
        'sha': '8d0af8a81e668fbf04b7676f173016976131877e9fbdcd0a396d4e6b70a5e8f4'
      };
    case 'windows':
      return {
        'platform': 'win32',
        'arch': 'x64',
        'pkg': 'win64.zip',
        'bin': 'win-x64.exe',
        'sha': '64054a021dd7d49e618799a35ddbc618dcfc7b3990e28e513a420741717ac1ad'
      };
    default:
      throw 'Unsupported operating system';
  }
}

class Response {
  final String server;
  final String isp;
  final String latency;
  final String download;
  final String upload;
  Response(this.server, this.isp, this.latency, this.download, this.upload);
}

Future<Response> run() async {
  var shell = Shell();
  var zipFile = await downloadFile(getSpeedTestDownloadUrl());
  var folderPath = await decompileZip(zipFile.path);
  var response = await shell.run('$folderPath/speedtest');
  var lines = (response.stdout.toString()).split('\n').map((e) => e.trim()).toList();
  String lineValue(String keyword) =>
      lines.firstWhere((element) => element.startsWith(keyword), orElse: () => '').split(keyword).last;
  var server = lineValue('Server:');
  var isp = lineValue('ISP:');
  var latency = lineValue('Latency:').split('(').first;
  var download = lineValue('Download:').split('(').first;
  var upload = lineValue('Upload:').split('(').first;
  return Response(server, isp, latency, download, upload);
}
