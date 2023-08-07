import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:wordmatch/main.dart';
import 'package:wordmatch/providers/session_state_provider.dart';
import 'package:wordmatch/utils/socket_methods.dart';

class ResultPage extends StatefulWidget {
  const ResultPage({Key? key}) : super(key: key);

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  final SocketMethods _socketMethods = SocketMethods();

  @override
  Widget build(BuildContext context) {
    final sessionStateNotifier = context.read<SessionStateProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('WordMatch!'),
        leading: const Text(''),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: Text(
                sessionStateNotifier.sessionState.result!
                    ? 'You Win!'
                    : 'You Lose!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 40,
                  color: sessionStateNotifier.sessionState.result!
                      ? Colors.green
                      : Colors.red,
                ),
              ),
            ),
            ElevatedButton(
                onPressed: () {
                  _socketMethods.disconnectToHome(context);
                },
                style: ButtonStyle(
                  fixedSize:
                      MaterialStateProperty.all<Size>(const Size(100, 50)),
                ),
                child: const Text('Menu')),
          ],
        ),
      ),
    );
  }
}
