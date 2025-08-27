import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bamstar/services/user_service.dart';
import 'package:bamstar/services/cloudinary.dart';
import 'package:bamstar/services/avatar_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
// ...existing code... (removed unused cached_network_image and solar_icons imports)

/// Show the edit profile modal (photo + name/email). Calls [onImagePicked]
/// when the user picks a new image so callers can update preview state.
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

  // ...existing code... (helper removed after single-page refactor)ㄱ

  ImageProvider? preview = initialImage;
  final _formKey = GlobalKey<FormState>();

  await WoltModalSheet.show(
    context: context,
    pageListBuilder: (modalCtx) => [
      WoltModalSheetPage(
        backgroundColor: const Color(0xFFFFFFFF), // Clean white background
        surfaceTintColor: Colors.transparent,
        pageTitle: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
          child: Text(
            '프로필 수정',
            style: const TextStyle(
              color: Color(0xFF1C252E),
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        leadingNavBarWidget: null,
        trailingNavBarWidget: Container(
          margin: const EdgeInsets.only(right: 20.0),
          child: IconButton(
            visualDensity: VisualDensity.compact,
            padding: const EdgeInsets.all(8),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
            icon: const Icon(
              Icons.close_rounded,
              size: 20,
              color: Color(0xFF637381),
            ),
            onPressed: () => Navigator.of(modalCtx).pop(),
          ),
        ),
        stickyActionBar: Container(
          padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 32.0),
          decoration: const BoxDecoration(
            color: Color(0xFFFFFFFF),
            border: Border(
              top: BorderSide(
                color: Color(0x0F919EAB),
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
                  Theme.of(modalCtx).colorScheme.primary.withOpacity(0.8),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(modalCtx).colorScheme.primary.withOpacity(0.3),
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
                child: const SizedBox(
                  height: 52,
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      '저장',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(modalCtx).size.height * 0.42,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Local helper: pick from gallery, upload to Cloudinary, update DB + preview
                      // Note: shows immediate local preview, then swaps to cached network image after upload
                      FutureBuilder<void>(
                        future: Future.value(),
                        builder: (ctx, _) => const SizedBox.shrink(),
                      ),
                      // Enhanced Avatar with clean card design
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0x08000000),
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
                                    color: const Color(0x26919EAB),
                                    width: 3,
                                  ),
                                  color: const Color(0xFFF8F9FA),
                                ),
                                child: ClipOval(
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 57,
                                      backgroundImage: preview,
                                      backgroundColor: const Color(0xFFF4F6F8),
                                      child: preview == null
                                          ? const Icon(
                                              Icons.person,
                                              size: 48,
                                              color: Color(0xFF919EAB),
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
                                      color: const Color(0xFFFFFFFF),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: const Color(0x26919EAB),
                                        width: 1,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0x08000000),
                                          blurRadius: 8,
                                          offset: const Offset(0, 2),
                                        ),
                                        BoxShadow(
                                          color: const Color(0x12000000),
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
                                    splashColor: Theme.of(modalCtx).colorScheme.primary.withOpacity(0.1),
                                    highlightColor: Theme.of(modalCtx).colorScheme.primary.withOpacity(0.05),
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
                const SizedBox(height: 32),
                // Helper text
                Text(
                  '프로필 사진을 탭하여 변경하세요',
                  style: const TextStyle(
                    color: Color(0xFF919EAB),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: nameCtl,
                        style: Theme.of(modalCtx).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          labelText: '닉네임',
                          labelStyle: Theme.of(modalCtx).textTheme.labelSmall,
                          floatingLabelStyle: Theme.of(
                            modalCtx,
                          ).textTheme.labelSmall,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          isDense: true,
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.2,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.2,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          if (s.isEmpty) return '닉네임을 입력하세요';
                          if (s.length < 2) return '닉네임은 최소 2자 이상이어야 합니다';
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: emailCtl,
                        style: Theme.of(modalCtx).textTheme.bodyLarge,
                        decoration: InputDecoration(
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '이메일',
                                style: Theme.of(modalCtx).textTheme.labelSmall,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                '(이메일은 공개되지 않습니다)',
                                style: Theme.of(modalCtx).textTheme.bodySmall
                                    ?.copyWith(color: Colors.grey),
                              ),
                            ],
                          ),
                          floatingLabelStyle: Theme.of(
                            modalCtx,
                          ).textTheme.labelSmall,
                          floatingLabelBehavior: FloatingLabelBehavior.auto,
                          isDense: true,
                          alignLabelWithHint: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 8,
                          ),
                          border: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.2,
                            ),
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.2,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.black,
                              width: 0.2,
                            ),
                          ),
                        ),
                        validator: (v) {
                          final s = v?.trim() ?? '';
                          if (s.isEmpty) return '이메일을 입력하세요';
                          final emailRegex = RegExp(
                            r"^[\w\-\.]+@([\w\-]+\.)+[A-Za-z]{2,}",
                          );
                          if (!emailRegex.hasMatch(s)) return '유효한 이메일을 입력하세요';
                          return null;
                        },
                      ),
                    ],
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
