import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show ByteData, rootBundle;
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:archive/archive.dart';

// ─── ألوان التطبيق الهادئة ───
const Color kEmerald50 = Color(0xFFECFDF5);
const Color kEmerald100 = Color(0xFFD1FAE5);
const Color kEmerald200 = Color(0xFFA7F3D0);
const Color kEmerald400 = Color(0xFF34D399);
const Color kEmerald600 = Color(0xFF059669);
const Color kEmerald700 = Color(0xFF047857);
const Color kEmerald800 = Color(0xFF065F46);
const Color kEmerald900 = Color(0xFF064E3B);
const Color kGold = Color(0xFFD4A84B);
const Color kGoldLight = Color(0xFFF5ECD7);
const Color kOffWhite = Color(0xFFFAF9F6);
const Color kWarmGray = Color(0xFF6B7280);

const MaterialColor emerald = MaterialColor(0xFF10B981, <int, Color>{
  50: kEmerald50, 100: kEmerald100, 200: kEmerald200,
  300: Color(0xFF6EE7B7), 400: kEmerald400, 500: Color(0xFF10B981),
  600: kEmerald600, 700: kEmerald700, 800: kEmerald800, 900: kEmerald900,
});

void main() => runApp(const SakeenahApp());

class SakeenahApp extends StatelessWidget {
  const SakeenahApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'سَكينة AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: emerald,
        scaffoldBackgroundColor: kOffWhite,
        fontFamily: 'Cairo',
        appBarTheme: AppBarTheme(
          backgroundColor: kEmerald700,
          foregroundColor: Colors.white,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontFamily: 'Cairo', fontWeight: FontWeight.bold, fontSize: 20,
          ),
        ),
        bottomNavigationBarTheme: BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: kEmerald700,
          unselectedItemColor: kWarmGray,
          selectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 13, fontWeight: FontWeight.bold),
          unselectedLabelStyle: const TextStyle(fontFamily: 'Cairo', fontSize: 12),
          type: BottomNavigationBarType.fixed,
        ),
      ),
      home: const IntroScreen(),
    );
  }
}

// ═══════════════════════════════════════════
// شاشة البداية (Intro/Splash)
// ═══════════════════════════════════════════
class IntroScreen extends StatefulWidget {
  const IntroScreen({super.key});
  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> with SingleTickerProviderStateMixin {
  late AnimationController _fadeCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2));
    _fadeAnim = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeIn);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [kEmerald900, kEmerald700],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.mosque_rounded, size: 120, color: kGold),
              const SizedBox(height: 24),
              const Text('سَكينة AI',
                style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 12),
              const Text('رفيقك الآمن والمطمئن في الحج',
                style: TextStyle(fontSize: 20, color: kEmerald100, fontFamily: 'Cairo'),
              ),
              const SizedBox(height: 60),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kGold,
                  foregroundColor: kEmerald900,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                  elevation: 8,
                ),
                child: const Text('ابدأ الرحلة', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cairo')),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


// ═══════════════════════════════════════════
// الهيكل الرئيسي — شريط تنقل سفلي بـ 4 تبويبات
// ═══════════════════════════════════════════
class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentTab = 0;
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  void _initTTS() async {
    await _tts.setLanguage("ar");
    await _tts.setSpeechRate(0.42);
    await _tts.setPitch(1.0);
  }

  void _speak(String msg) async => await _tts.speak(msg);

  @override
  Widget build(BuildContext context) {
    final tabs = [
      DashboardTab(tts: _tts, speak: _speak),
      TawafSaiTab(speak: _speak),
      SafeRouteTab(tts: _tts, speak: _speak),
      EmergencyTab(speak: _speak),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('سَكينة AI — المساعد الذكي للحاج'),
        ),
        body: IndexedStack(index: _currentTab, children: tabs),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentTab,
          onTap: (i) => setState(() => _currentTab = i),
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home_rounded, size: 30), label: 'الرئيسية'),
            BottomNavigationBarItem(icon: Icon(Icons.mosque_rounded, size: 30), label: 'الطواف والسعي'),
            BottomNavigationBarItem(icon: Icon(Icons.map_rounded, size: 30), label: 'المسار الآمن'),
            BottomNavigationBarItem(icon: Icon(Icons.sos_rounded, size: 30), label: 'نداء الطوارئ'),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// بطاقة عامة مُنسّقة
// ═══════════════════════════════════════════
class SakeenahCard extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final Color? bgColor;
  const SakeenahCard({super.key, required this.child, this.borderColor = kEmerald200, this.bgColor});
  @override
  Widget build(BuildContext context) {
    return Card(
      color: bgColor ?? Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(color: borderColor, width: 1.5),
      ),
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(padding: const EdgeInsets.all(18), child: child),
    );
  }
}

