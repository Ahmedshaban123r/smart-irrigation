import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../widgets/mode_toggle_card.dart';

class ActuatorScreen extends StatelessWidget {
  const ActuatorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Controls')),
      body: StreamBuilder<String>(
        stream: FirebaseService.currentMode,
        builder: (context, modeSnap) {
          final mode = modeSnap.data ?? 'AUTOMATIC';
          final isManual = mode == 'MANUAL';
          return Column(
            children: [
              ModeToggleCard(currentMode: mode),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SystemStateCard(isManual: isManual),
                    const SizedBox(height: 16),
                    _ManualPumpCard(isManual: isManual),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── System State Card ─────────────────────────────────────────────────────────

class _SystemStateCard extends StatelessWidget {
  final bool isManual;
  const _SystemStateCard({required this.isManual});

  void _triggerEmergencyStop(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Emergency stop'),
        content:
            const Text('This stops ALL actuators immediately. Are you sure?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(context);
              FirebaseService.writeEmergencyStop();
            },
            child: const Text('Stop everything'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DatabaseEvent>(
      stream: FirebaseDatabase.instance.ref('status/system_state').onValue,
      builder: (context, snapshot) {
        final systemState =
            snapshot.data?.snapshot.value?.toString() ?? 'UNKNOWN';
        return Card(
          child: ListTile(
            leading: Icon(
              systemState == 'NORMAL' ? Icons.check_circle : Icons.warning,
              color: systemState == 'NORMAL' ? Colors.green : Colors.red,
              size: 32,
            ),
            title: const Text('System State'),
            subtitle: Text(systemState),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.danger,
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.stop_circle),
              label: const Text('E-STOP'),
              onPressed: () => _triggerEmergencyStop(context),
            ),
          ),
        );
      },
    );
  }
}

// ── Manual Pump + Plant Card (writes to esp/pump) ─────────────────────────────
class _ManualPumpCard extends StatefulWidget {
  final bool isManual;
  const _ManualPumpCard({required this.isManual});

  @override
  State<_ManualPumpCard> createState() => _ManualPumpCardState();
}

class _ManualPumpCardState extends State<_ManualPumpCard> {
  int _selectedPlant = 0;
  bool _initialized = false;

  Future<void> _sendPump(String state, int plant) async {
    try {
      await FirebaseService.writeEspPump(state: state, plant: plant);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService.espPump,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const {};
        final state = (data['state']?.toString() ?? 'OFF').toUpperCase();
        final fbPlant = (data['plant'] is num)
            ? (data['plant'] as num).toInt()
            : 0;
        final isOn = state == 'ON';

        if (!_initialized && snapshot.hasData) {
          _initialized = true;
          _selectedPlant = fbPlant.clamp(0, 1);
        }

        final disabled = !widget.isManual;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Manual Pump Control',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text('esp/pump → $state  (plant P$fbPlant)',
                    style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 16),

                const Text('Plant', style: TextStyle(fontWeight: FontWeight.w500)),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('P0  (3 cm)')),
                    ButtonSegment(value: 1, label: Text('P1  (13 cm)')),
                  ],
                  selected: {_selectedPlant},
                  onSelectionChanged: disabled
                      ? null
                      : (s) => setState(() => _selectedPlant = s.first),
                ),

                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Pump ON'),
                        onPressed: (disabled || isOn)
                            ? null
                            : () => _sendPump('ON', _selectedPlant),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        icon: const Icon(Icons.stop),
                        label: const Text('Pump OFF'),
                        onPressed: (disabled || !isOn)
                            ? null
                            : () => _sendPump('OFF', _selectedPlant),
                      ),
                    ),
                  ],
                ),

                if (disabled) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Controls locked — switch to Manual mode',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.45),
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
