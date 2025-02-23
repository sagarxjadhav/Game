// import 'package:flame/collisions.dart';
// import 'package:flame/game.dart';
// import 'package:flame/components.dart';
// import 'package:flame/input.dart';
// import 'package:flutter/material.dart';
// import 'dart:math';
// import 'dart:async';
// import 'dart:ui';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vibration/vibration.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: GameScreen(),
//       theme: ThemeData(scaffoldBackgroundColor: Colors.black),
//     );
//   }
// }

// class HighScoreDisplay extends StatefulWidget {
//   final int highScore;
//   const HighScoreDisplay({required this.highScore, super.key});

//   @override
//   _HighScoreDisplayState createState() => _HighScoreDisplayState();
// }

// class _HighScoreDisplayState extends State<HighScoreDisplay> {
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 16.0,
//       left: 16.0,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Colors.purple, Colors.blue],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.white.withOpacity(0.3),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           'High Score: ${widget.highScore}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             shadows: [Shadow(color: Colors.black, blurRadius: 2)],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class GameScreen extends StatefulWidget {
//   @override
//   _GameScreenState createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   late GravitySwitchGame game;
//   bool showSettings = false;
//   int highScore = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadHighScore();
//     game = GravitySwitchGame(onGameEnd: _handleGameEnd);
//   }

//   Future<void> _loadHighScore() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       highScore = prefs.getInt('highScore') ?? 0;
//     });
//   }

