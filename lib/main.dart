import 'dart:async';
import 'dart:developer';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_accessibility_service/accessibility_event.dart';
import 'package:flutter_accessibility_service/constants.dart';
import 'package:flutter_accessibility_service/flutter_accessibility_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter_overlay_window/flutter_overlay_window.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';




@pragma("vm:entry-point")
void overlayMain() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: OverlayScreen(),
    ),
  );
}

class OverlayScreen extends StatefulWidget {
  const OverlayScreen({Key? key}) : super(key: key);

  @override
  State<OverlayScreen> createState() => _OverlayScreenState();
}

class _OverlayScreenState extends State<OverlayScreen> {
  late AudioPlayer _audioPlayer;
  bool isSpeaking = false;
  AudioPlayer? _player;

  void _play() {
    _player?.dispose();
    final player = _player = AudioPlayer();
    player.play(AssetSource('whatsappOverlayAudio.mp3'));
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _player?.dispose(); // Stop audio when overlay is closed
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: Container(
          margin: EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: Color(0xCCF0F0F0), // Soft gray with transparency
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 2), // Add a slight drop shadow
              ),
            ],
          ),
          child: ClipRRect( // Clip the rounded corners
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Prevent unnecessary space
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      SizedBox(width: 30,),
                      Text(
                        'SenioGuide',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold), // Larger and bolder text
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(
                          icon: Icon(Icons.close, color: Colors.red,size: 30,), // Red close button
                          onPressed: () {
                            _player?.dispose(); // Stop audio when overlay is manually closed
                            _closeOverlay();
                          },
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      OptionButton(
                        icon: FontAwesomeIcons.image, // Using FontAwesome icon here
                        text: 'Send Image',
                        onPressed: () {
                          // Add functionality for sending image to contact
                          _incrementCounter(1);
                        },
                        color: Colors.red,
                      ),
                      OptionButton(
                        icon: Icons.message,
                        text: 'Send Text',
                        onPressed: () {
                          // Add functionality for sending text to contact
                          _incrementCounter(2);
                        },
                        color: Colors.green,
                      ),
                      OptionButton(
                        icon: FontAwesomeIcons.video, // Using FontAwesome icon here
                        text: 'Video Call',
                        onPressed: () {
                          // Add functionality for initiating video call to contact
                          _incrementCounter(3);
                        },
                        color: Colors.blue,
                      ),

                    ],
                  ),
                  SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: (){_incrementCounter(1);},
                        child: Row(children: [Icon(Icons.phone),SizedBox(width: 10,),Text('Phone Call')]),
                      ),
                      IconButton(
                        icon: isSpeaking ? Icon(Icons.volume_off,size: 40,) : Icon(Icons.volume_up,size: 40,),
                        onPressed: () {
                          // _speakText("This screen lets you easily connect with loved ones! Here's how to use it: Tap the big red X in the corner to close it anytime. Sending a picture? Tap the red camera button to choose a photo and share it with a friend or family member. Need to send a text message? Tap the green message bubble button to type and send a text.Want to see someone face-to-face? Tap the blue video camera button to start a video call.");
                          _play();
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _incrementCounter(int data) async {
    final isSent = await FlutterOverlayWindow.shareData(data);
    log('[OverlayScreen] Is message sent: $isSent');
    _player?.dispose();
    _closeOverlay();
  }

  Future<void> _closeOverlay() async {
    await FlutterOverlayWindow.closeOverlay();
  }
}

class OptionButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color color;

  const OptionButton({
    Key? key,
    required this.icon,
    required this.text,
    required this.onPressed,
    required this.color,

  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon,color: color,size: 40,),
          onPressed: onPressed,
        ),
        Text(text),
      ],
    );
  }
}





void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<AccessibilityEvent>? _subscription;
  StreamSubscription<AccessibilityEvent>? _imageFlowSubscription;
  StreamSubscription<dynamic>? _overlayListener;
  List<AccessibilityEvent?> events = [];
  DateTime eventDateTime = DateTime.now();
  

  @override
  void initState() {
    super.initState();
    _overlayListener = FlutterOverlayWindow.overlayListener.listen((data) {
      log("[MainAppScreen] Event from overlay: $data");
      if (!mounted) return;
      if(data==1){
        log("Running sendImageFlow");
        sendImageFlow();
      }else if(data == 2){
        //sendTextFlow();
        log("Running sendTextFlow");
      }else if(data == 3){
        //sendVideoCallFlow();
        log("Running sendVideoCallFlow");
      }
      log("Data fetched from Overlay");
    });
  }

  @override
  void dispose() {
    _overlayListener?.cancel();
    super.dispose();
  }

  Future<void> _runMethod(
    BuildContext context,
    Future<void> Function() method,
  ) async {
    try {
      await method();
    } catch (error) {
      log(
        name: 'MergedApp',
        error.toString(),
      );
      log('Error: $error');
    }
  }

  // void showOverlayWindow() async {
  //   final bool status = await FlutterOverlayWindow.isPermissionGranted();
  //   if (!status) {
  //     await FlutterOverlayWindow.requestPermission();
  //   }

  //   // Specify the dimensions of the overlay
  //   // final double overlayWidth = 300; // Adjust width as needed
  //   // final double overlayHeight = 200; // Adjust height as needed

  //   // // Calculate the position of the overlay to center it on the screen
  //   // final double screenWidth = MediaQuery.of(context).size.width;
  //   // final double screenHeight = MediaQuery.of(context).size.height;
  //   // final double overlayX = (screenWidth - overlayWidth) / 2;
  //   // final double overlayY = (screenHeight - overlayHeight) / 2;

  //   // Show the overlay with custom dimensions and position
  //   await FlutterOverlayWindow.showOverlay(
  //     height: 200,
  //     width: 300,
  //     alignment: OverlayAlignment.center,
  //     visibility: NotificationVisibility.visibilityPublic,
  //     overlayTitle: "Hello from BSC",
  //     enableDrag: true,
      
  //   );
  // }
  void handleAccessiblityStream() {
    if (_subscription?.isPaused ?? false) {
      _subscription?.resume();
      return;
    }
    _subscription =
        FlutterAccessibilityService.accessStream.listen((event) async {
      setState(() {
        events.add(event);
      });
    // automateWikipedia(event);
    if (event.packageName!.contains('whatsapp')){
      if(!(await FlutterOverlayWindow.isPermissionGranted())){ 
        await FlutterOverlayWindow.requestPermission();
    }
      await FlutterOverlayWindow.showOverlay();
      events.clear();
      log("Event: $events");
      _subscription?.cancel();
      }

    // sendImageFlow(event);
    });
  }

