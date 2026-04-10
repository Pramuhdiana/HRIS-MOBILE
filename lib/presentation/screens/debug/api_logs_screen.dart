import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/snackbar_helper.dart';
import '../../../core/network/api_log_store.dart';

class ApiLogsScreen extends StatelessWidget {
  const ApiLogsScreen({super.key});

  Color _chipColor(ApiLogType type) {
    switch (type) {
      case ApiLogType.request:
        return Colors.blue;
      case ApiLogType.response:
        return Colors.green;
      case ApiLogType.error:
        return AppColors.error;
    }
  }

  String _chipText(ApiLogType type) {
    switch (type) {
      case ApiLogType.request:
        return 'REQ';
      case ApiLogType.response:
        return 'RES';
      case ApiLogType.error:
        return 'ERR';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('API Logger Panel'),
        actions: [
          IconButton(
            tooltip: 'Clear logs',
            onPressed: () => ApiLogStore.instance.clear(),
            icon: const Icon(Icons.delete_sweep_outlined),
          ),
        ],
      ),
      body: ValueListenableBuilder<List<ApiLogEntry>>(
        valueListenable: ApiLogStore.instance.logs,
        builder: (context, logs, _) {
          if (logs.isEmpty) {
            return const Center(
              child: Text('No logs yet. Trigger some API calls.'),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: logs.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, i) {
              final item = logs[i];
              final queryLines = item.queryParameters?.trim();
              final queryDisplay = (queryLines == null || queryLines.isEmpty)
                  ? 'queryParameters: —'
                  : queryLines;
              return Card(
                child: InkWell(
                  onTap: () => _openDetail(context, item),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 14,
                          backgroundColor: _chipColor(item.type),
                          child: Text(
                            _chipText(item.type),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.url,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                queryDisplay,
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      fontFamily: 'monospace',
                                      fontSize: 11,
                                      height: 1.25,
                                    ),
                                maxLines: 6,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, ApiLogEntry e) {
    final timeStr = DateFormat('yyyy-MM-dd HH:mm:ss.SSS').format(e.timestamp);
    final rawBody = e.responseBody?.trim() ?? '';
    final displayBody = rawBody.isEmpty ? '(no response body)' : rawBody;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final pad = MediaQuery.paddingOf(ctx);
        final inset = MediaQuery.viewInsetsOf(ctx);
        return Padding(
          padding: EdgeInsets.only(bottom: inset.bottom),
          child: DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.88,
            maxChildSize: 0.95,
            minChildSize: 0.45,
            builder: (_, scrollController) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Time: $timeStr',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Method: ${e.method}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'URL: ${e.url}',
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                          ),
                        ),
                        if (e.statusCode != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Status: ${e.statusCode}',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                              color: Theme.of(ctx).colorScheme.primary,
                            ),
                          ),
                        ],
                        if (e.message != null && e.message!.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            e.message!,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.error,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            'Response body',
                            style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          tooltip: 'Copy response body',
                          onPressed: () async {
                            await Clipboard.setData(
                              ClipboardData(text: rawBody),
                            );
                            if (ctx.mounted) {
                              SnackBarHelper.showCopied(
                                ctx,
                                message: 'Response body copied',
                              );
                            }
                          },
                          icon: const Icon(Icons.copy_outlined),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        padding: EdgeInsets.fromLTRB(
                          20,
                          0,
                          20,
                          16 + pad.bottom,
                        ),
                        child: SelectableText(
                          displayBody,
                          style: const TextStyle(
                            fontFamily: 'monospace',
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }
}
