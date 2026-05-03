import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/toast_utils.dart';

class UserProfileScreen extends StatefulWidget {
  final bool useScaffold;
  const UserProfileScreen({super.key, this.useScaffold = true});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  Map<String, dynamic>? _userProfile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
  }

  Future<void> _editName(String currentName) async {
    final TextEditingController nameController = TextEditingController(text: currentName);
    
    final newName = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: context.colors.bgCard,
          title: Text('Edit Profile Name', style: TextStyle(color: context.colors.textPrimary)),
          content: TextField(
            controller: nameController,
            style: TextStyle(color: context.colors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Enter new name',
              hintStyle: TextStyle(color: context.colors.textTertiary),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('CANCEL', style: TextStyle(color: context.colors.textSecondary)),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, nameController.text.trim()),
              child: Text('SAVE', style: TextStyle(color: context.colors.precisionBlue)),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty && newName != currentName) {
      final user = _authService.currentUser;
      if (user != null) {
        try {
          await _dbService.createOrUpdateUserProfile(
            uid: user.uid,
            email: user.email ?? '',
            name: newName,
          );
        } catch (e) {
          if (mounted) {
            TallyToast.showError(context, 'Error updating name: $e');
          }
        }
      }
    }
  }

  Future<void> _pickAndUploadImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    
    if (image != null) {
      final user = _authService.currentUser;
      if (user != null) {
        setState(() => _isLoading = true);
        try {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('user_profiles')
              .child('${user.uid}.jpg');
          
          await storageRef.putFile(File(image.path));
          final downloadUrl = await storageRef.getDownloadURL();
          
          await _dbService.updateProfileImage(uid: user.uid, imageUrl: downloadUrl);
          if (mounted) setState(() => _isLoading = false);
        } catch (e) {
          if (mounted) {
            setState(() => _isLoading = false);
            TallyToast.showError(context, 'Upload failed: $e');
          }
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    if (user == null) return const Center(child: Text('Please log in'));

    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting || _isLoading) {
          return Center(child: CircularProgressIndicator(color: context.colors.precisionBlue));
        }

        final data = snapshot.data?.data();
        final String displayName = data?['name'] ?? 'Athlete';
        final String? profileImageUrl = data?['profileImageUrl'];
        final String gamesPlayed = (data?['gamesPlayed'] ?? 0).toString();
        final String totalXP = (data?['totalXP'] ?? 0).toString();

        final content = SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAndUploadImage,
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: context.colors.bgCardLight,
                        backgroundImage: profileImageUrl != null ? NetworkImage(profileImageUrl) : null,
                        child: profileImageUrl == null ? Icon(Icons.person, size: 50, color: context.colors.textSecondary) : null,
                      ),
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: context.colors.precisionBlue,
                        child: Icon(Icons.camera_alt, size: 16, color: context.colors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(displayName, style: TallyTextStyles.heading2(context)),
                  IconButton(
                    icon: Icon(Icons.edit, size: 16, color: context.colors.textSecondary),
                    onPressed: () => _editName(displayName),
                  ),
                ],
              ),
              Text('Pro Player', style: TallyTextStyles.bodyMedium(context)),
              const SizedBox(height: 32),
              GlassCard(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStat(context, 'MATCHES', gamesPlayed),
                    _buildStat(context, 'TOTAL XP', totalXP),
                    _buildStat(context, 'WIN RATE', '0%'),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ListTile(
                leading: Icon(Icons.history, color: context.colors.precisionBlue),
                title: Text('Match History', style: TallyTextStyles.bodyLarge(context)),
                trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
                onTap: () => Navigator.pushNamed(context, '/history'),
              ),
              Divider(color: context.colors.border),
              ListTile(
                leading: Icon(Icons.bar_chart, color: context.colors.precisionBlue),
                title: Text('Performance Stats', style: TallyTextStyles.bodyLarge(context)),
                trailing: Icon(Icons.chevron_right, color: context.colors.textSecondary),
                onTap: () {},
              ),
            ],
          ),
        );

        if (!widget.useScaffold) return content;

        return Scaffold(
          backgroundColor: context.colors.bgPrimary,
          appBar: AppBar(
            title: const Text('PROFILE'),
            titleTextStyle: TallyTextStyles.heading2(context).copyWith(color: context.colors.precisionBlue),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
          body: content,
        );
      },
    );
  }

  Widget _buildStat(BuildContext context, String label, String value) {
    return Column(
      children: [
        Text(value, style: TallyTextStyles.heading2(context).copyWith(color: context.colors.optimisticYellow)),
        const SizedBox(height: 4),
        Text(label, style: TallyTextStyles.label(context)),
      ],
    );
  }
}

