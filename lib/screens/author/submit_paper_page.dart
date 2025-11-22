import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../utils/constants.dart';
import '../../services/api_service.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../models/paper.dart';

class SubmitPaperPage extends StatefulWidget {
  const SubmitPaperPage({Key? key}) : super(key: key);

  @override
  State<SubmitPaperPage> createState() => _SubmitPaperPageState();
}

class _SubmitPaperPageState extends State<SubmitPaperPage> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();
  
  // Controllers
  final _titleController = TextEditingController();
  final _abstractController = TextEditingController();
  final _keywordsController = TextEditingController();
  final _authorsController = TextEditingController();
  
  // State
  bool _isSubmitting = false;
  String? _selectedTrack;
  String? _selectedCategory;
  String? _fileName;
  PlatformFile? _selectedFile;
  
  final List<String> _tracks = [
    'Computer Science',
    'Information Technology',
    'Software Engineering',
    'Data Science',
    'Artificial Intelligence',
    'Cybersecurity',
  ];
  
  final List<String> _categories = [
    'Full Paper',
    'Short Paper',
    'Poster',
    'Workshop Paper',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _abstractController.dispose();
    _keywordsController.dispose();
    _authorsController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
          _fileName = result.files.first.name;
        });
      }
    } catch (e) {
      _showSnackBar('Error picking file: $e', isError: true);
    }
  }

  Future<void> _submitPaper() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedFile == null) {
      _showSnackBar('Please select a file', isError: true);
      return;
    }

    if (_selectedTrack == null) {
      _showSnackBar('Please select a track', isError: true);
      return;
    }

    if (_selectedCategory == null) {
      _showSnackBar('Please select a category', isError: true);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      // Submit paper with named parameters
      await _apiService.submitPaper(
        conferenceId: 1, // TODO: Get from selected conference
        title: _titleController.text,
        abstract: _abstractController.text,
        keywords: _keywordsController.text,
        filePath: _selectedFile?.path,
      );

      if (mounted) {
        _showSnackBar('Paper submitted successfully!');
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      _showSnackBar('Error submitting paper: $e', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const Text('Submit Paper'),
        backgroundColor: AppColors.authorPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInfoCard(),
              const SizedBox(height: 24),
              _buildFormSection(),
              const SizedBox(height: 24),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.authorPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.authorPrimary.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: AppColors.authorPrimary,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Submission Guidelines',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.authorPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Papers must be original and not submitted elsewhere. Accepted formats: PDF, DOC, DOCX.',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paper Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Paper Title
          CustomTextField(
            controller: _titleController,
            label: 'Paper Title *',
            hint: 'Enter your paper title',
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter paper title';
              }
              if (value.length < 10) {
                return 'Title must be at least 10 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Abstract
          CustomTextField(
            controller: _abstractController,
            label: 'Abstract *',
            hint: 'Enter paper abstract (max 300 words)',
            maxLines: 6,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter abstract';
              }
              if (value.length < 100) {
                return 'Abstract must be at least 100 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Authors
          CustomTextField(
            controller: _authorsController,
            label: 'Authors *',
            hint: 'e.g., John Doe, Jane Smith, Peter Johnson',
            maxLines: 2,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter authors';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Keywords
          CustomTextField(
            controller: _keywordsController,
            label: 'Keywords *',
            hint: 'Enter keywords separated by commas',
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter keywords';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Track Selection
          Text(
            'Track *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedTrack,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
              hint: const Text('Select track'),
              isExpanded: true,
              items: _tracks.map((track) {
                return DropdownMenuItem(
                  value: track,
                  child: Text(track),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedTrack = value);
              },
            ),
          ),
          const SizedBox(height: 16),

          // Category Selection
          Text(
            'Category *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: InputBorder.none,
              ),
              hint: const Text('Select category'),
              isExpanded: true,
              items: _categories.map((category) {
                return DropdownMenuItem(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() => _selectedCategory = value);
              },
            ),
          ),
          const SizedBox(height: 20),

          // File Upload
          Text(
            'Upload Paper *',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          InkWell(
            onTap: _pickFile,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.backgroundLight,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedFile != null 
                      ? AppColors.authorPrimary 
                      : Colors.grey.shade300,
                  width: 2,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.authorPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _selectedFile != null ? Icons.check_circle : Icons.upload_file,
                      color: AppColors.authorPrimary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _fileName ?? 'Choose file to upload',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PDF, DOC, DOCX (Max 10MB)',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return CustomButton(
      text: _isSubmitting ? 'Submitting...' : 'Submit Paper',
      onPressed: _isSubmitting ? null : _submitPaper,
      isLoading: _isSubmitting,
      backgroundColor: AppColors.authorPrimary,
      fullWidth: true,
    );
  }
}