//   Future<void> _handleGameEnd(int finalScore) async {
//     final prefs = await SharedPreferences.getInstance();
//     int currentHighScore = prefs.getInt('highScore') ?? -1;
//     if (currentHighScore == -1 || finalScore > currentHighScore) {
//       await prefs.setInt('highScore', finalScore);
//       setState(() {
//         highScore = finalScore;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GameWidget(game: game),
//           HighScoreDisplay(highScore: highScore),
//           if (!game.gameStarted)
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                   backgroundColor: Colors.greenAccent,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   elevation: 5,
//                   shadowColor: Colors.green.withOpacity(0.5),
//                 ),
//                 onPressed: () {
//                   game.startGame();
//                   setState(() {});
//                 },
//                 child: const Text(
//                   'Start Game',
//                   style: TextStyle(
//                       fontSize: 28,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           Positioned(
//             top: 16.0,
//             right: 16.0,
//             child: IconButton(
//               icon: const Icon(Icons.settings, size: 32),
//               color: Colors.white,
//               onPressed: () {
//                 game.pauseGame();
//                 setState(() {
//                   showSettings = !showSettings;
//                 });
//               },
//             ),
//           ),
//           if (showSettings)
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.blue.withOpacity(0.5),
//                           Colors.purple.withOpacity(0.5)
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Colors.white.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildSettingsButton(Icons.play_arrow, Colors.green,
//                             () {
//                           setState(() {
//                             showSettings = false;
//                           });
//                           game.showCountdown(context);
//                         }),
//                         const SizedBox(width: 20),
//                         _buildSettingsButton(Icons.refresh, Colors.orange, () {
//                           setState(() {
//                             showSettings = false;
//                           });
//                           game.resetGame();
//                         }),
//                         const SizedBox(width: 20),
//                         _buildSettingsButton(Icons.exit_to_app, Colors.red, () {
//                           setState(() {
//                             showSettings = false;
//                           });
//                           game.quitGame();
//                           Navigator.pop(context);
//                         }),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsButton(
//       IconData icon, Color color, VoidCallback onPressed) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.8), color],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//               color: color.withOpacity(0.5),
//               blurRadius: 8,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: IconButton(
//           icon: Icon(icon, size: 40, color: Colors.white),
//           onPressed: onPressed),
//     );
//   }
// }

// class GravitySwitchGame extends FlameGame
//     with TapDetector, HasCollisionDetection {
//   late Ball ball;
//   late Wall topWall, bottomWall;
//   List<Obstacle> obstacles = [];
//   List<Collectible> collectibles = [];
//   double spawnTimer = 0;
//   int score = 0;
//   bool gameOver = false;
//   bool isPaused = false;
//   bool gameStarted = false;
//   late TextComponent scoreText;
//   final Function(int) onGameEnd;

//   GravitySwitchGame({required this.onGameEnd});

//   @override
//   Color backgroundColor() => const Color(0xFF1A1A2E);

//   @override
//   Future<void> onLoad() async {
//     ball = Ball(size.x / 2, size.y - 50);
//     topWall = Wall(0, -20, size.x, 20);
//     bottomWall = Wall(0, size.y, size.x, 20);
//     scoreText = TextComponent(
//       text: 'Score: 0',
//       position: Vector2(16, 60),
//       textRenderer: TextPaint(
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           shadows: [Shadow(color: Colors.black, blurRadius: 2)],
//         ),
//       ),
//     );
//     for (int i = 0; i < 50; i++) {
//       add(Star(Random().nextDouble() * size.x, Random().nextDouble() * size.y));
//     }
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     if (!gameStarted || gameOver || isPaused) return;

//     spawnTimer += dt;
//     if (spawnTimer >= 1.5) {
//       spawnTimer = 0;
//       add(Obstacle(size.x, Random().nextDouble() * (size.y - 40) + 20));
//       if (Random().nextBool()) {
//         add(Collectible(size.x, Random().nextDouble() * (size.y - 40) + 20));
//       }
//     }

//     double wallShift = sin(DateTime.now().millisecondsSinceEpoch / 1000) * 50;
//     topWall.y = -20 + wallShift;
//     bottomWall.y = size.y - wallShift;

//     score += (dt * 10).toInt();
//     scoreText.text = 'Score: $score';

//     if (ball.y <= 0 || ball.y + ball.size.y >= size.y) {
//       endGame();
//     }
//   }

//   @override
//   void onTap() {
//     if (gameOver) {
//       resetGame();
//     } else if (gameStarted && !isPaused) {
//       ball.switchGravity();
//     }
//   }

//   void startGame() {
//     if (!gameStarted) {
//       gameStarted = true;
//       add(ball);
//       add(topWall);
//       add(bottomWall); // Fixed: Changed 'customWall' to 'bottomWall'
//       add(scoreText);
//     }
//     score = 0;
//     isPaused = false;
//   }

//   void resetGame() {
//     gameOver = false;
//     isPaused = false;
//     gameStarted = false;
//     score = 0;
//     obstacles.clear();
//     collectibles.clear();
//     children
//         .where((child) => child is! Star)
//         .forEach((child) => child.removeFromParent());
//     ball = Ball(size.x / 2, size.y - 50);
//     startGame();
//   }

//   void endGame() {
//     if (!gameOver) {
//       gameOver = true;
//       isPaused = true;
//       onGameEnd(score);
//       add(TextComponent(
//         text: 'Game Over! Tap to Restart',
//         position: size / 2,
//         anchor: Anchor.center,
//         textRenderer: TextPaint(
//           style: const TextStyle(
//             color: Colors.redAccent,
//             fontSize: 36,
//             fontWeight: FontWeight.bold,
//             shadows: [Shadow(color: Colors.black, blurRadius: 4)],
//           ),
//         ),
//       ));
//     }
//   }

//   void resumeGame() => isPaused = false;

//   void pauseGame() => isPaused = true;

//   void quitGame() {
//     gameOver = false;
//     isPaused = false;
//     gameStarted = false;
//     score = 0;
//     ball.position = Vector2(size.x / 2, size.y - 50);
//     ball.velocity.y = -180;
//     ball.gravityUp = true;
//     obstacles.clear();
//     collectibles.clear();
//     children.forEach((child) => child.removeFromParent());
//   }

//   void showCountdown(BuildContext context) async {
//     int countdown = 3;
//     OverlayEntry? overlayEntry;

//     overlayEntry = OverlayEntry(
//       builder: (context) => Positioned.fill(
//         child: Material(
//           color: Colors.black.withOpacity(0.8),
//           child: Center(
//             child: ValueListenableBuilder<int>(
//               valueListenable: ValueNotifier(countdown),
//               builder: (context, value, child) {
//                 return Text(
//                   '$value',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 80,
//                     fontWeight: FontWeight.bold,
//                     shadows: [Shadow(color: Colors.blue, blurRadius: 8)],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(overlayEntry);
//     for (int i = countdown; i > 0; i--) {
//       await Future.delayed(const Duration(seconds: 1));
//       countdown--;
//       overlayEntry.markNeedsBuild();
//     }
//     overlayEntry.remove();
//     resumeGame();
//   }
// }

// class Ball extends PositionComponent with CollisionCallbacks {
//   static final Vector2 ballSize = Vector2(20, 20);
//   Vector2 velocity = Vector2(0, -180);
//   bool gravityUp = true;
//   final Paint paint = Paint()
//     ..shader = const LinearGradient(
//       colors: [Colors.cyan, Colors.blue],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ).createShader(Rect.fromCircle(center: Offset.zero, radius: 10));

//   Ball(double x, double y) {
//     position = Vector2(x, y);
//     size = ballSize;
//     add(CircleHitbox());
//   }

//   @override
//   void update(double dt) {
//     if ((parent as GravitySwitchGame).isPaused) return;
//     velocity.y += (gravityUp ? -360 : 360) * dt;
//     position += velocity * dt;
//     position.y =
//         position.y.clamp(0, (parent as GravitySwitchGame).size.y - size.y);
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawCircle(size.toOffset() / 2, size.x / 2, paint);
//     canvas.drawCircle(
//       size.toOffset() / 2,
//       size.x / 2 + 2,
//       Paint()
//         ..color = Colors.cyan.withOpacity(0.3)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
//     );
//   }

//   void switchGravity() {
//     gravityUp = !gravityUp;
//     velocity.y = gravityUp ? -180 : 180;
//   }

//   @override
//   void onCollision(Set<Vector2> points, PositionComponent other) {
//     super.onCollision(points, other);
//     final game = parent as GravitySwitchGame;

//     if (other is Obstacle) {
//       velocity = Vector2.zero();
//       Vibration.vibrate(duration: 200);
//       game.endGame();
//     } else if (other is Collectible) {
//       other.removeFromParent();
//       game.score += 50;
//     }
//   }
// }

// class Wall extends PositionComponent {
//   final double width, height;
//   final Paint paint = Paint()..color = Colors.transparent;

//   Wall(double x, double y, this.width, this.height) {
//     position = Vector2(x, y);
//     size = Vector2(width, height);
//   }

//   @override
//   void render(Canvas canvas) {}
// }

// class Obstacle extends PositionComponent with CollisionCallbacks {
//   final Paint paint = Paint()
//     ..shader = const LinearGradient(
//       colors: [Colors.red, Colors.deepOrange],
//       begin: Alignment.topLeft,
//       end: Alignment.bottomRight,
//     ).createShader(Rect.fromLTWH(0, 0, 20, 20));
//   static const double speed = -150;

//   Obstacle(double x, double y) {
//     position = Vector2(x, y);
//     size = Vector2(20, 20);
//     add(RectangleHitbox());
//   }

//   @override
//   void update(double dt) {
//     if ((parent as GravitySwitchGame).isPaused) return;
//     position.x += speed * dt;
//     if (position.x < -size.x) removeFromParent();
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawRect(size.toRect(), paint);
//   }
// }

// class Collectible extends PositionComponent with CollisionCallbacks {
//   final Paint paint = Paint()
//     ..shader = const RadialGradient(
//       colors: [Colors.yellow, Colors.orange],
//       center: Alignment.center,
//       radius: 0.5,
//     ).createShader(Rect.fromCircle(center: Offset.zero, radius: 5));
//   static const double speed = -150;

//   Collectible(double x, double y) {
//     position = Vector2(x, y);
//     size = Vector2(10, 10);
//     add(CircleHitbox());
//   }

//   @override
//   void update(double dt) {
//     if ((parent as GravitySwitchGame).isPaused) return;
//     position.x += speed * dt;
//     if (position.x < -size.x) removeFromParent();
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawCircle(size.toOffset() / 2, size.x / 2, paint);
//     canvas.drawCircle(
//       size.toOffset() / 2,
//       size.x / 2 + 1,
//       Paint()
//         ..color = Colors.yellow.withOpacity(0.4)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
//     );
//   }
// }

// class Star extends PositionComponent {
//   final Paint paint = Paint()..color = Colors.white.withOpacity(0.5);
//   final double radius = Random().nextDouble() * 1.5 + 0.5;

//   Star(double x, double y) {
//     position = Vector2(x, y);
//     size = Vector2.all(radius * 2);
//   }

//   @override
//   void update(double dt) {
//     paint.color = Colors.white.withOpacity(
//         (sin(DateTime.now().millisecondsSinceEpoch / 1000) + 1) / 4 + 0.25);
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawCircle(size.toOffset() / 2, radius, paint);
//   }
// }

// import 'package:flame/collisions.dart';
// import 'package:flame/game.dart';
// import 'package:flame/components.dart';
// import 'package:flame/input.dart';
// import 'package:flutter/material.dart';
// import 'dart:math';
// import 'dart:async';
// import 'dart:ui';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:vibration/vibration.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: GameScreen(),
//       theme: ThemeData(scaffoldBackgroundColor: Colors.black),
//     );
//   }
// }

// class HighScoreDisplay extends StatefulWidget {
//   final int highScore;
//   const HighScoreDisplay({required this.highScore, super.key});

//   @override
//   _HighScoreDisplayState createState() => _HighScoreDisplayState();
// }

// class _HighScoreDisplayState extends State<HighScoreDisplay> {
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       top: 16.0,
//       left: 16.0,
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
//         decoration: BoxDecoration(
//           gradient: const LinearGradient(
//             colors: [Colors.purple, Colors.blue],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(8),
//           boxShadow: [
//             BoxShadow(
//               color: Colors.white.withOpacity(0.3),
//               blurRadius: 4,
//               offset: const Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Text(
//           'High Score: ${widget.highScore}',
//           style: const TextStyle(
//             color: Colors.white,
//             fontSize: 20,
//             fontWeight: FontWeight.bold,
//             shadows: [Shadow(color: Colors.black, blurRadius: 2)],
//           ),
//         ),
//       ),
//     );
//   }
// }

// class GameScreen extends StatefulWidget {
//   @override
//   _GameScreenState createState() => _GameScreenState();
// }

// class _GameScreenState extends State<GameScreen> {
//   late GravitySwitchGame game;
//   bool showSettings = false;
//   int highScore = 0;

//   @override
//   void initState() {
//     super.initState();
//     _loadHighScore();
//     game = GravitySwitchGame(onGameEnd: _handleGameEnd);
//   }

//   Future<void> _loadHighScore() async {
//     final prefs = await SharedPreferences.getInstance();
//     setState(() {
//       highScore = prefs.getInt('highScore') ?? 0;
//     });
//   }

//   Future<void> _handleGameEnd(int finalScore) async {
//     final prefs = await SharedPreferences.getInstance();
//     int currentHighScore = prefs.getInt('highScore') ?? -1;
//     if (currentHighScore == -1 || finalScore > currentHighScore) {
//       await prefs.setInt('highScore', finalScore);
//       setState(() {
//         highScore = finalScore;
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GameWidget(game: game),
//           HighScoreDisplay(highScore: highScore),
//           if (!game.gameStarted)
//             Center(
//               child: ElevatedButton(
//                 style: ElevatedButton.styleFrom(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                   backgroundColor: Colors.greenAccent,
//                   shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12)),
//                   elevation: 5,
//                   shadowColor: Colors.green.withOpacity(0.5),
//                 ),
//                 onPressed: () {
//                   game.startGame();
//                   setState(() {});
//                 },
//                 child: const Text(
//                   'Start Game',
//                   style: TextStyle(
//                       fontSize: 28,
//                       color: Colors.black,
//                       fontWeight: FontWeight.bold),
//                 ),
//               ),
//             ),
//           Positioned(
//             top: 16.0,
//             right: 16.0,
//             child: IconButton(
//               icon: const Icon(Icons.settings, size: 32),
//               color: Colors.white,
//               onPressed: () {
//                 game.pauseGame();
//                 setState(() {
//                   showSettings = !showSettings;
//                 });
//               },
//             ),
//           ),
//           if (showSettings)
//             Center(
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(20),
//                 child: BackdropFilter(
//                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
//                   child: Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       gradient: LinearGradient(
//                         colors: [
//                           Colors.blue.withOpacity(0.5),
//                           Colors.purple.withOpacity(0.5)
//                         ],
//                         begin: Alignment.topLeft,
//                         end: Alignment.bottomRight,
//                       ),
//                       borderRadius: BorderRadius.circular(20),
//                       border: Border.all(color: Colors.white.withOpacity(0.3)),
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         _buildSettingsButton(Icons.play_arrow, Colors.green,
//                             () {
//                           setState(() {
//                             showSettings = false;
//                           });
//                           game.showCountdown(context);
//                         }),
//                         const SizedBox(width: 20),
//                         _buildSettingsButton(Icons.refresh, Colors.orange, () {
//                           setState(() {
//                             showSettings = false;
//                           });
//                           game.resetGame();
//                         }),
//                         const SizedBox(width: 20),
//                         _buildSettingsButton(Icons.exit_to_app, Colors.red, () {
//                           setState(() {
//                             showSettings = false;
//                           });
//                           game.quitGame();
//                           Navigator.pop(context);
//                         }),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }

//   Widget _buildSettingsButton(
//       IconData icon, Color color, VoidCallback onPressed) {
//     return Container(
//       decoration: BoxDecoration(
//         shape: BoxShape.circle,
//         gradient: LinearGradient(
//           colors: [color.withOpacity(0.8), color],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         boxShadow: [
//           BoxShadow(
//               color: color.withOpacity(0.5),
//               blurRadius: 8,
//               offset: const Offset(0, 2))
//         ],
//       ),
//       child: IconButton(
//           icon: Icon(icon, size: 40, color: Colors.white),
//           onPressed: onPressed),
//     );
//   }
// }

// class GravitySwitchGame extends FlameGame
//     with TapDetector, HasCollisionDetection {
//   late Spaceship spaceship;
//   late Wall topWall, bottomWall;
//   List<Meteoroid> meteoroids = [];
//   List<Collectible> collectibles = [];
//   double spawnTimer = 0;
//   int score = 0;
//   bool gameOver = false;
//   bool isPaused = false;
//   bool gameStarted = false;
//   late TextComponent scoreText;
//   final Function(int) onGameEnd;

//   GravitySwitchGame({required this.onGameEnd});

//   @override
//   Color backgroundColor() => const Color(0xFF1A1A2E);

//   @override
//   Future<void> onLoad() async {
//     spaceship = Spaceship(size.x / 2, size.y - 50);
//     topWall = Wall(0, -20, size.x, 20);
//     bottomWall = Wall(0, size.y, size.x, 20);
//     scoreText = TextComponent(
//       text: 'Score: 0',
//       position: Vector2(16, 60),
//       textRenderer: TextPaint(
//         style: const TextStyle(
//           color: Colors.white,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//           shadows: [Shadow(color: Colors.black, blurRadius: 2)],
//         ),
//       ),
//     );
//     for (int i = 0; i < 50; i++) {
//       add(Star(Random().nextDouble() * size.x, Random().nextDouble() * size.y));
//     }
//     await spaceship.load(); // Load spaceship sprite
//   }

//   @override
//   void update(double dt) {
//     super.update(dt);
//     if (!gameStarted || gameOver || isPaused) return;

//     spawnTimer += dt;
//     if (spawnTimer >= 1.5) {
//       spawnTimer = 0;
//       add(Meteoroid(size.x, Random().nextDouble() * (size.y - 40) + 20));
//       if (Random().nextBool()) {
//         add(Collectible(size.x, Random().nextDouble() * (size.y - 40) + 20));
//       }
//     }

//     double wallShift = sin(DateTime.now().millisecondsSinceEpoch / 1000) * 50;
//     topWall.y = -20 + wallShift;
//     bottomWall.y = size.y - wallShift;

//     score += (dt * 10).toInt();
//     scoreText.text = 'Score: $score';

//     if (spaceship.y <= 0 || spaceship.y + spaceship.size.y >= size.y) {
//       endGame();
//     }
//   }

//   @override
//   void onTap() {
//     if (gameOver) {
//       resetGame();
//     } else if (gameStarted && !isPaused) {
//       spaceship.switchGravity();
//     }
//   }

//   void startGame() {
//     if (!gameStarted) {
//       gameStarted = true;
//       add(spaceship);
//       add(topWall);
//       add(bottomWall);
//       add(scoreText);
//     }
//     score = 0;
//     isPaused = false;
//   }

//   void resetGame() {
//     gameOver = false;
//     isPaused = false;
//     gameStarted = false;
//     score = 0;
//     meteoroids.clear();
//     collectibles.clear();
//     children
//         .where((child) => child is! Star)
//         .forEach((child) => child.removeFromParent());
//     spaceship = Spaceship(size.x / 2, size.y - 50);
//     startGame();
//   }

//   void endGame() {
//     if (!gameOver) {
//       gameOver = true;
//       isPaused = true;
//       onGameEnd(score);
//       add(TextComponent(
//         text: 'Game Over! Tap to Restart',
//         position: size / 2,
//         anchor: Anchor.center,
//         textRenderer: TextPaint(
//           style: const TextStyle(
//             color: Colors.redAccent,
//             fontSize: 36,
//             fontWeight: FontWeight.bold,
//             shadows: [Shadow(color: Colors.black, blurRadius: 4)],
//           ),
//         ),
//       ));
//     }
//   }

//   void resumeGame() => isPaused = false;

//   void pauseGame() => isPaused = true;

//   void quitGame() {
//     gameOver = false;
//     isPaused = false;
//     gameStarted = false;
//     score = 0;
//     spaceship.position = Vector2(size.x / 2, size.y - 50);
//     spaceship.velocity.y = -180;
//     spaceship.gravityUp = true;
//     meteoroids.clear();
//     collectibles.clear();
//     children.forEach((child) => child.removeFromParent());
//   }

//   void showCountdown(BuildContext context) async {
//     int countdown = 3;
//     OverlayEntry? overlayEntry;

//     overlayEntry = OverlayEntry(
//       builder: (context) => Positioned.fill(
//         child: Material(
//           color: Colors.black.withOpacity(0.8),
//           child: Center(
//             child: ValueListenableBuilder<int>(
//               valueListenable: ValueNotifier(countdown),
//               builder: (context, value, child) {
//                 return Text(
//                   '$value',
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 80,
//                     fontWeight: FontWeight.bold,
//                     shadows: [Shadow(color: Colors.blue, blurRadius: 8)],
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ),
//     );

//     Overlay.of(context).insert(overlayEntry);
//     for (int i = countdown; i > 0; i--) {
//       await Future.delayed(const Duration(seconds: 1));
//       countdown--;
//       overlayEntry.markNeedsBuild();
//     }
//     overlayEntry.remove();
//     resumeGame();
//   }
// }

// class Spaceship extends SpriteComponent with CollisionCallbacks {
//   static final Vector2 spaceshipSize = Vector2(40, 40);
//   Vector2 velocity = Vector2(0, -180);
//   bool gravityUp = true;

//   Spaceship(double x, double y) : super(size: spaceshipSize) {
//     position = Vector2(x, y);
//     anchor = Anchor.center;
//   }

//   Future<void> load() async {
//     sprite = await Sprite.load('assets/images/spaceship.jpg');
//     add(RectangleHitbox(size: spaceshipSize));
//   }

//   @override
//   void update(double dt) {
//     if ((parent as GravitySwitchGame).isPaused) return;
//     velocity.y += (gravityUp ? -360 : 360) * dt;
//     position += velocity * dt;
//     position.y =
//         position.y.clamp(0, (parent as GravitySwitchGame).size.y - size.y);
//   }

//   void switchGravity() {
//     gravityUp = !gravityUp;
//     velocity.y = gravityUp ? -180 : 180;
//   }

//   @override
//   void onCollision(Set<Vector2> points, PositionComponent other) {
//     super.onCollision(points, other);
//     final game = parent as GravitySwitchGame;

//     if (other is Meteoroid) {
//       velocity = Vector2.zero();
//       Vibration.vibrate(duration: 200);
//       game.endGame();
//     } else if (other is Collectible) {
//       other.removeFromParent();
//       game.score += 50;
//     }
//   }
// }

// class Wall extends PositionComponent {
//   final double width, height;
//   final Paint paint = Paint()..color = Colors.transparent;

//   Wall(double x, double y, this.width, this.height) {
//     position = Vector2(x, y);
//     size = Vector2(width, height);
//   }

//   @override
//   void render(Canvas canvas) {}
// }

// class Meteoroid extends SpriteComponent with CollisionCallbacks {
//   static const double speed = -150;
//   static final Vector2 meteoroidSize = Vector2(30, 30);

//   Meteoroid(double x, double y) : super(size: meteoroidSize) {
//     position = Vector2(x, y);
//     anchor = Anchor.center;
//     loadSprite();
//   }

//   Future<void> loadSprite() async {
//     sprite = await Sprite.load('assets/images/meteoroid.jpg');
//     add(RectangleHitbox(size: meteoroidSize));
//   }

//   @override
//   void update(double dt) {
//     if ((parent as GravitySwitchGame).isPaused) return;
//     position.x += speed * dt;
//     if (position.x < -size.x) removeFromParent();
//   }
// }

// class Collectible extends PositionComponent with CollisionCallbacks {
//   final Paint paint = Paint()
//     ..shader = const RadialGradient(
//       colors: [Colors.yellow, Colors.orange],
//       center: Alignment.center,
//       radius: 0.5,
//     ).createShader(Rect.fromCircle(center: Offset.zero, radius: 5));
//   static const double speed = -150;

//   Collectible(double x, double y) {
//     position = Vector2(x, y);
//     size = Vector2(10, 10);
//     add(CircleHitbox());
//   }

//   @override
//   void update(double dt) {
//     if ((parent as GravitySwitchGame).isPaused) return;
//     position.x += speed * dt;
//     if (position.x < -size.x) removeFromParent();
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawCircle(size.toOffset() / 2, size.x / 2, paint);
//     canvas.drawCircle(
//       size.toOffset() / 2,
//       size.x / 2 + 1,
//       Paint()
//         ..color = Colors.yellow.withOpacity(0.4)
//         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
//     );
//   }
// }

// class Star extends PositionComponent {
//   final Paint paint = Paint()..color = Colors.white.withOpacity(0.5);
//   final double radius = Random().nextDouble() * 1.5 + 0.5;

//   Star(double x, double y) {
//     position = Vector2(x, y);
//     size = Vector2.all(radius * 2);
//   }

//   @override
//   void update(double dt) {
//     paint.color = Colors.white.withOpacity(
//         (sin(DateTime.now().millisecondsSinceEpoch / 1000) + 1) / 4 + 0.25);
//   }

//   @override
//   void render(Canvas canvas) {
//     canvas.drawCircle(size.toOffset() / 2, radius, paint);
//   }
// }

// // import 'package:flame/collisions.dart';
// // import 'package:flame/game.dart';
// // import 'package:flame/components.dart';
// // import 'package:flame/input.dart';
// // import 'package:flutter/material.dart';
// // import 'dart:math';
// // import 'dart:async';
// // import 'dart:ui';
// // import 'package:shared_preferences/shared_preferences.dart';
// // import 'package:vibration/vibration.dart';

// // void main() {
// //   runApp(const MyApp());
// // }

// // class MyApp extends StatelessWidget {
// //   const MyApp({super.key});

// //   @override
// //   Widget build(BuildContext context) {
// //     return MaterialApp(
// //       debugShowCheckedModeBanner: false,
// //       home: GameScreen(),
// //       theme: ThemeData(scaffoldBackgroundColor: Colors.black),
// //     );
// //   }
// // }

// // class HighScoreDisplay extends StatefulWidget {
// //   final int highScore;
// //   const HighScoreDisplay({required this.highScore, super.key});

// //   @override
// //   _HighScoreDisplayState createState() => _HighScoreDisplayState();
// // }

// // class _HighScoreDisplayState extends State<HighScoreDisplay> {
// //   @override
// //   Widget build(BuildContext context) {
// //     return Positioned(
// //       top: 16.0,
// //       left: 16.0,
// //       child: Container(
// //         padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
// //         decoration: BoxDecoration(
// //           gradient: const LinearGradient(
// //             colors: [Colors.purple, Colors.blue],
// //             begin: Alignment.topLeft,
// //             end: Alignment.bottomRight,
// //           ),
// //           borderRadius: BorderRadius.circular(8),
// //           boxShadow: [
// //             BoxShadow(
// //               color: Colors.white.withOpacity(0.3),
// //               blurRadius: 4,
// //               offset: const Offset(0, 2),
// //             ),
// //           ],
// //         ),
// //         child: Text(
// //           'High Score: ${widget.highScore}',
// //           style: const TextStyle(
// //             color: Colors.white,
// //             fontSize: 20,
// //             fontWeight: FontWeight.bold,
// //             shadows: [Shadow(color: Colors.black, blurRadius: 2)],
// //           ),
// //         ),
// //       ),
// //     );
// //   }
// // }

// // class GameScreen extends StatefulWidget {
// //   @override
// //   _GameScreenState createState() => _GameScreenState();
// // }

// // class _GameScreenState extends State<GameScreen> {
// //   late GravitySwitchGame game;
// //   bool showSettings = false;
// //   int highScore = 0;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadHighScore();
// //     game = GravitySwitchGame(onGameEnd: _handleGameEnd);
// //   }

// //   Future<void> _loadHighScore() async {
// //     final prefs = await SharedPreferences.getInstance();
// //     setState(() {
// //       highScore = prefs.getInt('highScore') ?? 0;
// //     });
// //   }

// //   Future<void> _handleGameEnd(int finalScore) async {
// //     final prefs = await SharedPreferences.getInstance();
// //     int currentHighScore = prefs.getInt('highScore') ?? -1;
// //     if (currentHighScore == -1 || finalScore > currentHighScore) {
// //       await prefs.setInt('highScore', finalScore);
// //       setState(() {
// //         highScore = finalScore;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       body: Stack(
// //         children: [
// //           GameWidget(game: game),
// //           HighScoreDisplay(highScore: highScore),
// //           if (!game.gameStarted)
// //             Center(
// //               child: ElevatedButton(
// //                 style: ElevatedButton.styleFrom(
// //                   padding:
// //                       const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
// //                   backgroundColor: Colors.greenAccent,
// //                   shape: RoundedRectangleBorder(
// //                       borderRadius: BorderRadius.circular(12)),
// //                   elevation: 5,
// //                   shadowColor: Colors.green.withOpacity(0.5),
// //                 ),
// //                 onPressed: () {
// //                   game.startGame();
// //                   setState(() {});
// //                 },
// //                 child: const Text(
// //                   'Start Game',
// //                   style: TextStyle(
// //                       fontSize: 28,
// //                       color: Colors.black,
// //                       fontWeight: FontWeight.bold),
// //                 ),
// //               ),
// //             ),
// //           Positioned(
// //             top: 16.0,
// //             right: 16.0,
// //             child: IconButton(
// //               icon: const Icon(Icons.settings, size: 32),
// //               color: Colors.white,
// //               onPressed: () {
// //                 game.pauseGame();
// //                 setState(() {
// //                   showSettings = !showSettings;
// //                 });
// //               },
// //             ),
// //           ),
// //           if (showSettings)
// //             Center(
// //               child: ClipRRect(
// //                 borderRadius: BorderRadius.circular(20),
// //                 child: BackdropFilter(
// //                   filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
// //                   child: Container(
// //                     padding: const EdgeInsets.all(20),
// //                     decoration: BoxDecoration(
// //                       gradient: LinearGradient(
// //                         colors: [
// //                           Colors.blue.withOpacity(0.5),
// //                           Colors.purple.withOpacity(0.5)
// //                         ],
// //                         begin: Alignment.topLeft,
// //                         end: Alignment.bottomRight,
// //                       ),
// //                       borderRadius: BorderRadius.circular(20),
// //                       border: Border.all(color: Colors.white.withOpacity(0.3)),
// //                     ),
// //                     child: Row(
// //                       mainAxisSize: MainAxisSize.min,
// //                       children: [
// //                         _buildSettingsButton(Icons.play_arrow, Colors.green,
// //                             () {
// //                           setState(() {
// //                             showSettings = false;
// //                           });
// //                           game.showCountdown(context);
// //                         }),
// //                         const SizedBox(width: 20),
// //                         _buildSettingsButton(Icons.refresh, Colors.orange, () {
// //                           setState(() {
// //                             showSettings = false;
// //                           });
// //                           game.resetGame();
// //                         }),
// //                         const SizedBox(width: 20),
// //                         _buildSettingsButton(Icons.exit_to_app, Colors.red, () {
// //                           setState(() {
// //                             showSettings = false;
// //                           });
// //                           game.quitGame();
// //                           Navigator.pop(context);
// //                         }),
// //                       ],
// //                     ),
// //                   ),
// //                 ),
// //               ),
// //             ),
// //         ],
// //       ),
// //     );
// //   }

// //   Widget _buildSettingsButton(
// //       IconData icon, Color color, VoidCallback onPressed) {
// //     return Container(
// //       decoration: BoxDecoration(
// //         shape: BoxShape.circle,
// //         gradient: LinearGradient(
// //           colors: [color.withOpacity(0.8), color],
// //           begin: Alignment.topLeft,
// //           end: Alignment.bottomRight,
// //         ),
// //         boxShadow: [
// //           BoxShadow(
// //               color: color.withOpacity(0.5),
// //               blurRadius: 8,
// //               offset: const Offset(0, 2))
// //         ],
// //       ),
// //       child: IconButton(
// //           icon: Icon(icon, size: 40, color: Colors.white),
// //           onPressed: onPressed),
// //     );
// //   }
// // }

// // class GravitySwitchGame extends FlameGame
// //     with TapDetector, HasCollisionDetection {
// //   late Spaceship spaceship;
// //   late Wall topWall, bottomWall;
// //   List<Meteoroid> meteoroids = [];
// //   List<Collectible> collectibles = [];
// //   double spawnTimer = 0;
// //   int score = 0;
// //   bool gameOver = false;
// //   bool isPaused = false;
// //   bool gameStarted = false;
// //   late TextComponent scoreText;
// //   final Function(int) onGameEnd;

// //   GravitySwitchGame({required this.onGameEnd});

// //   @override
// //   Color backgroundColor() => const Color(0xFF1A1A2E);

// //   @override
// //   Future<void> onLoad() async {
// //     // Preload the images synchronously for later use
// //     await images.load('images/spaceship.png');
// //     await images.load('images/meteoroid.png');

// //     spaceship = Spaceship(this, size.x / 2, size.y - 50);
// //     topWall = Wall(0, -20, size.x, 20);
// //     bottomWall = Wall(0, size.y, size.x, 20);
// //     scoreText = TextComponent(
// //       text: 'Score: 0',
// //       position: Vector2(16, 60),
// //       textRenderer: TextPaint(
// //         style: const TextStyle(
// //           color: Colors.white,
// //           fontSize: 24,
// //           fontWeight: FontWeight.bold,
// //           shadows: [Shadow(color: Colors.black, blurRadius: 2)],
// //         ),
// //       ),
// //     );
// //     for (int i = 0; i < 50; i++) {
// //       add(Star(Random().nextDouble() * size.x, Random().nextDouble() * size.y));
// //     }
// //     // No need to load sprites here since they’re preloaded
// //   }

// //   @override
// //   void update(double dt) {
// //     super.update(dt);
// //     if (!gameStarted || gameOver || isPaused) return;

// //     spawnTimer += dt;
// //     if (spawnTimer >= 1.5) {
// //       spawnTimer = 0;
// //       add(Meteoroid(this, size.x, Random().nextDouble() * (size.y - 40) + 20));
// //       if (Random().nextBool()) {
// //         add(Collectible(size.x, Random().nextDouble() * (size.y - 40) + 20));
// //       }
// //     }

// //     double wallShift = sin(DateTime.now().millisecondsSinceEpoch / 1000) * 50;
// //     topWall.y = -20 + wallShift;
// //     bottomWall.y = size.y - wallShift;

// //     score += (dt * 10).toInt();
// //     scoreText.text = 'Score: $score';

// //     if (spaceship.y <= 0 || spaceship.y + spaceship.size.y >= size.y) {
// //       endGame();
// //     }
// //   }

// //   @override
// //   void onTap() {
// //     if (gameOver) {
// //       resetGame();
// //     } else if (gameStarted && !isPaused) {
// //       spaceship.switchGravity();
// //     }
// //   }

// //   void startGame() {
// //     if (!gameStarted) {
// //       gameStarted = true;
// //       add(spaceship);
// //       add(topWall);
// //       add(bottomWall);
// //       add(scoreText);
// //     }
// //     score = 0;
// //     isPaused = false;
// //   }

// //   void resetGame() {
// //     gameOver = false;
// //     isPaused = false;
// //     gameStarted = false;
// //     score = 0;
// //     meteoroids.clear();
// //     collectibles.clear();
// //     children
// //         .where((child) => child is! Star)
// //         .forEach((child) => child.removeFromParent());
// //     spaceship = Spaceship(this, size.x / 2, size.y - 50);
// //     startGame();
// //   }

// //   void endGame() {
// //     if (!gameOver) {
// //       gameOver = true;
// //       isPaused = true;
// //       onGameEnd(score);
// //       add(TextComponent(
// //         text: 'Game Over! Tap to Restart',
// //         position: size / 2,
// //         anchor: Anchor.center,
// //         textRenderer: TextPaint(
// //           style: const TextStyle(
// //             color: Colors.redAccent,
// //             fontSize: 36,
// //             fontWeight: FontWeight.bold,
// //             shadows: [Shadow(color: Colors.black, blurRadius: 4)],
// //           ),
// //         ),
// //       ));
// //     }
// //   }

// //   void resumeGame() => isPaused = false;

// //   void pauseGame() => isPaused = true;

// //   void quitGame() {
// //     gameOver = false;
// //     isPaused = false;
// //     gameStarted = false;
// //     score = 0;
// //     spaceship.position = Vector2(size.x / 2, size.y - 50);
// //     spaceship.velocity.y = -180;
// //     spaceship.gravityUp = true;
// //     meteoroids.clear();
// //     collectibles.clear();
// //     children.forEach((child) => child.removeFromParent());
// //   }

// //   void showCountdown(BuildContext context) async {
// //     int countdown = 3;
// //     OverlayEntry? overlayEntry;

// //     overlayEntry = OverlayEntry(
// //       builder: (context) => Positioned.fill(
// //         child: Material(
// //           color: Colors.black.withOpacity(0.8),
// //           child: Center(
// //             child: ValueListenableBuilder<int>(
// //               valueListenable: ValueNotifier(countdown),
// //               builder: (context, value, child) {
// //                 return Text(
// //                   '$value',
// //                   style: const TextStyle(
// //                     color: Colors.white,
// //                     fontSize: 80,
// //                     fontWeight: FontWeight.bold,
// //                     shadows: [Shadow(color: Colors.blue, blurRadius: 8)],
// //                   ),
// //                 );
// //               },
// //             ),
// //           ),
// //         ),
// //       ),
// //     );

// //     Overlay.of(context).insert(overlayEntry);
// //     for (int i = countdown; i > 0; i--) {
// //       await Future.delayed(const Duration(seconds: 1));
// //       countdown--;
// //       overlayEntry.markNeedsBuild();
// //     }
// //     overlayEntry.remove();
// //     resumeGame();
// //   }
// // }

// // class Spaceship extends SpriteComponent with CollisionCallbacks {
// //   static final Vector2 spaceshipSize = Vector2(40, 40);
// //   Vector2 velocity = Vector2(0, -180);
// //   bool gravityUp = true;
// //   final GravitySwitchGame game; // Reference to the game instance

// //   Spaceship(this.game, double x, double y) : super(size: spaceshipSize) {
// //     position = Vector2(x, y);
// //     anchor = Anchor.center;
// //     // Use preloaded image from the game's image cache
// //     sprite = Sprite(game.images.fromCache('images/spaceship.png'));
// //     add(RectangleHitbox(size: spaceshipSize));
// //   }

// //   @override
// //   void update(double dt) {
// //     if (game.isPaused) return; // Use the game instance for isPaused
// //     velocity.y += (gravityUp ? -360 : 360) * dt;
// //     position += velocity * dt;
// //     position.y = position.y.clamp(0, game.size.y - size.y);
// //   }

// //   void switchGravity() {
// //     gravityUp = !gravityUp;
// //     velocity.y = gravityUp ? -180 : 180;
// //   }

// //   @override
// //   void onCollision(Set<Vector2> points, PositionComponent other) {
// //     super.onCollision(points, other);

// //     if (other is Meteoroid) {
// //       velocity = Vector2.zero();
// //       Vibration.vibrate(duration: 200);
// //       game.endGame();
// //     } else if (other is Collectible) {
// //       other.removeFromParent();
// //       game.score += 50;
// //     }
// //   }
// // }

// // class Wall extends PositionComponent {
// //   final double width, height;
// //   final Paint paint = Paint()..color = Colors.transparent;

// //   Wall(double x, double y, this.width, this.height) {
// //     position = Vector2(x, y);
// //     size = Vector2(width, height);
// //   }

// //   @override
// //   void render(Canvas canvas) {}
// // }

// // class Meteoroid extends SpriteComponent with CollisionCallbacks {
// //   static const double speed = -150;
// //   static final Vector2 meteoroidSize = Vector2(30, 30);
// //   final GravitySwitchGame game; // Reference to the game instance

// //   Meteoroid(this.game, double x, double y) : super(size: meteoroidSize) {
// //     position = Vector2(x, y);
// //     anchor = Anchor.center;
// //     // Use preloaded image from the game's image cache
// //     sprite = Sprite(game.images.fromCache('images/meteoroid.png'));
// //     add(RectangleHitbox(size: meteoroidSize));
// //   }

// //   @override
// //   void update(double dt) {
// //     if (game.isPaused) return; // Use the game instance for isPaused
// //     position.x += speed * dt;
// //     if (position.x < -size.x) removeFromParent();
// //   }
// // }

// // class Collectible extends PositionComponent with CollisionCallbacks {
// //   final Paint paint = Paint()
// //     ..shader = const RadialGradient(
// //       colors: [Colors.yellow, Colors.orange],
// //       center: Alignment.center,
// //       radius: 0.5,
// //     ).createShader(Rect.fromCircle(center: Offset.zero, radius: 5));
// //   static const double speed = -150;

// //   Collectible(double x, double y) {
// //     position = Vector2(x, y);
// //     size = Vector2(10, 10);
// //     add(CircleHitbox());
// //   }

// //   @override
// //   void update(double dt) {
// //     if ((parent as GravitySwitchGame).isPaused) return;
// //     position.x += speed * dt;
// //     if (position.x < -size.x) removeFromParent();
// //   }

// //   @override
// //   void render(Canvas canvas) {
// //     canvas.drawCircle(size.toOffset() / 2, size.x / 2, paint);
// //     canvas.drawCircle(
// //       size.toOffset() / 2,
// //       size.x / 2 + 1,
// //       Paint()
// //         ..color = Colors.yellow.withOpacity(0.4)
// //         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
// //     );
// //   }
// // }

// // class Star extends PositionComponent {
// //   final Paint paint = Paint()..color = Colors.white.withOpacity(0.5);
// //   final double radius = Random().nextDouble() * 1.5 + 0.5;

// //   Star(double x, double y) {
// //     position = Vector2(x, y);
// //     size = Vector2.all(radius * 2);
// //   }

// //   @override
// //   void update(double dt) {
// //     paint.color = Colors.white.withOpacity(
// //         (sin(DateTime.now().millisecondsSinceEpoch / 1000) + 1) / 4 + 0.25);
// //   }

// //   @override
// //   void render(Canvas canvas) {
// //     canvas.drawCircle(size.toOffset() / 2, radius, paint);
// //   }
// // }


import 'package:flame/collisions.dart';
import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vibration/vibration.dart';

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
    int currentHighScore = prefs.getInt('highScore') ?? -1;
    if (currentHighScore == -1 || finalScore > currentHighScore) {
      await prefs.setInt('highScore', finalScore);
      setState(() {
        highScore = finalScore;
      });
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
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  backgroundColor: Colors.greenAccent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                  shadowColor: Colors.green.withOpacity(0.5),
                ),
                onPressed: () {
                  game.startGame();
                  setState(() {});
                },
                child: const Text(
                  'Start Game',
                  style: TextStyle(fontSize: 28, color: Colors.black, fontWeight: FontWeight.bold),
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
                        colors: [Colors.blue.withOpacity(0.5), Colors.purple.withOpacity(0.5)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.3)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildSettingsButton(Icons.play_arrow, Colors.green, () {
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

  Widget _buildSettingsButton(IconData icon, Color color, VoidCallback onPressed) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [color.withOpacity(0.8), color],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: IconButton(icon: Icon(icon, size: 40, color: Colors.white), onPressed: onPressed),
    );
  }
}

class GravitySwitchGame extends FlameGame with TapDetector, HasCollisionDetection {
  late Ball ball;
  late Wall topWall, bottomWall;
  List<Obstacle> obstacles = [];
  List<Collectible> collectibles = [];
  double spawnTimer = 0;
  int score = 0;
  bool gameOver = false;
  bool isPaused = false;
  bool gameStarted = false;
  late TextComponent scoreText;
  final Function(int) onGameEnd;

  GravitySwitchGame({required this.onGameEnd});

  @override
  Color backgroundColor() => const Color(0xFF1A1A2E);

  @override
  Future<void> onLoad() async {
    ball = Ball(size.x / 2, size.y - 50);
    topWall = Wall(0, -20, size.x, 20);
    bottomWall = Wall(0, size.y, size.x, 20);
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
    for (int i = 0; i < 50; i++) {
      add(Star(Random().nextDouble() * size.x, Random().nextDouble() * size.y));
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!gameStarted || gameOver || isPaused) return;

    spawnTimer += dt;
    if (spawnTimer >= 1.5) {
      spawnTimer = 0;
      add(Obstacle(size.x, Random().nextDouble() * (size.y - 40) + 20));
      if (Random().nextBool()) {
        add(Collectible(size.x, Random().nextDouble() * (size.y - 40) + 20));
      }
    }

    double wallShift = sin(DateTime.now().millisecondsSinceEpoch / 1000) * 50;
    topWall.y = -20 + wallShift;
    bottomWall.y = size.y - wallShift;

    score += (dt * 10).toInt();
    scoreText.text = 'Score: $score';

    if (ball.y <= 0 || ball.y + ball.size.y >= size.y) {
      endGame();
    }
  }

  @override
  void onTap() {
    if (gameOver) {
      resetGame();
    } else if (gameStarted && !isPaused) {
      ball.switchGravity();
    }
  }

  void startGame() {
    if (!gameStarted) {
      gameStarted = true;
      add(ball);
      add(topWall);
      add(bottomWall); // Fixed: Changed 'customWall' to 'bottomWall'
      add(scoreText);
    }
    score = 0;
    isPaused = false;
  }

  void resetGame() {
    gameOver = false;
    isPaused = false;
    gameStarted = false;
    score = 0;
    obstacles.clear();
    collectibles.clear();
    children.where((child) => child is! Star).forEach((child) => child.removeFromParent());
    ball = Ball(size.x / 2, size.y - 50);
    startGame();
  }

  void endGame() {
    if (!gameOver) {
      gameOver = true;
      isPaused = true;
      onGameEnd(score);
      add(TextComponent(
        text: 'Game Over! Tap to Restart',
        position: size / 2,
        anchor: Anchor.center,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Colors.redAccent,
            fontSize: 36,
            fontWeight: FontWeight.bold,
            shadows: [Shadow(color: Colors.black, blurRadius: 4)],
          ),
        ),
      ));
    }
  }

  void resumeGame() => isPaused = false;

  void pauseGame() => isPaused = true;

  void quitGame() {
    gameOver = false;
    isPaused = false;
    gameStarted = false;
    score = 0;
    ball.position = Vector2(size.x / 2, size.y - 50);
    ball.velocity.y = -180;
    ball.gravityUp = true;
    obstacles.clear();
    collectibles.clear();
    children.forEach((child) => child.removeFromParent());
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
}

