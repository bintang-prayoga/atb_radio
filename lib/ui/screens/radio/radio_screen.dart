import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../../../view_models/radio_tile_view_model.dart';

class NeuCircle extends StatelessWidget {
  final Widget? child;

  const NeuCircle({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.inversePrimary,
        borderRadius: BorderRadius.circular(99),
      ),
      padding: const EdgeInsets.all(12),
      child: child,
    );
  }
}

class RadioScreen extends ConsumerWidget {
  final String name;
  final String url;
  final String favicon;
  final String tags;

  const RadioScreen({
    super.key,
    required this.name,
    required this.url,
    required this.favicon,
    required this.tags,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = FirebaseAuth.instance.currentUser;
    final radioTileViewModel = ref.watch(radioTileViewModelProvider);
    final isFavoriteProvider = FutureProvider<bool>((ref) =>
        radioTileViewModel.isFavorite(name)); // Provider untuk status favorit

    final sleepTimerOptions = [
      {'label': '5 Seconds', 'duration': const Duration(seconds: 5)},
      {'label': '5 Minutes', 'duration': const Duration(minutes: 5)},
      {'label': '10 Minutes', 'duration': const Duration(minutes: 10)},
      {'label': '30 Minutes', 'duration': const Duration(minutes: 30)},
      {'label': '1 Hour', 'duration': const Duration(hours: 1)},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 25, right: 25, bottom: 25),
          child: Column(
            children: [
              // Header
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      Icons.arrow_back,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const Text(
                    'N O W   P L A Y I N G',
                    style: TextStyle(fontSize: 16, color: Colors.amberAccent),
                  ),
                ],
              ),
              const SizedBox(height: 50),

              // Album Art
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  favicon,
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.radio,
                      size: 150,
                      color: Theme.of(context).colorScheme.primary,
                    );
                  },
                ),
              ),
              const SizedBox(height: 25),

              // Station Name
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 100),

              // Control Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Sleep Timer
                  if (user != null)
                    _buildSleepTimerButton(
                        context, sleepTimerOptions, radioTileViewModel),

                  // Play/Pause Button
                  GestureDetector(
                    onTap: () async {
                      if (radioTileViewModel.playing) {
                        await radioTileViewModel.pause();
                      } else {
                        await radioTileViewModel.resume();
                      }
                    },
                    child: NeuCircle(
                      child: Icon(
                        radioTileViewModel.playing
                            ? Icons.pause
                            : Icons.play_arrow,
                        color: Theme.of(context).colorScheme.primary,
                        size: 65,
                      ),
                    ),
                  ),

                  // Favorite Button
                  if (user != null)
                    Consumer(
                      builder: (context, ref, _) {
                        final isFavoriteAsync = ref.watch(isFavoriteProvider);
                        return isFavoriteAsync.when(
                          data: (isFavorite) => GestureDetector(
                            onTap: () async {
                              await radioTileViewModel.toggleFavorite(
                                name,
                                url,
                                favicon,
                                tags,
                              );
                              // Feedback snackbar
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  backgroundColor: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface,
                                  content: Text(
                                    isFavorite
                                        ? 'Removed from Favorites'
                                        : 'Added to Favorites',
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .onPrimary,
                                    ),
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                            },
                            child: NeuCircle(
                              child: Icon(
                                isFavorite
                                    ? FontAwesomeIcons.solidStar
                                    : FontAwesomeIcons.star,
                                color: isFavorite
                                    ? Colors.amber
                                    : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          loading: () => const NeuCircle(
                              child: CircularProgressIndicator()),
                          error: (_, __) => const NeuCircle(
                            child: Icon(Icons.error),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Sleep Timer Button
  Widget _buildSleepTimerButton(
      BuildContext context,
      List<Map<String, dynamic>> sleepTimerOptions,
      RadioTileViewModel viewModel) {
    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet(
          context: context,
          builder: (context) {
            return Container(
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
              ),
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15),
                    child: Text(
                      'Sleep Timer',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      itemCount: sleepTimerOptions.length,
                      itemBuilder: (context, index) {
                        final option = sleepTimerOptions[index];
                        return ListTile(
                          title: Text(
                            option['label']! as String,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            final duration = option['duration']! as Duration;
                            viewModel.setSleepTimer(duration);
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(
                                  'Sleep Timer Set',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                content: Text(
                                  'The sleep timer is set for ${duration.inMinutes > 0 ? '${duration.inMinutes} minutes' : '${duration.inSeconds} seconds'}.',
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: NeuCircle(
        child: Icon(
          FontAwesomeIcons.moon,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
