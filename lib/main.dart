import 'package:flutter/foundation.dart';
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

  get value => null;

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

  final ScrollController _controller = ScrollController();

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
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            fileList.isEmpty
                ? const Text("백업할 대상이 없습니다.")
                : Expanded(
                    child: Scrollbar(
                      controller: _controller,
                      thumbVisibility: true,
                      child: ListView.separated(
                        controller: _controller,
                        itemCount: fileList.length + infoList.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (infoList.length > index) {
                            return Text(
                              infoList[index].toString(),
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.red,
                              ),
                            );
                          }
                          if (infoList.length <= index) {
                            return Text(fileList[index-infoList.length].toString(), style: const TextStyle(fontSize: 16, color: Colors.black87));
                          }

                          return const Divider();
                        },
                        separatorBuilder: (BuildContext context, int index) {
                          return const Divider();
                        },
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  // void _scroll2Bottom() {
  //   _controller.jumpTo(_controller.position.maxScrollExtent);
  // }

  void subCopy() {
    copyReservedFile();
  }

  Future<void> copyReservedFile() async {
    for (var temp in fileList.reversed) {
      io.File file = io.File("$pathOrigin/$temp");
      await file
          .copy("$pathDest1/$temp")
          .then((value) async => await file.copy("$pathDest2/$temp"))
          .then((value) async => await file.delete())
          .then((value) => setState(() {
                infoList.insert(0, "$temp is Deleted");
                if (temp == fileList.first) {
                  infoList.insert(0, "COMPLETE!!!");
                }
              }));

      if (kDebugMode) {
        print("Delete: $pathOrigin/$temp");
      }
    }
  }
}
