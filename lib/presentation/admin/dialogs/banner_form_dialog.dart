import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/models/banner_model.dart';
import '../../../domain/enums/banner_action.dart';

class BannerFormDialog extends StatefulWidget {
  final BannerModel? initialBanner;
  final ValueChanged<BannerModel> onSave;

  const BannerFormDialog({super.key, this.initialBanner, required this.onSave});

  @override
  State<BannerFormDialog> createState() => _BannerFormDialogState();
}

class _BannerFormDialogState extends State<BannerFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _imageUrlController;
  late TextEditingController _targetController;
  late BannerAction _actionType;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    final b = widget.initialBanner;
    _titleController = TextEditingController(text: b?.title ?? '');
    _subtitleController = TextEditingController(text: b?.subtitle ?? '');
    _imageUrlController = TextEditingController(text: b?.imageUrl ?? '');
    _targetController = TextEditingController(text: b?.actionTarget ?? '');
    _actionType = b?.actionType ?? BannerAction.content;
    _isActive = b?.isActive ?? true;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _imageUrlController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final banner = BannerModel(
        id: widget.initialBanner?.id ?? const Uuid().v4(),
        title: _titleController.text.trim(),
        subtitle: _subtitleController.text.trim().isNotEmpty
            ? _subtitleController.text.trim()
            : null,
        imageUrl: _imageUrlController.text.trim(),
        actionType: _actionType,
        actionTarget: _targetController.text.trim(),
        isActive: _isActive,
        createdAt: widget.initialBanner?.createdAt ?? DateTime.now(),
      );
      widget.onSave(banner);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.initialBanner != null ? 'Edit Featured Banner' : 'New Featured Banner',
                    style: AppTypography.headlineLarge,
                  ),
                  const Divider(),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _titleController,
                    decoration: const InputDecoration(labelText: 'Banner Title *'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Title is required' : null,
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _subtitleController,
                    decoration: const InputDecoration(labelText: 'Subtitle / Tagline'),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _imageUrlController,
                    decoration: const InputDecoration(labelText: 'Image URL *'),
                    validator: (v) => v?.trim().isEmpty == true ? 'Image URL is required' : null,
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<BannerAction>(
                    initialValue: _actionType,
                    decoration: const InputDecoration(labelText: 'Action Type *'),
                    items: BannerAction.values
                        .map((a) => DropdownMenuItem(value: a, child: Text(a.label)))
                        .toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _actionType = val);
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _targetController,
                    decoration: const InputDecoration(
                      labelText: 'Target Video ID / Category ID / URL *',
                      hintText: 'e.g. video_id or https://...',
                    ),
                    validator: (v) => v?.trim().isEmpty == true ? 'Target is required' : null,
                  ),
                  const SizedBox(height: 14),
                  SwitchListTile(
                    title: const Text('Banner Active'),
                    value: _isActive,
                    onChanged: (val) => setState(() => _isActive = val),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                      const SizedBox(width: 12),
                      ElevatedButton(onPressed: _submit, child: const Text('Save Banner')),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
