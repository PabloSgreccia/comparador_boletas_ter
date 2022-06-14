// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
// ignore: depend_on_referenced_packages
import 'package:path/path.dart' as pathpack;
// ignore: import_of_legacy_library_into_null_safe
import 'package:excel/excel.dart';
import "dart:collection";
// ignore: import_of_legacy_library_into_null_safe
import 'package:permission_handler/permission_handler.dart';

import 'camera.dart';

class Home extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final _datos;
  const Home(this._datos, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String? _resultadoScanner;
  // ignore: prefer_typing_uninitialized_variables
  var _excel;
  final List _listaMatFull = [];
  final List _listaMatInd = [];
  int contFila = 0;
  final _materialTexto1 = TextEditingController()..text = "";
  final _materialTexto2 = TextEditingController()..text = "";
  String grupoRadio = '';
  late int _cantMatMuestrear;
  late String _cantMatMuestrearTot;
  late FocusNode focusMaterial1;
  late FocusNode focusMaterial2;
  //String _subMaterial = '';
  // bool _verTeclado = false;

  @override
  void dispose() {
    _materialTexto1.dispose();
    _materialTexto2.dispose();
    focusMaterial1.dispose();
    focusMaterial2.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    focusMaterial1 = FocusNode();
    focusMaterial2 = FocusNode();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomPadding: false,
      appBar: AppBar(
        title: Text(
          // ignore: prefer_interpolation_to_compose_strings
          'Usuario: ' + widget._datos[1].toUpperCase(),
        ),
        actions: <Widget>[
          Image.asset('assets/logoternium.jpg'),
        ],
      ),
      body: (SingleChildScrollView(
        child: Column(
          children: [
            //---------------------------------------------------------------------- Material
            //---------------------------------------------------------------------- Material
            //---------------------------------------------------------------------- Material
            // Container(
            //   margin: (MediaQuery.of(context).orientation).toString() ==
            //           'Orientation.landscape'
            //       ? const EdgeInsets.only(top: 10)
            //       : const EdgeInsets.all(20),
            //   child: Text(
            //     // ignore: prefer_interpolation_to_compose_strings
            //     'Último Material: ' + obtenerScan(),
            //     style: const TextStyle(
            //       fontWeight: FontWeight.bold,
            //       fontSize: 20,
            //     ),
            //   ),
            // ),
            //---------------------------------------------------------------------- Input material 1
            ListTile(
              title: TextField(
                // readOnly: _verTeclado ? false : true,
                // onTap: () => _verTeclado = true,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (value) {
                  focusMaterial2.requestFocus();
                },
                // onChanged: (value) {
                //   if (_listaMatInd.contains((value).toUpperCase())) {
                //     _resultadoScanner = value.toUpperCase();
                //     setState(() {});
                //     evaluarMaterial();
                //   }
                // },
                autofocus: true,
                focusNode: focusMaterial1,
                controller: _materialTexto1, // ver esto que onda
                decoration: const InputDecoration(
                  labelText: 'Boleta 1: ',
                ),
              ),
            ),
            //---------------------------------------------------------------------- Input material 2
            ListTile(
              title: TextField(
                // readOnly: _verTeclado ? false : true,
                // onTap: () => _verTeclado = true,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (value) {
                  focusMaterial1.requestFocus();
                },
                // onChanged: (value) {
                //   if (_listaMatInd.contains((value).toUpperCase())) {
                //     _resultadoScanner = value.toUpperCase();
                //     setState(() {});
                //     evaluarMaterial();
                //   }
                // },
                //autofocus: true,
                focusNode: focusMaterial2,
                controller: _materialTexto2,
                decoration: const InputDecoration(
                  labelText: 'Boleta 2: ',
                ),
              ),
            ),
            Container(padding: const EdgeInsets.only(top: 10)),
            RaisedButton(
              onPressed: () {
                if ((_materialTexto1.text != '') &&
                    (_materialTexto2.text != '')) {
                  //setState(() {});
                  evaluarMaterial(); //Esta función tiene la logica para devolver el resultado
                }
              },
              padding: const EdgeInsets.all(15),
              child: const Text("COMPARAR"),
            ),
            Container(
              padding: const EdgeInsets.only(top: 30),
              child: Text(
                // ignore: prefer_interpolation_to_compose_strings
                '${'Boletas Comparadas: ' + getCantMatMuestrear()} / $_cantMatMuestrearTot',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
      )),
      // ),
      //---------------------------------------------------------------------- end body
      //---------------------------------------------------------------------- end body
      //---------------------------------------------------------------------- end body
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () => _openScanner(context),
      //   child: const Icon(Icons.center_focus_strong),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  //---------------------------------------------------------------------------- Funciones
  //---------------------------------------------------------------------------- Funciones
  //---------------------------------------------------------------------------- GET DATA + DOCUMENTO

  excelXtabla() {
    var bytes = File(widget._datos[0]).readAsBytesSync();
    _excel = Excel.decodeBytes(bytes);

    int fila1 = 0;
    _cantMatMuestrear = 0;
    var col = [];
    for (var row in _excel.tables[_excel.tables.keys.first].rows) {
      fila1++;
      if ((fila1 > 1) && (row[1] != null)) {
        var mat = [];
        mat.add(row[0].toString());
        mat.add(row[1].toString());
        mat.add(row[2].toString());
        _listaMatFull.add(mat);
        _listaMatInd.add(row[0].toString());
        col.add(row[1]);
        if (row[2] == 'S') {
          _cantMatMuestrear++;
        }
      }
    }
    List col2 = LinkedHashSet.from(col).toList();
    _cantMatMuestrearTot = (col2.length).toString();
  }

//------------------------------------------------------------------------------

  obtenerScan() {
    // ignore: unnecessary_null_comparison
    if (_resultadoScanner == null) {
      return ' - ';
    } else {
      return _resultadoScanner;
    }
  }

//------------------------------------------------------------------------------ Scanner
//------------------------------------------------------------------------------ Scanner
//------------------------------------------------------------------------------ Scanner

  // Future _openScanner(BuildContext context) async {
  //   final result = await Navigator.push(
  //       context, MaterialPageRoute(builder: (c) => const Scanner()));
  //   _resultadoScanner = result;
  //   //_materialTexto.text = result;
  //   setState(() {});
  //   evaluarMaterial();
  // }

  evaluarMaterial() async {
    // ignore: unnecessary_null_comparison
    if (_resultadoScanner == null) {
      return;
    }
    //Crea el array interno con el excel
    if (_listaMatFull.isEmpty) {
      excelXtabla();
    }

    if (_listaMatInd.contains(_resultadoScanner)) {
      var posicion = _listaMatInd.indexOf(_resultadoScanner);
      var colada = _listaMatFull[posicion][1];

      String originalValue = _listaMatFull[posicion][2];

      //Devuelve pop-up en funcion del valor                                    ### OPCIONES 1, 2 Y 3
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
              contentPadding: const EdgeInsets.all(0),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6)),
              children: [
                Container(
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          topLeft: Radius.circular(6)),
                      color: (originalValue == 'N')
                          ? Colors.greenAccent[700]
                          : (originalValue == 'S')
                              ? Colors.yellowAccent[700]
                              : Colors.redAccent[700]),
                  height: 50,
                  child: Center(
                      child: Text(
                    _resultadoScanner!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  )),
                ),
                Container(
                    padding: const EdgeInsets.only(
                        top: 20, bottom: 20, left: 10, right: 10),
                    child: originalValue == 'X'
                        ? const Center(
                            child: Text("Identificar material para muestrear."))
                        : originalValue == 'N'
                            ? const Center(
                                child: Text("No debe muestrear este material."))
                            : const Center(
                                child: Text(
                                    "Material ya identificado para muestrear.")) // originalValue == 'S'
                    ),
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

      //Si el material analizado esta en X                                      ### --> Pone en 'S' si es 'X'
      if (originalValue == 'X') {
        final Sheet sheet = _excel.tables[_excel.tables.keys.first];

        int filaAux = 0;
        for (var mat in _listaMatFull) {
          filaAux++;
          //if (mat[0] != _resultadoScanner && mat[1] == colada) {
          if (mat[1] == colada) {
            //Actualiza materiales de la misma colada (excel y lista)
            var cell = sheet.cell(CellIndex.indexByString("C${filaAux + 1}"));
            cell.value = "N";
            mat[2] = "N";
          }
        }

        //Actualiza material a muestrear (excel y lista)
        String posicionAux = (posicion + 2).toString();
        var cell = sheet.cell(CellIndex.indexByString('C$posicionAux'));
        //print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
        //print(sheet.cell(CellIndex.indexByString('C$posicionAux')));
        cell.value = 'S';
        _listaMatFull[posicion][2] = 'S';
        _cantMatMuestrear++;
        var cellNom = sheet.cell(CellIndex.indexByString('D$posicionAux'));
        cellNom.value = widget._datos[1];

        var status = await Permission.storage.status;
        if (!status.isGranted) {
          await Permission.storage.request();
        }

        _excel.encode().then((onValue) {
          File(pathpack.join(widget._datos[0]))
            ..createSync(recursive: true)
            ..writeAsBytesSync(onValue);
        });
      }
      //Si el material analizado NO EXISTE                                      ### OPCION 4
    } else {
      showDialog(
          context: context,
          builder: (context) {
            return SimpleDialog(
                contentPadding: const EdgeInsets.all(0),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6)),
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(6),
                          topLeft: Radius.circular(6)),
                      color: Colors.blueGrey[400],
                    ),
                    height: 50,
                    child: Center(
                        child: Text(
                      _resultadoScanner!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.bold),
                    )),
                  ),
                  Container(
                      padding: const EdgeInsets.only(
                          top: 20, bottom: 20, left: 10, right: 10),
                      child: const Center(
                        child: Text(
                          'ERROR: Material no encontrado.',
                          style: TextStyle(fontSize: 16),
                        ),
                      )),
                  Container(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          RaisedButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Aceptar'),
                          ),
                        ],
                      )),
                ]);
          });
    }
    _materialTexto1.text = '';
    focusMaterial1.requestFocus();
  }

  getCantMatMuestrear() {
    if (_listaMatFull.isEmpty) {
      excelXtabla();
    }
    return _cantMatMuestrear.toString();
  }
}
