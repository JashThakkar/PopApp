import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pop/pages/info_page.dart';
import 'package:pop/pages/setting_page.dart';
import 'package:intl/intl.dart';
import 'package:pop/db/database_helper.dart';
import 'package:flutter/services.dart';
import 'package:pop/services/haptic_service.dart';


class BreathingPage extends StatefulWidget {
  final VoidCallback? onLogAdded;
  
  const BreathingPage({super.key, this.onLogAdded});

  @override
  State<BreathingPage> createState() => _BreathingPageState();
}

class _BreathingPageState extends State<BreathingPage>
    with TickerProviderStateMixin {
  final List<String> _steps = ['Inhale', 'Hold', 'Exhale', 'Hold'];
  int _currentStepIndex = 0;
  final _hapticService = HapticService();

  static const int _stepMilliseconds = 4000;
  bool _isPaused = false;
  Timer? _timer;

  late AnimationController _animationController;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;
  late Animation<Color?> _playButtonColorAnimation;
  late AnimationController _fadeController;

  bool _isCountingDown = false;
  String _countdownText = '';
  Timer? _countdownTimer;
  bool _hasStarted = false;

  // Stopwatch variables
  int _elapsedSeconds = 0;
  Timer? _stopwatchTimer;

  @override
  void initState() {
    super.initState();
    _initHapticService();
    
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _stepMilliseconds),
    );

    _animation = Tween<double>(
      begin: 0.8,
      end: 1.5,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _colorAnimation = ColorTween(
      begin: Colors.blue.shade100,
      end: const Color.fromARGB(255, 31, 57, 95),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _playButtonColorAnimation = ColorTween(
      begin: const Color.fromARGB(255, 31, 57, 95),
      end: Colors.blue.shade100,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  Future<void> _initHapticService() async {
    await _hapticService.init();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      const Duration(milliseconds: _stepMilliseconds),
      (timer) {
        if (!_isPaused) {
          setState(() {
            _currentStepIndex = (_currentStepIndex + 1) % _steps.length;
          });
          if (_hapticService.isHapticEnabled) {
            HapticFeedback.lightImpact();
          }
          _resumeAnimation();
        }
      },
    );
    _startStopwatch();
  }

  void _startStopwatch() {
    _stopwatchTimer?.cancel();
    _stopwatchTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!_isPaused && !_isCountingDown) {
        setState(() {
          _elapsedSeconds++;
        });
      }
    });
  }

  void _togglePause() {
    if (_isPaused) {
      setState(() {
        _isCountingDown = true;
        _countdownText = '3';
      });

      _fadeController.forward(from: 0.0);

      _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (int.parse(_countdownText) > 1) {
          setState(() => _countdownText = '${int.parse(_countdownText) - 1}');
        } else {
          setState(() {
            _isPaused = false;
            _isCountingDown = false;
            _startTimer();
            _resumeAnimation();
          });
          timer.cancel();
        }
      });
    } else {
      setState(() {
        _isPaused = true;
        _animationController.stop();
        _timer?.cancel();
      });

      _stopwatchTimer?.cancel();
    }
  }

  void _resumeAnimation() {
    switch (_currentStepIndex) {
      case 0:
        _animationController.forward();
        break;
      case 1:
        _animationController.value = 1.0;
        break;
      case 2:
        _animationController.reverse();
        break;
      case 3:
        _animationController.value = 0.0;
        break;
    }
  }

  void _startBreathing() {
    setState(() {
      _isCountingDown = true;
      _countdownText = '3';
      _elapsedSeconds = 0;
    });

    _fadeController.forward(from: 0.0);

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (int.parse(_countdownText) > 1) {
        setState(() => _countdownText = '${int.parse(_countdownText) - 1}');
      } else {
        setState(() {
          _isCountingDown = false;
          _hasStarted = true;
          _startTimer();
          _resumeAnimation();
        });
        if (_hapticService.isHapticEnabled) {
          HapticFeedback.lightImpact();
        }
        timer.cancel();
      }
    });
  }

  Future<void> _resetBreathing() async {
    if (_hasStarted) {
      final now = DateTime.now();
      final endTime = DateFormat('HH:mm').format(now);
      final date = DateFormat('MMM d, y').format(now);
      final totalTime = _elapsedSeconds >= 60
          ? '${(_elapsedSeconds / 60).floor()}m ${_elapsedSeconds % 60}s'
          : '${_elapsedSeconds}s';

      await DatabaseHelper().insertLog({
        'date': date,
        'startTime': endTime,
        'endTime': endTime,
        'totalTime': totalTime,
      });

      widget.onLogAdded?.call();
    }

    setState(() {
      _timer?.cancel();
      _stopwatchTimer?.cancel();
      _countdownTimer?.cancel();
      _animationController.reset();
      _fadeController.reset();
      _isPaused = false;
      _isCountingDown = false;
      _hasStarted = false;
      _elapsedSeconds = 0;
      _currentStepIndex = 0;
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _stopwatchTimer?.cancel();
    _countdownTimer?.cancel();
    _animationController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String currentStep = _steps[_currentStepIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          padding: EdgeInsets.only(left: 35, bottom: 20, top: 10),
          icon: const Icon(Icons.info_outline, size: 25),
          color: const Color.fromARGB(255, 191, 191, 191),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const InfoPage()),
            );
          },
        ),
        actions: [
          IconButton(
            padding: EdgeInsets.only(right: 35, bottom: 20, top: 10),
            icon: const Icon(Icons.settings_outlined),
            color: const Color.fromARGB(255, 191, 191, 191),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const SettingPage()));
            },
          )
        ],
      ),
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: _hasStarted ? _togglePause : null,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: _animation.value,
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              color: _colorAnimation.value,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (_isCountingDown)
                          Text(
                            _countdownText,
                            style: TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                              color: _playButtonColorAnimation.value,
                            ),
                          ),
                        if (_isPaused && _hasStarted && !_isCountingDown)
                          Icon(
                            Icons.pause,
                            size: 50,
                            color: _playButtonColorAnimation.value,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 150),
                  if (!_hasStarted && !_isCountingDown)
                    ElevatedButton(
                      onPressed: _startBreathing,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 40,
                          vertical: 15,
                        ),
                        backgroundColor: const Color.fromARGB(255, 31, 57, 95),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.white,
                        ),
                      ),
                    )
                  else
                    Column(
                      children: [
                        Text(
                          currentStep,
                          style: TextStyle(
                            fontSize: 35,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            ElevatedButton(
                              onPressed: _resetBreathing,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 12),
                                backgroundColor: Colors.red,
                              ),
                              child: const Text(
                                'Stop',
                                style: TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Text(
                              "${_elapsedSeconds}s",
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
