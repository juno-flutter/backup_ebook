import 'package:flutter/material.dart';
// import 'package:file/file.dart';
// import 'package:file/local.dart';
// import 'package:file/memory.dart';
// import 'package:path_provider/path_provider.dart';
import 'dart:io' as io;
import 'package:path/path.dart' as p;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final String pathDest1 = "/Volumes/SSD-Data/Document/BOOK";
  final String pathDest2 = "/Volumes/Public/Document/Book";
  final String pathOrigin = "/Volumes/RamDisk";

  // final String pathOrigin = "/Users/junho/Pictures";
  late final String directory;
  late final List folderList;
  final String ext1 = ".pdf";
  final String ext2 = ".epub";
  bool bEndOfTask = false;

  List<String> fileList = [];
  List<String> infoList = [];

  @override
  void initState() {
    super.initState();
    _listOfFiles();
  }

  void _listOfFiles() {
    folderList = io.Directory(pathOrigin).listSync();
    for (var temp in folderList) {
      final extension = p.extension(temp.path);
      if (temp.runtimeType.toString() == "_File" && (extension == ext1 || extension == ext2)) {
        String subString = temp.path.toString().replaceAll("$pathOrigin/", "");
        fileList.add(subString);
      }
    }
    // copyReservedFile();
  }

  @override
  Widget build(BuildContext context) {
    if (!bEndOfTask) {
      copyReservedFile();
      bEndOfTask = !bEndOfTask;
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Backup eBook"),
      ),
      body: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            fileList.isEmpty
                ? const Text("백업할 대상이 없습니다.")
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: fileList.length,
                    itemBuilder: (BuildContext context, int index) {
                      return Text(
                        fileList[index].toString(),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
            fileList.isEmpty ? Container() : const Divider(),
            infoList.isEmpty
                ? Container()
                : ListView.separated(
                    shrinkWrap: true,
                    itemCount: infoList.length,
                    itemBuilder: (_, ii) {
                      return Text(
                        infoList[ii].toString(),
                        style: const TextStyle(color: Colors.red),
                      );
                    },
                    separatorBuilder: (BuildContext context, int index) => const Divider(),
                  ),
          ],
        ),
      ),
    );
  }

  void subCopy() {
    copyReservedFile();
  }

  Future<void> copyReservedFile() async {
    for (var temp in fileList) {
      io.File file = io.File("$pathOrigin/$temp");
      await file
          .copy("$pathDest1/$temp")
          .then((value) async => await file.copy("$pathDest2/$temp"))
          .then((value) async => await file.delete())
          .then((value) => setState(() {
                infoList.add("$temp is Deleted");
                if(temp == fileList.last){
                  infoList.add("COMPLETE!!!");
                }
              }));
      print("Delete: $pathOrigin/$temp");
    }
  }
}
