//import 'Model.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';

class TensorFlowLight {
//  late Model model;

  Future<void> loadModel(String path) async {
    String? res = await Tflite.loadModel(
      model: path,
      labels: 'assets/labels.txt', //if you have a labels file
    );
    print(res ??
        'Model loading failed.'); // use null coalescing operator to print a default message if res is null
  }

  Future<List> predict(CameraImage image) async {
    var recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) {
          return plane.bytes; // get bytes of each camera image plane
        }).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5, // these values depend on your model
        imageStd: 127.5, // these values depend on your model
        rotation: 90, // depend on how you are holding the device
        numResults: 2, // number of results to return per prediction
        threshold: 0.1, // threshold for prediction score
        asynch: true // run inference in a separate isolate
        );
    return recognitions ?? [];
  }

  void dispose() {
    Tflite.close(); // don't forget to close Tflite when not needed
  }
}
