import 'dart:ui';
import 'package:flutter/material.dart';

class WindyLoader {
  static OverlayEntry? _entry;
  static bool _scheduled = false;

  static void show(BuildContext context) {
    if (_entry != null || _scheduled) return;
    _scheduled = true;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;

      final overlay = Overlay.maybeOf(context, rootOverlay: true);
      if (overlay == null) return;

      if (_entry != null) return;
      _entry = OverlayEntry(builder: (_) => const _WindyLoaderOverlay());
      overlay.insert(_entry!);
    });
  }

  static void hide() {
    if (_entry == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _entry?.remove();
      _entry = null;
    });
  }
}

class WindyLoaderObserver extends NavigatorObserver {
  static const _pulseMs = 800; // 0.8s

  void _pulse() {
    final ctx = navigator?.context;
    if (ctx == null) return;

    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) return;

    WindyLoader.show(ctx);
    Future.delayed(const Duration(milliseconds: _pulseMs), () {
      WindyLoader.hide();
    });
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pulse();
    super.didPush(route, previousRoute);
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _pulse();
    super.didPop(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    _pulse();
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
  }
}

class _WindyLoaderOverlay extends StatefulWidget {
  const _WindyLoaderOverlay();

  @override
  State<_WindyLoaderOverlay> createState() => _WindyLoaderOverlayState();
}

class _WindyLoaderOverlayState extends State<_WindyLoaderOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _wave;
  late final Animation<double> _spin;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _wave = Tween<double>(begin: -12, end: 12).animate(
      CurvedAnimation(parent: _c, curve: Curves.easeInOutSine),
    );
    _spin = Tween<double>(begin: 0, end: 1).animate(_c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.10),
      child: Stack(
        children: [
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
              child: Container(color: Colors.transparent),
            ),
          ),
          Center(
            child: AnimatedBuilder(
              animation: _c,
              builder: (_, __) {
                return Transform.translate(
                  offset: Offset(_wave.value, 0),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 86,
                        height: 86,
                        child: CircularProgressIndicator(
                          strokeWidth: 4,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.green.shade400,
                          ),
                        ),
                      ),
                      RotationTransition(
                        turns: _spin,
                        child: Icon(
                          Icons.eco,
                          size: 44,
                          color: Colors.green.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
