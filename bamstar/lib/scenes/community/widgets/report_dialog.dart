import 'package:flutter/material.dart';

enum ReportReason {
  inappropriate('부적절한 내용 (음란, 폭력, 혐오 표현 등)'),
  spam('스팸 또는 광고성 게시물'),
  harassment('욕설/비방/개인 공격 (명예훼손)'),
  illegal('불법 정보 (불법 도박, 마약 판매 등)'),
  privacy('개인 정보 침해 (타인의 개인 정보 유출)'),
  misinformation('허위 사실 유포 또는 가짜 뉴스'),
  other('기타');

  const ReportReason(this.displayName);
  final String displayName;
}

class ReportDialog extends StatefulWidget {
  const ReportDialog({
    super.key,
    required this.onReport,
  });

  final Function(ReportReason reason) onReport;

  @override
  State<ReportDialog> createState() => _ReportDialogState();
}

class _ReportDialogState extends State<ReportDialog> {
  ReportReason? selectedReason;
  bool isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '게시물 신고하기',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Subtitle
              Text(
                '신고 사유를 선택해주세요',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colors.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              
              // Radio Button List
              ...ReportReason.values.map((reason) => 
                RadioListTile<ReportReason>(
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: isSubmitting ? null : (value) {
                    setState(() {
                      selectedReason = value;
                    });
                  },
                  title: Text(
                    reason.displayName,
                    style: theme.textTheme.bodyMedium,
                  ),
                  contentPadding: EdgeInsets.zero,
                  visualDensity: VisualDensity.compact,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: isSubmitting ? null : () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('취소'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton(
                    onPressed: (selectedReason == null || isSubmitting) 
                        ? null 
                        : _submitReport,
                    child: isSubmitting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Text('신고하기'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitReport() async {
    if (selectedReason == null) return;

    setState(() {
      isSubmitting = true;
    });

    try {
      await widget.onReport(selectedReason!);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error handling will be done by the caller
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }
}

/// Show report dialog
Future<void> showReportDialog({
  required BuildContext context,
  required Function(ReportReason reason) onReport,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => ReportDialog(onReport: onReport),
  );
}