import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:path_provider/path_provider.dart';

class SaveImageExample extends StatefulWidget {
  @override
  _SaveImageExampleState createState() => _SaveImageExampleState();
}

class _SaveImageExampleState extends State<SaveImageExample> {
  final imageUrl =
      "https://ww4.sinaimg.cn/bmiddle/005TR3jLly1ga48shax8zj30u02ickjl.jpg";

  final haveExifUrl = "http://172.16.100.7:2393/IMG_20200107_182905.jpg";

  final videoUrl = "http://img.ksbbs.com/asset/Mon_1703/05cacb4e02f9d9e.mp4";
  // final videoUrl = "http://192.168.31.252:51781/out.mov";
  // final videoUrl = "http://192.168.31.252:51781/out.ogv";

  String get videoName {
    final extName = Uri.parse(videoUrl).pathSegments.last.split(".").last;
    final name = DateTime.now().microsecondsSinceEpoch ~/
        Duration.microsecondsPerMillisecond;
    return "$name.$extName";
  }

  @override
  void initState() {
    super.initState();
    PhotoManager.addChangeCallback(_onChange);
    PhotoManager.startChangeNotify();
  }

  void _onChange(MethodCall call) {
    print(call.arguments);
  }

  @override
  void dispose() {
    PhotoManager.stopChangeNotify();
    PhotoManager.removeChangeCallback(_onChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Save image"),
      ),
      body: Container(
        child: Column(
          children: <Widget>[
            RaisedButton(
              child: Text("Save image"),
              onPressed: () async {
                final client = HttpClient();
                // Replace to your have exif image url to test the android Q exif info.
                // final req = await client.getUrl(Uri.parse(haveExifUrl));
                final req = await client.getUrl(Uri.parse(imageUrl));
                final resp = await req.close();
                List<int> bytes = [];
                resp.listen((data) {
                  bytes.addAll(data);
                }, onDone: () {
                  final image = Uint8List.fromList(bytes);
                  saveImage(image);
                  client.close();
                });
              },
            ),
            RaisedButton(
              child: Text("Save video"),
              onPressed: () async {
                final client = HttpClient();
                // Replace to your have exif image url to test the android Q exif info.
                // final req = await client.getUrl(Uri.parse(haveExifUrl));
                final req = await client.getUrl(Uri.parse(videoUrl));
                final resp = await req.close();

                final name = this.videoName;

                final tmpDir = await getTemporaryDirectory();
                final file = File('${tmpDir.path}/$name');
                if (file.existsSync()) {
                  file.deleteSync();
                }
                resp.listen((data) {
                  file.writeAsBytesSync(data, mode: FileMode.append);
                }, onDone: () {
                  print("file path = ${file.lengthSync()}");
                  PhotoManager.editor.saveVideo(file, title: "$name");
                  client.close();
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  void saveImage(Uint8List uint8List) async {
    final asset = await PhotoManager.editor.saveImage(uint8List);
    print(asset);
  }
}