// ═══════════════════════════════════════════
// تبويب 1: الرئيسية — مراقبة الإجهاد الحراري
// ═══════════════════════════════════════════
class DashboardTab extends StatefulWidget {
  final FlutterTts tts;
  final void Function(String) speak;
  const DashboardTab({super.key, required this.tts, required this.speak});
  @override
  State<DashboardTab> createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> with SingleTickerProviderStateMixin {
  StreamSubscription? _accelSub;
  late AnimationController _pulseCtrl;

  // حالة صحية من 5 مستويات
  int _healthLevel = 0; // 0=طبيعي, 1=خفيف, 2=متوسط, 3=شديد, 4=طوارئ
  String _healthText = "مستقر وطبيعي";
  Color _healthColor = kEmerald700;
  IconData _healthIcon = Icons.favorite_rounded;

  // تحليل المشية
  final List<double> _gaitSamples = [];
  int _gaitWindowSize = 50;
  double _gaitVariability = 0.0;
  int _stumblingCount = 0;
  DateTime? _lastAlertTime;

  static const _levels = [
    {"text": "مستقر وطبيعي ✅", "color": kEmerald700, "icon": Icons.favorite_rounded},
    {"text": "يُنصح بشرب الماء والراحة 💧", "color": Color(0xFF2563EB), "icon": Icons.water_drop_rounded},
    {"text": "علامات إرهاق حراري 🌡️", "color": Color(0xFFD97706), "icon": Icons.thermostat_rounded},
    {"text": "إجهاد حراري ودوخة شديدة 🚨", "color": Color(0xFFEA580C), "icon": Icons.warning_amber_rounded},
    {"text": "طوارئ: تم رصد سقوط مفاجئ ⚠️", "color": Color(0xFFDC2626), "icon": Icons.emergency_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat(reverse: true);
    _initSensors();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _initSensors() {
    _accelSub = accelerometerEventStream().listen((e) {
      if (!mounted) return;
      double g = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);

      // تجميع عينات المشية
      _gaitSamples.add(g);
      if (_gaitSamples.length > _gaitWindowSize) _gaitSamples.removeAt(0);

      // حساب تذبذب المشية
      if (_gaitSamples.length >= 20) {
        double mean = _gaitSamples.reduce((a, b) => a + b) / _gaitSamples.length;
        double variance = _gaitSamples.map((v) => (v - mean) * (v - mean)).reduce((a, b) => a + b) / _gaitSamples.length;
        _gaitVariability = sqrt(variance);
      }

      // تحديد المستوى الصحي
      int newLevel = 0;
      if (g > 23.0) {
        newLevel = 4; // سقوط
        _stumblingCount++;
      } else if ((e.x.abs() > 13.5 || e.y.abs() > 13.5) && g <= 22.0) {
        newLevel = 3; // إجهاد شديد
      } else if (_gaitVariability > 4.0 || _stumblingCount >= 3) {
        newLevel = 2; // إرهاق متوسط
      } else if (_gaitVariability > 2.5) {
        newLevel = 1; // خفيف
      }

      if (newLevel != _healthLevel) {
        final now = DateTime.now();
        if (_lastAlertTime == null || now.difference(_lastAlertTime!) > const Duration(seconds: 8)) {
          _lastAlertTime = now;
          setState(() {
            _healthLevel = newLevel;
            _healthText = _levels[newLevel]["text"] as String;
            _healthColor = _levels[newLevel]["color"] as Color;
            _healthIcon = _levels[newLevel]["icon"] as IconData;
          });
          if (newLevel >= 2) {
            widget.speak(_healthText.replaceAll(RegExp(r'[✅💧🌡️🚨⚠️]'), ''));
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        // بطاقة الحالة الصحية
        SakeenahCard(
          borderColor: _healthColor,
          child: Column(children: [
            const Text('مراقبة الحالة الصحية بالذكاء الاصطناعي', style: TextStyle(fontSize: 13, color: kWarmGray)),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, __) {
                double scale = _healthLevel >= 2 ? 1.0 + _pulseCtrl.value * 0.15 : 1.0;
                return Transform.scale(
                  scale: scale,
                  child: Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _healthColor.withOpacity(0.12),
                      border: Border.all(color: _healthColor, width: 3),
                    ),
                    child: Icon(_healthIcon, color: _healthColor, size: 48),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            Text(_healthText, textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: _healthColor)),
            const SizedBox(height: 8),
            // مؤشرات إضافية
            Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
              _miniStat('تذبذب المشية', _gaitVariability.toStringAsFixed(1)),
              _miniStat('حالات التعثر', '$_stumblingCount'),
            ]),
          ]),
        ),
        // نصائح سريعة
        SakeenahCard(
          bgColor: kGoldLight,
          borderColor: kGold,
          child: Row(children: [
            Icon(Icons.lightbulb_rounded, color: kGold, size: 32),
            const SizedBox(width: 12),
            Expanded(child: Text(
              _healthLevel == 0 ? 'أنت بخير والحمد لله. حافظ على شرب الماء باستمرار.'
              : _healthLevel <= 2 ? 'استرح في مكان مُظلّل واشرب ماءً بارداً. لا تتعجّل.'
              : 'توجّه فوراً لأقرب نقطة إسعاف. اطلب المساعدة من حولك.',
              style: const TextStyle(fontSize: 15, color: Color(0xFF78350F)),
            )),
          ]),
        ),
      ]),
    );
  }

  Widget _miniStat(String label, String value) {
    return Column(children: [
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kEmerald800)),
      Text(label, style: const TextStyle(fontSize: 12, color: kWarmGray)),
    ]);
  }
}

