import 'package:flutter/material.dart';
import '../services/firebase_service.dart';
import '../theme/app_theme.dart';
import '../models/protocol_definition.dart';

class AiMonitorScreen extends StatelessWidget {
  const AiMonitorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Monitor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const _DetectionCard(),
            const SizedBox(height: 16),
            // ── Protocol Reference ───────────────────────────────────
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: ExpansionTile(
                title: Text(
                  'Protocol reference',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                backgroundColor: AppTheme.greenPale,
                collapsedBackgroundColor: AppTheme.greenPale,
                shape: const Border(),
                collapsedShape: const Border(),
                children: ProtocolDefinition.all.map((def) {
                  return ListTile(
                    dense: true,
                    leading: Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        color: def.indicatorColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    title: Text(
                      def.plantClass,
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: AppTheme.greenDeep),
                    ),
                    trailing: Text(
                      def.actionLabel,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.55),
                          ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Detection Card ────────────────────────────────────────────────────────────

class _DetectionCard extends StatelessWidget {
  const _DetectionCard();

  Color _colorForClass(String className) {
    final def = ProtocolDefinition.forClass(className);
    return def?.indicatorColor ?? Colors.grey;
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.8) return Colors.green;
    if (confidence >= 0.5) return Colors.amber;
    return Colors.red;
  }

  String _updatedAgo(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      final dt = DateTime.parse(timestamp.replaceAll(' UTC', 'Z'));
      final diff = DateTime.now().toUtc().difference(dt);
      if (diff.inSeconds < 60) return 'Updated ${diff.inSeconds}s ago';
      if (diff.inMinutes < 60) return 'Updated ${diff.inMinutes}m ago';
      return 'Updated ${diff.inHours}h ago';
    } catch (_) {
      return timestamp;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseService.latestDetection,
      builder: (context, snap) {
        final detection = snap.data ?? {};
        final plantClass = detection['class']?.toString() ?? 'None';
        final confidence = (detection['confidence'] as num?)?.toDouble() ?? 0.0;
        final entropy = (detection['entropy'] as num?)?.toDouble();
        final timestamp = detection['timestamp']?.toString();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Latest Detection',
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    if (timestamp != null)
                      Text(
                        _updatedAgo(timestamp),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.45),
                            ),
                      ),
                  ],
                ),
                const Divider(),
                const Center(
                  child:
                      Icon(Icons.camera_alt, size: 100, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: _colorForClass(plantClass),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      plantClass,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontFamily: 'DM Serif Display',
                            color: AppTheme.greenDeep,
                          ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: confidence,
                          minHeight: 8,
                          valueColor: AlwaysStoppedAnimation<Color>(
                              _confidenceColor(confidence)),
                          backgroundColor:
                              _confidenceColor(confidence).withValues(alpha: 0.15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${(confidence * 100).toStringAsFixed(1)}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _confidenceColor(confidence),
                      ),
                    ),
                  ],
                ),
                if (entropy != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    'Entropy: ${entropy.toStringAsFixed(3)}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.5),
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
