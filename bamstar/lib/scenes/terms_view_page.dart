import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:go_router/go_router.dart';
import '../services/terms_service.dart';
import '../theme/app_text_styles.dart';
import '../utils/toast_helper.dart';

class TermsViewPage extends StatefulWidget {
  final String termId;
  
  const TermsViewPage({
    super.key,
    required this.termId,
  });

  @override
  State<TermsViewPage> createState() => _TermsViewPageState();
}

class _TermsViewPageState extends State<TermsViewPage> {
  Term? _term;
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _loadTermData();
  }

  Future<void> _loadTermData() async {
    try {
      final term = await TermsService.getTermById(widget.termId);
      
      setState(() {
        _term = term;
        _isLoading = false;
      });
      
      if (term == null) {
        setState(() {
          _error = '약관 정보를 찾을 수 없습니다';
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = '약관 정보를 불러오는데 실패했습니다';
      });
      
      if (mounted) {
        ToastHelper.error(context, '약관 정보를 불러오는데 실패했습니다');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: cs.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(
          _term?.title ?? '약관',
          style: AppTextStyles.pageTitle(context),
        ),
        centerTitle: true,
        backgroundColor: cs.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      backgroundColor: cs.surface,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    final cs = Theme.of(context).colorScheme;
    
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: cs.error,
            ),
            const SizedBox(height: 16),
            Text(
              _error,
              style: AppTextStyles.primaryText(context),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = '';
                });
                _loadTermData();
              },
              child: Text(
                '다시 시도',
                style: AppTextStyles.buttonText(context),
              ),
            ),
          ],
        ),
      );
    }
    
    if (_term == null) {
      return Center(
        child: Text(
          '약관 정보를 찾을 수 없습니다',
          style: AppTextStyles.primaryText(context),
        ),
      );
    }
    
    return Column(
      children: [
        // Header info
        _buildTermHeader(),
        
        // Content
        Expanded(
          child: _buildTermContent(),
        ),
      ],
    );
  }

  Widget _buildTermHeader() {
    final cs = Theme.of(context).colorScheme;
    final term = _term!;
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term type badge
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: term.type == 'mandatory' 
                      ? cs.errorContainer.withValues(alpha: 0.15)
                      : cs.secondaryContainer.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      term.type == 'mandatory' 
                          ? Icons.priority_high_rounded
                          : Icons.notifications_rounded,
                      size: 16,
                      color: term.type == 'mandatory' ? cs.error : cs.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      term.type == 'mandatory' ? '필수 약관' : '선택 약관',
                      style: AppTextStyles.chipLabel(context).copyWith(
                        color: term.type == 'mandatory' ? cs.error : cs.secondary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: cs.outline.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'v${term.version}',
                  style: AppTextStyles.captionText(context),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Title
          Text(
            term.title,
            style: AppTextStyles.sectionTitle(context),
          ),
          
          // Description
          if (term.description != null && term.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              term.description!,
              style: AppTextStyles.secondaryText(context),
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Date info
          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 16,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                '시행일: ${_formatDate(term.createdAt)}',
                style: AppTextStyles.captionText(context),
              ),
              if (term.updatedAt != term.createdAt) ...[
                const SizedBox(width: 16),
                Icon(
                  Icons.update_rounded,
                  size: 16,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  '수정일: ${_formatDate(term.updatedAt)}',
                  style: AppTextStyles.captionText(context),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermContent() {
    final cs = Theme.of(context).colorScheme;
    final term = _term!;
    
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      decoration: BoxDecoration(
        color: cs.surfaceContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outline.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Content header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.article_rounded,
                  color: cs.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '약관 내용',
                  style: AppTextStyles.cardTitle(context),
                ),
              ],
            ),
          ),
          
          // Content body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _isHtmlContent(term.content)
                  ? Html(
                      data: term.content,
                      style: {
                        'body': Style(
                          margin: Margins.zero,
                          padding: HtmlPaddings.zero,
                          fontSize: FontSize(16),
                          lineHeight: LineHeight(1.6),
                          color: cs.onSurface,
                          fontFamily: 'Pretendard',
                        ),
                        'h1, h2, h3, h4, h5, h6': Style(
                          color: cs.onSurface,
                          fontWeight: FontWeight.bold,
                          margin: Margins.only(bottom: 12, top: 20),
                        ),
                        'h1': Style(fontSize: FontSize(24)),
                        'h2': Style(fontSize: FontSize(22)),
                        'h3': Style(fontSize: FontSize(20)),
                        'h4': Style(fontSize: FontSize(18)),
                        'p': Style(
                          margin: Margins.only(bottom: 12),
                          lineHeight: LineHeight(1.6),
                        ),
                        'ul, ol': Style(
                          margin: Margins.only(bottom: 12, left: 16),
                        ),
                        'li': Style(
                          margin: Margins.only(bottom: 6),
                          lineHeight: LineHeight(1.5),
                        ),
                        'strong, b': Style(
                          fontWeight: FontWeight.bold,
                          color: cs.onSurface,
                        ),
                        'em, i': Style(
                          fontStyle: FontStyle.italic,
                        ),
                        'a': Style(
                          color: cs.primary,
                          textDecoration: TextDecoration.underline,
                        ),
                        'blockquote': Style(
                          border: Border(
                            left: BorderSide(
                              color: cs.outline,
                              width: 4,
                            ),
                          ),
                          margin: Margins.only(left: 16, bottom: 12),
                          padding: HtmlPaddings.only(left: 12),
                          backgroundColor: cs.surfaceContainerHighest,
                        ),
                        'code': Style(
                          backgroundColor: cs.surfaceContainerHighest,
                          padding: HtmlPaddings.symmetric(horizontal: 4, vertical: 2),
                          fontFamily: 'monospace',
                          fontSize: FontSize(14),
                        ),
                        'pre': Style(
                          backgroundColor: cs.surfaceContainerHighest,
                          padding: HtmlPaddings.all(12),
                          margin: Margins.only(bottom: 12),
                        ),
                        'hr': Style(
                          border: Border(
                            top: BorderSide(color: cs.outline, width: 1),
                          ),
                          margin: Margins.symmetric(vertical: 16),
                        ),
                      },
                    )
                  : Text(
                      term.content,
                      style: AppTextStyles.primaryText(context).copyWith(
                        height: 1.6,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  bool _isHtmlContent(String content) {
    return content.contains('<') && content.contains('>');
  }

  String _formatDate(DateTime date) {
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }
}