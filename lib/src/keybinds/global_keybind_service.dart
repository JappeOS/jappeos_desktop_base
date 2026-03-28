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
  // Normalize sided modifier keys to their unsided equivalents so that
  // registrations using e.g. LogicalKeyboardKey.shift match physical
  // shiftLeft / shiftRight events coming from HardwareKeyboard.
  static final Map<LogicalKeyboardKey, LogicalKeyboardKey> _modifierNorm = {
    LogicalKeyboardKey.shiftLeft:    LogicalKeyboardKey.shift,
    LogicalKeyboardKey.shiftRight:   LogicalKeyboardKey.shift,
    LogicalKeyboardKey.controlLeft:  LogicalKeyboardKey.control,
    LogicalKeyboardKey.controlRight: LogicalKeyboardKey.control,
    LogicalKeyboardKey.altLeft:      LogicalKeyboardKey.alt,
    LogicalKeyboardKey.altRight:     LogicalKeyboardKey.alt,
    LogicalKeyboardKey.metaLeft:     LogicalKeyboardKey.superKey,
    LogicalKeyboardKey.metaRight:    LogicalKeyboardKey.superKey,
  };

  final Map<LogicalKeySet, List<KeybindAction>> _bindings = {};

  GlobalKeybindService() {
    ServicesBinding.instance.keyboard.addHandler(_handleKey);
  }

  void register(LogicalKeySet keySet, KeybindAction action) {
    _bindings.putIfAbsent(keySet, () => []).add(action);
  }

  void unregister(LogicalKeySet keySet, KeybindAction action) {
    final list = _bindings[keySet];
    if (list == null) return;
    list.remove(action);
    if (list.isEmpty) _bindings.remove(keySet);
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

  /// Replaces every sided modifier key (shiftLeft, controlRight, …) with its
  /// canonical unsided form so Map lookups match registrations made with the
  /// unsided constants.
  LogicalKeySet _normalizeKeys(Set<LogicalKeyboardKey> keys) {
    return LogicalKeySet.fromSet(
      keys.map((k) => _modifierNorm[k] ?? k).toSet(),
    );
  }

  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_handleKey);
  }
}