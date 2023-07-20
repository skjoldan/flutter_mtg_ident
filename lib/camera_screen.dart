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
      _cameraService.controller!.startImageStream(_onImageCaptured);
    } catch (e) {
      print(e);
    }
    setState(() {});
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
          if (identifiedCard.isNotEmpty)
            Positioned(
              bottom: 0,
              child: Text('Identified card: $identifiedCard'),
            ),
          const CircularProgressIndicator()
        ],
      );
    } else {
      return AspectRatio(
        aspectRatio: _cameraService.controller!.value.aspectRatio,
        child: CameraPreview(_cameraService.controller!),
      );
    }
  }

  @override
  void dispose() {
    _cameraService.dispose();
    _tensorflowLight.dispose();
    super.dispose();
  }

  void _onImageCaptured(CameraImage image) async {
    setState(() {
      isProcessing = true;
    });
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
}
