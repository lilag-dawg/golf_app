import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:ffi/ffi.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as imglib;

import 'ImagePreview.dart';

typedef convert_func = Pointer<Uint32> Function(Pointer<Uint8>, Int32, Int32);
typedef Convert = Pointer<Uint32> Function(Pointer<Uint8>, int, int);

class TakePictureScreen extends StatefulWidget {
  final CameraDescription camera;

  const TakePictureScreen({
    Key key,
    @required this.camera,
  }) : super(key: key);

  @override
  _TakePictureScreenState createState() => _TakePictureScreenState();
}

class _TakePictureScreenState extends State<TakePictureScreen> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  CameraImage _savedImage;

  final DynamicLibrary convertImageLib = Platform.isAndroid
      ? DynamicLibrary.open("libconvertImage.so")
      : DynamicLibrary.process();
  //Convert yuvTOrgb;
  Convert yuvTOgrayscale;

  @override
  void initState() {
    super.initState();
    // To display the current output from the camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );

    // Load the convertImage() function from the library
    yuvTOgrayscale = convertImageLib
        .lookup<NativeFunction<convert_func>>('yuvTOgrayscale')
        .asFunction<Convert>();

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      _controller.startImageStream((image) => _processCameraImageStream(image));
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  void _processCameraImageStream(CameraImage image) {
    setState(() {
      _savedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Take a picture')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing.
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            //print(MediaQuery.of(context).orientation); // todo link phone orientation with camera orientation
            return Stack(
              fit: StackFit.expand,
              children: [
                CameraPreview(_controller),
                Text("waddup"),
              ],
            );
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.

          try {
            Stopwatch stopwatch = Stopwatch()..start();
            Pointer<Uint8> p = calloc(_savedImage.planes[0].bytes.length);
            Pointer<Uint8> p1 = calloc(_savedImage.planes[1].bytes.length);
            Pointer<Uint8> p2 = calloc(_savedImage.planes[2].bytes.length);

            // Assign the planes data to the pointers of the image
            Uint8List pointerList =
                p.asTypedList(_savedImage.planes[0].bytes.length);
            Uint8List pointerList1 =
                p1.asTypedList(_savedImage.planes[1].bytes.length);
            Uint8List pointerList2 =
                p2.asTypedList(_savedImage.planes[2].bytes.length);
            pointerList.setRange(0, _savedImage.planes[0].bytes.length,
                _savedImage.planes[0].bytes);
            pointerList1.setRange(0, _savedImage.planes[1].bytes.length,
                _savedImage.planes[1].bytes);
            pointerList2.setRange(0, _savedImage.planes[2].bytes.length,
                _savedImage.planes[2].bytes);

            // Call the convertImage function and convert the YUV to grayscale
            Pointer<Uint32> imgP = yuvTOgrayscale(
                p, _savedImage.planes[0].bytesPerRow, _savedImage.height);
            List imgData =
                imgP.asTypedList((_savedImage.width * _savedImage.height));

            // Generate image from the converted data
            imglib.Image img = imglib.Image.fromBytes(
                _savedImage.height, _savedImage.width, imgData);

            print("4 =====> ${stopwatch.elapsedMilliseconds}");
            // Free the memory space allocated
            // from the planes and the converted data
            calloc.free(p);
            calloc.free(p1);
            calloc.free(p2);
            calloc.free(imgP);

            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ImagePreview(img: img)));
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
      ),
    );
  }
}
