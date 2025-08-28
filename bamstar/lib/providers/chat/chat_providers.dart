import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../app_providers.dart';
import '../auth/auth_providers.dart';

/// 채팅 메시지 모델
class ChatMessage {
  final String id;
  final String roomId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final String content;
  final String? type; // text, image, file
  final bool isRead;
  final DateTime createdAt;
  
  const ChatMessage({
    required this.id,
    required this.roomId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.content,
    this.type = 'text',
    this.isRead = false,
    required this.createdAt,
  });
  
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'],
      roomId: json['room_id'],
      senderId: json['sender_id'],
      senderName: json['sender_name'],
      senderAvatar: json['sender_avatar'],
      content: json['content'],
      type: json['type'] ?? 'text',
      isRead: json['is_read'] ?? false,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// 채팅방 모델
class ChatRoom {
  final String id;
  final String name;
  final String? description;
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final DateTime createdAt;
  
  const ChatRoom({
    required this.id,
    required this.name,
    this.description,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    required this.createdAt,
  });
  
  factory ChatRoom.fromJson(Map<String, dynamic> json) {
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'] != null
        ? DateTime.parse(json['last_message_time'])
        : null,
      unreadCount: json['unread_count'] ?? 0,
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

/// 현재 채팅방 ID Provider
final currentChatRoomIdProvider = StateProvider<String?>((ref) => null);

/// 채팅방 목록 Provider
final chatRoomsProvider = FutureProvider<List<ChatRoom>>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return [];
  
  // 사용자가 참여중인 채팅방 조회
  final response = await supabase
    .from('chat_rooms')
    .select('''
      *,
      messages:chat_messages(
        content,
        created_at
      )
    ''')
    .contains('participants', [userId])
    .order('updated_at', ascending: false);
  
  return response.map((json) {
    // 마지막 메시지 정보 추출
    final messages = json['messages'] as List? ?? [];
    final lastMsg = messages.isNotEmpty ? messages.first : null;
    
    return ChatRoom(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      participants: List<String>.from(json['participants'] ?? []),
      lastMessage: lastMsg?['content'],
      lastMessageTime: lastMsg?['created_at'] != null
        ? DateTime.parse(lastMsg['created_at'])
        : null,
      createdAt: DateTime.parse(json['created_at']),
    );
  }).toList();
});

/// 채팅 메시지 실시간 스트림 Provider
final chatMessagesStreamProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, roomId) {
    final supabase = ref.watch(supabaseProvider);
    
    return supabase
      .from('chat_messages')
      .stream(primaryKey: ['id'])
      .eq('room_id', roomId)
      .order('created_at', ascending: false)
      .limit(50)
      .map((data) {
        return data.map((json) => ChatMessage.fromJson(json)).toList();
      });
  },
);

/// 채팅 실시간 구독 Provider (Supabase Realtime)
final chatRealtimeProvider = StreamProvider.family<ChatMessage?, String>(
  (ref, roomId) {
    final supabase = ref.watch(supabaseProvider);
    
    // Realtime 구독 설정
    final streamController = StreamController<ChatMessage?>();
    
    final channel = supabase
      .channel('chat:$roomId')
      .onPostgresChanges(
        event: PostgresChangeEvent.insert,
        schema: 'public',
        table: 'chat_messages',
        callback: (payload) {
          // 새 메시지 수신시 처리
          if (payload.newRecord != null) {
            final newMessage = ChatMessage.fromJson(payload.newRecord!);
            streamController.add(newMessage);
          }
        },
      )
      .subscribe();
      
    // Clean up on dispose
    ref.onDispose(() {
      streamController.close();
      channel.unsubscribe();
    });
    
    return streamController.stream;
  },
);

/// 채팅 메시지 전송 Notifier
class ChatNotifier extends AsyncNotifier<void> {
  @override
  Future<void> build() async {
    // 초기 상태
  }
  
