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

import 'package:shadcn_flutter/shadcn_flutter.dart' hide Monitor;
import 'package:shadcn_flutter/shadcn_flutter.dart' as shui show Monitor;
import 'package:jdwm_flutter/jdwm_flutter.dart';

import '../../jappeos_desktop_base.dart';

class DesktopBase extends StatefulWidget {
  final WmConfig wmConfig;
  final MonitorConfig? monitorConfig;
  final Widget Function(BuildContext context, Monitor monitor)? monitorBuilder;
  final Widget Function(BuildContext context, Monitor monitor)? monitorOverlayBuilder;

  const DesktopBase({super.key, required this.wmConfig, this.monitorConfig, this.monitorBuilder, this.monitorOverlayBuilder});

  @override
  _DesktopBaseState createState() => _DesktopBaseState();
}

class _DesktopBaseState extends State<DesktopBase> {
  @override
  Widget build(BuildContext context) {
    Widget buildWMLayer(MonitorConfig? monitorConfig) {
      (List<shui.Monitor>, int) shuiMonitors = monitorConfig != null ? _convertMonitorsForSHUI(monitorConfig.monitors) : (<shui.Monitor>[], 0);
      return WindowStack(
        wmController: widget.wmConfig.wmController,
        dynamicMonitorInsets: widget.wmConfig.dynamicMonitorInsets,
        monitors: monitorConfig != null ? shuiMonitors.$1 : null,
        primaryMonitorIndex: shuiMonitors.$2,
      );
    }

    return LayoutBuilder(builder: (context, constraints) {
      var monConf = widget.monitorConfig;
      monConf ??= MonitorConfig(monitors: [
        Monitor(
          id: 'default',
          name: 'Default Monitor',
          isPrimary: true,
          x: 0,
          y: 0,
          width: constraints.maxWidth.toInt(),
          height: constraints.maxHeight.toInt(),
        ),
      ]);
      return Stack(
        children: [
          if (widget.monitorBuilder != null) ... [
            ...monConf.monitors.map((monitor) {
              return Positioned(
                left: monitor.x.toDouble(),
                top: monitor.y.toDouble(),
                width: monitor.width.toDouble(),
                height: monitor.height.toDouble(),
                child: widget.monitorBuilder!(context, monitor),
              );
            }),
          ],
          buildWMLayer(widget.monitorConfig), // pass original monitorConfig to have single dynamic monitor when null
          if (widget.monitorOverlayBuilder != null) ... [
            ...monConf.monitors.map((monitor) {
              return Positioned(
                left: monitor.x.toDouble(),
                top: monitor.y.toDouble(),
                width: monitor.width.toDouble(),
                height: monitor.height.toDouble(),
                child: widget.monitorOverlayBuilder!(context, monitor),
              );
            }),
          ],
        ],
      );
    });
  }

  (List<shui.Monitor>, int) _convertMonitorsForSHUI(List<Monitor> monitors) {
    List<shui.Monitor> shadcnMonitors = [];
    int primaryIndex = 0;
    for (int i = 0; i < monitors.length; i++) {
      var m = monitors[i];
      shadcnMonitors.add(shui.Monitor(
        id: i,
        bounds: Rect.fromLTWH(m.x.toDouble(), m.y.toDouble(), m.width.toDouble(), m.height.toDouble()),
        padding: m.insets,
        name: m.name,
      ));
      if (m.isPrimary) {
        primaryIndex = i;
      }
    }
    return (shadcnMonitors, primaryIndex);
  }
}