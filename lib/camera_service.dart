import 'package:camera/camera.dart';

class CameraService {
  List<CameraDescription> cameras = [];
  CameraController? controller;

  Future<void> getCameras() async {
    cameras = await availableCameras();
  }

  Future<void> initCamera() async {
    if (cameras.isEmpty) {
      print('No camera is found');
    } else {
      controller = CameraController(cameras[0], ResolutionPreset.medium);
      await controller!.initialize();
    }
  }

  void dispose() {
    controller?.dispose();
  }
}
