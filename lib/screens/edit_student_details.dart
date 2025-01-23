import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditStudentDetailsScreen extends StatefulWidget {
  const EditStudentDetailsScreen({super.key, required this.documentId});
  final String documentId;

  @override
  State<EditStudentDetailsScreen> createState() =>
      _EditStudentDetailsScreenState();
}

class _EditStudentDetailsScreenState extends State<EditStudentDetailsScreen> {
  // Firestore reference
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  // Form key for validation (optional but recommended)
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields
  late final TextEditingController _emailController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;

  // Dropdown fields to edit
  String _classValue = 'MMed1'; // Displayed value in the dropdown (uppercase)
  String _roleValue = 'student';

  // Rotations. We store them as strings. Each rotation has a dropdown.
  String _rotation1 = '';
  String _rotation2 = '';
  String _rotation3 = '';
  String _rotation4 = '';
  String _rotation5 = '';
  String _rotation6 = '';
  String _rotation7 = '';
  String _rotation8 = '';

  // Because the rotation options differ depending on the class, we define them here:
  final List<String> _mmed1And3Rotations = [
    "Infectious Diseases",
    "Gastroenterology",
    "Pulmonology",
    "Nephrology",
    "Neurology",
    "Ward 11",
    "Hematology",
    "Cardiology",
    "Endocrinology",
    "ICU/Palliative Care"
  ];

  final List<String> _mmed2Rotations = [
    "Radiology",
    "Emergency - Mulago",
    "TB",
    "UCI",
    "MLI",
    "IDI",
    "Dermatology",
    "UHI"
  ];

  @override
  void initState() {
    super.initState();

    // Initialize our controllers
    _emailController = TextEditingController();
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();

    // Load data from Firestore
    _loadStudentData();
  }

  @override
  void dispose() {
    // Dispose controllers to avoid memory leaks
    _emailController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  /// Loads the student data from Firestore and populates the local fields.
  Future<void> _loadStudentData() async {
    final docSnapshot = await _usersCollection.doc(widget.documentId).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;

      setState(() {
        // Convert stored 'class' (e.g. 'mmed1') to uppercase display (e.g. 'MMed1')
        _classValue = _convertClassValueToDisplay(data['class'] ?? 'mmed1');
        _roleValue = data['role'] ?? 'student';

        // Update the text controllers
        _emailController.text = data['email'] ?? '';
        _firstNameController.text = data['firstname'] ?? '';
        _lastNameController.text = data['lastname'] ?? '';

        // Schedule is a map with rotation keys
        final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
        _rotation1 = schedule['rotation1'] ?? '';
        _rotation2 = schedule['rotation2'] ?? '';
        _rotation3 = schedule['rotation3'] ?? '';
        _rotation4 = schedule['rotation4'] ?? '';
        _rotation5 = schedule['rotation5'] ?? '';
        _rotation6 = schedule['rotation6'] ?? '';
        _rotation7 = schedule['rotation7'] ?? '';
        _rotation8 = schedule['rotation8'] ?? '';

        // Clear any invalid rotations for the current class
        _clearInvalidRotations();
      });
    }
  }

  /// Converts the stored lowercase class value (e.g. 'mmed1') into uppercase display (e.g. 'MMed1').
  String _convertClassValueToDisplay(String classValue) {
    switch (classValue) {
      case 'mmed1':
        return 'MMed1';
      case 'mmed2':
        return 'MMed2';
      case 'mmed3':
        return 'MMed3';
      default:
        return 'MMed1'; // default fallback
    }
  }

  /// Converts the displayed class value (e.g. 'MMed1') back to lowercase (e.g. 'mmed1') for storing in Firestore.
  String _convertClassValueToStore(String classValue) {
    switch (classValue) {
      case 'MMed1':
        return 'mmed1';
      case 'MMed2':
        return 'mmed2';
      case 'MMed3':
        return 'mmed3';
      default:
        return 'mmed1'; // default fallback
    }
  }

