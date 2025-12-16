//  jappeos_desktop_base, Base widgets and tools used by the greeter and the desktop environment.
//  Copyright (C) 2025  Jappe02
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

import 'package:shadcn_flutter/shadcn_flutter.dart';

class MonitorConfig {
  final List<Monitor> monitors;
  final int totalWidth;
  final int totalHeight;

  MonitorConfig({required this.monitors})
      : totalWidth = monitors.fold(0, (sum, m) => sum + m.width),
        totalHeight = monitors.fold(0, (sum, m) => sum + m.height),
        assert(monitors.where((m) => m.isPrimary).length == 1, 'There must be exactly one primary monitor');
}

class Monitor {
  final String id;
  final String name;
  final bool isPrimary;
  final int x;
  final int y;
  final int width;
  final int height;
  final EdgeInsets insets;

  Monitor({
    required this.id,
    required this.name,
    this.isPrimary = false,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.insets = EdgeInsets.zero,
  });
}