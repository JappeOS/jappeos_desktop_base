//  jappeos_desktop_base, Base widgets and tools used by the greeter and the desktop environment.
//  Copyright (C) 2026  Jappe02
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

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Monitor;
import 'package:jdwm_flutter/jdwm_flutter.dart';

class DesktopBase extends StatefulWidget {
  final GlobalKey<MultiMonitorManagerState> wmKey;
  final EdgeInsets dynamicMonitorInsets;
  final List<MonitorConfig> monitorConfig;
  final Widget Function(BuildContext context, MonitorConfig monitor)? monitorBuilder;
  final Widget Function(BuildContext context, MonitorConfig monitor)? monitorOverlayBuilder;

  const DesktopBase({
    super.key,
    required this.wmKey,
    required this.dynamicMonitorInsets,
    this.monitorConfig = const [],
    this.monitorBuilder,
    this.monitorOverlayBuilder
  });

  @override
  _DesktopBaseState createState() => _DesktopBaseState();
}

class _DesktopBaseState extends State<DesktopBase> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      var monConf = widget.monitorConfig.toList();
      if (widget.monitorConfig.isEmpty) {
        monConf.add(MonitorConfig(
          id: 'primary',
          bounds: Rect.fromLTWH(0, 0, constraints.maxWidth, constraints.maxHeight),
          margin: widget.dynamicMonitorInsets,
        ));
      }

      return MultiMonitorManager(
        key: widget.wmKey,
        monitors: monConf,
        monitorBuilder: widget.monitorBuilder,
        monitorOverlayBuilder: widget.monitorOverlayBuilder,
      );
    });
  }
}