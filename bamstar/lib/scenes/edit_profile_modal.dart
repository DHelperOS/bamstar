import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wolt_modal_sheet/wolt_modal_sheet.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bamstar/services/user_service.dart';
import 'package:bamstar/services/cloudinary.dart';
import 'package:bamstar/services/avatar_helper.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:cached_network_image/cached_network_image.dart';
// ...existing code... (removed unused solar_icons import)

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
        pageTitle: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '커뮤니티 프로필 수정',
              style: Theme.of(
                modalCtx,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        leadingNavBarWidget: null,
        trailingNavBarWidget: IconButton(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.all(8),
          constraints: const BoxConstraints(),
          icon: const Icon(Icons.close, size: 20),
          onPressed: () => Navigator.of(modalCtx).pop(),
        ),
        stickyActionBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () async {
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
                  ScaffoldMessenger.of(
                    modalCtx,
                  ).showSnackBar(const SnackBar(content: Text('프로필이 저장되었습니다')));
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
              height: 48,
              width: double.infinity,
              child: Center(child: Text('저장')),
            ),
          ),
        ),
        child: SizedBox(
          height: MediaQuery.of(modalCtx).size.height * 0.42,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
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
                      // Avatar with subtle border and elevation + semi-circular overlay with edit icon
                      Material(
                        elevation: 2,
                        shape: const CircleBorder(),
                        color: Colors.transparent,
                        child: SizedBox(
                          width: 100,
                          height: 100,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              // circular avatar + border
                              Container(
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(modalCtx)
                                        .colorScheme
                                        .outline
                                        .withValues(alpha: 0.14),
                                    width: 1.2,
                                  ),
                                  color: Theme.of(modalCtx)
                                      .colorScheme
                                      .surfaceContainerHighest
                                      .withValues(alpha: 0.6),
                                ),
                                child: ClipOval(
                                  child: Center(
                                    child: CircleAvatar(
                                      radius: 50,
                                      backgroundImage: preview,
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              // overlay removed per design request
                              // small circular edit button moved to lower-right edge (less obtrusive)
                              Positioned(
                                bottom: 6,
                                right: 6,
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
                                    width: 28,
                                    height: 28,
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        // subtle inner shadow
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.08,
                                          ),
                                          blurRadius: 4,
                                          offset: const Offset(0, 1),
                                        ),
                                        // larger soft shadow to lift the button
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.10,
                                          ),
                                          blurRadius: 8,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: Center(
                                      child: Icon(
                                        Icons.edit,
                                        size: 14,
                                        color: Theme.of(
                                          modalCtx,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              // full hit area so tapping avatar also opens picker
                              Positioned.fill(
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(50),
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
                const SizedBox(height: 20),
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
