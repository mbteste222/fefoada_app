import 'dart:io';
import 'package:camera/camera.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class GalleryPage extends StatefulWidget {
  const GalleryPage({super.key});

  @override
  State<GalleryPage> createState() => _GalleryPageState();
}

class _GalleryPageState extends State<GalleryPage> {
  PlatformFile? pickedFile;
  late CameraController controller;
  XFile? imageFile;
  File? previewFile;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    controller = CameraController(cameras.first, ResolutionPreset.max);
    controller.initialize().then((_) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((Object e) {
      if (e is CameraException) {
        switch (e.code) {
          case 'CameraAccessDenied':
            break;
          default:
            break;
        }
      }
    });
  }

  Future<void> _showImagePreview(File imageFile) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(0),
        ),
        backgroundColor: Colors.black,
        title: const Text('Confirme a Imagem'),
        content: Image.file(imageFile),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              await _uploadImage(imageFile);
            },
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child:
                const Text('Cancelar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> pickImageFromCamera() async {
    final returnedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) {
      return;
    } else {
      final file = File(returnedImage.path);
      setState(() {
        previewFile = file;
      });

      await _showImagePreview(file);
    }
  }

  Future<void> selectFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        allowMultiple: true,
        allowedExtensions: ['jpg', 'jpeg', 'png'],
      );
      if (result == null) return;

      final file = File(result.files.single.path!);
      setState(() {
        previewFile = file;
      });

      await _showImagePreview(file);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Erro ao adicionar foto.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _uploadImage(File file) async {
    try {
      final path = 'fotosFefoada/${file.uri.pathSegments.last}';
      final ref = FirebaseStorage.instance.ref().child(path);
      await ref.putFile(file);

      final downloadURL = await ref.getDownloadURL();
      await FirebaseFirestore.instance.collection('imagesUrl').add({
        'url': downloadURL,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Foto adicionada com sucesso!',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
              'Erro ao adicionar foto.',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.red),
      );
    }
  }

  void _showImageDialog(String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          color: Colors.black,
          child: FutureBuilder(
            future: _loadImage(imageUrl),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return const Center(child: Text('Erro ao carregar a imagem'));
              } else {
                return Center(
                  child: Image.network(
                    imageUrl,
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      );
                    },
                    fit: BoxFit.contain,
                  ),
                );
              }
            },
          ),
        ),
      ),
    );
  }

  Future<void> _loadImage(String imageUrl) async {
    await Future.delayed(Duration(milliseconds: 0));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xff5f2c82), Color(0xff49a09d)],
            stops: [0, 1],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: selectFile,
                      icon: const Icon(Icons.file_copy, color: Colors.black),
                      label: const Text(
                        'GALERIA',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(0),
                        ),
                      ),
                      onPressed: pickImageFromCamera,
                      icon: const Icon(Icons.camera, color: Colors.black),
                      label: const Text(
                        'FOTO',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ],
                ),
                const Divider(),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('imagesUrl')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                        return const Center(
                            child: Text('Nenhuma imagem encontrada'));
                      }

                      final imageUrls = snapshot.data!.docs
                          .map((doc) => doc['url'] as String)
                          .toList();

                      return Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: imageUrls.map((url) {
                          return GestureDetector(
                            onTap: () => _showImageDialog(url),
                            child: SizedBox(
                              width: 150,
                              height: 150,
                              child: Image.network(
                                url,
                                fit: BoxFit.cover,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) {
                                    return child;
                                  }
                                  return Center(
                                    child: CircularProgressIndicator(
                                      value:
                                          loadingProgress.expectedTotalBytes !=
                                                  null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                    ),
                                  );
                                },
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
