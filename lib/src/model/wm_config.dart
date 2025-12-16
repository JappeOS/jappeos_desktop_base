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

import 'package:jdwm_flutter/jdwm_flutter.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';

class WmConfig {
  final EdgeInsets dynamicMonitorInsets;
  final WindowStackController wmController;

  const WmConfig({
    this.dynamicMonitorInsets = EdgeInsets.zero,
    required this.wmController,
  });
}