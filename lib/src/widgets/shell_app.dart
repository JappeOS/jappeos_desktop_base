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

import 'package:jappeos_services/jappeos_services.dart';
import 'package:jdwm_flutter/jdwm_flutter.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_flutter/shadcn_flutter.dart';
import 'package:nested/nested.dart';

import '../keybinds/global_keybind_scope.dart';
import '../keybinds/global_keybind_service.dart';
import '../provider/theme_provider.dart';
import 'desktop_base.dart';

class ShellApp extends StatelessWidget {
  final List<SingleChildWidget> providers;
  final String title;
  final bool debugShowMaterialGrid;
  final bool showPerformanceOverlay;
  final bool showSemanticsDebugger;
  final bool debugShowCheckedModeBanner;
  final ThemeData theme;
  final ThemeData? darkTheme;
  final bool enableThemeAnimation;
  final Map<ShortcutActivator, Intent>? shortcuts;
  final Map<Type, Action<Intent>>? actions;
  final GlobalKeybindService? keybinds;
  final GlobalKey<WindowManagerState> wmKey;
  final EdgeInsets dynamicMonitorInsets;
  final List<MonitorConfig> monitors;
  final Widget Function(BuildContext, MonitorConfig)? monitorBuilder;
  final Widget Function(BuildContext, MonitorConfig)? monitorOverlayBuilder;

  const ShellApp({
    super.key,
    this.providers = const [],
    this.title = '',
    this.debugShowMaterialGrid = false,
    this.showPerformanceOverlay = false,
    this.showSemanticsDebugger = false,
    this.debugShowCheckedModeBanner = true,
    this.theme = const ThemeData(),
    this.darkTheme,
    this.enableThemeAnimation = true,
    this.shortcuts,
    this.actions,
    this.keybinds,
    required this.wmKey,
    this.dynamicMonitorInsets = EdgeInsets.zero,
    this.monitors = const [],
    this.monitorBuilder,
    this.monitorOverlayBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return JappeosServiceProvider(
      child: MultiProvider(
        providers: [
          ...providers,
          ListenableProvider<ThemeProvider>(create: (_) => ThemeProvider()),
        ],
        builder: (context, _) => MediaQuery(
          // TODO: Correctly integrate system text scaling by changing scales of icons and other UI elements with text.
          data: mediaQuery.copyWith(textScaler: const TextScaler.linear(1.0)),
          child: ShadcnApp(
            title: title,
            debugShowMaterialGrid: debugShowMaterialGrid,
            showPerformanceOverlay: showPerformanceOverlay,
            showSemanticsDebugger: showSemanticsDebugger,
            debugShowCheckedModeBanner: debugShowCheckedModeBanner,
            theme: theme,
            darkTheme: darkTheme,
            themeMode: context.watch<ThemeProvider>().isDark
                ? ThemeMode.dark
                : ThemeMode.light,
            enableThemeAnimation: enableThemeAnimation,
            shortcuts: shortcuts,
            actions: actions,
            /*builder: builder,
            home: child,*/
            home: _globalKeybindScope(
              keybinds: keybinds,
              child: Scaffold(
                backgroundColor: Colors.transparent,
                child: DesktopBase(
                  wmKey: wmKey,
                  dynamicMonitorInsets: dynamicMonitorInsets,
                  monitorConfig: monitors,
                  monitorBuilder: monitorBuilder,
                  monitorOverlayBuilder: monitorOverlayBuilder,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _globalKeybindScope({
    GlobalKeybindService? keybinds,
    required Widget child,
  }) {
    if (keybinds == null) {
      return child;
    }
    return GlobalKeybindScope(
      keybinds: keybinds,
      child: child,
    );
  }
}