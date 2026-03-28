//  jappeos_desktop_base, Base widgets and tools used by the greeter and the desktop environment.
//  Copyright (C) 2026  The JappeOS team.
//
//  This program is free software: you can redistribute it and/or modify
//  it under the terms of the GNU Affero General Public License as
//  published by the Free Software Foundation, either version 3 of the
//  License, or (at your option) any later version.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU Affero General Public License for more details.
//
//  You should have received a copy of the GNU Affero General Public License
//  along with this program.  If not, see <https://www.gnu.org/licenses/>.

import 'package:flutter/services.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

typedef KeybindAction = bool Function();

class GlobalKeybindService {
  // Normalize sided modifiers and Super/Meta variants into canonical keys so
  // registrations and pressed-state lookups are comparable across platforms.
  static final Map<LogicalKeyboardKey, LogicalKeyboardKey> _keyNorm = {
    LogicalKeyboardKey.shiftLeft: LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftRight: LogicalKeyboardKey.shift,
    LogicalKeyboardKey.controlLeft: LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlRight: LogicalKeyboardKey.control,
    LogicalKeyboardKey.altLeft: LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altRight: LogicalKeyboardKey.alt,

    // Treat Meta variants and Super as one canonical "Super" key.
    LogicalKeyboardKey.metaLeft: LogicalKeyboardKey.superKey,
    LogicalKeyboardKey.metaRight: LogicalKeyboardKey.superKey,
    LogicalKeyboardKey.meta: LogicalKeyboardKey.superKey,
    LogicalKeyboardKey.superKey: LogicalKeyboardKey.superKey,
  };

  static final Set<LogicalKeyboardKey> _modifierKeys = {
    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.control,
    LogicalKeyboardKey.alt,
    LogicalKeyboardKey.meta,
    LogicalKeyboardKey.superKey,
  };

  final Map<LogicalKeySet, List<KeybindAction>> _bindings = {};

  // Prevent firing the same chord repeatedly while it stays held.
  final Set<LogicalKeySet> _firedWhilePressed = {};

  // Deferred "modifier-only" chord (e.g. Super) fired on key-up if untouched.
  LogicalKeySet? _pendingModifierOnlySet;

  GlobalKeybindService() {
    ServicesBinding.instance.keyboard.addHandler(_handleKey);
  }

  void register(LogicalKeySet keySet, KeybindAction action) {
    final normalized = _normalizeKeySet(keySet);
    _bindings.putIfAbsent(normalized, () => []).add(action);
  }

  void unregister(LogicalKeySet keySet, KeybindAction action) {
    final normalized = _normalizeKeySet(keySet);
    final list = _bindings[normalized];
    if (list == null) return;
    list.remove(action);
    if (list.isEmpty) _bindings.remove(normalized);

    _firedWhilePressed.remove(normalized);
    if (_pendingModifierOnlySet == normalized) {
      _pendingModifierOnlySet = null;
    }
  }

  bool _handleKey(KeyEvent event) {
    final pressed = _normalizeKeys(HardwareKeyboard.instance.logicalKeysPressed);

    // Drop fired chords that are no longer fully held.
    _firedWhilePressed.removeWhere(
      (set) => !_isSubset(set.keys, pressed.keys),
    );

    if (event is KeyUpEvent) {
      return _handleKeyUp(pressed);
    }

    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    // If a pending modifier-only chord exists, any "new" key cancels it.
    final pending = _pendingModifierOnlySet;
    if (pending != null) {
      final normalizedEventKey = _normalizeKey(event.logicalKey);
      if (!pending.keys.contains(normalizedEventKey)) {
        _pendingModifierOnlySet = null;
      }
    }

    final actions = _bindings[pressed];
    if (actions == null || actions.isEmpty) return false;

    // Modifier-only chords (Super, Ctrl+Shift, etc.) are deferred to key-up.
    if (_isModifierOnly(pressed)) {
      if (event is KeyDownEvent) {
        _pendingModifierOnlySet = pressed;
      }
      return false;
    }

    // Already fired for this held chord.
    if (_firedWhilePressed.contains(pressed)) return false;

    for (final action in List.of(actions).reversed) {
      if (action()) {
        _firedWhilePressed.add(pressed);
        _pendingModifierOnlySet = null;
        return true;
      }
    }

    return false;
  }

  bool _handleKeyUp(LogicalKeySet pressed) {
    final pending = _pendingModifierOnlySet;
    if (pending == null) return false;

    // Wait until the pending chord is no longer fully pressed.
    if (_isSubset(pending.keys, pressed.keys)) {
      return false;
    }

    _pendingModifierOnlySet = null;

    final actions = _bindings[pending];
    if (actions == null || actions.isEmpty) return false;

    for (final action in List.of(actions).reversed) {
      if (action()) return true;
    }

    return false;
  }

  LogicalKeyboardKey _normalizeKey(LogicalKeyboardKey key) {
    return _keyNorm[key] ?? key;
  }

  LogicalKeySet _normalizeKeySet(LogicalKeySet keySet) {
    return _normalizeKeys(keySet.keys);
  }

  LogicalKeySet _normalizeKeys(Set<LogicalKeyboardKey> keys) {
    return LogicalKeySet.fromSet(
      keys.map(_normalizeKey).toSet(),
    );
  }

  bool _isModifierOnly(LogicalKeySet keySet) {
    return keySet.keys.every(_modifierKeys.contains);
  }

  bool _isSubset(
    Set<LogicalKeyboardKey> subset,
    Set<LogicalKeyboardKey> superset,
  ) {
    return subset.every(superset.contains);
  }

  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKey);
    _firedWhilePressed.clear();
    _pendingModifierOnlySet = null;
  }
}