// ═══════════════════════════════════════════
// تبويب 2: عداد الطواف والسعي مع التوجيه الصوتي
// ═══════════════════════════════════════════
class TawafSaiTab extends StatefulWidget {
  final void Function(String) speak;
  const TawafSaiTab({super.key, required this.speak});
  @override
  State<TawafSaiTab> createState() => _TawafSaiTabState();
}

class _TawafSaiTabState extends State<TawafSaiTab> {
  bool _isSaiMode = false; // false=طواف, true=سعي
  bool _isManualChecklist = true; // Default to visually friendly checklist
  int _currentShawt = 0;
  int _stepCount = 0;
  int _stepsPerShawt = 800;
  int _lastShawtSteps = 0;
  StreamSubscription? _accelSub;

  double _lastMag = 0;
  bool _stepHigh = false;

  static const _tawafDuaa = [
    'سبحان الله والحمد لله ولا إله إلا الله والله أكبر',
    'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار',
    'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير',
    'اللهم إني أسألك العفو والعافية في الدنيا والآخرة',
    'رب اغفر وارحم، أنت خير الراحمين',
    'اللهم اغفر لي ذنوبي وافتح لي أبواب رحمتك',
    'سبحان الله والحمد لله ولا إله إلا الله والله أكبر',
  ];

  static const _tawafDuaaTTS = [
    'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ',
    'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ',
    'لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ لاَ شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ',
    'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالآخِرَةِ',
    'رَبِّ اغْفِرْ وَارْحَمْ، أَنْتَ خَيْرُ الرَّاحِمِينَ',
    'اللَّهُمَّ اغْفِرْ لِي ذُنُوبِي وَافْتَحْ لِي أَبْوَابَ رَحْمَتِكَ',
    'سُبْحَانَ اللَّهِ وَالْحَمْدُ لِلَّهِ وَلاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ',
  ];

  static const _saiDuaa = [
    'إن الصفا والمروة من شعائر الله — بسم الله نبدأ',
    'لا إله إلا الله والله أكبر، لا إله إلا الله وحده',
    'رب اغفر وارحم واهدني السبيل الأقوم',
    'اللهم اجعلنا من عبادك الصالحين المقبولين',
    'سبحانك اللهم وبحمدك، أشهد ألا إله إلا أنت',
    'اللهم أعنّي على ذكرك وشكرك وحسن عبادتك',
    'الحمد لله الذي أتمّ علينا نسكنا. اللهم تقبّل منا',
  ];

  static const _saiDuaaTTS = [
    'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ. بِسْمِ اللَّهِ نَبْدَأُ',
    'لاَ إِلَهَ إِلاَّ اللَّهُ وَاللَّهُ أَكْبَرُ، لاَ إِلَهَ إِلاَّ اللَّهُ وَحْدَهُ',
    'رَبِّ اغْفِرْ وَارْحَمْ وَاهْدِنِي السَّبِيلَ الأَقْوَمَ',
    'اللَّهُمَّ اجْعَلْنَا مِنْ عِبَادِكَ الصَّالِحِينَ الْمَقْبُولِينَ',
    'سُبْحَانَكَ اللَّهُمَّ وَبِحَمْدِكَ، أَشْهَدُ أَلاَّ إِلَهَ إِلاَّ أَنْتَ',
    'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ',
    'الْحَمْدُ لِلَّهِ الَّذِي أَتَمَّ عَلَيْنَا نُسُكَنَا. اللَّهُمَّ تَقَبَّلْ مِنَّا',
  ];

  @override
  void initState() {
    super.initState();
    _initPedometer();
  }

  @override
  void dispose() {
    _accelSub?.cancel();
    super.dispose();
  }

