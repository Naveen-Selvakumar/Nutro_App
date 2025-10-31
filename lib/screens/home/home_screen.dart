// migrated from lib/home_page.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _photo;

  User? get _user => FirebaseAuth.instance.currentUser;
  
  // Common allergies list
  static const List<String> _allAllergies = [
    'Milk',
    'Eggs',
    'Peanuts',
    'Tree nuts',
    'Fish',
    'Crustacean shellfish',
    'Wheat',
    'Soy',
    'Sesame',
  ];

  final Set<String> _selectedAllergies = {}; // stored locally for now
  String? _phone; // editable phone field (local)

  Future<void> _logout(BuildContext context) async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        await googleSignIn.signOut();
      }
    } catch (_) {}
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Logged out successfully')),
    );
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.rear,
        imageQuality: 85,
        maxWidth: 1600,
      );
      if (picked != null) {
        setState(() {
          _photo = picked;
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open camera: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // initialize phone from Firebase user if available
    _phone = _user?.phoneNumber;
  }

  Future<void> _editPhone() async {
    final controller = TextEditingController(text: _phone ?? '');
    final result = await showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit phone number'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(hintText: '+1234567890'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(null), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(context).pop(controller.text.trim()), child: const Text('Save')),
        ],
      ),
    );

    if (result != null) {
      if (!mounted) return;
      setState(() {
        _phone = result.isEmpty ? null : result;
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Phone updated locally')));
    }
  }

  void _toggleAllergy(String allergy) {
    setState(() {
      if (_selectedAllergies.contains(allergy)) {
        _selectedAllergies.remove(allergy);
      } else {
        _selectedAllergies.add(allergy);
      }
    });
  }

  void _saveAllergies() {
    // TODO: persist to server or Firestore. Currently local only.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Saved allergies: ${_selectedAllergies.join(', ')}')));
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;
    final displayName = user?.displayName ?? 'User';
    final email = user?.email ?? '';
    final photoUrl = user?.photoURL;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            tooltip: 'Logout',
            icon: const Icon(Icons.logout),
            onPressed: () async => await _logout(context),
          )
        ],
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (photoUrl != null)
                    CircleAvatar(
                      radius: 36,
                      backgroundImage: NetworkImage(photoUrl),
                    )
                  else
                    const CircleAvatar(
                      radius: 36,
                      child: Icon(Icons.person, size: 36),
                    ),
                  const SizedBox(height: 12),
                  Text(displayName,
                      style: const TextStyle(
                          fontSize: 20, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  // Email and Phone row
                  Column(
                    children: [
                      Text(email, style: TextStyle(color: Colors.grey[700])),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[700]),
                          const SizedBox(width: 6),
                          Text(_phone ?? 'No phone number', style: TextStyle(color: Colors.grey[700])),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit, size: 18),
                            tooltip: 'Edit phone',
                            onPressed: _editPhone,
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),

                  ElevatedButton.icon(
                    onPressed: _takePhoto,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Open Camera'),
                  ),
                  const SizedBox(height: 12),

                  // Allergies selection
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Common allergies', style: Theme.of(context).textTheme.titleMedium),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    children: _allAllergies.map((a) {
                      final selected = _selectedAllergies.contains(a);
                      return FilterChip(
                        label: Text(a),
                        selected: selected,
                        onSelected: (_) => _toggleAllergy(a),
                        selectedColor: Theme.of(context).colorScheme.primary.withAlpha(31),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _saveAllergies,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Allergies'),
                    ),
                  ),

                  if (_photo != null) ...[
                    const Text('Captured photo:'),
                    const SizedBox(height: 8),
                    Image.file(File(_photo!.path)),
                    const SizedBox(height: 8),
                    ElevatedButton(
                      onPressed: () => setState(() => _photo = null),
                      child: const Text('Remove Photo'),
                    ),
                  ],

                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () => _logout(context),
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
