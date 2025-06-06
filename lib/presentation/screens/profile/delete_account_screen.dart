import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:knowledge/core/themes/app_theme.dart';
import 'package:knowledge/data/providers/auth_provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

class DeleteAccountScreen extends HookConsumerWidget {
  const DeleteAccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Delete Account',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.navyBlue),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: authState.maybeMap(
        loading: (_) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.limeGreen),
          ),
        ),
        orElse: () => const _DeleteAccountForm(),
      ),
    );
  }
}

class _DeleteAccountForm extends ConsumerStatefulWidget {
  const _DeleteAccountForm();

  @override
  ConsumerState<_DeleteAccountForm> createState() => _DeleteAccountFormState();
}

class _DeleteAccountFormState extends ConsumerState<_DeleteAccountForm> {
  final _passwordController = TextEditingController();
  final _missingFeaturesController = TextEditingController();
  final _otherReasonController = TextEditingController();
  final _suggestionsController = TextEditingController();

  bool _showPasswordError = false;
  String _passwordErrorText = '';
  bool _showPassword = false;

  // Reason checkboxes
  bool _notEngaging = false;
  bool _difficultNavigation = false;
  bool _expectedMoreFeatures = false;
  bool _technicalIssues = false;
  bool _otherReason = false;

  // Likelihood to return scale
  int _likelihoodToReturn = 0; // 0 = not selected, 1-5 = rating

  // Current step in the flow
  int _currentStep = 0;
  static const int _totalSteps = 3;

  // Submitted feedback flag
  bool _feedbackSubmitted = false;

  @override
  void dispose() {
    _passwordController.dispose();
    _missingFeaturesController.dispose();
    _otherReasonController.dispose();
    _suggestionsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_feedbackSubmitted) {
      return _buildThankYouScreen();
    }

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header message
                _buildHeader(),
                const SizedBox(height: 24),

                // Stepper indicator
                _buildStepIndicator(),
                const SizedBox(height: 32),

                // Current step content
                ..._buildCurrentStepContent(),

                const SizedBox(height: 32),