  void _initPedometer() {
    _accelSub = accelerometerEventStream().listen((e) {
      if (!mounted) return;
      double mag = sqrt(e.x * e.x + e.y * e.y + e.z * e.z);
      if (mag > 12.0 && !_stepHigh) {
        _stepHigh = true;
        setState(() {
          _stepCount++;
          if (!_isManualChecklist) _checkAutoShawt();
        });
      } else if (mag < 10.5) {
        _stepHigh = false;
      }
      _lastMag = mag;
    });
  }

  void _checkAutoShawt() {
    int stepsSinceLastShawt = _stepCount - _lastShawtSteps;
    if (stepsSinceLastShawt >= _stepsPerShawt && _currentShawt < 7) {
      _addShawt();
    }
  }

  void _addShawt() {
    if (_currentShawt >= 7) return;
    setState(() {
      _currentShawt++;
      _lastShawtSteps = _stepCount;
    });
    _speakProgress();
  }

  void _setShawt(int count) {
    setState(() {
      _currentShawt = count;
      _lastShawtSteps = _stepCount;
    });
    if (count > 0) _speakProgress();
  }

  void _speakProgress() {
    final ttsList = _isSaiMode ? _saiDuaaTTS : _tawafDuaaTTS;
    String ritualName = _isSaiMode ? 'السَّعْيِ' : 'الطَّوَافِ';
    if (_currentShawt == 7) {
      widget.speak('مَا شَاءَ اللَّهُ! أَتْمَمْتَ $ritualName كَامِلاً. ${ttsList[6]}');
    } else {
      String direction = '';
      if (_isSaiMode) {
        direction = _currentShawt.isOdd ? ' مِنْ الصَّفَا إِلَى الْمَرْوَةِ' : ' مِنْ الْمَرْوَةِ إِلَى الصَّفَا';
      }
      widget.speak('أَتْمَمْتَ الشَّوْطَ $_currentShawt مِنْ $ritualName$direction. ${ttsList[_currentShawt - 1]}');
    }
  }

  void _reset() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('إعادة ضبط العداد', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
        content: const Text('هل أنت متأكد من إعادة ضبط العداد من البداية؟', style: TextStyle(fontFamily: 'Cairo', fontSize: 16)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('إلغاء')),
          TextButton(onPressed: () {
            _forceReset();
            Navigator.pop(ctx);
          }, child: const Text('نعم، إعادة ضبط', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _forceReset() {
    setState(() { _currentShawt = 0; _stepCount = 0; _lastShawtSteps = 0; });
  }

  @override
  Widget build(BuildContext context) {
    double progress = _currentShawt / 7.0;
    final duaaList = _isSaiMode ? _saiDuaa : _tawafDuaa;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        // اختيار الوضع
        SakeenahCard(
          borderColor: kGold,
          bgColor: kGoldLight,
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _modeButton('طواف 🕋', !_isSaiMode, () {
              setState(() { _isSaiMode = false; _forceReset(); });
            }),
            const SizedBox(width: 16),
            _modeButton('سعي ⛰️', _isSaiMode, () {
              setState(() { _isSaiMode = true; _forceReset(); });
            }),
          ]),
        ),
        
        const SizedBox(height: 12),
        // Toggle Method
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('كيفية الحساب:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kEmerald900)),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('عداد آلي 🤖', style: TextStyle(fontSize: 15, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              selected: !_isManualChecklist,
              onSelected: (val) => setState(() => _isManualChecklist = false),
              selectedColor: kEmerald200,
            ),
            const SizedBox(width: 8),
            ChoiceChip(
              label: const Text('مرئي يدوي 📋', style: TextStyle(fontSize: 15, fontFamily: 'Cairo', fontWeight: FontWeight.bold)),
              selected: _isManualChecklist,
              onSelected: (val) => setState(() => _isManualChecklist = true),
              selectedColor: kEmerald200,
            ),
          ],
        ),
        const SizedBox(height: 16),

        if (_isManualChecklist)
          _buildVisualChecklist(duaaList)
        else
          _buildAutoCounter(progress, duaaList),

