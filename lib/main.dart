import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'providers/app_provider.dart';
import 'theme.dart';
import 'screens/home_screen.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> initNotifications() async {
  tz.initializeTimeZones();

  const AndroidInitializationSettings androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initSettings =
      InitializationSettings(android: androidSettings);

  await flutterLocalNotificationsPlugin.initialize(
    initSettings,
    onDidReceiveNotificationResponse: (details) {},
  );

  // Create notification channel
  const AndroidNotificationChannel channel = AndroidNotificationChannel(
    'water_reminder_channel',
    'Water Reminders',
    description: 'Reminds you to drink water throughout the day',
    importance: Importance.high,
    playSound: true,
    enableVibration: true,
    showBadge: true,
  );

  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.createNotificationChannel(channel);

  // Request permission on Android 13+
  await flutterLocalNotificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>()
      ?.requestNotificationsPermission();
}

Future<void> showWaterNotification(String title, String body) async {
  const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
    'water_reminder_channel',
    'Water Reminders',
    channelDescription: 'Reminds you to drink water throughout the day',
    importance: Importance.high,
    priority: Priority.high,
    icon: '@mipmap/ic_launcher',
    largeIcon: DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
    styleInformation: BigTextStyleInformation(''),
    visibility: NotificationVisibility.public, // shows on lock screen
    playSound: true,
    enableVibration: true,
    ongoing: false,
    autoCancel: true,
    ticker: 'Water Reminder',
  );

  const NotificationDetails details =
      NotificationDetails(android: androidDetails);

  await flutterLocalNotificationsPlugin.show(
    99,
    title,
    body,
    details,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));

  await initNotifications();

  final prefs = await SharedPreferences.getInstance();
  final skipConfirm = prefs.getBool('skipConfirm') ?? false;

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppProvider(onNotify: showWaterNotification),
      child: DailyTrackerApp(skipConfirm: skipConfirm),
    ),
  );
}

class DailyTrackerApp extends StatelessWidget {
  final bool skipConfirm;
  const DailyTrackerApp({super.key, required this.skipConfirm});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'daily tracker',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.system,
      home: skipConfirm ? const HomeScreen() : const ConfirmScreen(),
    );
  }
}

// ── Confirm / Splash screen ─────────────────────────────
class ConfirmScreen extends StatefulWidget {
  const ConfirmScreen({super.key});
  @override
  State<ConfirmScreen> createState() => _ConfirmScreenState();
}

class _ConfirmScreenState extends State<ConfirmScreen>
    with SingleTickerProviderStateMixin {
  bool _dontShow = false;
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 450));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dontShow) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('skipConfirm', true);
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(PageRouteBuilder(
      pageBuilder: (_, a, __) => const HomeScreen(),
      transitionsBuilder: (_, a, __, child) =>
          FadeTransition(opacity: a, child: child),
      transitionDuration: const Duration(milliseconds: 350),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg      = isDark ? const Color(0xFF111110) : const Color(0xFFFAFAF9);
    final surface = isDark ? const Color(0xFF1A1A19) : Colors.white;
    final text    = isDark ? const Color(0xFFEEEDE8) : const Color(0xFF111110);
    final text2   = isDark ? const Color(0xFF78776E) : const Color(0xFF78776E);
    final text3   = isDark ? const Color(0xFF4A4A46) : const Color(0xFFB0AFA8);
    final border  = isDark ? const Color(0x22FFFFFF) : const Color(0x22000000);
    final surf2   = isDark ? const Color(0xFF232321) : const Color(0xFFF4F4F2);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Center(
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Logo ──
                      Center(
                        child: Container(
                          width: 120,
                          height: 60,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: surf2,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: border),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(11),
                            child: Image.asset(
                              'assets/images/logo.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        "Don't Lie To Yourself",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                            color: text,
                            letterSpacing: -0.3),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "This tracker only works if you're honest with it — and with yourself. Log what you actually did. Not what you wished you did.",
                        style:
                            TextStyle(fontSize: 13, color: text2, height: 1.6),
                      ),
                      const SizedBox(height: 22),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => setState(() => _dontShow = !_dontShow),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: Checkbox(
                                value: _dontShow,
                                onChanged: (v) =>
                                    setState(() => _dontShow = v!),
                                activeColor: text,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4)),
                                side: BorderSide(color: text3),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              "don't show this message again",
                              style: TextStyle(
                                  fontSize: 12,
                                  color: text3,
                                  fontFamily: 'monospace'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _dismiss,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: text,
                            foregroundColor: bg,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(vertical: 13),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10)),
                          ),
                          child: const Text("I'm ready — let's go",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Footer logo text
                      Center(
                        child: RichText(
                          text: TextSpan(children: [
                            TextSpan(
                                text: 'daily',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: text3,
                                    fontFamily: 'monospace')),
                            TextSpan(
                                text: ' tracker',
                                style: TextStyle(
                                    fontSize: 11,
                                    color: text2,
                                    fontFamily: 'monospace')),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
