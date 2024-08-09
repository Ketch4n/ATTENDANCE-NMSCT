import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class MetaDataIndex extends StatefulWidget {
  const MetaDataIndex({super.key, required this.name, required this.ids});
  final String name;
  final String ids;

  @override
  State<MetaDataIndex> createState() => _MetaDataIndexState();
}

class _MetaDataIndexState extends State<MetaDataIndex> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final StreamController<List<String>> _textStreamController =
      StreamController<List<String>>();
  List<Reference> _imageReferences = [];
  final TextEditingController _commentController = TextEditingController();
  final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
  bool isLoading = false;

  List<String> _pendingUploads = [];
  List<File> _localImages = [];

  @override
  void initState() {
    super.initState();
    _getImageReferences();
    _loadPendingUploads();
    _loadLocalImages();
    Connectivity().onConnectivityChanged.listen((ConnectivityResult result) {
      if (result != ConnectivityResult.none) {
        _checkPendingUploads();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _textStreamController.close();
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = widget.name;
    final email = prefs.getString('userEmail');
    final folderName = 'face_data/$section/$email/$date';

    try {
      final listResult = await storage.ref(folderName).list();
      final items = listResult.items;

      setState(() {
        _imageReferences = items.toList();
        isLoading = false;
      });
    } catch (e) {
      print('Error listing files: $e');
      isLoading = false;
    }
  }

  Future<void> _uploadImage(File imageFile, String description) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      // Save the image locally if offline
      final directory = await getApplicationDocumentsDirectory();
      final localPath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await imageFile.copy(localPath);

      // Store the metadata for later upload
      _pendingUploads.add(localPath);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${localPath}_description', description);
      await _savePendingUploads();

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Info'),
              content: Text('No internet connection. Image saved locally.'),
            );
          });

      setState(() {
        _localImages.add(File(localPath));
      });
    } else {
      // Upload the image if online
      await _uploadImageToFirebase(imageFile, description);
    }
  }

  Future<void> _uploadImageToFirebase(
      File imageFile, String description) async {
    setState(() {
      isLoading = true;
    });
    try {
      final storage = FirebaseStorage.instance;
      final prefs = await SharedPreferences.getInstance();
      final section = widget.name;
      final email = prefs.getString('userEmail');
      final date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final folderName = 'face_data/$section/$email/$date';

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final Reference storageRef =
          storage.ref().child('$folderName/$fileName.jpg');

      // Set metadata including description
      final metadata = SettableMetadata(
        customMetadata: {'description': description},
      );

      await storageRef.putFile(imageFile, metadata);

      showDialog(
          context: context,
          builder: (BuildContext context) {
            return const AlertDialog(
              title: Text('Success'),
              content: Text('Uploaded Successfully'),
            );
          });

      _getImageReferences();
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _checkPendingUploads() async {
    for (String localPath in _pendingUploads) {
      final file = File(localPath);
      if (await file.exists()) {
        final prefs = await SharedPreferences.getInstance();
        final description = prefs.getString('${localPath}_description') ?? '';
        await _uploadImageToFirebase(file, description);
        file.delete();
      }
    }

    // Clear pending uploads
    _pendingUploads.clear();
    await _savePendingUploads();
    _loadLocalImages();
  }

  Future<void> _loadPendingUploads() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pendingUploads = prefs.getStringList('pendingUploads') ?? [];
    });
  }

  Future<void> _savePendingUploads() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('pendingUploads', _pendingUploads);
  }

  Future<void> _loadLocalImages() async {
    final directory = await getApplicationDocumentsDirectory();
    final localImages = directory
        .listSync()
        .where((item) => item.path.endsWith('.jpg'))
        .map((item) => File(item.path))
        .toList();
    setState(() {
      _localImages = localImages;
    });
  }

  Future<void> _deleteImage(Reference imageRef, int index) async {
    bool deleteConfirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (deleteConfirmed == true) {
      try {
        await imageRef.delete();
        setState(() {
          _imageReferences.removeAt(index);
        });
        _getImageReferences();
      } catch (e) {
        print('Error deleting image: $e');
      }
    }
  }

  Future<void> _refreshAndUpload() async {
    await _loadLocalImages();
    await _checkPendingUploads();
  }

  Future<void> _selectImageAndUpload(option) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: option);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      String? description = await showDialog<String>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Add Description'),
            content: TextField(
              controller: _commentController,
              decoration: const InputDecoration(labelText: 'Enter Description'),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String? finalDescription = await _getDescription();
                  if (finalDescription != null && finalDescription.isNotEmpty) {
                    Navigator.of(context).pop(finalDescription);
                  }
                },
                child: const Text('Upload'),
              ),
            ],
          );
        },
      );
      if (description != null && description.isNotEmpty) {
        await _uploadImage(imageFile, description);
      }
    }
  }

  Future<String?> _getDescription() async {
    // Determine user's current position
    Position? currentPosition = await determineUserCurrentPosition("pin");
    if (currentPosition != null) {
      // Get the address from the current position
      String? address = await _getAddress(
          LatLng(currentPosition.latitude, currentPosition.longitude));
      // Format the location as description
      String locationDescription = "Location: $address";

      // Combine the original description with the location information
      String finalDescription =
          "${_commentController.text}\n$locationDescription";

      // Store the description and location in local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('imageDescription', finalDescription);

      return finalDescription;
    } else {
      // If unable to get location, use the entered description as it is
      return _commentController.text;
    }
  }

  Future<String> _getAddress(LatLng position) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      Placemark address = placemarks.first;

      // Construct the address string using desired fields from the first placemark
      String addressStr = "";

      // Check if the thoroughfare is an unnamed road before including it in the address
      if (address.thoroughfare != null &&
          !address.thoroughfare!.toLowerCase().contains('unnamed')) {
        addressStr += "${address.thoroughfare} ";
      }

      // Include other address components
      addressStr +=
          "${address.subThoroughfare ?? ''} ${address.subLocality ?? ''} ${address.locality ?? ''}, ${address.subAdministrativeArea ?? ''}";

      return addressStr
          .trim(); // Trim to remove any leading or trailing whitespace
    } else {
      return "Address not found";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            onPressed: () async {
              final source = await showDialog<ImageSource>(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('Capture Accomplishment'),
                    // content: Text(
                    //     'Do you want to take a picture or choose from gallery?'),
                    actions: [
                      // TextButton(
                      //   onPressed: () {
                      //     Navigator.of(context).pop(ImageSource.gallery);
                      //   },
                      //   child: Text('Gallery'),
                      // ),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop(ImageSource.camera);
                        },
                        child: const Text('Open Camera'),
                      ),
                    ],
                  );
                },
              );

              _selectImageAndUpload(source);
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _refreshAndUpload,
            child: const Icon(Icons.sync),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _getImageReferences,
        child: ListView(
          children: [
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ..._imageReferences.asMap().entries.map((entry) {
                final index = entry.key;
                final imageRef = entry.value;
                return ListTile(
                  title: FutureBuilder<String>(
                    future: imageRef.getDownloadURL(),
                    builder:
                        (BuildContext context, AsyncSnapshot<String> snapshot) {
                      if (snapshot.connectionState == ConnectionState.done &&
                          snapshot.hasData) {
                        return GestureDetector(
                          onTap: () async {
                            // Handle tap on the image (if needed)
                            try {
                              final metadata = await imageRef.getMetadata();
                              final creationDate = metadata.timeCreated;
                              final description =
                                  metadata.customMetadata?['description'] ?? '';
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Image Details'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.network(snapshot.data!),
                                          const SizedBox(height: 10),
                                          Text('Description: $description'),
                                          Text('Creation Date: $creationDate'),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              );
                            } catch (e) {
                              print('Error retrieving metadata: $e');
                            }
                          },
                          child: AspectRatio(
                            aspectRatio: 1, // Adjust the aspect ratio as needed
                            child: Image.network(
                              snapshot.data!,
                              fit: BoxFit
                                  .cover, // Ensure the image covers the whole
                            ),
                          ),
                        );
                      } else {
                        return const Text("Loading...");
                      }
                    },
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _deleteImage(imageRef, index);
                    },
                  ),
                );
              }),
            if (_localImages.isNotEmpty) const Divider(),
            if (_localImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    const Text(
                      "Local Images",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    ..._localImages.map((file) {
                      return ListTile(
                        title: Image.file(file),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () async {
                            if (await file.exists()) {
                              await file.delete();
                              setState(() {
                                _localImages.remove(file);
                              });
                            }
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<Position?> determineUserCurrentPosition(purpose) async {
  LocationPermission locationPermission;
  bool isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();

  if (!isLocationServiceEnabled) {
    print("user don't enable location permission");
    return null;
  }

  locationPermission = await Geolocator.checkPermission();

  if (locationPermission == LocationPermission.denied) {
    locationPermission = await Geolocator.requestPermission();
    if (locationPermission == LocationPermission.denied) {
      print("user denied location permission");
      return null;
    }
  }

  if (locationPermission == LocationPermission.deniedForever) {
    print("user denied permission forever");
    return null;
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: purpose == "pin"
        ? LocationAccuracy.best
        : LocationAccuracy.bestForNavigation,
    forceAndroidLocationManager: true,
  );
}
