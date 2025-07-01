import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'dart:async';
import 'home.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Staff Management',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.light(
          primary: Colors.lightGreen.shade700,
          secondary: Colors.lightGreenAccent.shade400,
          background: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.green[50],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.lightGreen.shade700,
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Colors.lightGreen.shade400,
          foregroundColor: Colors.white,
          elevation: 4,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.lightGreen.shade700,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.green[50],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.lightGreen.shade700),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.lightGreen.shade700, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.lightGreen.shade700),
        ),
        cardTheme: CardTheme(
          color: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        textTheme: const TextTheme(
          bodyMedium: TextStyle(
            color: Colors.black87,
            fontSize: 16,
          ),
          titleLarge: TextStyle(
            color: Colors.lightGreen,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _firebaseReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    // Animate the wave offset for the background
    _animation = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    Firebase.initializeApp().then((_) {
      setState(() {
        _firebaseReady = true;
      });
    }).catchError((_) {
      setState(() {
        _hasError = true;
      });
    });

    Timer(const Duration(seconds: 4), () {
      if (_firebaseReady && !_hasError) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const StaffList()),
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return Scaffold(
        body: Center(child: Text('Firebase initialization failed')),
      );
    }
    return Scaffold(
      body: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: _WavyBackgroundPainter(_animation.value),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 80),
                  Text(
                    "Yusra Sdn. Bhd.",
                    style: TextStyle(
                      color: Colors.lightGreen.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      letterSpacing: 1.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  const CircularProgressIndicator(
                    color: Colors.lightGreen,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _WavyBackgroundPainter extends CustomPainter {
  final double waveOffset;
  _WavyBackgroundPainter(this.waveOffset);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = Colors.lightGreen.shade100;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    final wavePaint = Paint()..color = Colors.lightGreen.shade300.withOpacity(0.7);

    final path = Path();
    path.moveTo(0, size.height * 0.3 + waveOffset);
    path.quadraticBezierTo(
      size.width * 0.25, size.height * 0.25 + waveOffset * 1.5,
      size.width * 0.5, size.height * 0.35 - waveOffset,
    );
    path.quadraticBezierTo(
      size.width * 0.75, size.height * 0.45 + waveOffset,
      size.width, size.height * 0.3 + waveOffset,
    );
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();

    canvas.drawPath(path, wavePaint);

    final path2 = Path();
    path2.moveTo(0, size.height * 0.7 - waveOffset);
    path2.quadraticBezierTo(
      size.width * 0.25, size.height * 0.75 - waveOffset * 1.5,
      size.width * 0.5, size.height * 0.65 + waveOffset,
    );
    path2.quadraticBezierTo(
      size.width * 0.75, size.height * 0.55 - waveOffset,
      size.width, size.height * 0.7 - waveOffset,
    );
    path2.lineTo(size.width, size.height);
    path2.lineTo(0, size.height);
    path2.close();

    canvas.drawPath(path2, wavePaint..color = Colors.lightGreen.shade200.withOpacity(0.7));
  }

  @override
  bool shouldRepaint(_WavyBackgroundPainter oldDelegate) =>
      oldDelegate.waveOffset != waveOffset;
}