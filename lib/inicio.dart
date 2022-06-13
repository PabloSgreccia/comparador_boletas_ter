// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
// ignore: import_of_legacy_library_into_null_safe
import 'package:file_picker/file_picker.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:path_provider/path_provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:excel/excel.dart';

import 'home.dart';

class Inicio extends StatefulWidget {
  const Inicio({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _InicioState createState() => _InicioState();
}

class _InicioState extends State<Inicio> {
  String? _filePath;
  final _nombre = TextEditingController()..text = '';
  final _pass = TextEditingController()..text = '';
  late FocusNode _focusNombre;
  // ignore: prefer_typing_uninitialized_variables
  var _excel;

  @override
  void initState() {
    super.initState();
    _focusNombre = FocusNode();
  }

  @override
  void dispose() {
    _nombre.dispose();
    _pass.dispose();
    _focusNombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: const Text('Ternium - Muestreo Muelle'),
        actions: <Widget>[
          Image.asset('assets/logoternium.jpg'),
        ],
      ),
//---------------------------------------------------------------------- Body
//---------------------------------------------------------------------- Body
//---------------------------------------------------------------------- Body
      body: (Column(children: [
        ListTile(
          contentPadding: const EdgeInsets.only(top: 10.0, left: 15),
          leading: RaisedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  return SimpleDialog(
                    contentPadding: const EdgeInsets.all(0),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6)),
                    children: [
                      Container(
                        padding: const EdgeInsets.only(
                            top: 20, bottom: 20, left: 10, right: 10),
                        child: Center(
                          child: TextField(
                            controller: _pass,
                            decoration: const InputDecoration(
                              labelText: 'Constraseña: ',
                            ),
                            obscureText: true,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            RaisedButton(
                              onPressed: () {
                                if (_pass.text == '123') {
                                  _pass.text = '';
                                  getFilePath();
                                }
                                Navigator.pop(context);
                              },
                              child: const Text('Aceptar'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
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
//---------------------------------------------------------------------- Usuario
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
                datos.add(_filePath);
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
            // ignore: unnecessary_null_comparison
            if (_filePath == null) {
              leerArchivoLocal('docXlsx.txt', 1);
            }
            if (esXlsx() == '') {
              cantidadMuestra();
            }
          },
          child: const Icon(
            Icons.confirmation_number,
          )),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

//-------------------------------------------------------------------- Funciones
//-------------------------------------------------------------------- Funciones
//-------------------------------------------------------------------- DOCUMENTO EXCEL
  void getFilePath() async {
    try {
      // ignore: avoid_print
      print("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA");
      FilePickerResult? filePath = await FilePicker.platform.pickFiles();
      if (filePath == null) {
        return;
      } else {
        setState(() {
          _filePath = filePath.files.single.path;
          // ignore: avoid_print
          print("BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB");
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
      // ignore: avoid_print
      print('DOCUMENTO FILEPATH ESCRITO. VALOR: $_filePath');
      return localFile.writeAsString(_filePath);
    } else {
      var nombre = _nombre.text;
      // ignore: avoid_print
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
      // ignore: avoid_print
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
      // ignore: avoid_print
      print(
          'ERROR: algo salio mal al leer el contenido del archivo. $invocacion');
    }
  }

  void cantidadMuestra() {
    var bytes = File(_filePath!).readAsBytesSync();
    _excel = Excel.decodeBytes(bytes);

    int contCantMuestras = 0;
    for (var row in _excel.tables[_excel.tables.keys.first].rows) {
      if (row[2] == 'S') {
        contCantMuestras++;
      }
    }

    showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            contentPadding: const EdgeInsets.all(0),
            title: const Text('Materiales a muestrear:'),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            children: [
              Container(
                  padding: const EdgeInsets.only(bottom: 10, top: 10),
                  child: Center(
                    child: Text(
                      contCantMuestras.toString(),
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )),
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
                  )),
            ],
          );
        });
  }
}
