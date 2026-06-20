import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/providers.dart';

class UnitConverterScreen extends ConsumerStatefulWidget {
  const UnitConverterScreen({super.key});

  @override
  ConsumerState<UnitConverterScreen> createState() => _UnitConverterScreenState();
}

class _UnitConverterScreenState extends ConsumerState<UnitConverterScreen> {
  final TextEditingController _fromController = TextEditingController();
  final TextEditingController _toController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _customNameController = TextEditingController();
  final TextEditingController _customFactorController = TextEditingController();

  @override
  void dispose() {
    _fromController.dispose();
    _toController.dispose();
    _customNameController.dispose();
    _customFactorController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(converterProvider);
    final notifier = ref.read(converterProvider.notifier);

    // Sync input values with provider state (avoid resetting cursor when editing)
    if (_fromController.text != state.fromValue) {
      final oldSelection = _fromController.selection;
      _fromController.text = state.fromValue;
      try {
        _fromController.selection = oldSelection;
      } catch (_) {}
    }
    if (_toController.text != state.toValue) {
      final oldSelection = _toController.selection;
      _toController.text = state.toValue;
      try {
        _toController.selection = oldSelection;
      } catch (_) {}
    }

    final categories = ref.read(unitConverterRepositoryProvider).getCategories();
    final isFavorite = state.pinnedFavorites.any((f) =>
        f['category'] == state.selectedCategory &&
        f['from'] == state.fromUnit &&
        f['to'] == state.toUnit);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Unit Converter', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          // Favorite Pin
          IconButton(
            icon: Icon(
              isFavorite ? Icons.pin_drop : Icons.pin_drop_outlined,
              color: isFavorite ? Theme.of(context).colorScheme.primary : null,
            ),
            tooltip: 'Pin/Unpin Favorite',
            onPressed: () {
              HapticFeedback.lightImpact();
              notifier.toggleFavorite();
            },
          ),
          // Custom Unit Creator Button
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'Add Custom Unit',
            onPressed: () => _showCustomUnitSheet(context, notifier),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Horizontal Category Selector
            Container(
              height: 56,
              margin: const EdgeInsets.only(top: 8),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  final isSelected = state.selectedCategory == cat;

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          HapticFeedback.lightImpact();
                          notifier.changeCategory(cat);
                        }
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // 2. Bidirectional Input Panels
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildConverterField(
                    context: context,
                    controller: _fromController,
                    onChanged: notifier.updateFromValue,
                    selectedUnit: state.fromUnit,
                    units: state.availableUnits,
                    onUnitChanged: (s) => notifier.setFromUnit(s!),
                    label: 'From',
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Icon(Icons.swap_vert, size: 32),
                  ),
                  _buildConverterField(
                    context: context,
                    controller: _toController,
                    onChanged: notifier.updateToValue,
                    selectedUnit: state.toUnit,
                    units: state.availableUnits,
                    onUnitChanged: (s) => notifier.setToUnit(s!),
                    label: 'To',
                  ),
                ],
              ),
            ),

            // 3. Pinned Favorites Panel
            if (state.pinnedFavorites.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Pinned Conversions',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: state.pinnedFavorites.length,
                itemBuilder: (context, index) {
                  final fav = state.pinnedFavorites[index];
                  final cat = fav['category'] ?? '';
                  final from = fav['from'] ?? '';
                  final to = fav['to'] ?? '';

                  return ListTile(
                    leading: const Icon(Icons.pin_drop, color: Colors.amber),
                    title: Text('$from ➔ $to'),
                    subtitle: Text('Category: $cat'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      HapticFeedback.lightImpact();
                      notifier.changeCategory(cat);
                      notifier.setFromUnit(from);
                      notifier.setToUnit(to);
                    },
                  );
                },
              ),
            ],
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildConverterField({
    required BuildContext context,
    required TextEditingController controller,
    required ValueChanged<String> onChanged,
    required String selectedUnit,
    required List<dynamic> units,
    required ValueChanged<String?> onUnitChanged,
    required String label,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: TextField(
                controller: controller,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  labelText: label,
                  border: InputBorder.none,
                ),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<String>(
                value: selectedUnit.isEmpty ? null : selectedUnit,
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
                items: units.map<DropdownMenuItem<String>>((u) {
                  return DropdownMenuItem<String>(
                    value: u.symbol,
                    child: Text('${u.symbol} (${u.name})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: onUnitChanged,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCustomUnitSheet(BuildContext context, ConverterNotifier notifier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 24,
            right: 24,
            top: 24,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Add Custom Unit for ${ref.read(converterProvider).selectedCategory}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customNameController,
                  decoration: const InputDecoration(
                    labelText: 'Unit Name (e.g. My Pace)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter a unit name';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customFactorController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(
                    labelText: 'Conversion Factor relative to Base Unit',
                    border: OutlineInputBorder(),
                    helperText: 'e.g. If base unit is meters, and new unit is 2 meters, enter 2.0',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Enter a factor';
                    if (double.tryParse(value) == null) return 'Enter a valid number';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      HapticFeedback.lightImpact();
                      notifier.addCustom(
                        _customNameController.text,
                        double.parse(_customFactorController.text),
                      );
                      _customNameController.clear();
                      _customFactorController.clear();
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Save Custom Unit'),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        );
      },
    );
  }
}
