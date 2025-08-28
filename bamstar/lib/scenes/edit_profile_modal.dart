import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bamstar/services/user_service.dart';
import 'package:bamstar/services/cloudinary.dart';
import 'package:bamstar/services/avatar_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_text_styles.dart';

/// Enhanced edit profile modal with clean white theme and modern card design
Future<void> showEditProfileModal(
  BuildContext context,
  ImageProvider? initialImage, {
  ValueChanged<ImageProvider?>? onImagePicked,
}) async {
  final picker = ImagePicker();
  final TextEditingController nameCtl = TextEditingController(
    text: UserService.instance.user?.nickname ?? '',
  );
  final TextEditingController emailCtl = TextEditingController(
    text: UserService.instance.user?.email ?? '',
  );

  ImageProvider? preview = initialImage;
  final _formKey = GlobalKey<FormState>();

  await WoltModalSheet.show(
    context: context,
    pageListBuilder: (modalCtx) => [
      WoltModalSheetPage(
        backgroundColor: Theme.of(modalCtx).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        pageTitle: null,
        leadingNavBarWidget: Padding(
          padding: const EdgeInsets.only(left: 20.0),
          child: Text(
            '프로필 수정',
            style: AppTextStyles.dialogTitle(modalCtx),
          ),
        ),
        trailingNavBarWidget: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: Icon(
              Icons.close_rounded,
              size: 20,
              color: Theme.of(modalCtx).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => Navigator.of(modalCtx).pop(),
          ),
        ),
        stickyActionBar: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          decoration: BoxDecoration(
            color: Theme.of(modalCtx).colorScheme.surface,
            border: Border(
              top: BorderSide(
                color: Theme.of(modalCtx).colorScheme.outline.withValues(alpha: 0.1),
                width: 1,
              ),
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  Theme.of(modalCtx).colorScheme.primary,
                  Theme.of(modalCtx).colorScheme.primary.withValues(alpha: 0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(modalCtx).colorScheme.primary.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () async {
                  if (!(_formKey.currentState?.validate() ?? false)) return;
                  final name = nameCtl.text.trim();
                  final email = emailCtl.text.trim();
                  try {
                    await UserService.instance.upsertUser(
                      nickname: name,
                      email: email,
                    );
                    await UserService.instance.loadCurrentUser();
                    if (onImagePicked != null) {
                      onImagePicked(preview);
                    }
                    if (modalCtx.mounted) {
                      ScaffoldMessenger.of(modalCtx).showSnackBar(
                        const SnackBar(content: Text('프로필이 저장되었습니다')),
                      );
                      Navigator.of(modalCtx).pop();
                    }
                  } catch (e) {
                    debugPrint('save profile error: $e');
                    if (modalCtx.mounted) {
                      ScaffoldMessenger.of(modalCtx).showSnackBar(
                        const SnackBar(content: Text('저장 중 오류가 발생했습니다')),
                      );
                    }
                  }
                },
                child: SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      '저장',
                      style: AppTextStyles.buttonText(modalCtx).copyWith(
                        color: Theme.of(modalCtx).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(modalCtx).size.height * 0.65,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Enhanced Avatar with clean card design
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Theme.of(modalCtx).colorScheme.shadow,
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: SizedBox(
                          width: 120,
                          height: 120,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // Avatar with enhanced styling
                              Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(modalCtx).colorScheme.outline.withValues(alpha: 0.15),
                                    width: 3,
                                  ),
                                  color: Theme.of(modalCtx).colorScheme.surfaceContainerHighest,
                                ),
                                child: ClipOval(
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 57,
                                      backgroundImage: preview,
                                      backgroundColor: Theme.of(modalCtx).colorScheme.surface,
                                      child: preview == null
                                          ? Icon(
                                              Icons.person,
                                              size: 48,
                                              color: Theme.of(modalCtx).colorScheme.onSurfaceVariant,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ),
                              // Modern edit button with enhanced styling
                              Positioned(
                                bottom: 8,
                                right: 8,
                                child: GestureDetector(
                                  onTap: () async {
                                    await _pickAndUpload(
                                      modalCtx: modalCtx,
                                      picker: picker,
                                      onPreview: (img) {
                                        preview = img;
                                        if (modalCtx.mounted &&
                                            onImagePicked != null) {
                                          onImagePicked(preview);
                                        }
                                      },
                                    );
                                  },
                                  child: Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: Theme.of(modalCtx).colorScheme.surface,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(modalCtx).colorScheme.outline.withValues(alpha: 0.15),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(modalCtx).colorScheme.shadow.withValues(alpha: 0.08),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                        BoxShadow(
                                          color: Theme.of(modalCtx).colorScheme.shadow.withValues(alpha: 0.12),
                                          blurRadius: 16,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.camera_alt_rounded,
                                        size: 18,
                                        color: Theme.of(modalCtx).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // Tap area for avatar editing
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(60),
                                    splashColor: Theme.of(modalCtx).colorScheme.primary.withValues(alpha: 0.1),
                                    highlightColor: Theme.of(modalCtx).colorScheme.primary.withValues(alpha: 0.05),
                                    onTap: () async {
                                      await _pickAndUpload(
                                        modalCtx: modalCtx,
                                        picker: picker,
                                        onPreview: (img) {
                                          preview = img;
                                          if (modalCtx.mounted &&
                                              onImagePicked != null) {
                                            onImagePicked(preview);
                                          }
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Helper text
                Text(
                  '프로필 사진을 탭하여 변경하세요',
                  style: AppTextStyles.captionText(modalCtx).copyWith(
                    color: Theme.of(modalCtx).colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                // Enhanced form with card styling
                Container(
                  padding: const EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    color: Theme.of(modalCtx).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Theme.of(modalCtx).colorScheme.outline.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Theme.of(modalCtx).colorScheme.shadow.withValues(alpha: 0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nickname field
                        Text(
                          '닉네임',
                          style: AppTextStyles.formLabel(modalCtx),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(modalCtx).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(modalCtx).colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            controller: nameCtl,
                            style: AppTextStyles.primaryText(modalCtx),
                            decoration: InputDecoration(
                              hintText: '닉네임을 입력하세요',
                              hintStyle: AppTextStyles.secondaryText(modalCtx),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (v) {
                              final s = v?.trim() ?? '';
                              if (s.isEmpty) return '닉네임을 입력하세요';
                              if (s.length < 2) return '닉네임은 최소 2자 이상이어야 합니다';
                              return null;
                            },
                          ),
                        ),
                        
                        const SizedBox(height: 20),
                        
                        // Email field
                        Row(
                          children: [
                            Text(
                              '이메일',
                              style: AppTextStyles.formLabel(modalCtx),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '(공개되지 않음)',
                              style: AppTextStyles.captionText(modalCtx),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(modalCtx).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: Theme.of(modalCtx).colorScheme.outline.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          child: TextFormField(
                            controller: emailCtl,
                            style: AppTextStyles.primaryText(modalCtx),
                            decoration: InputDecoration(
                              hintText: '이메일을 입력하세요',
                              hintStyle: AppTextStyles.secondaryText(modalCtx),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                            ),
                            validator: (v) {
                              final s = v?.trim() ?? '';
                              if (s.isEmpty) return '이메일을 입력하세요';
                              final emailRegex = RegExp(r"^[\w\-\.]+@([\w\-]+\.)+[A-Za-z]{2,}");
                              if (!emailRegex.hasMatch(s)) return '유효한 이메일을 입력하세요';
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    ],
    modalTypeBuilder: (ctx) => WoltModalType.bottomSheet(),
  );
}

// Pick an image, upload to Cloudinary, then update users.profile_img and preview.
Future<void> _pickAndUpload({
  required BuildContext modalCtx,
  required ImagePicker picker,
  required ValueChanged<ImageProvider> onPreview,
}) async {
  try {
    final XFile? f = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (f == null) return;
    final bytes = await f.readAsBytes();

    // Immediate local preview for snappy UX
    onPreview(MemoryImage(bytes));

    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return;

    // Upload to Cloudinary (signed via Supabase Edge Function)
    final cloud = CloudinaryService.fromEnv();
    final secureUrl = await cloud.uploadImageFromBytes(
      bytes,
      fileName: f.name.isNotEmpty ? f.name : 'avatar.jpg',
      folder: 'user_avatars',
      publicId: 'users/$uid',
      context: {'app': 'bamstar', 'kind': 'avatar'},
    );

    // Inject default transformations for delivery
    final deliveryUrl = cloud.transformedUrlFromSecureUrl(
      secureUrl,
      width: 256,
      height: 256,
      crop: 'fill',
      gravity: 'auto',
      autoFormat: true,
      autoQuality: true,
    );

    // Persist to DB
    await client
        .from('users')
        .update({'profile_img': deliveryUrl})
        .eq('id', uid);

    // Clear any local avatar placeholders and temp b64
    final sp = await SharedPreferences.getInstance();
    await sp.remove('avatar_b64');
    await sp.remove('${UserService.avatarPrefKey}_$uid');

    // Switch preview to cached network image (via avatar helper which will
    // attempt to inject Cloudinary transforms when possible).
    onPreview(avatarImageProviderFromUrl(deliveryUrl, width: 256, height: 256));

    if (modalCtx.mounted) {
      ScaffoldMessenger.of(
        modalCtx,
      ).showSnackBar(const SnackBar(content: Text('프로필 사진이 업데이트되었습니다')));
    }
  } catch (e) {
    debugPrint('pick/upload image error: $e');
    if (modalCtx.mounted) {
      final msg = e.toString().contains('UnsafeImageException')
          ? '부적절한 이미지로 업로드할 수 없습니다'
          : '이미지 업로드 중 오류가 발생했습니다';
      ScaffoldMessenger.of(modalCtx).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}