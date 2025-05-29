import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'dart:io';
import 'dart:async';

void main() {
  runApp(MakeUpViewApp());
}

class MakeUpViewApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  bool _showCodeField = false;

  void _sendCode() {
    final phoneInput = _phoneController.text.trim().replaceAll(RegExp(r'\D'), '');
    if (phoneInput.length != 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Введите корректный номер телефона (10 цифр)')),
      );
      return;
    }

    setState(() {
      _showCodeField = true;
      _codeController.text = '';
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Код отправлен: 1234')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('MakeUpView'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Log into account',
              style: GoogleFonts.roboto(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Phone number',
                prefixText: '+7 - ',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 16),
            if (_showCodeField)
              TextField(
                controller: _codeController,
                decoration: InputDecoration(
                  labelText: 'Code',
                  border: OutlineInputBorder(),
                ),
              ),
            if (_showCodeField) SizedBox(height: 16),
            Center(
              child: Column(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4A7B9),
                      minimumSize: Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _sendCode,
                    child: Text(
                      'Send Code',
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFFF4A7B9),
                      minimumSize: Size(200, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AvatarScreen()),
                      );
                    },
                    child: Text(
                      'Log in',
                      style: GoogleFonts.roboto(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 32),
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.grey[300],
                ),
                child: Center(
                  child: Text(
                    'your avatar',
                    style: GoogleFonts.roboto(
                      fontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AvatarScreen extends StatefulWidget {
  @override
  _AvatarScreenState createState() => _AvatarScreenState();
}

class _AvatarScreenState extends State<AvatarScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _avatarImage;
  String _modelPath = ''; // Изначально пусто, модель не загружается
  bool _showImage = false;

  Future<void> pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      print('Image selected: ${image.path}');
      setState(() {
        _avatarImage = File(image.path);
        _showImage = true;
        _modelPath = '';
      });
      Timer(Duration(seconds: 5), () {
        print('Timer done, loading face.obj');
        setState(() {
          _showImage = false;
          _modelPath = 'assets/models/face.obj';
        });
      });
    }
  }

  void _changeModel(String path) {
    print('Changing model to: $path');
    setState(() {
      _modelPath = path;
      _showImage = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset(
            'assets/icons/arrow_back.png',
            width: 24,
            height: 24,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading arrow_back.png: $error');
              return Icon(Icons.error, color: Colors.red);
            },
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'MakeUpView',
          style: GoogleFonts.roboto(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 320,
              height: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Color(0xFFE0E0E0), width: 1),
              ),
              child: _showImage && _avatarImage != null
                  ? Image.file(
                      _avatarImage!,
                      fit: BoxFit.cover,
                    )
                  : _modelPath.isNotEmpty
                      ? Cube(
                          onSceneCreated: (Scene scene) {
                            print('Loading model: $_modelPath');
                            try {
                              scene.world.add(Object(
                                fileName: _modelPath,
                                scale: Vector3(3, 3, 3), // Ещё больше увеличен масштаб
                                position: Vector3(0, 0, 0),
                                lighting: true,
                                backfaceCulling: true
                              ));
                              scene.light.position.setFrom(Vector3(0, 100, 100));
                              scene.camera.position.setFrom(Vector3(0, 0, 5));
                              scene.camera.target.setFrom(Vector3(0, 0, 0));
                            } catch (e) {
                              print('Error loading model: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to load model')),
                              );
                            }
                          },
                          onObjectCreated: (Object object) {
                            print('Object create');
                          },
                        )
                      : Center(
                          child: Text(
                            'your avatar',
                            style: GoogleFonts.roboto(
                              fontSize: 16,
                              color: Color(0xFF666666),
                            ),
                          ),
                        ),
            ),
            SizedBox(height: 8),
            Text(
              'your avatar',
              style: GoogleFonts.roboto(fontSize: 16, color: Color(0xFF666666)),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFF4A7B9),
                minimumSize: Size(200, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: pickImage,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/icons/icon_camera.png',
                    width: 24,
                    height: 24,
                    errorBuilder: (context, error, stackTrace) {
                      print('Error loading icon_camera.png: $error');
                      return Icon(Icons.error, color: Colors.red);
                    },
                  ),
                  SizedBox(width: 8),
                  Text(
                    'upload photo',
                    style: GoogleFonts.roboto(fontSize: 16),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'righting photo',
              style: GoogleFonts.roboto(fontSize: 12, color: Color(0xFF666666)),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 100,
              width: double.infinity,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  MakeupCard(
                    image: 'assets/cards/card_lipstick_red.png',
                    name: 'Красная помада',
                    color: Color(0xFFFF0000),
                    onTap: () {
                      _changeModel('assets/models/face_red_lipstick.obj');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Применяется красная помада')),
                      );
                    },
                  ),
                  MakeupCard(
                    image: 'assets/cards/card_eyeshadow_brown.png',
                    name: 'Коричневые тени',
                    color: Color(0xFF8B4513),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Применяются коричневые тени')),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MakeupCard extends StatelessWidget {
  final String image;
  final String name;
  final Color color;
  final VoidCallback onTap;

  MakeupCard({
    required this.image,
    required this.name,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 64,
        margin: EdgeInsets.symmetric(horizontal: 4),
        child: Column(
          children: [
            Image.asset(
              image,
              width: 40,
              height: 40,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading $image: $error');
                return Icon(Icons.error, color: Colors.red);
              },
            ),
            SizedBox(height: 8),
            Text(
              name,
              style: GoogleFonts.roboto(fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}