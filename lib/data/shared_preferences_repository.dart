import 'package:shared_preferences/shared_preferences.dart';
import 'package:simple_beautiful_checklist_exercise/data/database_repository.dart';
import 'package:flutter/foundation.dart';

class SharedPreferencesRepository implements DatabaseRepository {
  static const String _itemsKey = 'checklist_items';
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  SharedPreferencesRepository();

  Future<void> initialize() async {
    if (!_isInitialized) {
      _prefs = await SharedPreferences.getInstance();
      _isInitialized = true;
      debugPrint('SharedPreferencesRepository: Initialisiert.');
    }
  }

  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  Future<List<String>> _getStoredItems() async {
    await _ensureInitialized();
    return _prefs.getStringList(_itemsKey) ?? [];
  }

  Future<void> _saveItems(List<String> items) async {
    await _ensureInitialized();
    await _prefs.setStringList(_itemsKey, items);
    debugPrint('SharedPreferencesRepository: Items gespeichert: $items');
  }

  @override
  Future<int> getItemCount() async {
    final items = await _getStoredItems();
    return items.length;
  }

  @override
  Future<List<String>> getItems() async {
    return await _getStoredItems();
  }

  @override
  Future<void> addItem(String item) async {
    if (item.isEmpty) {
      debugPrint(
        'SharedPreferencesRepository: Versuch, leeres Item hinzuzufügen. Ignoriert.',
      );
      return;
    }
    final items = await _getStoredItems();
    if (!items.contains(item)) {
      items.add(item);
      await _saveItems(items);
      debugPrint('SharedPreferencesRepository: Item "$item" hinzugefügt.');
    } else {
      debugPrint(
        'SharedPreferencesRepository: Item "$item" existiert bereits. Ignoriert.',
      );
    }
  }

  @override
  Future<void> deleteItem(int index) async {
    final items = await _getStoredItems();
    if (index >= 0 && index < items.length) {
      final deletedItem = items.removeAt(index);
      await _saveItems(items);
      debugPrint(
        'SharedPreferencesRepository: Item "$deletedItem" an Index $index gelöscht.',
      );
    } else {
      debugPrint(
        'SharedPreferencesRepository: Ungültiger Index $index zum Löschen.',
      );
    }
  }

  @override
  Future<void> editItem(int index, String newItem) async {
    if (newItem.isEmpty) {
      debugPrint(
        'SharedPreferencesRepository: Versuch, Item auf leer zu bearbeiten. Ignoriert.',
      );
      return;
    }
    final items = await _getStoredItems();
    if (index >= 0 && index < items.length) {
      if (items[index] == newItem) {
        debugPrint(
          'SharedPreferencesRepository: Item an Index $index ist bereits "$newItem". Keine Änderung.',
        );
        return;
      }
      if (items.contains(newItem) && items.indexOf(newItem) != index) {
        debugPrint(
          'SharedPreferencesRepository: Item "$newItem" existiert bereits an anderem Index. Bearbeitung nicht möglich.',
        );
        return;
      }
      final oldItem = items[index];
      items[index] = newItem;
      await _saveItems(items);
      debugPrint(
        'SharedPreferencesRepository: Item an Index $index von "$oldItem" zu "$newItem" bearbeitet.',
      );
    } else {
      debugPrint(
        'SharedPreferencesRepository: Ungültiger Index $index zum Bearbeiten.',
      );
    }
  }
}