class Ball extends PositionComponent with CollisionCallbacks {
  static final Vector2 ballSize = Vector2(20, 20);
  Vector2 velocity = Vector2(0, -180);
  bool gravityUp = true;
  final Paint paint = Paint()
    ..shader = const LinearGradient(
      colors: [Colors.cyan, Colors.blue],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 10));

  Ball(double x, double y) {
    position = Vector2(x, y);
    size = ballSize;
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    if ((parent as GravitySwitchGame).isPaused) return;
    velocity.y += (gravityUp ? -360 : 360) * dt;
    position += velocity * dt;
    position.y = position.y.clamp(0, (parent as GravitySwitchGame).size.y - size.y);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(size.toOffset() / 2, size.x / 2, paint);
    canvas.drawCircle(
      size.toOffset() / 2,
      size.x / 2 + 2,
      Paint()..color = Colors.cyan.withOpacity(0.3)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void switchGravity() {
    gravityUp = !gravityUp;
    velocity.y = gravityUp ? -180 : 180;
  }

  @override
  void onCollision(Set<Vector2> points, PositionComponent other) {
    super.onCollision(points, other);
    final game = parent as GravitySwitchGame;

    if (other is Obstacle) {
      velocity = Vector2.zero();
      Vibration.vibrate(duration: 200);
      game.endGame();
    } else if (other is Collectible) {
      other.removeFromParent();
      game.score += 50;
    }
  }
}

class Wall extends PositionComponent {
  final double width, height;
  final Paint paint = Paint()..color = Colors.transparent;

  Wall(double x, double y, this.width, this.height) {
    position = Vector2(x, y);
    size = Vector2(width, height);
  }

  @override
  void render(Canvas canvas) {}
}

class Obstacle extends PositionComponent with CollisionCallbacks {
  final Paint paint = Paint()
    ..shader = const LinearGradient(
      colors: [Colors.red, Colors.deepOrange],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromLTWH(0, 0, 20, 20));
  static const double speed = -150;

  Obstacle(double x, double y) {
    position = Vector2(x, y);
    size = Vector2(20, 20);
    add(RectangleHitbox());
  }

  @override
  void update(double dt) {
    if ((parent as GravitySwitchGame).isPaused) return;
    position.x += speed * dt;
    if (position.x < -size.x) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(size.toRect(), paint);
  }
}

class Collectible extends PositionComponent with CollisionCallbacks {
  final Paint paint = Paint()
    ..shader = const RadialGradient(
      colors: [Colors.yellow, Colors.orange],
      center: Alignment.center,
      radius: 0.5,
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 5));
  static const double speed = -150;

  Collectible(double x, double y) {
    position = Vector2(x, y);
    size = Vector2(10, 10);
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
      Paint()..color = Colors.yellow.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }
}

class Star extends PositionComponent {
  final Paint paint = Paint()..color = Colors.white.withOpacity(0.5);
  final double radius = Random().nextDouble() * 1.5 + 0.5;

  Star(double x, double y) {
    position = Vector2(x, y);
    size = Vector2.all(radius * 2);
  }

  @override
  void update(double dt) {
    paint.color = Colors.white.withOpacity((sin(DateTime.now().millisecondsSinceEpoch / 1000) + 1) / 4 + 0.25);
  }

  @override
  void render(Canvas canvas) {
    canvas.drawCircle(size.toOffset() / 2, radius, paint);
  }
}