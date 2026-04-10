import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/routes/app_router.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers/app_providers.dart';
import '../../widgets/auth/auth_glass_theme.dart';
import '../../widgets/liquid_glass_scaffold.dart';

class SessionExpiredScreen extends ConsumerWidget {
  const SessionExpiredScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    return LiquidGlassScaffold(
      theme: AuthGlassTheme.scaffoldTheme,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AuthGlassTheme.panelTint.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AuthGlassTheme.panelTint.withValues(alpha: 0.32),
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.lock_clock_outlined,
                        size: 64,
                        color: AuthGlassTheme.primaryBlue.withValues(alpha: 0.9),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        l10n.unauthorized,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: AuthGlassTheme.inkPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.sessionExpired,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AuthGlassTheme.inkSecondary,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          style: FilledButton.styleFrom(
                            backgroundColor: AuthGlassTheme.primaryBlue,
                            foregroundColor: Colors.white,
                          ),
                          onPressed: () {
                            ref.read(sessionExpiredNoticeProvider.notifier).state =
                                false;
                            context.go(AppRoutes.login);
                          },
                          child: Text(l10n.login),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