void sendImageFlow() async {
  log("Entered ImageFlow");
  bool searchItemFound = false;
  bool editFieldFound = false;
  bool linkItemFound = false;
  bool galleryItemFound = false;

  if (_imageFlowSubscription?.isPaused ?? false) {
    _imageFlowSubscription?.resume();
    return;
  }

  _imageFlowSubscription =
      FlutterAccessibilityService.accessStream.listen((event) async {
    setState(() {
      events.add(event);
    });

    log(events.toString());

    if (!searchItemFound) {
      final searchItem = [...event.subNodes!, event].firstWhereOrNull(
        (element) => element.nodeId == 'com.whatsapp:id/menuitem_search',
      );
      if (searchItem != null) {
        await doAction(searchItem, NodeAction.actionClick);
        searchItemFound = true;
      }
    } else if (!editFieldFound) {
      final editField = [...event.subNodes!, event].firstWhereOrNull((element) => element.text!.contains("Search") && element.isEditable!);
      log(editField.toString());
      if (editField != null) {
        await doAction(editField, NodeAction.actionSetText, "Riyanshu MNC");
        editFieldFound = true;
      }
    } else if (!linkItemFound) {
      final linkItem = [...event.subNodes!, event].firstWhereOrNull((element) => element.nodeId == 'com.whatsapp:id/input_attach_button');
      log(linkItem != null ? linkItem.toString() : "Not found");
      if (linkItem != null) {
        await doAction(linkItem, NodeAction.actionClick);
        linkItemFound = true;
      }
    } else if (!galleryItemFound) {
      final galleryItem = [...event.subNodes!, event].firstWhereOrNull((element) => element.nodeId == 'com.whatsapp:id/pickfiletype_contact_holder');
      log(galleryItem != null ? galleryItem.toString() : "Not found");
      if (galleryItem != null) {
        await doAction(galleryItem, NodeAction.actionClick);
        galleryItemFound = true;
        _imageFlowSubscription?.cancel(); // Cancel subscription once all items are found
      }
    }
  });

}


// void automateWikipedia(AccessibilityEvent event) async {
//   if (!event.packageName!.contains('whatsapp')) return;
//   // log(event.subNodes.toString());

//   final searchItem = [...event.subNodes!, event].firstWhereOrNull(
//     (element) => element.nodeId == 'com.whatsapp:id/menuitem_search',
//   );

//     log(searchItem.toString());

//  if (searchItem != null) {
//     await doAction(searchItem, NodeAction.actionClick); 
//     final editField = [...event.subNodes!, event].firstWhereOrNull((element) => element.text!.contains("Search")  && element.isEditable!);
//     log(editField.toString());
//     if (editField != null) {
//         await doAction(editField, NodeAction.actionSetText, "Riyanshu MNC");
//       }



    
    // if (editField != null) {
    //   await doAction(editField, NodeAction.actionSetText, "Riyanshu MNC");
    // }





  Future<bool> doAction(
    AccessibilityEvent node,
    NodeAction action, [
    dynamic argument,
  ]) async {
    return await FlutterAccessibilityService.performAction(
      node,
      action,
      argument,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('SenioGuide',style: TextStyle(fontSize: 40,color: Colors.white),),
          centerTitle: true,
          backgroundColor: Colors.blueGrey[900],
          elevation: 40,
        ),
        body: Center(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        await _runMethod(
                          context,
                          () async {
                            await FlutterAccessibilityService
                                .requestAccessibilityPermission();
                          },
                        );
                      },
                      child: const Text("Request Permission"),
                    ),
                const SizedBox(height: 20.0),
                ElevatedButton(
                  onPressed: () async {
                    await _runMethod(
                      context,
                      () async {
                        final bool res = await FlutterAccessibilityService
                            .isAccessibilityPermissionEnabled();
                        log("Is enabled: $res");
                      },
                    );
                  },
                  child: const Text("Check Permission"),
                )]),
              ),
              const SizedBox(height: 20.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: handleAccessiblityStream,
                    child: const Text("Start listening"),
                  ),
              const SizedBox(height: 20.0),
              ElevatedButton(
                onPressed: () {
                  _subscription?.cancel();
                },
                child: const Text("Stop Stream"),
              ),]),
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: events.length,
                  itemBuilder: (_, index) => ListTile(
                    title: Text(events[index]!.packageName!),
                    subtitle: Text(
                      (events[index]!.subNodes ?? [])
                              .map((e) => e.actions)
                              .expand((element) => element!)
                              .contains(NodeAction.actionClick)
                          ? 'Have Action to click'
                          : '',
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}