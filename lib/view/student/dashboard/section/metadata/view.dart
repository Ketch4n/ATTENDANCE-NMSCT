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
  final String name;
  final String ids;

  const MetaDataIndex({Key? key, required this.name, required this.ids})
      : super(key: key);

  @override
  _MetaDataIndexState createState() => _MetaDataIndexState();
}

class _MetaDataIndexState extends State<MetaDataIndex> {
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();
  final StreamController<List<String>> _textStreamController =
      StreamController<List<String>>();
  final TextEditingController _commentController = TextEditingController();

  late final String date;
  bool isLoading = false;
  List<Reference> _imageReferences = [];
  List<String> _pendingUploads = [];
  List<File> _localImages = [];
  String location = "";

  @override
  void initState() {
    super.initState();
    date = DateFormat('yyyy-MM-dd').format(DateTime.now());
    _getLocation();
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
    _textStreamController.close();
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _getImageReferences() async {
    final storage = FirebaseStorage.instance;
    final prefs = await SharedPreferences.getInstance();
    final section = widget.name;
    final email = prefs.getString('userEmail');
    final folderName = 'face_data/$section/$email/$date';

    try {
      final listResult = await storage.ref(folderName).list();
      setState(() {
        _imageReferences = listResult.items;
        isLoading = false;
      });
    } catch (e) {
      print('Error listing files: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _uploadImage(
      File imageFile, String description, String location) async {
    final connectivityResult = await Connectivity().checkConnectivity();

    if (connectivityResult == ConnectivityResult.none) {
      final directory = await getApplicationDocumentsDirectory();
      final localPath =
          '${directory.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      await imageFile.copy(localPath);

      _pendingUploads.add(localPath);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('${localPath}_description', description);
      await prefs.setString('${localPath}_location', location);
      await _savePendingUploads();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Info'),
            content: Text('No internet connection. Image saved locally.'),
          );
        },
      );

      setState(() {
        _localImages.add(File(localPath));
      });
    } else {
      await _uploadImageToFirebase(imageFile, description, location);
    }
  }

  Future<void> _uploadImageToFirebase(
      File imageFile, String description, String location) async {
    setState(() => isLoading = true);

    try {
      final storage = FirebaseStorage.instance;
      final prefs = await SharedPreferences.getInstance();
      final section = widget.name;
      final email = prefs.getString('userEmail');
      final folderName = 'face_data/$section/$email/$date';

      final fileName = DateTime.now().millisecondsSinceEpoch.toString();
      final storageRef = storage.ref().child('$folderName/$fileName.jpg');
      final metadata = SettableMetadata(
          customMetadata: {'description': description, 'Location': location});

      await storageRef.putFile(imageFile, metadata);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('Uploaded Successfully'),
          );
        },
      );

      _getImageReferences();
    } catch (e) {
      print('Error uploading image: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<void> _checkPendingUploads() async {
    for (String localPath in _pendingUploads) {
      final file = File(localPath);
      if (await file.exists()) {
        final prefs = await SharedPreferences.getInstance();
        final description = prefs.getString('${localPath}_description') ?? '';
        final location = prefs.getString('${localPath}_location') ?? '';

        await _uploadImageToFirebase(file, description, location);
        await file.delete();
      }
    }

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
    final deleteConfirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text('Are you sure you want to delete this image?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text('Delete'),
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

  Future<void> _selectImageAndUpload(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);
      final result = await showDialog<Map<String, String>>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Add Description'),
            content: TextField(
              controller: _commentController,
              decoration: InputDecoration(labelText: 'Enter Description'),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop({
                    'description': _commentController.text,
                    'location': location,
                  });
                },
                child: Text('Upload'),
              ),
            ],
          );
        },
      );

      if (result != null) {
        final description = result['description'];
        final location = result['location'];

        if (description != null && description.isNotEmpty) {
          await _uploadImage(imageFile, description, location ?? '');
        }
      }
    }
  }

  Future<String?> _getLocation() async {
    // Determine user's current position
    Position? currentPosition = await determineUserCurrentPosition("pin");
    if (currentPosition != null) {
      // Get the address from the current position
      String? address = await _getAddress(
          LatLng(currentPosition.latitude, currentPosition.longitude));
      // Format the location as description
      String locationDescription = address;

      String finalLocation = locationDescription;

      // Store the description and location in local storage
      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('imageLocation', finalLocation);
      location = finalLocation;

      return finalLocation;
    } else {
      // If unable to get location, use the entered description as it is
      return "Location not Found";
    }
  }

  Future<String> _getAddress(LatLng position) async {
    final placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      final address = placemarks.first;
      final addressStr = [
        if (address.thoroughfare != null &&
            !address.thoroughfare!.toLowerCase().contains('unnamed'))
          address.thoroughfare,
        address.subThoroughfare,
        address.subLocality,
        address.locality,
        address.subAdministrativeArea,
      ].where((s) => s != null).join(' ');
      return addressStr.trim();
    }
    return 'Address not found';
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
                    title: Text('Capture Accomplishment'),
                    actions: [
                      ElevatedButton(
                        onPressed: () =>
                            Navigator.of(context).pop(ImageSource.camera),
                        child: Text('Open Camera'),
                      ),
                      TextButton(
                        onPressed: () =>
                            Navigator.of(context).pop(ImageSource.gallery),
                        child: Text('Gallery'),
                      ),
                    ],
                  );
                },
              );

              if (source != null) {
                _selectImageAndUpload(source);
              }
            },
            child: Icon(Icons.add),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: _refreshAndUpload,
            child: Icon(Icons.sync),
          ),
        ],
      ),
      body: RefreshIndicator(
        key: _refreshIndicatorKey,
        onRefresh: _getImageReferences,
        child: ListView(
          children: [
            if (isLoading)
              Center(child: CircularProgressIndicator())
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
                            try {
                              final metadata = await imageRef.getMetadata();
                              final creationDate = metadata.timeCreated;
                              final description =
                                  metadata.customMetadata?['description'] ?? '';
                              final location =
                                  metadata.customMetadata?['Location'] ?? '';
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: Text('Image Details'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Image.network(snapshot.data!),
                                          SizedBox(height: 10),
                                          Text('Creation Date: $creationDate'),
                                          Text('Location: $location'),
                                          Text('Description: $description'),
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
                            aspectRatio: 1,
                            child: Image.network(snapshot.data!,
                                fit: BoxFit.cover),
                          ),
                        );
                      } else {
                        return Text('Loading...');
                      }
                    },
                  ),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => _deleteImage(imageRef, index),
                  ),
                );
              }).toList(),
            if (_localImages.isNotEmpty) Divider(),
            if (_localImages.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Text("Local Images",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    ..._localImages.map((file) {
                      return ListTile(
                        title: Image.file(file),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
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
                    }).toList(),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

Future<Position?> determineUserCurrentPosition(String purpose) async {
  if (!await Geolocator.isLocationServiceEnabled()) {
    print("Location services are not enabled.");
    return null;
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      print("Location permission denied.");
      return null;
    }
  }

  if (permission == LocationPermission.deniedForever) {
    print("Location permission denied forever.");
    return null;
  }

  return await Geolocator.getCurrentPosition(
    desiredAccuracy: purpose == "pin"
        ? LocationAccuracy.best
        : LocationAccuracy.bestForNavigation,
    forceAndroidLocationManager: true,
  );
}
