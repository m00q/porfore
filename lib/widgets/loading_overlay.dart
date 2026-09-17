import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_spritesheet_animation/flutter_spritesheet_animation.dart';

/// An opaque, input-blocking cover that plays one decorative sprite cycle.
class LoadingOverlay extends StatefulWidget {
  const LoadingOverlay({super.key, required this.onComplete});

  final VoidCallback onComplete;

  static const double animationFps = 12;
  static const double maxSpriteSize = 400;
  static const double viewportFraction = .4;
  static const spriteImage = AssetImage('assets/anime/lodinganime.png');

  @override
  State<LoadingOverlay> createState() => _LoadingOverlayState();
}

class _LoadingOverlayState extends State<LoadingOverlay> {
  final _focusNode = FocusNode(debugLabel: 'Loading overlay');
  bool _precacheStarted = false;
  bool _spriteReady = false;

  @override
  void initState() {
    super.initState();
    FocusManager.instance.primaryFocus?.unfocus();
    _focusNode.requestFocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_precacheStarted) return;
    _precacheStarted = true;
    SpriteAnimation.precache(LoadingOverlay.spriteImage, context).then((_) {
      if (mounted) setState(() => _spriteReady = true);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Focus(
    focusNode: _focusNode,
    autofocus: true,
    onKeyEvent: (_, _) => KeyEventResult.handled,
    child: Stack(
      fit: StackFit.expand,
      children: [
        const ModalBarrier(dismissible: false, color: Color(0xFFFFFFFF)),
        IgnorePointer(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(
                LoadingOverlay.maxSpriteSize,
                math.min(
                  constraints.maxWidth * LoadingOverlay.viewportFraction,
                  constraints.maxHeight,
                ),
              );
              return Center(
                child: _spriteReady
                    ? SpriteAnimation.grid(
                        image: LoadingOverlay.spriteImage,
                        columns: 3,
                        rows: 3,
                        frameCount: 9,
                        fps: LoadingOverlay.animationFps,
                        loop: false,
                        autoPlay: true,
                        width: size,
                        height: size,
                        onComplete: widget.onComplete,
                      )
                    : const SizedBox.shrink(),
              );
            },
          ),
        ),
      ],
    ),
  );
}
