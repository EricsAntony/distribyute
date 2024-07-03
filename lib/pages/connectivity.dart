import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';

class ConnectivityStatusWidget extends StatefulWidget {
  final Function? onConnectionRestored;

  const ConnectivityStatusWidget({Key? key, this.onConnectionRestored})
      : super(key: key);

  @override
  _ConnectivityStatusWidgetState createState() =>
      _ConnectivityStatusWidgetState();
}

class _ConnectivityStatusWidgetState extends State<ConnectivityStatusWidget> {
  late StreamSubscription<ConnectivityResult> subscription;
  PersistentBottomSheetController? bottomSheetController;
  bool isOnline = true; // Variable to track connectivity status

  @override
  void initState() {
    super.initState();
    subscription =
        Connectivity().onConnectivityChanged.listen(showConnectivityBottomSheet);
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }

  //Methods
  //show no connection

  void showConnectivityBottomSheet(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      isOnline = false; // Update connectivity status
      bottomSheetController ??= Scaffold.of(context).showBottomSheet(
            (context) => IgnorePointer(
          ignoring: true,
          child: Container(
            height: MediaQuery.of(context).size.height / .5,
            color: Colors.white,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'lib/images/no conn.webp',
                  height: 500,
                  width: 500,
                ),
                const SizedBox(height: 2),
                Text(
                  "You're offline!",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  "Your activities while offline, will not be saved...",
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
      );
      bottomSheetController!.closed.then((value) {
        Future.delayed(const Duration(milliseconds: 500), () {
          if (!isOnline) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.not_interested_outlined, color: Colors.white),
                    Text(
                      '  No internet connection',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
                backgroundColor: Colors.grey,
                duration: Duration(days: 1),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        });
      });
    } else {
      isOnline = true; // Update connectivity status
      if (bottomSheetController != null) {
        bottomSheetController!.close();
        bottomSheetController = null;
      }

      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check, color: Colors.white),
              Text(
                ' Back Online!',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
        ),
      );

      if (widget.onConnectionRestored != null) {
        widget.onConnectionRestored!();
      }
    }
  }
}
