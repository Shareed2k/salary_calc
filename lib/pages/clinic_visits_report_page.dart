import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:json_table/json_table.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pdfLib;

class PreviewScreenshot extends StatelessWidget {
  final List visitList;

  PreviewScreenshot({Key key, this.visitList}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    GlobalKey globalKey = GlobalKey();

    return Scaffold(
      appBar: AppBar(
        title: Text('Screenshot'),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              Icons.local_printshop,
              color: Colors.white,
            ),
            onPressed: () => _captureScreenshot(globalKey),
          ),
        ],
      ),
      body: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.0),
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: RepaintBoundary(
            key: globalKey,
            child: JsonTable(this.visitList),
          )),
    );
  }

  Future<void> _captureScreenshot(_globalKey) async {
    try {
      RenderRepaintBoundary boundary =
          _globalKey.currentContext.findRenderObject();
      ui.Image image = await boundary.toImage();
      ByteData byteData =
          await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      var png = byteData.buffer.asUint8List();

      final pdfLib.Document pdf = pdfLib.Document(
        deflate: zlib.encode,
      );

      pdf.addPage(pdfLib.Page(
        pageFormat: PdfPageFormat.a4,
        build: (c) {
          return pdfLib.Center(
              child: pdfLib.Image(
            PdfImage(pdf.document,
                image: png, width: image.width, height: image.height),
          ));
        },
      ));

      final output =
          await getExternalStorageDirectory(); // use the [path_provider (https://pub.dartlang.org/packages/path_provider) library:
      final file = File("${output.path}/example.pdf");
      await file.writeAsBytes(pdf.save());
    } catch (e) {
      print(e);
    }
  }
}
