import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class SocketClient {
  IO.Socket? socket;
  static SocketClient? _instance;

  SocketClient._internal() {
    // Load environment variables from the .env file
    dotenv.load(fileName: ".env");

    // URL is for deployment, use testURL for development
    // final url = dotenv.env['URL'];
    final testURL = dotenv.env['TEST_URL'];

    socket = IO.io(testURL!, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });
    socket!.connect();
  }

  static SocketClient get instance {
    _instance ??= SocketClient._internal();
    return _instance!;
  }

  void dispose() {
    socket?.disconnect();
    socket = null;
    _instance = null;
  }
}
