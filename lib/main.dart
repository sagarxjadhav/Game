import 'package:flame/collisions.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'dart:html' as html; // For web audio fallback
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: GameScreen(),
      theme: ThemeData(scaffoldBackgroundColor: Colors.black),
    );
  }
}

class HighScoreDisplay extends StatefulWidget {
  final int highScore;
  const HighScoreDisplay({required this.highScore, super.key});

  @override
  _HighScoreDisplayState createState() => _HighScoreDisplayState();
}

class _HighScoreDisplayState extends State<HighScoreDisplay> {
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 16.0,
      left: 16.0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.purple, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          'High Score: ${widget.highScore}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 2)],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GravitySwitchGame game;
  bool showSettings = false;
  int highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
    game = GravitySwitchGame(onGameEnd: _handleGameEnd);
  }

  Future<void> _loadHighScore() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('highScore') ?? 0;
    });
  }

  Future<void> _handleGameEnd(int finalScore) async {
    final prefs = await SharedPreferences.getInstance();
    int currentHighScore = prefs.getInt('highScore') ?? 0;
    if (finalScore > currentHighScore) {
      await prefs.setInt('highScore', finalScore);
      setState(() {
        highScore = finalScore;
      });
      game.showConfetti(); // Trigger confetti when new high score is set
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GameWidget(game: game),
          HighScoreDisplay(highScore: highScore),
          if (!game.gameStarted)
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.5),
                ),
                onPressed: () {
                  game.startGame();
                  setState(() {});
                },
                child: const Text(
                  'Start Game',
                  style: TextStyle(
                      fontSize: 28,
                      color: Colors.black,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          Positioned(
            top: 16.0,
            right: 16.0,
            child: IconButton(
              icon: const Icon(Icons.settings, size: 32),
              color: Colors.white,
              onPressed: () {
                game.pauseGame();
                setState(() {
                  showSettings = !showSettings;
                });
              },
            ),
          ),
          if (showSettings)
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(0.5),
                          Colors.purple.withOpacity(0.5)
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSettingsButton(Icons.play_arrow, Colors.green,
                            () {
                          setState(() {
                            showSettings = false;
                          });
                          game.showCountdown(context);
                        }),
                        const SizedBox(width: 20),
                        _buildSettingsButton(Icons.refresh, Colors.orange, () {
                          setState(() {
                            showSettings = false;
                          });
                          game.resetGame();
                        }),
                        const SizedBox(width: 20),
                        _buildSettingsButton(Icons.exit_to_app, Colors.red, () {
                          setState(() {
                            showSettings = false;
                          });
                          game.quitGame();
                          Navigator.pop(context);
                        }),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSettingsButton(
      IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: IconButton(
          icon: Icon(icon, size: 40, color: Colors.white),
          onPressed: onPressed),
    );
  }
}

