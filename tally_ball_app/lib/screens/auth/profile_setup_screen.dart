import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../widgets/common.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';
import '../../utils/toast_utils.dart';
import '../../utils/auth_error_handler.dart';

class ProfileSetupScreen extends StatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  State<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends State<ProfileSetupScreen> {
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  DateTime? _dob;
  bool _isLoading = false;
  final AuthService _authService = AuthService();
  final DatabaseService _dbService = DatabaseService();

  Future<void> _handleSave() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      TallyToast.showError(context, 'Name is required');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final user = _authService.currentUser;
      if (user != null) {
        await _dbService.createOrUpdateUserProfile(
          uid: user.uid,
          email: user.email ?? '',
          name: name,
          extraData: {
            if (_dob != null) 'dob': _dob!.toIso8601String(),
            if (_locationController.text.isNotEmpty) 'location': _locationController.text.trim(),
          },
        );
        if (mounted) {
          Navigator.pushNamed(context, '/success');
        }
      }
    } catch (e) {
      if (mounted) TallyToast.showError(context, AuthErrorHandler.message(e));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Step indicator
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('STEP 2 OF 2', style: TallyTextStyles.label(context)),
                  Text('TARGET ACQUIRED', style: TallyTextStyles.labelYellow(context)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: Container(height: 3, color: context.colors.precisionBlue)),
                  const SizedBox(width: 4),
                  Expanded(child: Container(height: 3, color: context.colors.precisionBlue)),
                ],
              ),

              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      GlassCard(
                        borderColor: context.colors.precisionBlue.withValues(alpha: 0.3),
                        child: Column(
                          children: [
                            Icon(Icons.gps_fixed, color: context.colors.precisionBlue, size: 36),
                            const SizedBox(height: 16),
                            Text('SETUP YOUR\nPROFILE', style: TallyTextStyles.heading1(context), textAlign: TextAlign.center),
                            const SizedBox(height: 8),
                            Text(
                              'Calibrate your telemetry before\nentering the arena.',
                              style: TallyTextStyles.bodyMedium(context),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 32),
                            TallyTextField(
                              label: 'FULL NAME',
                              hint: 'Enter full designation',
                              prefixIcon: Icons.person_outline,
                              controller: _nameController,
                            ),
                            const SizedBox(height: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('DATE OF BIRTH', style: TallyTextStyles.label(context)),
                                    Text('REQ', style: TallyTextStyles.bodySmall(context)),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                GestureDetector(
                                  onTap: _selectDate,
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                    decoration: BoxDecoration(
                                      color: context.colors.bgCard,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: context.colors.border),
                                    ),
                                    child: Row(
                                      children: [
                                        Icon(Icons.calendar_today, color: context.colors.textTertiary, size: 20),
                                        const SizedBox(width: 12),
                                        Text(
                                          _dob != null ? '${_dob!.day.toString().padLeft(2, '0')}/${_dob!.month.toString().padLeft(2, '0')}/${_dob!.year}' : 'DD/MM/YYYY',
                                          style: TextStyle(
                                            color: _dob != null ? context.colors.textPrimary : context.colors.textTertiary,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const Spacer(),
                                        Icon(Icons.calendar_month, color: context.colors.textTertiary, size: 20),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TallyTextField(
                              label: 'LOCATION',
                              hint: 'City, Region',
                              prefixIcon: Icons.my_location,
                              controller: _locationController,
                            ),
                            const SizedBox(height: 32),
                            Divider(color: context.colors.border),
                            const SizedBox(height: 16),
                            Text("Ready to deploy?", style: TallyTextStyles.scriptAccent(context).copyWith(fontSize: 18)),
                            const SizedBox(height: 12),
                            TallyButton(
                              text: _isLoading ? 'SAVING...' : 'CONFIRM',
                              icon: _isLoading ? Icons.hourglass_empty : Icons.send,
                              onPressed: _isLoading ? () {} : _handleSave,
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text('GO BACK', style: TallyTextStyles.bodyMedium(context)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1960),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: context.colors.precisionBlue,
              onPrimary: Colors.white,
              surface: context.colors.bgCard,
              onSurface: context.colors.textPrimary,
            ),
            dialogTheme: DialogThemeData(backgroundColor: context.colors.bgCard),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) setState(() => _dob = picked);
  }
}