                // Navigation buttons
                _buildNavigationButtons(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'We\'re sorry to see you go',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.navyBlue,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Before you leave, we\'d love to understand your experience — your feedback shapes the future of our app and helps amplify the stories that deserve to be told.',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    ).animate().fadeIn(duration: const Duration(milliseconds: 300));
  }

  Widget _buildStepIndicator() {
    return Row(
      children: List.generate(
        _totalSteps,
        (index) => Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 2),
            decoration: BoxDecoration(
              color: index <= _currentStep
                  ? AppColors.limeGreen
                  : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCurrentStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1Content();
      case 1:
        return _buildStep2Content();
      case 2:
        return _buildStep3Content();
      default:
        return [];
    }
  }

  List<Widget> _buildStep1Content() {
    return [
      const Text(
        'What\'s the main reason you\'re leaving?',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.navyBlue,
        ),
      ),
      const SizedBox(height: 4),
      Text(
        'Select all that apply',
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey.shade600,
        ),
      ),
      const SizedBox(height: 16),

      // Reason checkboxes
      _buildCheckboxOption(
        'I didn\'t find the content engaging',
        _notEngaging,
        (value) => setState(() => _notEngaging = value!),
      ),
      _buildCheckboxOption(
        'The app was difficult to navigate',
        _difficultNavigation,
        (value) => setState(() => _difficultNavigation = value!),
      ),
      _buildCheckboxOption(
        'I expected more stories / features',
        _expectedMoreFeatures,
        (value) => setState(() => _expectedMoreFeatures = value!),
      ),
      _buildCheckboxOption(
        'I encountered technical issues',
        _technicalIssues,
        (value) => setState(() => _technicalIssues = value!),
      ),
      _buildCheckboxOption(
        'Other (please share)',
        _otherReason,
        (value) => setState(() => _otherReason = value!),
      ),

      // Other reason text field
      if (_otherReason)
        Padding(
          padding: const EdgeInsets.only(left: 32, top: 8, bottom: 8),
          child: TextFormField(
            controller: _otherReasonController,
            decoration: InputDecoration(
              hintText: 'Please tell us more...',
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            minLines: 2,
            maxLines: 4,
          ),
        ),
    ];
  }

  List<Widget> _buildStep2Content() {
    return [
      const Text(
        'Tell us more',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.navyBlue,
        ),
      ),
      const SizedBox(height: 24),

      // Missing features text field
      const Text(
        'Were there specific features you hoped to see but didn\'t?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.navyBlue,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _missingFeaturesController,
        decoration: InputDecoration(
          hintText: 'Share your thoughts (optional)',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        minLines: 2,
        maxLines: 4,
      ),

      const SizedBox(height: 24),

      // Likelihood to return
      const Text(
        'How likely are you to try the app again in the future?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.navyBlue,
        ),
      ),
      const SizedBox(height: 16),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: List.generate(
          5,
          (index) => _buildRatingButton(index + 1),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Not likely',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            'Very likely',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),

      const SizedBox(height: 24),

      // Final suggestions
      const Text(
        'Any final thoughts or suggestions for us?',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.navyBlue,
        ),
      ),
      const SizedBox(height: 8),
      TextFormField(
        controller: _suggestionsController,
        decoration: InputDecoration(
          hintText: 'For example, is there a story you wish we had? (optional)',
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
        ),
        minLines: 2,
        maxLines: 4,
      ),
    ];
  }

  List<Widget> _buildStep3Content() {
    return [
      const Text(
        'Confirm Account Deletion',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.navyBlue,
        ),
      ),
      const SizedBox(height: 16),
      Text(
        'For security, please enter your password to confirm account deletion.',
        style: TextStyle(
          fontSize: 16,
          color: Colors.grey.shade700,
          height: 1.5,
        ),
      ),
      const SizedBox(height: 24),

      // Password input field
      TextFormField(
        controller: _passwordController,
        obscureText: !_showPassword,
        decoration: InputDecoration(
          labelText: 'Password',
          hintText: 'Enter your password',
          errorText: _showPasswordError ? _passwordErrorText : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.all(16),
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
        ),
      ),
      const SizedBox(height: 24),

      // Warning text
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'This action cannot be undone',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.red.shade700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Once you delete your account, all your data will be permanently removed.',
                    style: TextStyle(
                      color: Colors.red.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ];
  }

  Widget _buildNavigationButtons() {
    return Row(
      children: [
        if (_currentStep > 0)
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navyBlue,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: AppColors.navyBlue),
                ),
              ),
              child: const Text('Back'),
            ),
          ),
        if (_currentStep > 0) const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              if (_currentStep < _totalSteps - 1) {
                setState(() {
                  _currentStep++;
                });
              } else {
                _confirmDeletion();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _currentStep == _totalSteps - 1
                  ? Colors.red
                  : AppColors.limeGreen,
              foregroundColor: _currentStep == _totalSteps - 1
                  ? Colors.white
                  : AppColors.navyBlue,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(_currentStep == _totalSteps - 1
                ? 'Delete Account'
                : 'Continue'),
          ),
        ),
      ],
    );
  }

  Widget _buildCheckboxOption(
      String label, bool value, ValueChanged<bool?> onChanged) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: CheckboxListTile(
        title: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            color: AppColors.navyBlue,
          ),
        ),
        value: value,
        onChanged: onChanged,
        controlAffinity: ListTileControlAffinity.leading,
        contentPadding: EdgeInsets.zero,
        activeColor: AppColors.limeGreen,
        checkColor: AppColors.navyBlue,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildRatingButton(int rating) {
    final bool isSelected = _likelihoodToReturn == rating;

    return GestureDetector(
      onTap: () {
        setState(() {
          _likelihoodToReturn = rating;
        });
      },
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limeGreen : Colors.grey.shade200,
          shape: BoxShape.circle,
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.limeGreen.withOpacity(0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  )
                ]
              : null,
        ),
        child: Center(
          child: Text(
            rating.toString(),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isSelected ? AppColors.navyBlue : Colors.grey.shade700,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThankYouScreen() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.favorite,
              color: AppColors.limeGreen,
              size: 72,
            ),
            const SizedBox(height: 24),
            const Text(
              'Account Deleted Successfully',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.navyBlue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Your account has been permanently deleted. Thank you for your feedback - it helps us build a better experience for everyone. We hope to see you again in the future.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                context.go('/login');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.limeGreen,
                foregroundColor: AppColors.navyBlue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Return to Login'),
            ),
          ],
        ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
      ),
    );
  }

  void _confirmDeletion() async {
    final password = _passwordController.text.trim();

    if (password.isEmpty) {
      setState(() {
        _showPasswordError = true;
        _passwordErrorText = 'Please enter your password';
      });
      return;
    }

    setState(() {
      _showPasswordError = false;
    });

    // Collect all feedback
    final Map<String, dynamic> feedback = {};

    // Reasons for leaving
    final List<String> reasons = [];
    if (_notEngaging) reasons.add('Content not engaging');
    if (_difficultNavigation) reasons.add('Difficult navigation');
    if (_expectedMoreFeatures) reasons.add('Expected more features');
    if (_technicalIssues) reasons.add('Technical issues');
    if (_otherReason && _otherReasonController.text.isNotEmpty) {
      reasons.add('Other: ${_otherReasonController.text}');
    }
    if (reasons.isNotEmpty) {
      feedback['reasons'] = reasons;
    }

    // Missing features
    if (_missingFeaturesController.text.isNotEmpty) {
      feedback['missing_features'] = _missingFeaturesController.text;
    }

    // Likelihood to return
    if (_likelihoodToReturn > 0) {
      feedback['likelihood_to_return'] = _likelihoodToReturn;
    }

    // Final suggestions
    if (_suggestionsController.text.isNotEmpty) {
      feedback['suggestions'] = _suggestionsController.text;
    }

    try {
      await ref.read(authNotifierProvider.notifier).deleteAccount(
            password,
            feedback: feedback,
          );

      // Show thank you screen after successful deletion
      setState(() {
        _feedbackSubmitted = true;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account deleted successfully!'),
            backgroundColor: AppColors.limeGreen,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _showPasswordError = true;
        _passwordErrorText = e.toString();
      });

      // Show error message in snackbar as well for better visibility
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }
}
