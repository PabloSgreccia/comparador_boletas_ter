import 'package:flutter/material.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:qr_code_scanner/qr_code_scanner.dart';

class Scanner extends StatefulWidget {
  const Scanner({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ScannerState createState() => _ScannerState();
}

class _ScannerState extends State<Scanner> {
  bool _flashOn = false;
  final GlobalKey _qrKey = GlobalKey();
  late QRViewController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          QRView(
            key: _qrKey,
            overlay: QrScannerOverlayShape(borderColor: Colors.white),
            onQRViewCreated: (QRViewController controller) {
              _controller = controller;

              controller.scannedDataStream.listen(
                (val) {
                  if (mounted) {
                    _controller.dispose();
                    Navigator.pop(context, val);
                  }
                },
              );
            },
          ),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              margin: const EdgeInsets.only(top: 60),
              child: const Text(
                'Scanner',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: ButtonBar(
              alignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  color: Colors.white,
                  icon: Icon(_flashOn ? Icons.flash_on : Icons.flash_off),
                  onPressed: () {
                    setState(
                      () {
                        _flashOn = !_flashOn;
                      },
                    );
                    _controller.toggleFlash();
                  },
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.refresh),
                  // icon: Icon(_fronCam ? Icons.camera_front : Icons.camera_rear),
                  onPressed: () {
                    // setState(
                    //   () {
                    //     _fronCam = !_fronCam;
                    //   },
                    // );
                    //_controller.flipCamera();
                    _controller.pauseCamera();
                    _controller.resumeCamera();
                  },
                ),
                IconButton(
                  color: Colors.white,
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