        // بطاقة الدعاء الحالي
        if (_currentShawt > 0 && _currentShawt <= 7)
          SakeenahCard(
            bgColor: kEmerald50,
            borderColor: kEmerald400,
            child: Column(children: [
              Icon(Icons.menu_book_rounded, color: kEmerald700, size: 28),
              const SizedBox(height: 8),
              Text('دعاء الشوط $_currentShawt',
                style: TextStyle(fontSize: 14, color: kEmerald800, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(duaaList[_currentShawt - 1],
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.8, color: Color(0xFF1F2937))),
            ]),
          ),
      ]),
    );
  }

  Widget _buildAutoCounter(double progress, List<String> duaaList) {
    return SakeenahCard(child: Column(children: [
      Text(_isSaiMode ? 'عداد أشواط السعي التلقائي' : 'عداد أشواط الطواف التلقائي',
        style: const TextStyle(fontSize: 16, color: kWarmGray)),
      const SizedBox(height: 16),
      SizedBox(
        width: 200, height: 200,
        child: Stack(alignment: Alignment.center, children: [
          SizedBox(width: 200, height: 200,
            child: CircularProgressIndicator(
              value: progress, strokeWidth: 14,
              backgroundColor: kEmerald100,
              valueColor: AlwaysStoppedAnimation(_currentShawt == 7 ? kGold : kEmerald600),
            ),
          ),
          Column(mainAxisSize: MainAxisSize.min, children: [
            Text('$_currentShawt', style: TextStyle(fontSize: 64, fontWeight: FontWeight.bold, color: kEmerald900)),
            const Text('/ ٧', style: TextStyle(fontSize: 24, color: kWarmGray)),
          ]),
        ]),
      ),
      if (_currentShawt == 7) ...[
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(color: kGold.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
          child: Text('🎉 تقبّل الله منك!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: kGold)),
        ),
      ],
      const SizedBox(height: 16),
      Text('عدد الخطوات: $_stepCount', style: const TextStyle(fontSize: 16, color: kWarmGray)),
      if (_isSaiMode && _currentShawt > 0 && _currentShawt < 7) ...[
        const SizedBox(height: 6),
        Text(_currentShawt.isOdd ? '⬅️ متجه من الصفا إلى المروة' : '➡️ متجه من المروة إلى الصفا',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kEmerald700)),
      ],
      const SizedBox(height: 16),
      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
        ElevatedButton.icon(
          onPressed: _currentShawt < 7 ? _addShawt : null,
          icon: const Icon(Icons.add_circle_outline, size: 26),
          label: const Text('شوط إضافي', style: TextStyle(fontSize: 16)),
          style: ElevatedButton.styleFrom(
            backgroundColor: kEmerald600, foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        OutlinedButton.icon(
          onPressed: _reset,
          icon: const Icon(Icons.refresh_rounded, size: 24),
          label: const Text('إعادة ضبط', style: TextStyle(fontSize: 15)),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red[700],
            side: BorderSide(color: Colors.red[300]!),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
    ]));
  }

  Widget _buildVisualChecklist(List<String> duaaList) {
    return Column(
      children: List<Widget>.generate(7, (index) {
        int shawtIndex = index + 1;
        bool isCompleted = shawtIndex <= _currentShawt;
        return GestureDetector(
          onTap: () {
            if (shawtIndex == _currentShawt + 1) {
              _setShawt(shawtIndex);
            } else if (isCompleted && shawtIndex == _currentShawt) {
              _setShawt(shawtIndex - 1);
            }
          },
          child: SakeenahCard(
            bgColor: isCompleted ? kEmerald100 : Colors.white,
            borderColor: isCompleted ? kEmerald600 : kEmerald200,
            child: Row(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: isCompleted ? kEmerald600 : kOffWhite,
                    shape: BoxShape.circle,
                    border: Border.all(color: isCompleted ? kEmerald600 : kWarmGray, width: 2),
                  ),
                  child: Icon(
                    isCompleted ? Icons.check_rounded : Icons.touch_app_rounded,
                    color: isCompleted ? Colors.white : kWarmGray,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('الشوط $shawtIndex',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: isCompleted ? kEmerald900 : Colors.black87)
                      ),
                      if (_isSaiMode)
                        Text(shawtIndex.isOdd ? 'من الصفا إلى المروة' : 'من المروة إلى الصفا',
                          style: TextStyle(fontSize: 15, color: isCompleted ? kEmerald800 : kWarmGray)
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList()
        ..add(
          Padding(
            padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
            child: OutlinedButton.icon(
              onPressed: _reset,
              icon: const Icon(Icons.refresh_rounded, size: 24),
              label: const Text('إعادة ضبط جميع الأشواط', style: TextStyle(fontSize: 16)),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red[700], side: BorderSide(color: Colors.red[300]!),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ),
    );
  }

  Widget _modeButton(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
        decoration: BoxDecoration(
          color: active ? kEmerald700 : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: active ? kEmerald700 : kWarmGray),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 17, fontWeight: FontWeight.bold,
          color: active ? Colors.white : kWarmGray,
        )),
      ),
    );
  }
}

// ═══════════════════════════════════════════
// تبويب 3: المسار الآمن — خريطة أوفلاين + نقاط إسعاف
// ═══════════════════════════════════════════
class SafeRouteTab extends StatefulWidget {
  final FlutterTts tts;
  final void Function(String) speak;
  const SafeRouteTab({super.key, required this.tts, required this.speak});
  @override
  State<SafeRouteTab> createState() => _SafeRouteTabState();
}

class _SafeRouteTabState extends State<SafeRouteTab> {
  final MapController _mapCtrl = MapController();
  StreamSubscription<Position>? _locSub;
  LatLng _currentPos = const LatLng(29.8450, 31.3350);
  double _heading = 0.0;
  bool _extracting = true;
  String _tilesPath = "";
  String _navText = "جاري تحديد موقعك...";
  String _selectedFilter = 'الكل';

  static const _filters = ['الكل', 'مستشفى', 'إسعاف', 'مياه', 'ظل'];

  final List<Map<String, dynamic>> _aidPoints = [
    {"name": "مستشفى حلوان العام", "type": "مستشفى", "icon": Icons.local_hospital_rounded, "color": const Color(0xFFDC2626), "location": const LatLng(29.8425, 31.3015)},
    {"name": "مستشفى 15 مايو النموذجي", "type": "مستشفى", "icon": Icons.local_hospital_rounded, "color": const Color(0xFFDC2626), "location": const LatLng(29.8560, 31.3730)},
    {"name": "مركز إسعاف حلوان", "type": "إسعاف", "icon": Icons.emergency_rounded, "color": const Color(0xFFEA580C), "location": const LatLng(29.8390, 31.3120)},
    {"name": "نقطة إسعاف 15 مايو", "type": "إسعاف", "icon": Icons.emergency_rounded, "color": const Color(0xFFEA580C), "location": const LatLng(29.8610, 31.3810)},
    {"name": "نقطة مياه — ميدان حلوان", "type": "مياه", "icon": Icons.water_drop_rounded, "color": const Color(0xFF2563EB), "location": const LatLng(29.8440, 31.3180)},
    {"name": "نقطة مياه — شارع المصانع", "type": "مياه", "icon": Icons.water_drop_rounded, "color": const Color(0xFF2563EB), "location": const LatLng(29.8480, 31.3400)},
    {"name": "منطقة مظللة — حديقة حلوان", "type": "ظل", "icon": Icons.park_rounded, "color": const Color(0xFF059669), "location": const LatLng(29.8460, 31.3250)},
    {"name": "منطقة مظللة — كورنيش النيل", "type": "ظل", "icon": Icons.park_rounded, "color": const Color(0xFF059669), "location": const LatLng(29.8410, 31.2980)},
  ];

  final List<List<LatLng>> _shadedRoutes = [
    [const LatLng(29.8430, 31.3100), const LatLng(29.8445, 31.3150), const LatLng(29.8460, 31.3250), const LatLng(29.8470, 31.3300)],
    [const LatLng(29.8400, 31.2950), const LatLng(29.8410, 31.2980), const LatLng(29.8420, 31.3020), const LatLng(29.8425, 31.3015)],
  ];

  @override
  void initState() {
    super.initState();
    _prepTiles();
    _startLocation();
  }

  @override
  void dispose() {
    _locSub?.cancel();
    super.dispose();
  }

  Future<void> _prepTiles() async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final tilesDir = Directory('${docDir.path}/offline_tiles');
      if (!await tilesDir.exists()) {
        await tilesDir.create(recursive: true);
        ByteData data = await rootBundle.load('assets/map_tiles/map_tiles.zip');
        List<int> bytes = data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
        Archive archive = ZipDecoder().decodeBytes(bytes);
        for (ArchiveFile file in archive) {
          if (file.isFile) {
            File outFile = File('${tilesDir.path}/${file.name}');
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(file.content as List<int>);
          }
        }
      }
      if (mounted) setState(() { _tilesPath = tilesDir.path; _extracting = false; });
    } catch (e) {
      debugPrint("Tile error: $e");
      if (mounted) setState(() => _extracting = false);
    }
  }

  void _startLocation() async {
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) perm = await Geolocator.requestPermission();
    if (perm == LocationPermission.deniedForever) {
      setState(() => _navText = "يرجى تفعيل صلاحية الموقع من الإعدادات.");
      return;
    }
    _locSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 2),
    ).listen((pos) {
      if (!mounted) return;
      LatLng newLoc = LatLng(pos.latitude, pos.longitude);
      setState(() { _currentPos = newLoc; _heading = pos.heading; });
      try { _mapCtrl.move(newLoc, 15.0); } catch (_) {}
      _updateNav(newLoc);
    });
  }

  void _updateNav(LatLng pos) {
    final filtered = _filteredPoints();
    if (filtered.isEmpty) { setState(() => _navText = "لا توجد نقاط من هذا النوع."); return; }
    double minDist = double.infinity;
    String nearest = "";
    for (var p in filtered) {
      double d = Geolocator.distanceBetween(pos.latitude, pos.longitude,
        (p["location"] as LatLng).latitude, (p["location"] as LatLng).longitude);
      if (d < minDist) { minDist = d; nearest = p["name"]; }
    }
    String distStr = minDist >= 1000 ? "${(minDist / 1000).toStringAsFixed(1)} كم" : "${minDist.toStringAsFixed(0)} متر";
    setState(() => _navText = "أقرب نقطة: $nearest\nالمسافة: $distStr");
  }

  List<Map<String, dynamic>> _filteredPoints() {
    if (_selectedFilter == 'الكل') return _aidPoints;
    return _aidPoints.where((p) => p["type"] == _selectedFilter).toList();
  }

  void _speakNearest() {
    widget.speak(_navText.replaceAll('\n', '. '));
  }

  @override
  Widget build(BuildContext context) {
    final pts = _filteredPoints();
    return Column(children: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: _filters.map((f) {
            bool active = _selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(f, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold,
                  color: active ? Colors.white : kEmerald800)),
                selected: active,
                selectedColor: kEmerald700,
                backgroundColor: kEmerald50,
                onSelected: (_) { setState(() => _selectedFilter = f); _updateNav(_currentPos); },
              ),
            );
          }).toList()),
        ),
      ),
      Expanded(
        child: _extracting
          ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              CircularProgressIndicator(color: kEmerald700),
              const SizedBox(height: 12),
              const Text("جاري تهيئة الخريطة الأوفلاين...", style: TextStyle(color: kWarmGray)),
            ]))
          : Stack(children: [
              FlutterMap(
                mapController: _mapCtrl,
                options: MapOptions(initialCenter: _currentPos, initialZoom: 14.5, minZoom: 13, maxZoom: 16,
                  interactionOptions: const InteractionOptions(flags: InteractiveFlag.all)),
                children: [
                  TileLayer(
                    urlTemplate: '$_tilesPath/{z}/{x}/{y}.png',
                    tileProvider: FileTileProvider(),
                    fallbackUrl: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.sakeenah.ai',
                  ),
                  PolylineLayer(polylines: _shadedRoutes.map((route) => Polyline(
                    points: route, strokeWidth: 8,
                    color: kEmerald400.withOpacity(0.55),
                  )).toList()),
                  MarkerLayer(markers: [
                    Marker(point: _currentPos, width: 50, height: 50,
                      child: Transform.rotate(angle: _heading * (pi / 180),
                        child: const Icon(Icons.navigation_rounded, color: Colors.blue, size: 40))),
                    ...pts.map((p) => Marker(
                      point: p["location"], width: 44, height: 44,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: (p["color"] as Color).withOpacity(0.3), blurRadius: 6)],
                        ),
                        child: Icon(p["icon"] as IconData, color: p["color"] as Color, size: 28),
                      ),
                    )),
                  ]),
                ],
              ),
              Positioned(left: 16, bottom: 100, child: FloatingActionButton(
                heroTag: 'voice_nav', mini: true,
                backgroundColor: kEmerald700,
                onPressed: _speakNearest,
                child: const Icon(Icons.volume_up_rounded, color: Colors.white),
              )),
            ]),
      ),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        color: Colors.white,
        child: Row(children: [
          Icon(Icons.near_me_rounded, color: kEmerald700, size: 28),
          const SizedBox(width: 10),
          Expanded(child: Text(_navText, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF1F2937)))),
        ]),
      ),
    ]);
  }
}

