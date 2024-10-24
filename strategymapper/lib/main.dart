import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: MapScreen(),
      ),
    );
  }
}

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Map View fills the entire screen
        const Positioned.fill(
          child: MapView(),
        ),

        // Control Panel overlaps on the left side
        Positioned(
          left: 0,
          top: 0,
          bottom: 0,
          child: ControlPanel(),
        ),
      ],
    );
  }
}

class MapView extends StatefulWidget {
  const MapView({super.key});

  @override
  MapViewState createState() => MapViewState();
}

class MapViewState extends State<MapView> {
  final List<HeroData> _heroesOnMap = [];
  final GlobalKey _mapKey = GlobalKey();

  // Convert global position to local map coordinates
  Offset _getLocalPosition(Offset globalPosition) {
    final RenderBox renderBox =
        _mapKey.currentContext!.findRenderObject() as RenderBox;
    return renderBox.globalToLocal(globalPosition);
  }

  void _removeHero(HeroData hero) {
    setState(() {
      _heroesOnMap.remove(hero);
    });
  }

  @override
  Widget build(BuildContext context) {
    return InteractiveViewer(
      constrained: true,
      boundaryMargin: EdgeInsets.zero,
      minScale: 1.0,
      maxScale: 5.0,
      clipBehavior: Clip.none,
      child: DragTarget<HeroData>(
        onWillAcceptWithDetails: (details) => true,
        onAcceptWithDetails: (details) {
          setState(() {
            Offset localPosition = _getLocalPosition(details.offset);
            _heroesOnMap.add(details.data.copyWith(position: localPosition));
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Stack(
            key: _mapKey,
            children: [
              Center(
                child: Image.asset(
                  'assets/BlizzardWorld.jpg',
                  fit: BoxFit.contain,
                ),
              ),
              // Render placed heroes as smaller icons (1/4 size)
              ..._heroesOnMap.map((hero) => Positioned(
                    left: hero.position.dx,
                    top: hero.position.dy,
                    child: Draggable<HeroData>(
                      data: hero,
                      feedback: Image.asset(
                        hero.imagePath,
                        width: 30, // Full size during drag
                        height: 30,
                      ),
                      childWhenDragging: const SizedBox.shrink(),
                      onDragCompleted: () => _removeHero(hero),
                      child: Image.asset(
                        hero.imagePath,
                        width: 15, // 1/4 size when placed
                        height: 15,
                      ),
                    ),
                  )),
            ],
          );
        },
      ),
    );
  }
}

class ControlPanel extends StatefulWidget {
  const ControlPanel({super.key});

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> {
  String? _selectedRole;

  // Example hero data categorized by role
  final Map<String, List<HeroData>> heroesByRole = {
    'Tank': [
      HeroData('assets/heros/DVa.webp'),
      HeroData('assets/heros/Doomfist.webp'),
      HeroData('assets/heros/JunkerQueen.webp'),
      HeroData('assets/heros/Mauga.webp'),
      HeroData('assets/heros/Orisa.webp'),
      HeroData('assets/heros/Ramattra.webp'),
      HeroData('assets/heros/Reinhardt.webp'),
      HeroData('assets/heros/Roadhog.webp'),
      HeroData('assets/heros/Winston.webp'),
      HeroData('assets/heros/WreckingBall.webp'),
      HeroData('assets/heros/Zarya.webp'),

    ],
    'Damage': [
      HeroData('assets/heros/Ashe.webp'),
      HeroData('assets/heros/Bastion.webp'),
      HeroData('assets/heros/Cassidy.webp'),
      HeroData('assets/heros/Echo.webp'),
      HeroData('assets/heros/Genji.webp'),
      HeroData('assets/heros/Hanzo.webp'),
      HeroData('assets/heros/Junkrat.webp'),
      HeroData('assets/heros/Mei.webp'),
      HeroData('assets/heros/Pharah.webp'),
      HeroData('assets/heros/Reaper.webp'),
      HeroData('assets/heros/Sojourn.webp'),
      HeroData('assets/heros/Soldier76.webp'),
      HeroData('assets/heros/Sombra.webp'),
      HeroData('assets/heros/Symmetra.webp'),
      HeroData('assets/heros/Torbjorn.webp'),
      HeroData('assets/heros/Tracer.webp'),
      HeroData('assets/heros/Venture.webp'),
      HeroData('assets/heros/Widowmaker.webp'),
    ],
    'Support': [
      HeroData('assets/heros/Ana.webp'),
      HeroData('assets/heros/Baptiste.webp'),
      HeroData('assets/heros/Brigitte.webp'),
      HeroData('assets/heros/Illari.webp'),
      HeroData('assets/heros/Juno.webp'),
      HeroData('assets/heros/Kiriko.webp'),
      HeroData('assets/heros/Lifeweaver.webp'),
      HeroData('assets/heros/Moira.webp'),
      HeroData('assets/heros/Zenyatta.webp'),
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 80,
      color: Colors.blue.withOpacity(0.8),
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Roles',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // Role Buttons
          ...heroesByRole.keys.map((role) {
            return IconButton(
              icon: Image.asset(
                'assets/${role.toLowerCase()}.png', // Role icon
                width: 30,
                height: 30,
              ),
              onPressed: () {
                setState(() {
                  _selectedRole = _selectedRole == role ? null : role;
                });
              },
            );
          }),

          const SizedBox(height: 8),

          // Hero Icons for the Selected Role
          if (_selectedRole != null)
            Expanded(
              child: ListView(
                children: heroesByRole[_selectedRole!]!
                    .map((hero) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4.0),
                          child: Draggable<HeroData>(
                            data: hero,
                            feedback: Image.asset(
                              hero.imagePath,
                              width: 30, // Full size during drag
                              height: 30,
                            ),
                            childWhenDragging: Opacity(
                              opacity: 0.4,
                              child: Image.asset(
                                hero.imagePath,
                                width: 30,
                                height: 30,
                              ),
                            ),
                            child: Image.asset(
                              hero.imagePath,
                              width: 30, // Same size as feedback
                              height: 30,
                            ),
                          ),
                        ))
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }
}

// Model class to represent a hero with position and image path
class HeroData {
  final String imagePath;
  final Offset position;

  HeroData(this.imagePath, {this.position = Offset.zero});

  HeroData copyWith({Offset? position}) {
    return HeroData(imagePath, position: position ?? this.position);
  }
}
