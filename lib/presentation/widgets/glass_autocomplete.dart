import 'package:flutter/material.dart';
import 'glass_container.dart';

class GlassAutocomplete<T extends Object> extends StatelessWidget {
  final List<T> options;
  final T? initialValue;
  final ValueChanged<T?> onChanged;
  final String Function(T)? displayStringForOption;

  const GlassAutocomplete({
    super.key,
    required this.options,
    this.initialValue,
    required this.onChanged,
    this.displayStringForOption,
  });

  @override
  Widget build(BuildContext context) {
    final displayString = displayStringForOption ?? (T option) => option.toString();

    return Autocomplete<T>(
      initialValue: TextEditingValue(text: initialValue != null ? displayString(initialValue as T) : ''),
      optionsBuilder: (TextEditingValue textEditingValue) {
        if (textEditingValue.text.isEmpty) {
          return options;
        }
        return options.where((T option) {
          return displayString(option)
              .toLowerCase()
              .contains(textEditingValue.text.toLowerCase());
        });
      },
      displayStringForOption: displayString,
      onSelected: onChanged,
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController fieldTextEditingController,
        FocusNode fieldFocusNode,
        VoidCallback onFieldSubmitted,
      ) {
        return TextField(
          controller: fieldTextEditingController,
          focusNode: fieldFocusNode,
          style: const TextStyle(fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            suffixIcon: const Icon(Icons.arrow_drop_down),
            isDense: true,
          ),
          onSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<T> onSelected,
        Iterable<T> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: 4.0,
            color: Colors.transparent,
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: 250,
                maxWidth: MediaQuery.of(context).size.width - 64, // roughly screen width minus padding
              ),
              child: GlassContainer(
                child: ListView.builder(
                  padding: EdgeInsets.zero,
                  shrinkWrap: true,
                  itemCount: options.length,
                  itemBuilder: (BuildContext context, int index) {
                    final T option = options.elementAt(index);
                    return InkWell(
                      onTap: () {
                        onSelected(option);
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          displayString(option),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
