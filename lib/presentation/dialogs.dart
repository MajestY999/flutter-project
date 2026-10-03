// Определяет диалоги создания и редактирования карточек, профиля и действий.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/tracked_person.dart';
import '../theme/app_colors.dart';

class PersonFormData {
  const PersonFormData({
    required this.name,
    required this.promise,
    required this.isSelf,
    required this.broken,
    required this.kept,
  });

  final String name;
  final String promise;
  final bool isSelf;
  final int broken;
  final int kept;
}

class PersonDialog extends StatefulWidget {
  const PersonDialog({
    super.key,
    this.initialPerson,
    this.initiallySelf = false,
  });

  final TrackedPerson? initialPerson;
  final bool initiallySelf;

  @override
  State<PersonDialog> createState() => PersonDialogState();
}

class PersonDialogState extends State<PersonDialog> {
  final _nameController = TextEditingController();
  final _promiseController = TextEditingController();
  final _brokenController = TextEditingController();
  final _keptController = TextEditingController();
  bool _isSelf = false;

  @override
  void initState() {
    super.initState();
    _isSelf = widget.initiallySelf;
    final person = widget.initialPerson;
    if (person != null) {
      _nameController.text = person.name;
      _promiseController.text = person.promise
          .replaceAll('«', '')
          .replaceAll('»', '');
      _brokenController.text = '${person.broken}';
      _keptController.text = '${person.kept}';
      _isSelf = person.isSelf;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _promiseController.dispose();
    _brokenController.dispose();
    _keptController.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    FocusScope.of(context).unfocus();
    Navigator.of(context).pop(
      PersonFormData(
        name: name,
        promise: _promiseController.text.trim().isEmpty
            ? '«Обещал(а) что-то важное»'
            : '«${_promiseController.text.trim()}»',
        isSelf: _isSelf,
        broken: int.tryParse(_brokenController.text) ?? 0,
        kept: int.tryParse(_keptController.text) ?? 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.sizeOf(context);
    final horizontalInset = screenSize.width < 360 ? 8.0 : 16.0;
    return Dialog(
      insetPadding: EdgeInsets.symmetric(
        horizontal: horizontalInset,
        vertical: 12,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: math.min(420.0, screenSize.width - horizontalInset * 2),
          maxHeight: math.max(0.0, screenSize.height - 24),
        ),
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.initialPerson == null
                      ? 'Кого записываем?'
                      : 'Изменить карточку',
                  style: const TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 14),
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        DialogTextField(
                          controller: _nameController,
                          label: 'Имя',
                          hint: 'Например, Саша',
                        ),
                        const SizedBox(height: 13),
                        DialogTextField(
                          controller: _promiseController,
                          label: 'Главное обещание',
                          hint: 'Позвоню на выходных',
                          maxLength: 60,
                        ),
                        if (widget.initialPerson != null) ...[
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: DialogTextField(
                                  controller: _brokenController,
                                  label: 'Срывы',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  digitsOnly: true,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: DialogTextField(
                                  controller: _keptController,
                                  label: 'Сдержано',
                                  hint: '0',
                                  keyboardType: TextInputType.number,
                                  digitsOnly: true,
                                ),
                              ),
                            ],
                          ),
                        ],
                        const SizedBox(height: 6),
                        SwitchListTile.adaptive(
                          contentPadding: EdgeInsets.zero,
                          activeTrackColor: AppColors.lime,
                          title: const Text(
                            'Это я',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Следим и за своими обещаниями',
                            style: TextStyle(
                              fontSize: 10,
                              color: AppColors.muted,
                            ),
                          ),
                          value: _isSelf,
                          onChanged: (value) => setState(() => _isSelf = value),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Отмена',
                        style: TextStyle(color: AppColors.muted),
                      ),
                    ),
                    FilledButton(
                      onPressed: _submit,
                      style: FilledButton.styleFrom(
                        foregroundColor: AppColors.background,
                        backgroundColor: AppColors.lime,
                      ),
                      child: Text(
                        widget.initialPerson == null ? 'Добавить' : 'Сохранить',
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DialogTextField extends StatelessWidget {
  const DialogTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.autofocus = false,
    this.maxLength,
    this.keyboardType,
    this.digitsOnly = false,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final bool autofocus;
  final int? maxLength;
  final TextInputType? keyboardType;
  final bool digitsOnly;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLength: maxLength,
      keyboardType: keyboardType,
      inputFormatters: digitsOnly
          ? [FilteringTextInputFormatter.digitsOnly]
          : null,
      textCapitalization: TextCapitalization.sentences,
      style: const TextStyle(fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: const TextStyle(color: Color(0xFF77737F), fontSize: 12),
        labelStyle: const TextStyle(color: AppColors.muted, fontSize: 12),
        counterStyle: const TextStyle(color: AppColors.muted, fontSize: 9),
        filled: true,
        fillColor: AppColors.background,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 13,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: .07)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(color: AppColors.violet, width: 1.2),
        ),
      ),
    );
  }
}

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key, required this.initialName});

  final String initialName;

  @override
  State<ProfileDialog> createState() => ProfileDialogState();
}

class ProfileDialogState extends State<ProfileDialog> {
  late final TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      scrollable: true,
      insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
      title: const Text('Ваш профиль'),
      content: DialogTextField(
        controller: _nameController,
        label: 'Как вас зовут?',
        hint: 'Ваше имя',
        autofocus: false,
        maxLength: 30,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Отмена'),
        ),
        FilledButton(
          onPressed: () {
            final name = _nameController.text.trim();
            if (name.isEmpty) return;
            Navigator.pop(context, name);
          },
          child: const Text('Сохранить'),
        ),
      ],
    );
  }
}