  /// 메시지 전송
  Future<void> sendMessage({
    required String roomId,
    required String content,
    String type = 'text',
  }) async {
    final supabase = ref.read(supabaseProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) throw Exception('User not authenticated');
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 메시지 전송
      await supabase.from('chat_messages').insert({
        'room_id': roomId,
        'sender_id': userId,
        'content': content,
        'type': type,
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // 채팅방 업데이트 시간 갱신
      await supabase.from('chat_rooms').update({
        'last_message': content,
        'last_message_time': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      }).eq('id', roomId);
    });
  }
  
  /// 채팅방 생성
  Future<String> createChatRoom({
    required String name,
    String? description,
    required List<String> participants,
  }) async {
    final supabase = ref.read(supabaseProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) throw Exception('User not authenticated');
    
    state = const AsyncValue.loading();
    final result = await AsyncValue.guard(() async {
      // 현재 사용자 포함
      final allParticipants = {...participants, userId}.toList();
      
      final response = await supabase.from('chat_rooms').insert({
        'name': name,
        'description': description,
        'participants': allParticipants,
        'created_by': userId,
        'created_at': DateTime.now().toIso8601String(),
      }).select().single();
      
      // 채팅방 목록 새로고침
      ref.invalidate(chatRoomsProvider);
      
      return response['id'] as String;
    });
    
    state = result;
    return result.value ?? '';
  }
  
  /// 메시지 읽음 처리
  Future<void> markAsRead(String roomId) async {
    final supabase = ref.read(supabaseProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) return;
    
    await supabase
      .from('chat_messages')
      .update({'is_read': true})
      .eq('room_id', roomId)
      .neq('sender_id', userId);
  }
  
  /// 채팅방 나가기
  Future<void> leaveChatRoom(String roomId) async {
    final supabase = ref.read(supabaseProvider);
    final userId = ref.read(currentUserIdProvider);
    
    if (userId == null) return;
    
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 현재 참여자 목록 가져오기
      final room = await supabase
        .from('chat_rooms')
        .select('participants')
        .eq('id', roomId)
        .single();
      
      final participants = List<String>.from(room['participants']);
      participants.remove(userId);
      
      // 참여자 목록 업데이트
      await supabase
        .from('chat_rooms')
        .update({'participants': participants})
        .eq('id', roomId);
      
      // 채팅방 목록 새로고침
      ref.invalidate(chatRoomsProvider);
    });
  }
}

/// 채팅 작업 Provider
final chatNotifierProvider = AsyncNotifierProvider<ChatNotifier, void>(
  ChatNotifier.new,
);

/// 타이핑 상태 Provider (Presence)
final typingStatusProvider = StateProvider.family<bool, String>(
  (ref, roomId) => false,
);

/// 온라인 사용자 Provider (Presence)
final onlineUsersProvider = StreamProvider.family<List<String>, String>(
  (ref, roomId) {
    final supabase = ref.watch(supabaseProvider);
    final userId = ref.watch(currentUserIdProvider);
    
    if (userId == null) return Stream.value([]);
    
    final channel = supabase.channel('room:$roomId');
    
    // Presence 추적
    final streamController = StreamController<List<String>>();
    
    channel.onPresenceSync((payload) {
      // Extract user IDs from presence sync
      final presences = <String>[];
      // In Supabase Flutter SDK 2.x, the presence payload is different
      // We'll handle this using a simple approach for now
      streamController.add(presences);
    });
    
    // 자신의 presence 전송
    channel.track({
      'user_id': userId,
      'online_at': DateTime.now().toIso8601String(),
    });
    
    channel.subscribe();
    
    ref.onDispose(() {
      streamController.close();
      channel.unsubscribe();
    });
    
    return streamController.stream;
  },
);

/// 읽지 않은 메시지 수 Provider
final unreadMessagesCountProvider = FutureProvider<int>((ref) async {
  final supabase = ref.watch(supabaseProvider);
  final userId = ref.watch(currentUserIdProvider);
  
  if (userId == null) return 0;
  
  final response = await supabase
    .from('chat_messages')
    .select('id')
    .neq('sender_id', userId)
    .eq('is_read', false);
  
  return (response as List).length;
});