import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/providers.dart';
import '../../domain/entity/history_item.dart';
import '../../core/util/history_exporter.dart';
import 'app_shell.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);

    // Apply filtering and search in presentation layer
    final filteredItems = state.items.where((item) {
      final matchesQuery = item.expression.toLowerCase().contains(state.query.toLowerCase()) ||
          item.result.toLowerCase().contains(state.query.toLowerCase()) ||
          (item.note?.toLowerCase().contains(state.query.toLowerCase()) ?? false);

      if (state.filterModule == 'bookmarked') {
        return matchesQuery && item.isBookmarked;
      }

      final matchesModule = state.filterModule == null || item.module == state.filterModule;
      return matchesQuery && matchesModule;
    }).toList();

    final groupedItems = _groupItems(filteredItems);

    final tags = [
      {'label': 'All', 'value': null},
      {'label': 'Bookmarked', 'value': 'bookmarked'},
      {'label': 'Standard', 'value': 'standard'},
      {'label': 'Scientific', 'value': 'scientific'},
      {'label': 'Programmer', 'value': 'programmer'},
      {'label': 'Converter', 'value': 'converter'},
      {'label': 'Currency', 'value': 'currency'},
      {'label': 'OCR Scanner', 'value': 'ocr'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Calculation History', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download),
            tooltip: 'Export Report',
            onSelected: (val) => _handleExport(context, val, filteredItems),
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'csv', child: Text('Export to CSV')),
              PopupMenuItem(value: 'pdf', child: Text('Export to PDF')),
            ],
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep_outlined),
            tooltip: 'Clear All',
            onPressed: () => _showClearConfirmation(context, notifier),
          ),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search calculation history',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: state.query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          notifier.setQuery('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: notifier.setQuery,
            ),
          ),

          // 2. Horizontal Tags
          Container(
            height: 48,
            margin: const EdgeInsets.only(bottom: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: tags.length,
              itemBuilder: (context, index) {
                final tag = tags[index];
                final isSelected = state.filterModule == tag['value'];

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: FilterChip(
                    label: Text(tag['label'] as String),
                    selected: isSelected,
                    onSelected: (selected) {
                      HapticFeedback.lightImpact();
                      notifier.setFilterModule(selected ? tag['value'] : null);
                    },
                  ),
                );
              },
            ),
          ),

          // 3. Grouped History List
          Expanded(
            child: filteredItems.isEmpty
                ? const Center(child: Text('No calculations found.'))
                : ListView.builder(
                    itemCount: groupedItems.keys.length,
                    itemBuilder: (context, index) {
                      final dateLabel = groupedItems.keys.elementAt(index);
                      final items = groupedItems[dateLabel]!;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16, top: 16, bottom: 8),
                            child: Text(
                              dateLabel,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                          ...items.map((item) => _buildHistoryCard(context, item, notifier)),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(
    BuildContext context,
    HistoryItem item,
    HistoryNotifier notifier,
  ) {
    final colorScheme = Theme.of(context).colorScheme;

    IconData moduleIcon;
    switch (item.module) {
      case 'scientific':
        moduleIcon = Icons.science_outlined;
        break;
      case 'programmer':
        moduleIcon = Icons.terminal_outlined;
        break;
      case 'converter':
        moduleIcon = Icons.swap_horiz;
        break;
      case 'currency':
        moduleIcon = Icons.currency_exchange_outlined;
        break;
      case 'ocr':
        moduleIcon = Icons.photo_camera_outlined;
        break;
      case 'standard':
      default:
        moduleIcon = Icons.calculate_outlined;
        break;
    }

    return Dismissible(
      key: Key(item.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      onDismissed: (direction) {
        HapticFeedback.mediumImpact();
        notifier.deleteItem(item.id);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calculation entry deleted')),
        );
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.surfaceVariant,
            child: Icon(moduleIcon, color: colorScheme.primary),
          ),
          title: Text(
            item.expression,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '= ${item.result}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (item.note != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    item.note!,
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: colorScheme.primary),
                  ),
                ),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bookmark toggle
              IconButton(
                icon: Icon(
                  item.isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: item.isBookmarked ? Colors.amber : null,
                ),
                onPressed: () {
                  HapticFeedback.lightImpact();
                  notifier.toggleBookmark(item.id);
                },
              ),
              // Note edit dialog trigger
              IconButton(
                icon: const Icon(Icons.note_alt_outlined, size: 20),
                onPressed: () => _showNoteDialog(context, item, notifier),
              ),
            ],
          ),
          onTap: () => _showRestoreDialog(context, item),
        ),
      ),
    );
  }

  // Group items chronologically
  Map<String, List<HistoryItem>> _groupItems(List<HistoryItem> items) {
    final map = <String, List<HistoryItem>>{};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final item in items) {
      final itemDate = DateTime(item.timestamp.year, item.timestamp.month, item.timestamp.day);
      String label;
      if (itemDate == today) {
        label = 'Today';
      } else if (itemDate == yesterday) {
        label = 'Yesterday';
      } else {
        label = '${_getMonthName(itemDate.month)} ${itemDate.day}, ${itemDate.year}';
      }
      if (!map.containsKey(label)) {
        map[label] = [];
      }
      map[label]!.add(item);
    }
    return map;
  }

  String _getMonthName(int month) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return months[month - 1];
  }

  void _showRestoreDialog(BuildContext context, HistoryItem item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reload Calculation'),
          content: Text('Do you want to load "${item.expression}" back into the calculator?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                ref.read(calculatorProvider.notifier).loadFromHistory(item.expression);
                // Switch bottom nav to standard (0) or scientific (1) tab depending on where it came from
                final targetTab = item.module == 'scientific' ? 1 : 0;
                ref.read(currentTabProvider.notifier).state = targetTab;
                Navigator.pop(context);
              },
              child: const Text('Load'),
            ),
          ],
        );
      },
    );
  }

  void _showNoteDialog(
    BuildContext context,
    HistoryItem item,
    HistoryNotifier notifier,
  ) {
    final controller = TextEditingController(text: item.note);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Calculation Note'),
          content: TextField(
            controller: controller,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Write a tag or note',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                HapticFeedback.lightImpact();
                notifier.addNote(item.id, controller.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showClearConfirmation(BuildContext context, HistoryNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear History'),
          content: const Text('Are you sure you want to delete all calculations from your history? This action is irreversible.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () {
                HapticFeedback.mediumImpact();
                notifier.clearAll();
                Navigator.pop(context);
              },
              child: const Text('Clear All'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleExport(
    BuildContext context,
    String type,
    List<HistoryItem> items,
  ) async {
    if (items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nothing to export')),
      );
      return;
    }

    try {
      HapticFeedback.mediumImpact();
      String path;
      if (type == 'csv') {
        path = await HistoryExporter.exportToCSV(items);
      } else {
        path = await HistoryExporter.exportToPDF(items);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exported successfully! Saved to documents folder.'),
          action: SnackBarAction(
            label: 'Show Path',
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('File Exported'),
                  content: SelectableText(path),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }
}
