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

    // Treat Meta variants and Super as the same key for shortcuts like Super.
    LogicalKeyboardKey.metaLeft: LogicalKeyboardKey.superKey,
    LogicalKeyboardKey.metaRight: LogicalKeyboardKey.superKey,
    LogicalKeyboardKey.meta: LogicalKeyboardKey.superKey,
    LogicalKeyboardKey.superKey: LogicalKeyboardKey.superKey,
  };

  final Map<LogicalKeySet, List<KeybindAction>> _bindings = {};

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
  }

  bool _handleKey(KeyEvent event) {
    if (event is! KeyDownEvent && event is! KeyRepeatEvent) return false;

    final pressed = _normalizeKeys(HardwareKeyboard.instance.logicalKeysPressed);
    final actions = _bindings[pressed];
    if (actions == null || actions.isEmpty) return false;

    for (final action in List.of(actions).reversed) {
      if (action()) return true;
    }

    return false;
  }

  LogicalKeySet _normalizeKeySet(LogicalKeySet keySet) {
    return _normalizeKeys(keySet.keys);
  }

  LogicalKeySet _normalizeKeys(Set<LogicalKeyboardKey> keys) {
    return LogicalKeySet.fromSet(
      keys.map((k) => _keyNorm[k] ?? k).toSet(),
    );
  }

  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKey);
  }
}
