// Centered loading indicator with optional message
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final String? message;
  const LoadingWidget({Key? key, this.message}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(message!),
          ]
        ],
      ),
    );
  }
}