  void _clearInvalidRotations() {
    // Figure out which rotations are valid for the *current* class
    final isMmed2 = _classValue == 'MMed2';
    final validRotations = isMmed2 ? _mmed2Rotations : _mmed1And3Rotations;

    void clearIfInvalid(String rotationVal, void Function(String) setter) {
      if (!validRotations.contains(rotationVal)) {
        setter('');
      }
    }

    clearIfInvalid(_rotation1, (val) => _rotation1 = val);
    clearIfInvalid(_rotation2, (val) => _rotation2 = val);
    clearIfInvalid(_rotation3, (val) => _rotation3 = val);
    clearIfInvalid(_rotation4, (val) => _rotation4 = val);
    clearIfInvalid(_rotation5, (val) => _rotation5 = val);
    clearIfInvalid(_rotation6, (val) => _rotation6 = val);
    clearIfInvalid(_rotation7, (val) => _rotation7 = val);
    clearIfInvalid(_rotation8, (val) => _rotation8 = val);
  }

  /// Saves the updated student data to Firestore.
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Make sure to "save" form state if using onSaved in the fields
    // (We only do validation below; we rely on controllers for data)
    _formKey.currentState!.save();

    // Build the updated schedule map
    final updatedSchedule = {
      'rotation1': _rotation1,
      'rotation2': _rotation2,
      'rotation3': _rotation3,
      'rotation4': _rotation4,
      'rotation5': _rotation5,
      'rotation6': _rotation6,
      'rotation7': _rotation7,
      'rotation8': _rotation8,
    };

    await _usersCollection.doc(widget.documentId).update({
      'class': _convertClassValueToStore(_classValue),
      'email': _emailController.text.trim(),
      'firstname': _firstNameController.text.trim(),
      'lastname': _lastNameController.text.trim(),
      'role': _roleValue.trim(),
      'schedule': updatedSchedule,
    });