// ═══════════════════════════════════════════
// تبويب 4: نداء الطوارئ — شبكة بلوتوث
// ═══════════════════════════════════════════
class EmergencyTab extends StatefulWidget {
  final void Function(String) speak;
  const EmergencyTab({super.key, required this.speak});
  @override
  State<EmergencyTab> createState() => _EmergencyTabState();
}

class _EmergencyTabState extends State<EmergencyTab> with TickerProviderStateMixin {
  bool _sosActive = false;
  bool _sosHolding = false;
  int _nearbyCount = 0;
  late AnimationController _sosAnim;
  final List<Map<String, String>> _alerts = [];
  Timer? _scanTimer;

  @override
  void initState() {
    super.initState();
    _sosAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200))..repeat(reverse: true);
    _startSimulatedScan();
  }

  @override
  void dispose() {
    _sosAnim.dispose();
    _scanTimer?.cancel();
    super.dispose();
  }

  // TODO: استبدل بـ flutter_blue_plus للمسح الحقيقي عبر BLE Mesh
  void _startSimulatedScan() {
    _scanTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _nearbyCount = 2 + Random().nextInt(6));
    });
    setState(() => _nearbyCount = 3);
  }

  void _activateSOS() {
    setState(() => _sosActive = true);
    widget.speak('تم إرسال نداء الطوارئ. جاري إبلاغ الحجاج القريبين منك.');
    _addAlert('أنت', 'تم إرسال نداء استغاثة', isOutgoing: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _addAlert('حاج قريب', 'تم استلام ندائك — المساعدة في الطريق');
      widget.speak('تم استلام ندائك من حاج قريب. المساعدة في الطريق إن شاء الله.');
    });
  }

  void _cancelSOS() {
    setState(() => _sosActive = false);
    widget.speak('تم إلغاء نداء الطوارئ.');
  }

  void _addAlert(String sender, String msg, {bool isOutgoing = false}) {
    final now = DateTime.now();
    setState(() {
      _alerts.insert(0, {
        'sender': sender, 'message': msg,
        'time': '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}',
        'type': isOutgoing ? 'out' : 'in',
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(children: [
        // عدد الحجاج القريبين
        SakeenahCard(
          bgColor: kEmerald50, borderColor: kEmerald400,
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: const BoxDecoration(color: kEmerald700, shape: BoxShape.circle),
              child: const Icon(Icons.bluetooth_searching_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('شبكة سَكينة للطوارئ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: kEmerald900)),
              const SizedBox(height: 4),
              Text('$_nearbyCount حجاج بالقرب منك متصلون', style: const TextStyle(fontSize: 14, color: kEmerald700)),
            ])),
            AnimatedBuilder(
              animation: _sosAnim,
              builder: (_, __) => Container(
                width: 14, height: 14,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: kEmerald400.withOpacity(0.5 + _sosAnim.value * 0.5),
                ),
              ),
            ),
          ]),
        ),
        const SizedBox(height: 12),
        // زر SOS
        SakeenahCard(
          borderColor: _sosActive ? const Color(0xFFDC2626) : kEmerald200,
          child: Column(children: [
            Text(
              _sosActive ? 'تم إرسال نداء الطوارئ!' : 'اضغط مطوّلاً لإرسال نداء طوارئ',
              style: TextStyle(fontSize: 16, color: _sosActive ? const Color(0xFFDC2626) : kWarmGray),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onLongPressStart: (_) => setState(() => _sosHolding = true),
              onLongPressEnd: (_) {
                setState(() => _sosHolding = false);
                if (!_sosActive) _activateSOS();
              },
              onTap: _sosActive ? _cancelSOS : null,
              child: AnimatedBuilder(
                animation: _sosAnim,
                builder: (_, __) {
                  double scale = _sosActive || _sosHolding ? 1.0 + _sosAnim.value * 0.08 : 1.0;
                  return Transform.scale(
                    scale: scale,
                    child: Container(
                      width: 160, height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: _sosActive
                            ? [const Color(0xFFDC2626), const Color(0xFF991B1B)]
                            : _sosHolding
                              ? [const Color(0xFFEA580C), const Color(0xFFDC2626)]
                              : [kEmerald400, kEmerald700],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: (_sosActive ? const Color(0xFFDC2626) : kEmerald400).withOpacity(0.4),
                            blurRadius: 24, spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Icon(_sosActive ? Icons.check_rounded : Icons.sos_rounded, color: Colors.white, size: 56),
                        const SizedBox(height: 6),
                        Text(_sosActive ? 'تم الإرسال' : 'SOS',
                          style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ]),
                    ),
                  );
                },
              ),
            ),
            if (_sosActive) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: _cancelSOS,
                icon: const Icon(Icons.cancel_outlined, color: Color(0xFFDC2626)),
                label: const Text('إلغاء النداء', style: TextStyle(color: Color(0xFFDC2626), fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ],
            const SizedBox(height: 12),
            Text(
              _sosHolding ? 'استمر بالضغط...' : _sosActive ? 'جاري إبلاغ الحجاج القريبين' : 'اضغط مطوّلاً لمدة ثانيتين',
              style: TextStyle(fontSize: 13, color: _sosHolding ? const Color(0xFFEA580C) : kWarmGray),
            ),
          ]),
        ),
        // سجل التنبيهات
        if (_alerts.isNotEmpty) ...[
          const SizedBox(height: 8),
          SakeenahCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.history_rounded, color: kWarmGray, size: 22),
                SizedBox(width: 8),
                Text('سجل التنبيهات', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: kWarmGray)),
              ]),
              const Divider(height: 16),
              ..._alerts.map((a) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(
                    a['type'] == 'out' ? Icons.call_made_rounded : Icons.call_received_rounded,
                    color: a['type'] == 'out' ? const Color(0xFFDC2626) : kEmerald600, size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(a['sender']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text(a['message']!, style: const TextStyle(fontSize: 13, color: kWarmGray)),
                  ])),
                  Text(a['time']!, style: const TextStyle(fontSize: 12, color: kWarmGray)),
                ]),
              )),
            ]),
          ),
        ],
      ]),
    );
  }
}

