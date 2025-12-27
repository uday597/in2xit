import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:my_gate_clone/features/members/providers/guest.dart';
import 'package:my_gate_clone/features/security_guard/screens/guestdetails.dart';
import 'package:provider/provider.dart';

class GuardQRScannerScreen extends StatefulWidget {
  const GuardQRScannerScreen({super.key});

  @override
  State<GuardQRScannerScreen> createState() => _GuardQRScannerScreenState();
}

class _GuardQRScannerScreenState extends State<GuardQRScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool isProcessing = false;
  @override
  void dispose() {
    super.dispose();
    controller.stop();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RequestProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Camera scanner
          MobileScanner(
            controller: controller,
            onDetect: (capture) async {
              if (isProcessing) return;
              isProcessing = true;

              final barcode = capture.barcodes.first;
              final String? qr = barcode.rawValue;

              if (qr != null) {
                final data = await provider.fetchRequestByQR(qr);
                if (data != null) {
                  if (!mounted) return;

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          GuestRequestDetailForGuard(requestData: data.toMap()),
                    ),
                  ).then((value) {
                    isProcessing = false;
                    controller.start();
                  });
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Invalid QR code")),
                  );
                  isProcessing = false;
                }
              } else {
                isProcessing = false;
              }
            },
          ),

          // dark overlay
          Container(color: Colors.black.withOpacity(0.3)),

          // Page title
          Positioned(
            top: 60,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Scan QR Code",
                style: TextStyle(
                  fontSize: 22,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          // Back button
          Positioned(
            top: 50,
            left: 15,
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.white.withOpacity(0.2),
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  controller.stop();
                  Navigator.pop(context);
                },
              ),
            ),
          ),

          // Scanner frame
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.blueAccent, width: 3),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blueAccent.withOpacity(0.4),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),

          // Animated scanning line
          Center(
            child: TweenAnimationBuilder(
              tween: Tween(begin: 0.0, end: 250.0),
              duration: const Duration(seconds: 2),
              curve: Curves.easeInOut,
              onEnd: () {},
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, value - 125),
                  child: Container(
                    width: 220,
                    height: 2,
                    color: Colors.redAccent,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