    // Pop back to the previous screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the rotation list based on the current class
    final isMmed2 = _classValue == 'MMed2';
    final rotationOptions = isMmed2 ? _mmed2Rotations : _mmed1And3Rotations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student Details'),
      ),
      body: _buildBody(rotationOptions),
    );
  }

  Widget _buildBody(List<String> rotationOptions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CLASS DROPDOWN
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Class'),
              value: _classValue,
              items: const [
                DropdownMenuItem(value: 'MMed1', child: Text('MMed1')),
                DropdownMenuItem(value: 'MMed2', child: Text('MMed2')),
                DropdownMenuItem(value: 'MMed3', child: Text('MMed3')),
              ],
              onChanged: (val) {
                setState(() {
                  _classValue = val!;
                  // Now we reset or clear invalid rotations
                  _clearInvalidRotations();
                });
              },
              onSaved: (val) {
                _classValue = val ?? 'MMed1';
              },
            ),
            const SizedBox(height: 16),

            // EMAIL
            _buildTextFormField(
              label: 'Email',
              controller: _emailController,
            ),
            const SizedBox(height: 16),

            // FIRST NAME
            _buildTextFormField(
              label: 'First Name',
              controller: _firstNameController,
            ),
            const SizedBox(height: 16),

            // LAST NAME
            _buildTextFormField(
              label: 'Last Name',
              controller: _lastNameController,
            ),
            const SizedBox(height: 16),

            // ROLE DROPDOWN
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Role'),
              value: _roleValue,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('student')),
                DropdownMenuItem(value: 'faculty', child: Text('faculty')),
              ],
              onChanged: (val) {
                setState(() {
                  _roleValue = val!;
                });
              },
              onSaved: (val) {
                _roleValue = val ?? 'student';
              },
            ),
            const SizedBox(height: 24),

            // SCHEDULE HEADING
            const Text(
              'Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ROTATION 1
            _buildRotationDropdown(
              label: 'Rotation 1',
              initialValue: _rotation1,
              onChanged: (val) => setState(() => _rotation1 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 2
            _buildRotationDropdown(
              label: 'Rotation 2',
              initialValue: _rotation2,
              onChanged: (val) => setState(() => _rotation2 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 3
            _buildRotationDropdown(
              label: 'Rotation 3',
              initialValue: _rotation3,
              onChanged: (val) => setState(() => _rotation3 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 4
            _buildRotationDropdown(
              label: 'Rotation 4',
              initialValue: _rotation4,
              onChanged: (val) => setState(() => _rotation4 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 5
            _buildRotationDropdown(
              label: 'Rotation 5',
              initialValue: _rotation5,
              onChanged: (val) => setState(() => _rotation5 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 6
            _buildRotationDropdown(
              label: 'Rotation 6',
              initialValue: _rotation6,
              onChanged: (val) => setState(() => _rotation6 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 7
            _buildRotationDropdown(
              label: 'Rotation 7',
              initialValue: _rotation7,
              onChanged: (val) => setState(() => _rotation7 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 8
            _buildRotationDropdown(
              label: 'Rotation 8',
              initialValue: _rotation8,
              onChanged: (val) => setState(() => _rotation8 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 24),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cancel without saving
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------- Helper widgets -------

  /// Builds a generic text form field using a TextEditingController.
  Widget _buildTextFormField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(labelText: label),
      validator: (val) {
        // Optional: add validations if needed
        if (val == null || val.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  /// Builds a dropdown for a specific rotation, using the supplied options.
  Widget _buildRotationDropdown({
    required String label,
    required String initialValue,
    required ValueChanged<String?> onChanged,
    required List<String> rotationOptions,
  }) {
    return Row(
      children: [
        const SizedBox(width: 16), // Indent slightly
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: label),
            value: initialValue.isEmpty ? null : initialValue,
            items: rotationOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            hint: Text("Select $label"),
            onChanged: onChanged,
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}

/* import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class EditStudentDetailsScreen extends StatefulWidget {
  const EditStudentDetailsScreen({super.key, required this.documentId});
  final String documentId;

  @override
  State<EditStudentDetailsScreen> createState() =>
      _EditStudentDetailsScreenState();
}

class _EditStudentDetailsScreenState extends State<EditStudentDetailsScreen> {
  // Firestore reference
  final _usersCollection = FirebaseFirestore.instance.collection('users');

  // Form key for validation (optional but recommended)
  final _formKey = GlobalKey<FormState>();

  // Fields to edit
  // We will initialize them in `initState()` with the student's data.
  String _classValue = 'MMed1'; // Displayed value in the dropdown (uppercase)
  String _email = '';
  String _firstName = '';
  String _lastName = '';
  String _roleValue = 'student';

  // Rotations. We store them as strings. Each rotation has a dropdown.
  String _rotation1 = '';
  String _rotation2 = '';
  String _rotation3 = '';
  String _rotation4 = '';
  String _rotation5 = '';
  String _rotation6 = '';
  String _rotation7 = '';
  String _rotation8 = '';

  // Because the rotation options differ depending on the class, we define them here:
  final List<String> _mmed1And3Rotations = [
    "Infectious Diseases",
    "Gastroenterology",
    "Pulmonology",
    "Nephrology",
    "Neurology",
    "Ward 11",
    "Hematology",
    "Cardiology",
    "Endocrinology",
    "ICU/Palliative Care"
  ];

  final List<String> _mmed2Rotations = [
    "Radiology",
    "Emergency - Mulago",
    "TB",
    "UCI",
    "MLI",
    "IDI",
    "Dermatology",
    "UHI"
  ];

  @override
  void initState() {
    super.initState();
    _loadStudentData();
  }

  /// Loads the student data from Firestore and populates the local fields.
  Future<void> _loadStudentData() async {
    final docSnapshot = await _usersCollection.doc(widget.documentId).get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data() as Map<String, dynamic>;

      setState(() {
        // Convert stored 'class' (e.g. 'mmed1') to uppercase display (e.g. 'MMed1')
        _classValue = _convertClassValueToDisplay(data['class'] ?? 'mmed1');
        _email = data['email'] ?? '';
        _firstName = data['firstname'] ?? '';
        _lastName = data['lastname'] ?? '';
        _roleValue = data['role'] ?? 'student';

        // Schedule is a map with rotation keys
        final schedule = data['schedule'] as Map<String, dynamic>? ?? {};
        _rotation1 = schedule['rotation1'] ?? '';
        _rotation2 = schedule['rotation2'] ?? '';
        _rotation3 = schedule['rotation3'] ?? '';
        _rotation4 = schedule['rotation4'] ?? '';
        _rotation5 = schedule['rotation5'] ?? '';
        _rotation6 = schedule['rotation6'] ?? '';
        _rotation7 = schedule['rotation7'] ?? '';
        _rotation8 = schedule['rotation8'] ?? '';

        _clearInvalidRotations();
      });
    }
  }

  /// Converts the stored lowercase class value (e.g. 'mmed1') into uppercase display (e.g. 'MMed1').
  String _convertClassValueToDisplay(String classValue) {
    switch (classValue) {
      case 'mmed1':
        return 'MMed1';
      case 'mmed2':
        return 'MMed2';
      case 'mmed3':
        return 'MMed3';
      default:
        return 'MMed1'; // default fallback
    }
  }

  /// Converts the displayed class value (e.g. 'MMed1') back to lowercase (e.g. 'mmed1') for storing in Firestore.
  String _convertClassValueToStore(String classValue) {
    switch (classValue) {
      case 'MMed1':
        return 'mmed1';
      case 'MMed2':
        return 'mmed2';
      case 'MMed3':
        return 'mmed3';
      default:
        return 'mmed1'; // default fallback
    }
  }

  void _clearInvalidRotations() {
    // Figure out which rotations are valid for the *current* class
    final isMmed2 = _classValue == 'MMed2';
    final validRotations = isMmed2 ? _mmed2Rotations : _mmed1And3Rotations;

    void clearIfInvalid(String rotationVal, void Function(String) setter) {
      if (!validRotations.contains(rotationVal)) {
        setter('');
      }
    }

    clearIfInvalid(_rotation1, (val) => _rotation1 = val);
    clearIfInvalid(_rotation2, (val) => _rotation2 = val);
    clearIfInvalid(_rotation3, (val) => _rotation3 = val);
    clearIfInvalid(_rotation4, (val) => _rotation4 = val);
    clearIfInvalid(_rotation5, (val) => _rotation5 = val);
    clearIfInvalid(_rotation6, (val) => _rotation6 = val);
    clearIfInvalid(_rotation7, (val) => _rotation7 = val);
    clearIfInvalid(_rotation8, (val) => _rotation8 = val);
  }

  /// Saves the updated student data to Firestore.
  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate and save form fields to their variables
    _formKey.currentState!.save();

    // Build the updated schedule map
    final updatedSchedule = {
      'rotation1': _rotation1,
      'rotation2': _rotation2,
      'rotation3': _rotation3,
      'rotation4': _rotation4,
      'rotation5': _rotation5,
      'rotation6': _rotation6,
      'rotation7': _rotation7,
      'rotation8': _rotation8,
    };

    await _usersCollection.doc(widget.documentId).update({
      'class': _convertClassValueToStore(_classValue),
      'email': _email.trim(),
      'firstname': _firstName.trim(),
      'lastname': _lastName.trim(),
      'role': _roleValue.trim(),
      'schedule': updatedSchedule,
    });

    // Pop back to the previous screen
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determine the rotation list based on the current class
    final isMmed2 = _classValue == 'MMed2';
    final rotationOptions = isMmed2 ? _mmed2Rotations : _mmed1And3Rotations;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Student Details'),
      ),
      body: _buildBody(rotationOptions),
    );
  }

  Widget _buildBody(List<String> rotationOptions) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // CLASS DROPDOWN
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Class'),
              value: _classValue,
              items: const [
                DropdownMenuItem(value: 'MMed1', child: Text('MMed1')),
                DropdownMenuItem(value: 'MMed2', child: Text('MMed2')),
                DropdownMenuItem(value: 'MMed3', child: Text('MMed3')),
              ],
              onChanged: (val) {
                setState(() {
                  _classValue = val!;
                  // Now we reset or clear invalid rotations
                  _clearInvalidRotations();
                });
              },
              onSaved: (val) {
                _classValue = val ?? 'MMed1';
              },
            ),
            const SizedBox(height: 16),

            // EMAIL
            _buildTextFormField(
              label: 'Email',
              initialValue: _email,
              onSaved: (val) => _email = val ?? '',
            ),
            const SizedBox(height: 16),

            // FIRST NAME
            _buildTextFormField(
              label: 'First Name',
              initialValue: _firstName,
              onSaved: (val) => _firstName = val ?? '',
            ),
            const SizedBox(height: 16),

            // LAST NAME
            _buildTextFormField(
              label: 'Last Name',
              initialValue: _lastName,
              onSaved: (val) => _lastName = val ?? '',
            ),
            const SizedBox(height: 16),

            // ROLE DROPDOWN
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Role'),
              value: _roleValue,
              items: const [
                DropdownMenuItem(value: 'student', child: Text('student')),
                DropdownMenuItem(value: 'faculty', child: Text('faculty')),
              ],
              onChanged: (val) {
                setState(() {
                  _roleValue = val!;
                });
              },
              onSaved: (val) {
                _roleValue = val ?? 'student';
              },
            ),
            const SizedBox(height: 24),

            // SCHEDULE HEADING
            const Text(
              'Schedule',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // ROTATION 1
            _buildRotationDropdown(
              label: 'Rotation 1',
              initialValue: _rotation1,
              onChanged: (val) => setState(() => _rotation1 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 2
            _buildRotationDropdown(
              label: 'Rotation 2',
              initialValue: _rotation2,
              onChanged: (val) => setState(() => _rotation2 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 3
            _buildRotationDropdown(
              label: 'Rotation 3',
              initialValue: _rotation3,
              onChanged: (val) => setState(() => _rotation3 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 4
            _buildRotationDropdown(
              label: 'Rotation 4',
              initialValue: _rotation4,
              onChanged: (val) => setState(() => _rotation4 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 5
            _buildRotationDropdown(
              label: 'Rotation 5',
              initialValue: _rotation5,
              onChanged: (val) => setState(() => _rotation5 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 6
            _buildRotationDropdown(
              label: 'Rotation 6',
              initialValue: _rotation6,
              onChanged: (val) => setState(() => _rotation6 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 7
            _buildRotationDropdown(
              label: 'Rotation 7',
              initialValue: _rotation7,
              onChanged: (val) => setState(() => _rotation7 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 16),

            // ROTATION 8
            _buildRotationDropdown(
              label: 'Rotation 8',
              initialValue: _rotation8,
              onChanged: (val) => setState(() => _rotation8 = val!),
              rotationOptions: rotationOptions,
            ),
            const SizedBox(height: 24),

            // BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _saveChanges,
                  child: const Text('Save Changes'),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop(); // Cancel without saving
                  },
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ------- Helper widgets -------

  /// Builds a dropdown for selecting the student's class (MMed1, MMed2, MMed3).
  Widget _buildClassDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Class'),
      value: _classValue,
      items: const [
        DropdownMenuItem(value: 'MMed1', child: Text('MMed1')),
        DropdownMenuItem(value: 'MMed2', child: Text('MMed2')),
        DropdownMenuItem(value: 'MMed3', child: Text('MMed3')),
      ],
      onChanged: (val) {
        setState(() {
          _classValue = val!;
          // Also reset rotations if you want them to refresh
          // For now, we keep them, but you can clear them if needed.
        });
      },
      onSaved: (val) => _classValue = val ?? 'MMed1',
    );
  }

  /// Builds a dropdown for selecting the student's role (student or faculty).
  Widget _buildRoleDropdown() {
    return DropdownButtonFormField<String>(
      decoration: const InputDecoration(labelText: 'Role'),
      value: _roleValue,
      items: const [
        DropdownMenuItem(value: 'student', child: Text('student')),
        DropdownMenuItem(value: 'faculty', child: Text('faculty')),
      ],
      onChanged: (val) {
        setState(() {
          _roleValue = val!;
        });
      },
      onSaved: (val) => _roleValue = val ?? 'student',
    );
  }

  /// Builds a generic text form field with the given label and initial value.
  Widget _buildTextFormField({
    required String label,
    required String initialValue,
    required Function(String?) onSaved,
  }) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      initialValue: initialValue,
      validator: (val) {
        // Optional: add validations if needed
        if (val == null || val.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }

  /// Builds a dropdown for a specific rotation, using the supplied options.
  Widget _buildRotationDropdown({
    required String label,
    required String initialValue,
    required ValueChanged<String?> onChanged,
    required List<String> rotationOptions,
  }) {
    return Row(
      children: [
        const SizedBox(width: 16), // Indent slightly
        Expanded(
          child: DropdownButtonFormField<String>(
            decoration: InputDecoration(labelText: label),
            value: initialValue.isEmpty ? null : initialValue,
            items: rotationOptions.map((option) {
              return DropdownMenuItem(
                value: option,
                child: Text(option),
              );
            }).toList(),
            // If no initial value, it will show a placeholder
            hint: Text("Select $label"),
            onChanged: onChanged,
            // If you want to validate each rotation, add a validator
            validator: (val) {
              if (val == null || val.isEmpty) {
                return 'Please select $label';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }
}
 */