class GravitySwitchGame extends FlameGame
    with TapDetector, HasCollisionDetection {
  late Spaceship spaceship;
  List<Meteoroid> meteoroids = [];
  List<Collectible> collectibles = [];
  double spawnTimer = 0;
  int score = 0;
  int previousScore = 0;
  int hearts = 3;
  bool gameOver = false;
  bool isPaused = false;
  bool gameStarted = false;
  late TextComponent scoreText;
  late TextComponent heartsText;
  late TextComponent previousScoreText;
  final Function(int) onGameEnd;
  int lastHeartMilestone = 0;
  final AudioPlayer _audioPlayer = AudioPlayer();
  html.AudioElement? _webAudio;

  GravitySwitchGame({required this.onGameEnd});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    spaceship = Spaceship(this, size.x / 2, size.y / 2);
    scoreText = TextComponent(
      text: 'Score: 0',
      position: Vector2(16, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    );
    heartsText = TextComponent(
      text: '♥ 3',
      position: Vector2(16, 90),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    );
    previousScoreText = TextComponent(
      text: 'Previous: 0',
      position: Vector2(16, 120),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    );
    add(scoreText);
    add(heartsText);
    add(previousScoreText);
    for (int i = 0; i < 50; i++) {
      add(Star(Random().nextDouble() * size.x, Random().nextDouble() * size.y));
    }
    await _initBackgroundMusic();
  }

  Future<void> _initBackgroundMusic() async {
    if (kIsWeb) {
      try {
        _webAudio = html.AudioElement('assets/audio/space.mp3')
          ..loop = true
          ..load();
        print("Web audio initialized with HTML Audio");
      } catch (e) {
        print("Error initializing web audio: $e");
      }
    } else {
      try {
        await _audioPlayer.setSource(AssetSource('audio/space.mp3'));
        await _audioPlayer.setReleaseMode(ReleaseMode.loop);
        print("Android audio initialized with audioplayers");
      } catch (e) {
        print("Error initializing Android audio: $e");
      }
    }
  }

  Future<void> _playBackgroundMusic() async {
    if (kIsWeb && _webAudio != null) {
      try {
        _webAudio!.play();
        print("Web background music playing");
      } catch (e) {
        print("Error playing web audio: $e");
      }
    } else {
      try {
        await _audioPlayer.resume();
        print("Android background music playing");
      } catch (e) {
        print("Error playing Android audio: $e");
      }
    }
  }

  Future<void> _pauseBackgroundMusic() async {
    if (kIsWeb && _webAudio != null) {
      try {
        _webAudio!.pause();
        print("Web background music paused");
      } catch (e) {
        print("Error pausing web audio: $e");
      }
    } else {
      try {
        await _audioPlayer.pause();
        print("Android background music paused");
      } catch (e) {
        print("Error pausing Android audio: $e");
      }
    }
  }

  Future<void> _stopBackgroundMusic() async {
    if (kIsWeb && _webAudio != null) {
      try {
        _webAudio!.pause();
        _webAudio!.currentTime = 0;
        print("Web background music stopped");
      } catch (e) {
        print("Error stopping web audio: $e");
      }
    } else {
      try {
        await _audioPlayer.stop();
        print("Android background music stopped");
      } catch (e) {
        print("Error stopping Android audio: $e");
      }
    }
  }

  Future<void> _triggerVibration() async {
    if (!kIsWeb) {
      try {
        if (await Vibration.hasVibrator() ?? false) {
          Vibration.vibrate(duration: 100);
          print("Vibration triggered");
        } else {
          print("Device has no vibrator");
        }
      } catch (e) {
        print("Error triggering vibration: $e");
      }
    }
  }

  void showConfetti() {
    const int confettiCount = 50;
    final random = Random();
    for (int i = 0; i < confettiCount; i++) {
      final x = random.nextDouble() * size.x;
      final y = -random.nextDouble() * size.y / 2; // Start above screen
      final confetti = ConfettiParticle(
        position: Vector2(x, y),
        velocity: Vector2(
          random.nextDouble() * 200 - 100, // Random horizontal velocity
          random.nextDouble() * 300 + 100, // Downward velocity
        ),
        color: Colors.primaries[random.nextInt(Colors.primaries.length)],
      );
      add(confetti);
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameStarted || gameOver || isPaused) return;

    spawnTimer += dt;
    if (spawnTimer >= 1.5) {
      spawnTimer = 0;
      Meteoroid newMeteoroid =
          Meteoroid(this, size.x, Random().nextDouble() * (size.y - 40) + 20);
      meteoroids.add(newMeteoroid);
      add(newMeteoroid);
      if (Random().nextBool()) {
        add(Collectible(size.x, Random().nextDouble() * (size.y - 40) + 20));
      }
    }

    scoreText.text = 'Score: $score';
    heartsText.text = '♥ $hearts';
    previousScoreText.text = 'Previous: $previousScore';

    if (score >= 500 && score ~/ 500 > lastHeartMilestone) {
      hearts += 1;
      lastHeartMilestone = score ~/ 500;
      heartsText.text = '♥ $hearts';
    }

    if (spaceship.y <= 0 || spaceship.y + spaceship.size.y >= size.y) {
      loseHeart();
      _triggerVibration();
    }

    for (var meteoroid in meteoroids.toList()) {
      if (!meteoroid.hasScored &&
          meteoroid.position.x < spaceship.position.x - spaceship.size.x / 2) {
        score += 20;
        meteoroid.hasScored = true;
      }
    }

    meteoroids
        .removeWhere((meteoroid) => meteoroid.position.x < -meteoroid.size.x);
  }

  @override
  void onTap() {
    if (!gameStarted || isPaused) return;
    spaceship.switchGravity();
  }

  void startGame() {
    gameOver = false;
    isPaused = false;
    gameStarted = true;
    children
        .where((child) => child is! Star)
        .forEach((child) => child.removeFromParent());
    meteoroids.clear();
    collectibles.clear();
    spaceship = Spaceship(this, size.x / 2, size.y / 2);
    add(spaceship);
    scoreText = TextComponent(
      text: 'Score: $score',
      position: Vector2(16, 60),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    );
    heartsText = TextComponent(
      text: '♥ $hearts',
      position: Vector2(16, 90),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.red,
          fontSize: 24,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    );
    previousScoreText = TextComponent(
      text: 'Previous: $previousScore',
      position: Vector2(16, 120),
      textRenderer: TextPaint(
        style: const TextStyle(
          color: Colors.yellow,
          fontSize: 20,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 2)],
        ),
      ),
    );
    add(scoreText);
    add(heartsText);
    add(previousScoreText);
    resumeEngine();
    _playBackgroundMusic();
  }

  void resetGame() {
    gameOver = false;
    isPaused = false;
    gameStarted = false;
    previousScore = score;
    score = 0;
    hearts = 3;
    lastHeartMilestone = 0;
    meteoroids.clear();
    collectibles.clear();
    children
        .where((child) => child is! Star)
        .forEach((child) => child.removeFromParent());
    _stopBackgroundMusic();
  }

  void loseHeart() {
    hearts--;
    if (hearts <= 0) {
      endGame();
    } else {
      meteoroids.clear();
      collectibles.clear();
      children
          .where((child) => child is Spaceship || child is PlayButton)
          .forEach((child) => child.removeFromParent());
      spaceship = Spaceship(this, size.x / 2, size.y / 2);
      add(spaceship);
      heartsText.text = '♥ $hearts';
      final playButton = PlayButton(
        position: Vector2(size.x / 2, size.y / 2),
        onPressed: () {
          startGame();
        },
      );
      playButton.priority = 100;
      add(playButton);
      isPaused = true;
    }
  }

  void endGame() {
    if (!gameOver) {
      gameOver = true;
      isPaused = true;
      onGameEnd(score); // This will trigger confetti if new high score
      children
          .where((child) => child is! Star)
          .forEach((child) => child.removeFromParent());
      meteoroids.clear();
      collectibles.clear();
      final playButton = PlayButton(
        position: Vector2(size.x / 2, size.y / 2),
        onPressed: () {
          resetGame();
          startGame();
        },
      );
      playButton.priority = 100;
      add(playButton);
      _stopBackgroundMusic();
    }
  }

  void resumeGame() {
    isPaused = false;
    resumeEngine();
    _playBackgroundMusic();
  }

  void pauseGame() {
    isPaused = true;
    pauseEngine();
    _pauseBackgroundMusic();
  }

  void quitGame() {
    gameOver = false;
    isPaused = false;
    gameStarted = false;
    score = 0;
    previousScore = 0;
    hearts = 3;
    lastHeartMilestone = 0;
    spaceship.position = Vector2(size.x / 2, size.y / 2);
    spaceship.velocity.y = -180;
    spaceship.gravityUp = true;
    meteoroids.clear();
    collectibles.clear();
    children.forEach((child) => child.removeFromParent());
    add(scoreText);
    add(heartsText);
    add(previousScoreText);
    _stopBackgroundMusic();
  }

  void showCountdown(BuildContext context) async {
    int countdown = 3;
    OverlayEntry? overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (context) => Positioned.fill(
        child: Material(
          color: Colors.black.withOpacity(0.8),
          child: Center(
            child: ValueListenableBuilder<int>(
              valueListenable: ValueNotifier(countdown),
              builder: (context, value, child) {
                return Text(
                  '$value',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.bold,
                    shadows: [Shadow(color: Colors.blue, blurRadius: 8)],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
    Overlay.of(context).insert(overlayEntry);
    for (int i = countdown; i > 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      countdown--;
      overlayEntry.markNeedsBuild();
    }
    overlayEntry.remove();
    resumeGame();
  }

  @override
  void onRemove() {
    _audioPlayer.dispose();
    _webAudio?.remove();
    super.onRemove();
  }
}

class Spaceship extends PositionComponent with CollisionCallbacks {
  static final Vector2 spaceshipSize = Vector2(40, 40);
  Vector2 velocity = Vector2.zero();
  bool gravityUp = true;
  final GravitySwitchGame game;
  final Paint paint = Paint()..color = Colors.blueAccent;
  final Paint accentPaint = Paint()..color = Colors.cyanAccent;

  Spaceship(this.game, double x, double y) : super(size: spaceshipSize) {
    position = Vector2(x, y);
    anchor = Anchor.center;
    add(RectangleHitbox(size: spaceshipSize));
  }

  @override
  void update(double dt) {
    if (game.isPaused) return;
    velocity.y += (gravityUp ? -360 : 360) * dt;
    position += velocity * dt;
    position.y = position.y.clamp(0, game.size.y - size.y);
  }

  void switchGravity() {
    gravityUp = !gravityUp;
    velocity.y = gravityUp ? -180 : 180;
  }

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    final bodyWidth = size.x * 0.6;
    final bodyHeight = size.y * 0.8;
    final wingWidth = size.x * 0.3;
    final wingHeight = size.y * 0.4;
    final path = Path();
    if (gravityUp) {
      path.moveTo(center.x, center.y - bodyHeight / 2);
      path.lineTo(center.x - bodyWidth / 2, center.y + bodyHeight / 2);
      path.lineTo(center.x + bodyWidth / 2, center.y + bodyHeight / 2);
      path.close();
      path.moveTo(center.x - bodyWidth / 2, center.y + bodyHeight / 2);
      path.lineTo(center.x - bodyWidth / 2 - wingWidth, center.y + wingHeight);
      path.lineTo(center.x - bodyWidth / 2, center.y);
      path.close();
      path.moveTo(center.x + bodyWidth / 2, center.y + bodyHeight / 2);
      path.lineTo(center.x + bodyWidth / 2 + wingWidth, center.y + wingHeight);
      path.lineTo(center.x + bodyWidth / 2, center.y);
      path.close();
    } else {
      path.moveTo(center.x, center.y + bodyHeight / 2);
      path.lineTo(center.x - bodyWidth / 2, center.y - bodyHeight / 2);
      path.lineTo(center.x + bodyWidth / 2, center.y - bodyHeight / 2);
      path.close();
      path.moveTo(center.x - bodyWidth / 2, center.y - bodyHeight / 2);
      path.lineTo(center.x - bodyWidth / 2 - wingWidth, center.y - wingHeight);
      path.lineTo(center.x - bodyWidth / 2, center.y);
      path.close();
      path.moveTo(center.x + bodyWidth / 2, center.y - bodyHeight / 2);
      path.lineTo(center.x + bodyWidth / 2 + wingWidth, center.y - wingHeight);
      path.lineTo(center.x + bodyWidth / 2, center.y);
      path.close();
    }
    canvas.drawPath(path, paint);
    canvas.drawCircle(Offset(center.x, center.y), size.x * 0.1,
        accentPaint..style = PaintingStyle.fill);
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    if (other is Meteoroid) {
      velocity = Vector2.zero();
      game.loseHeart();
      game._triggerVibration();
    } else if (other is Collectible) {
      other.removeFromParent();
      game.score += 50;
    }
  }
}

class Meteoroid extends PositionComponent with CollisionCallbacks {
  static const double speed = -150;
  static final Vector2 meteoroidSize = Vector2(50, 50);
  final GravitySwitchGame game;
  final Paint paint = Paint()..color = Colors.redAccent;
  final Paint shadowPaint = Paint()..color = Colors.grey.withOpacity(0.5);
  bool hasScored = false;

  Meteoroid(this.game, double x, double y) : super(size: meteoroidSize) {
    position = Vector2(x, y);
    anchor = Anchor.center;
    add(RectangleHitbox(size: meteoroidSize));
  }

  @override
  void update(double dt) {
    if (game.isPaused) return;
    position.x += speed * dt;
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final center = size / 2;
    final path = Path();
    path.moveTo(center.x + size.x * 0.4, center.y);
    path.quadraticBezierTo(center.x + size.x * 0.5, center.y - size.y * 0.2,
        center.x + size.x * 0.3, center.y - size.y * 0.4);
    path.quadraticBezierTo(center.x, center.y - size.y * 0.5,
        center.x - size.x * 0.3, center.y - size.y * 0.4);
    path.quadraticBezierTo(center.x - size.x * 0.5, center.y - size.y * 0.1,
        center.x - size.x * 0.4, center.y + size.y * 0.2);
    path.quadraticBezierTo(center.x - size.x * 0.2, center.y + size.y * 0.5,
        center.x + size.x * 0.1, center.y + size.y * 0.4);
    path.quadraticBezierTo(center.x + size.x * 0.3, center.y + size.y * 0.3,
        center.x + size.x * 0.4, center.y);
    path.close();
    canvas.drawPath(path.shift(const Offset(2, 2)), shadowPaint);
    canvas.drawPath(path, paint);
  }
}

class Collectible extends PositionComponent with CollisionCallbacks {
  final Paint paint = Paint()
    ..shader = const RadialGradient(
            colors: [Colors.yellow, Colors.orange],
            center: Alignment.center,
            radius: 0.5)
        .createShader(Rect.fromCircle(center: Offset.zero, radius: 5));
  static const double speed = -150;

  Collectible(double x, double y) : super(size: Vector2(10, 10)) {
    position = Vector2(x, y);
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    if ((parent as GravitySwitchGame).isPaused) return;
    position.x += speed * dt;
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(size.toOffset() / 2, size.x / 2, paint);
    canvas.drawCircle(
        size.toOffset() / 2,
        size.x / 2 + 1,
        Paint()
          ..color = Colors.yellow.withOpacity(0.4)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
  }
}

class Star extends PositionComponent {
  final Paint paint = Paint()..color = Colors.white.withOpacity(0.5);
  final double radius;

  Star(double x, double y)
      : radius = Random().nextDouble() * 1.5 + 0.5,
        super(size: Vector2.zero()) {
    size = Vector2.all(radius * 2);
    position = Vector2(x, y);
  }

  @override
  void update(double dt) {
    paint.color = Colors.white.withOpacity(
        (sin(DateTime.now().millisecondsSinceEpoch / 1000) + 1) / 4 + 0.25);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(size.toOffset() / 2, radius, paint);
  }
}

class PlayButton extends PositionComponent with TapCallbacks {
  final VoidCallback onPressed;
  final Paint paint = Paint()..color = Colors.white.withOpacity(0.2);

  PlayButton({required Vector2 position, required this.onPressed})
      : super(position: position, size: Vector2(100, 50)) {
    anchor = Anchor.center;
    add(RectangleHitbox(size: size));
    priority = 100;
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, 0, size.x, size.y),
        const Radius.circular(8),
      ),
      paint,
    );

    final textPaint = TextPaint(
      style: const TextStyle(
        color: Colors.white,
        fontSize: 24,
        fontWeight: FontWeight.bold,
        shadows: [Shadow(color: Colors.black, blurRadius: 2)],
      ),
    );
    textPaint.render(canvas, 'Play', size / 2, anchor: Anchor.center);
  }

  @override
  void onTapDown(TapDownEvent event) {
    onPressed();
    removeFromParent();
  }
}

class ConfettiParticle extends PositionComponent {
  final Vector2 velocity;
  final Color color;
  double life = 3.0; // Seconds of life
  static const double gravity = 300;

  ConfettiParticle({
    required Vector2 position,
    required this.velocity,
    required this.color,
  }) : super(position: position, size: Vector2(8, 8));

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += gravity * dt; // Apply gravity
    position += velocity * dt; // Update position
    life -= dt;
    if (life <= 0 || position.y > (parent as GravitySwitchGame).size.y) {
      removeFromParent(); // Remove when life ends or off-screen
    }
  }

  @override
  void render(Canvas canvas) {
    final paint = Paint()..color = color;
    canvas.drawRect(
        Rect.fromLTWH(0, 0, size.x, size.y), paint); // Draw confetti piece
  }
}