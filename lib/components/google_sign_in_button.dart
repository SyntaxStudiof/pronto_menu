import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GoogleSignInButton extends StatefulWidget {
  const GoogleSignInButton({
    super.key,
    required this.onTap,
    this.text = 'Continua con Google',
  });

  final Future<void> Function() onTap;
  final String text;

  @override
  State<GoogleSignInButton> createState() => _GoogleSignInButtonState();
}

class _GoogleSignInButtonState extends State<GoogleSignInButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter(PointerEvent _) {
    setState(() => _isHovered = true);
    _controller.repeat();
  }

  void _onExit(PointerEvent _) {
    setState(() => _isHovered = false);
    _controller.stop();
    _controller.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryBg = theme.scaffoldBackgroundColor;
    final alternate = theme.dividerColor;

    return MouseRegion(
      onEnter: _onEnter,
      onExit: _onExit,
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 48.0,
        decoration: BoxDecoration(
          color: _isHovered
              ? primaryBg.withValues(alpha: 0.85)
              : primaryBg,
          borderRadius: BorderRadius.circular(14.0),
          border: Border.all(
            color: _isHovered
                ? const Color(0xFF4285F4).withValues(alpha: 0.45)
                : alternate.withValues(alpha: 0.25),
            width: _isHovered ? 1.3 : 1.0,
          ),
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: const Color(0xFF4285F4).withValues(alpha: 0.08),
                    blurRadius: 10.0,
                    offset: const Offset(0, 3),
                  ),
                ]
              : [],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14.0),
            onTap: _isLoading
                ? null
                : () async {
                    setState(() => _isLoading = true);
                    try {
                      await widget.onTap();
                    } finally {
                      if (mounted) {
                        setState(() => _isLoading = false);
                      }
                    }
                  },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedScale(
                  scale: _isHovered ? 1.1 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return ShaderMask(
                        shaderCallback: (Rect bounds) {
                          return SweepGradient(
                            center: Alignment.center,
                            startAngle: 0.0,
                            endAngle: 2 * math.pi,
                            transform: GradientRotation(
                              _controller.value * 2 * math.pi,
                            ),
                            colors: const [
                              Color(0xFF4285F4), // Google Blue (destra)
                              Color(0xFF34A853), // Google Green (sotto)
                              Color(0xFFFBBC05), // Google Yellow (sinistra)
                              Color(0xFFEA4335), // Google Red (sopra)
                              Color(0xFF4285F4), // Google Blue
                            ],
                            stops: const [0.0, 0.25, 0.5, 0.75, 1.0],
                          ).createShader(bounds);
                        },
                        blendMode: BlendMode.srcIn,
                        child: const FaIcon(
                          FontAwesomeIcons.google,
                          size: 19.0,
                          color: Colors.white,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12.0),
                Text(
                  widget.text,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
