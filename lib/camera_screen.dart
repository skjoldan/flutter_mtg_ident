import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'camera_service.dart';
import 'tensorflow_light.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({Key? key}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraService _cameraService;
  late TensorFlowLight _tensorflowLight;
  bool isProcessing = false;
  String identifiedCard = '';

  @override
  void initState() {
    super.initState();
    _cameraService = CameraService();
    _tensorflowLight = TensorFlowLight();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      await _cameraService.getCameras();
      await _cameraService.initCamera();
      await _tensorflowLight.loadModel('path/to/model.tflite');
      _cameraService.controller!.startImageStream((image) async {
        if (!isProcessing) {
          setState(() {
            isProcessing = true;
          });

          // Pass the image to the model
          List<dynamic> predictions = await _tensorflowLight.predict(image);
          print(predictions);
          if (predictions.isNotEmpty) {
            identifiedCard = predictions[
                0]; // assuming the card name is the first element in the predictions list
          }
          setState(() {
            isProcessing = false;
          });
        }
      });
    } catch (e) {
      print(e);
    }
    setState(() {});
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _tensorflowLight.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_cameraService.controller == null ||
        !_cameraService.controller!.value.isInitialized) {
      return Container();
    } else if (isProcessing) {
      return Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: _cameraService.controller!.value.aspectRatio,
            child: CameraPreview(_cameraService.controller!),
          ),
          const CircularProgressIndicator()
        ],
      );
    } else {
      return Stack(
        children: <Widget>[
          AspectRatio(
            aspectRatio: _cameraService.controller!.value.aspectRatio,
            child: CameraPreview(_cameraService.controller!),
          ),
          Positioned(
            left: 50, // adjust as needed
            top: 50, // adjust as needed
            child: Container(
              width: 200, // adjust as needed
              height: 300, // adjust as needed
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.red, // color of the box
                  width: 3, // width of the box border
                ),
              ),
            ),
          ),
          if (identifiedCard.isNotEmpty)
            Positioned(
              bottom: 0,
              child: Text('Identified card: $identifiedCard'),
            ),
        ],
      );
    }
  }
}
