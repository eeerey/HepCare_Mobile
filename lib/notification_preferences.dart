import 'package:flutter/material.dart';
import 'notification_service.dart';

const Color hepCareBlue = Color(0xFF1E88E5);
const Color primaryLightBlue = Color(0xFFE3F2FD);
const Color hepCareGreen = Color(0xFF4CAF50);

class NotificationPreferencesScreen extends StatefulWidget {
  const NotificationPreferencesScreen({super.key});

  @override
  State<NotificationPreferencesScreen> createState() =>
      _NotificationPreferencesScreenState();
}

class _NotificationPreferencesScreenState
    extends State<NotificationPreferencesScreen> {
  bool _isLoading = true;
  bool _notificationsEnabled = false;
  bool _articleNotifications = true;
  bool _reminderNotifications = true;
  bool _urgentNotifications = true;
  int _newArticleCount = 0;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
    _checkNewArticles();
  }

  Future<void> _loadPreferences() async {
    final isEnabled = await NotificationService.isNotificationEnabled();
    if (mounted) {
      setState(() {
        _notificationsEnabled = isEnabled;
        _isLoading = false;
      });
    }
  }

  Future<void> _checkNewArticles() async {
    final count = await NotificationService.getNewArticleCount();
    if (mounted) {
      setState(() => _newArticleCount = count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(color: primaryLightBlue),
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 16,
                left: 16,
                right: 16,
                bottom: 24,
              ),
              child: Row(
                children: [
                  InkWell(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    'Preferensi Notifikasi',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // --- CONTENT ---
            if (_isLoading)
              Expanded(
                child: Center(
                  child: CircularProgressIndicator(color: hepCareBlue),
                ),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  children: [
                    // --- MAIN TOGGLE ---
                    Container(
                      margin: const EdgeInsets.only(bottom: 20),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Aktifkan Notifikasi',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Terima notifikasi tentang artikel terbaru',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                          Switch(
                            value: _notificationsEnabled,
                            activeColor: hepCareGreen,
                            onChanged: (value) {
                              setState(() => _notificationsEnabled = value);
                              NotificationService.setNotificationEnabled(value);

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    value
                                        ? 'Notifikasi diaktifkan'
                                        : 'Notifikasi dinonaktifkan',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),

                    // --- NEW ARTICLES INFO ---
                    if (_newArticleCount > 0)
                      Container(
                        margin: const EdgeInsets.only(bottom: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: hepCareGreen.withOpacity(0.1),
                          border: Border.all(
                            color: hepCareGreen.withOpacity(0.3),
                            width: 1.5,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: hepCareGreen,
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.article_outlined,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Artikel Terbaru',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    'Ada $_newArticleCount artikel baru untuk dibaca',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const Icon(
                              Icons.arrow_forward_ios,
                              size: 16,
                              color: Colors.black26,
                            ),
                          ],
                        ),
                      ),

                    // --- NOTIFICATION TYPES ---
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                            child: Row(
                              children: [
                                const Text(
                                  'Tipe Notifikasi',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          NotificationTypeItem(
                            icon: Icons.article_outlined,
                            title: 'Artikel Terbaru',
                            subtitle:
                                'Notifikasi saat ada artikel kesehatan baru',
                            value: _articleNotifications,
                            enabled: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _articleNotifications = value);
                            },
                          ),
                          const Divider(height: 1, indent: 65, endIndent: 16),
                          NotificationTypeItem(
                            icon: Icons.schedule_outlined,
                            title: 'Pengingat Pemeriksaan',
                            subtitle:
                                'Pengingat untuk melakukan pemeriksaan rutin',
                            value: _reminderNotifications,
                            enabled: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _reminderNotifications = value);
                            },
                          ),
                          const Divider(height: 1, indent: 65, endIndent: 16),
                          NotificationTypeItem(
                            icon: Icons.warning_outlined,
                            title: 'Notifikasi Penting',
                            subtitle: 'Pemberitahuan tentang informasi penting',
                            value: _urgentNotifications,
                            enabled: _notificationsEnabled,
                            onChanged: (value) {
                              setState(() => _urgentNotifications = value);
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // --- INFO BOX ---
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: hepCareBlue.withOpacity(0.1),
                        border: Border.all(
                          color: hepCareBlue.withOpacity(0.3),
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: hepCareBlue,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.info_outline,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Tips',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Aktifkan notifikasi untuk mendapatkan update artikel kesehatan terbaru dan pengingat pemeriksaan kesehatan Anda.',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NotificationTypeItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final Function(bool) onChanged;

  const NotificationTypeItem({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Icon(
        icon,
        color: enabled ? hepCareBlue : Colors.black26,
        size: 28,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: enabled ? Colors.black87 : Colors.black38,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: enabled ? Colors.black54 : Colors.black26,
        ),
      ),
      trailing: Switch(
        value: value,
        activeColor: hepCareGreen,
        onChanged: enabled ? onChanged : null,
      ),
    );
  }
}
