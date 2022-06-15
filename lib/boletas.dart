// ignore_for_file: deprecated_member_use

import 'dart:ffi';

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

class Home extends StatefulWidget {
  // ignore: prefer_typing_uninitialized_variables
  final _datos;
  const Home(this._datos, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // String? _resultadoScanner;
  // ignore: prefer_typing_uninitialized_variables
  var _excel;
  final List _listaMatFull = [];
  // final List _listaMatInd = [];
  final List _listaBoletas = [];
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
            //---------------------------------------------------------------------- Input material 1
            ListTile(
              title: TextField(
                // readOnly: _verTeclado ? false : true,
                // onTap: () => _verTeclado = true,
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (value) {
                  focusMaterial2.requestFocus();
                },
                onChanged: (value) {
                  // print("Valor de _materialTexto2:" + _materialTexto2.text);
                  if (_listaBoletas.contains((value).toUpperCase())) {
                    if (_materialTexto2.text != "") {
                      evaluarMaterial(
                          _materialTexto1.text, _materialTexto2.text);
                    } else {
                      focusMaterial2.requestFocus();
                    }
                    // _resultadoScanner = value.toUpperCase();
                    // setState(() {});
                    // evaluarMaterial();
                  }
                },
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
                textCapitalization: TextCapitalization.characters,
                onSubmitted: (value) {
                  focusMaterial1.requestFocus();
                },
                onChanged: (value) {
                  if (_listaBoletas.contains((value).toUpperCase())) {
                    if (_materialTexto1.text != "") {
                      evaluarMaterial(
                          _materialTexto1.text, _materialTexto2.text);
                    } else {
                      focusMaterial1.requestFocus();
                    }
                  }
                },
                focusNode: focusMaterial2,
                controller: _materialTexto2,
                decoration: const InputDecoration(
                  labelText: 'Boleta 2: ',
                ),
              ),
            ),
            //---------------------------------------------------------------------- Boton
            Container(padding: const EdgeInsets.only(top: 10)),
            RaisedButton(
              onPressed: () {
                if ((_materialTexto1.text != '') &&
                    (_materialTexto2.text != '')) {
                  //setState(() {});
                  evaluarMaterial(_materialTexto1.text, _materialTexto2.text);
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
    // var col = [];
    for (var row in _excel.tables[_excel.tables.keys.first].rows) {
      fila1++;
      if ((fila1 > 1) && (row[1] != null)) {
        var mat = [];
        mat.add(row[0].toString());
        mat.add(row[1].toString());
        mat.add(row[2].toString());
        _listaMatFull.add(mat);
        _listaBoletas.add(row[0].toString());
        _listaBoletas.add(row[1].toString());
        // col.add(row[1]);
        if (row[2] == 'X') {
          _cantMatMuestrear++;
        }
      }
    }
    // List col2 = LinkedHashSet.from(col).toList();
    print(_listaMatFull);
    _cantMatMuestrearTot = (_listaBoletas.length ~/ 2).toString();
  }

//------------------------------------------------------------------------------

  // obtenerScan() {
  //   // ignore: unnecessary_null_comparison
  //   if (_resultadoScanner == null) {
  //     return ' - ';
  //   } else {
  //     return _resultadoScanner;
  //   }
  // }

//------------------------------------------------------------------------------ Scanner
//------------------------------------------------------------------------------ Scanner
//------------------------------------------------------------------------------ Scanner
  evaluarMaterial(boleta1, boleta2) async {
    if (_listaMatFull.isEmpty) {
      excelXtabla();
    }

    //usar _listaBoletas y _listaMatFull
    if ((_listaBoletas.contains(boleta1)) &&
        (_listaBoletas.contains(boleta2))) {
      int contador = 1;
      for (var fila in _listaMatFull) {
        contador = contador + 1;
        if (((fila[0] == boleta1) && (fila[1] == boleta2)) ||
            ((fila[0] == boleta2) && (fila[1] == boleta1))) {
          if (fila[2] == 'X') {
            mostrarMensaje(2, boleta1, boleta2);
            break;
          } else {
            //agregar posicion
            await mostrarMensaje(1, boleta1, boleta2, contador);
            break;
          }
        }

        if ((fila[0] == boleta1) && (fila[1] != boleta2)) {
          // mostrar mensaje que la boleta1 debe ir con fila[1]
          mostrarMensaje(3, boleta1, fila[1]);
          break;
        }
        if ((fila[1] == boleta1) && (fila[0] != boleta1)) {
          // mostrar mensaje que la boleta2 debe ir con fila[0]
          mostrarMensaje(3, boleta1, fila[0]);
          break;
        }
      }
    } else if (!_listaBoletas.contains(boleta1)) {
      mostrarMensaje(4, boleta1, boleta2);
    } else if (!_listaBoletas.contains(boleta2)) {
      mostrarMensaje(5, boleta1, boleta2);
    }
  }

  // estados: 2=ya se comparó, 1=ok, 3=mal comparado, 4=no existe bol1, 5=no existe bol2;
  //Devuelve pop-up en funcion del valor
  mostrarMensaje(int estado, String bol1, String bol2, [posicionv2]) async {
    // ignore: unrelated_type_equality_checks
    showDialog(
      context: context,
      builder: (context) {
        return SimpleDialog(
          contentPadding: const EdgeInsets.all(0),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(6),
                      topLeft: Radius.circular(6)),
                  color: (estado == 1)
                      ? Colors.greenAccent[700]
                      : (estado == 2)
                          ? Colors.yellowAccent[700]
                          : (estado == 3)
                              ? Colors.redAccent[700]
                              : Colors.grey[700]),
              height: 50,
              child: Center(
                child: estado == 1
                    ? const Center(
                        child: Text(
                          "OK",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      )
                    : estado == 2
                        ? const Center(
                            child: Text(
                              "Repetido",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          )
                        : estado == 3
                            ? const Center(
                                child: Text(
                                  "Asociación Erronea",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : const Center(
                                child: Text(
                                  "Inexistente",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
              ),
            ),
            Container(
              padding: const EdgeInsets.only(
                  top: 20, bottom: 20, left: 10, right: 10),
              child: estado == 1
                  ? Center(
                      child: Text(
                        "Boleta 1: $bol1\nBoleta 2: $bol2",
                        style: const TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    )
                  : estado == 2
                      ? Center(
                          child: Text(
                            "Boleta 1: $bol1\nBoleta 2: $bol2",
                            style: const TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        )
                      : estado == 3
                          ? Center(
                              child: Text(
                                "La boleta $bol1 debe asociarse con la boleta $bol2",
                                style: const TextStyle(
                                  fontSize: 20,
                                ),
                              ),
                            )
                          : estado == 4
                              ? Center(
                                  child: Text(
                                    "Boleta 1: $bol1 inexistente",
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                )
                              : Center(
                                  child: Text(
                                    "Boleta 2: $bol2 inexistente",
                                    style: const TextStyle(
                                      fontSize: 20,
                                    ),
                                  ),
                                ),
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
              ),
            ),
          ],
        );
      },
    );

    //Dentro de este IF se actualiza el estado del material en el excel
    if (estado == 1) {
      print("bueno, vamos a editar el documento");
      print("La posicion es: $posicionv2");

      final Sheet sheet = _excel.tables[_excel.tables.keys.first];
      //Actualiza material a muestrear (en el excel y la lista)
      String posicionAux = (posicionv2).toString();
      var cell = sheet.cell(CellIndex.indexByString('C$posicionAux'));
      print('AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA');
      //print(sheet.cell(CellIndex.indexByString('C$posicionAux')));
      cell.value = 'X';
      _listaMatFull[posicionv2 - 2][2] = 'X';
      print(_listaMatFull);
      print(_cantMatMuestrear);
      setState(() {
        _cantMatMuestrear++;
      });
      print("Modificado: $_cantMatMuestrear");
      var cellNom = sheet.cell(CellIndex.indexByString('D$posicionAux'));
      cellNom.value = widget._datos[1];

      var status = await Permission.storage.status;
      if (!status.isGranted) {
        print("tenemos que pedir permisos");
        await Permission.storage.request();
      }

      print("vamos a guardar el excel");
      _excel.encode().then(
        (onValue) {
          File(pathpack.join(widget._datos[0]))
            ..createSync(recursive: true)
            ..writeAsBytesSync(onValue);
          print("supuestamente guardamos el excel");
        },
      );
    }

    _materialTexto1.text = '';
    _materialTexto2.text = '';
    focusMaterial1.requestFocus();
  }

  getCantMatMuestrear() {
    if (_listaMatFull.isEmpty) {
      excelXtabla();
    }
    return _cantMatMuestrear.toString();
  }
}
