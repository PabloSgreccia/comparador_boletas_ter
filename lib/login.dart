// ignore_for_file: deprecated_member_use, avoid_print

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
//import 'package:file_picker/file_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:path_provider/path_provider.dart';
import 'package:filesystem_picker/filesystem_picker.dart';
import 'package:permission_handler/permission_handler.dart';

import 'boletas.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  String? _filePath;
  final _nombre = TextEditingController()..text = '';
  late FocusNode _focusNombre;

  @override
  void initState() {
    super.initState();
    _focusNombre = FocusNode();
  }

  @override
  void dispose() {
    _nombre.dispose();
    // _pass.dispose();
    _focusNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Comparador de Boletas'),
        actions: <Widget>[
          Image.asset('assets/logoternium.jpg'),
        ],
      ),
//---------------------------------------------------------------------- Body
//---------------------------------------------------------------------- Body
//---------------------------------------------------------------------- Body
      body: (Column(children: [
//---------------------------------------------------------------------- Archivo
        ListTile(
          contentPadding: const EdgeInsets.only(top: 10.0, left: 15),
          leading: RaisedButton(
            onPressed: () {
              getFilePath();
            },
            padding: const EdgeInsets.all(20),
            child: const Icon(Icons.sd_storage),
          ),
          title: (Container(
            margin: const EdgeInsets.only(right: 10.0),
            child: Text(
              iniciarAplicacion(),
              style: TextStyle(
                  // ignore: unnecessary_null_comparison
                  color: _filePath == null ? Colors.redAccent : Colors.black),
              overflow: TextOverflow.fade,
            ),
          )),
        ),
        Container(
          padding: esXlsx() == ''
              ? const EdgeInsets.all(0)
              : const EdgeInsets.only(top: 20),
          child: Text(
            'ERROR: Seleccione un archivo .XLSX',
            textAlign: TextAlign.center,
            style: TextStyle(
                color: Colors.redAccent,
                fontSize: esXlsx() == '' ? 0 : 20,
                fontWeight: FontWeight.bold),
          ),
        ),
        const Divider(color: Colors.black, height: 40),

//---------------------------------------------------------------------- Usuario
        ListTile(
          leading: RaisedButton(
            onPressed: () => _focusNombre.requestFocus(),
            padding: const EdgeInsets.all(20),
            child: const Icon(Icons.person),
          ),
          title: TextField(
            focusNode: _focusNombre,
            controller: _nombre,
            decoration: const InputDecoration(
              labelText: 'Usuario:',
            ),
            maxLength: 20,
          ),
        ),
//---------------------------------------------------------------------- Boton
        Container(
          padding: const EdgeInsets.all(30),
          child: RaisedButton(
            padding: const EdgeInsets.only(
                top: 20, bottom: 20, left: 100, right: 100),
            color: Colors.deepOrange[200],
            onPressed: () {
              if ((_nombre.text != '') &&
                  (esXlsx() == '') &&
                  // ignore: unnecessary_null_comparison
                  (_filePath != null)) {
                var datos = [];
                datos.add(
                    _filePath); // aca se agrega el directorio para pasarle a "boletas"
                datos.add(_nombre.text);
                reEscribirDoc('userName.txt', 2);
                //FocusScope.of(context).unfocus();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Home(datos)),
                );
              }
            },
            child: const Text('Siguiente'),
          ),
        ),
      ])),
//---------------------------------------------------------------------- end body
//---------------------------------------------------------------------- end body
//---------------------------------------------------------------------- end body
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          modeloExcel();
        },
        child: const Icon(
          Icons.question_mark_rounded,
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

//-------------------------------------------------------------------- Funciones
//-------------------------------------------------------------------- Funciones
//-------------------------------------------------------------------- DOCUMENTO EXCEL
  void getFilePath() async {
    try {
      Directory rootPath = Directory("/storage/emulated/0");

      String? filePath = await FilesystemPicker.open(
        title: 'Seleccionar Archivo XSLX',
        context: context,
        rootDirectory: rootPath,
        fsType: FilesystemType.file,
        folderIconColor: Colors.teal,
        allowedExtensions: ['.xlsx'],
        fileTileSelectMode: FileTileSelectMode.wholeTile,
        requestPermission: () async =>
            await Permission.storage.request().isGranted,
      );
      print("ASDASDASDASDASDASDADASDA");
      print(filePath);

      if (filePath == null) {
        return;
      } else {
        setState(() {
          _filePath = filePath;
          // print(_filePath);
          reEscribirDoc('docXlsx.txt', 1);
        });
      }
    } on Exception {
      //print("Error al obtener el archivo: " + e.toString());
      return;
    }
  }

  reEscribirDoc(archivo, invocacion) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final localFile = File('$path/$archivo');
    escribirDoc(localFile, invocacion);
  }

  Future<File> escribirDoc(localFile, invocacion) {
    if (invocacion == 1) {
      print('DOCUMENTO FILEPATH ESCRITO. VALOR: $_filePath');
      return localFile.writeAsString(_filePath);
    } else {
      var nombre = _nombre.text;
      print('DOCUMENTO NOMBRE ESCRITO. VALOR: $nombre');
      return localFile.writeAsString(nombre);
    }
  }

  esXlsx() {
    // ignore: unnecessary_null_comparison
    if ((_filePath == null) ||
        ((_filePath)!.toLowerCase().contains(
              ".xlsx",
              ((_filePath)!.length - 5),
            ))) {
      print('Pasó la validacion, valor: $_filePath');
      return '';
    } else {
      print('No pasó la validacion, valor: $_filePath');
      return 'E';
    }
  }

//------------------------------------------------------------------------------
  iniciarAplicacion() {
    // ignore: unnecessary_null_comparison
    if (_filePath == null) {
      leerArchivoLocal('docXlsx.txt', 1);
      leerArchivoLocal('userName.txt', 2);
      print('APLICACION INICIADA - PAGINA DE INICIO');
      return 'Seleccione un archivo .XLSX';
    } else {
      return _filePath!.substring(_filePath!.lastIndexOf('/') + 1);
    }
  }

  leerArchivoLocal(archivo, invocacion) async {
    final directory = await getApplicationDocumentsDirectory();
    final path = directory.path;
    final localFile = File('$path/$archivo');
    readContenido(localFile, invocacion);
  }

  readContenido(localFile, invocacion) async {
    try {
      String contents = await localFile.readAsString();
      invocacion == 1 ? _filePath = contents : _nombre.text = contents;
      setState(() {});
    } catch (e) {
      print(
          'ERROR: algo salio mal al leer el contenido del archivo. $invocacion');
    }
  }

  void modeloExcel() {
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          children: [
            const SizedBox(height: 10),
            const Center(
              child: Text(
                "Modelo del Excel",
                style: TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(height: 10),
            Image.asset('assets/modelo_excel.png'),
            Container(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  RaisedButton(
                    child: const Text('ACEPTAR'),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
