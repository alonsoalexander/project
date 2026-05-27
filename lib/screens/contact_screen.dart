import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// Maps Contact.tsx — contact form + contact info card

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_formKey.currentState?.validate() ?? false) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Tack för ditt meddelande! Vi återkommer snart.'),
          backgroundColor: AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppRadius.medium),
        ),
      );
      _nameCtrl.clear();
      _emailCtrl.clear();
      _subjectCtrl.clear();
      _messageCtrl.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1100),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Kontakta oss',
                  style: Theme.of(context).textTheme.displayMedium),
              const SizedBox(height: AppSpacing.xxl),

              LayoutBuilder(builder: (context, constraints) {
                final twoCol = constraints.maxWidth > 600;
                final form = _ContactForm(
                  formKey: _formKey,
                  nameCtrl: _nameCtrl,
                  emailCtrl: _emailCtrl,
                  subjectCtrl: _subjectCtrl,
                  messageCtrl: _messageCtrl,
                  onSubmit: _handleSubmit,
                );
                const info = _ContactInfo();

                return twoCol
                    ? Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: form),
                          const SizedBox(width: AppSpacing.xl),
                          const Expanded(child: _ContactInfo()),
                        ],
                      )
                    : Column(
                        children: [
                          form,
                          const SizedBox(height: AppSpacing.xl),
                          info,
                        ],
                      );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController subjectCtrl;
  final TextEditingController messageCtrl;
  final VoidCallback onSubmit;

  const _ContactForm({
    required this.formKey,
    required this.nameCtrl,
    required this.emailCtrl,
    required this.subjectCtrl,
    required this.messageCtrl,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Skicka ett meddelande',
                  style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: AppSpacing.xl),

              _label('Namn'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: nameCtrl,
                decoration: _greenInput(hintText: 'Ditt namn'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Namn krävs' : null,
              ),

              const SizedBox(height: AppSpacing.lg),
              _label('E-post'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: emailCtrl,
                keyboardType: TextInputType.emailAddress,
                decoration: _greenInput(hintText: 'din@email.se'),
                validator: (v) =>
                    v == null || !v.contains('@') ? 'Ogiltig e-post' : null,
              ),

              const SizedBox(height: AppSpacing.lg),
              _label('Ämne'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: subjectCtrl,
                decoration: _greenInput(hintText: 'Vad gäller det?'),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Ämne krävs' : null,
              ),

              const SizedBox(height: AppSpacing.lg),
              _label('Meddelande'),
              const SizedBox(height: AppSpacing.sm),
              TextFormField(
                controller: messageCtrl,
                maxLines: 5,
                decoration: _greenInput(
                  hintText: 'Skriv ditt meddelande här...',
                  alignLabelWithHint: true,
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Meddelande krävs' : null,
              ),

              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onSubmit,
                  child: const Text('Skicka meddelande'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ContactInfo extends StatelessWidget {
  const _ContactInfo();

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Kontaktinformation',
                style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: AppSpacing.xl),

            const _InfoItem(
              icon: Icons.mail_outline,
              title: 'E-post',
              value: 'info@imat.se',
            ),
            const SizedBox(height: AppSpacing.lg),
            const _InfoItem(
              icon: Icons.phone_outlined,
              title: 'Telefon',
              value: '08-123 456 78',
            ),
            const SizedBox(height: AppSpacing.lg),
            const _InfoItem(
              icon: Icons.location_on_outlined,
              title: 'Adress',
              value: 'Storgatan 123\n123 45 Stockholm',
            ),
            const SizedBox(height: AppSpacing.lg),
            const _InfoItem(
              icon: Icons.access_time_outlined,
              title: 'Öppettider',
              value: 'Mån–Fre: 08:00–20:00\nLör–Sön: 10:00–18:00',
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.mutedForeground),
        const SizedBox(width: AppSpacing.md),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.mutedForeground,
                    )),
          ],
        ),
      ],
    );
  }
}

Widget _label(String text) => Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.foreground,
      ),
    );

InputDecoration _greenInput({String? hintText, bool alignLabelWithHint = false}) =>
    InputDecoration(
      hintText: hintText,
      alignLabelWithHint: alignLabelWithHint,
      enabledBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.primary, width: 2.5),
      ),
      errorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.destructive),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide(color: AppColors.destructive, width: 2),
      ),
    );
