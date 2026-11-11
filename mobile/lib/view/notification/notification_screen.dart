import 'package:flutter/material.dart';
import 'package:newztable/view/widgets/publisher_badge.dart';

class NotificationItem {
  final String id;
  final String title;
  final String subtitle;
  final String time;
  final String? sourceName;
  final String? avatarUrl;
  final bool hasFollowButton;
  bool isFollowing;

  NotificationItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.time,
    this.sourceName,
    this.avatarUrl,
    this.hasFollowButton = false,
    this.isFollowing = false,
  });
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _todayNotifications = [
    NotificationItem(
      id: 'n1',
      title: 'BBC News',
      subtitle: 'has posted new europe news "Ukraine\'s President Zelensky to BBC: Blood money being paid..."',
      time: '15m ago',
      sourceName: 'BBC News',
    ),
    NotificationItem(
      id: 'n2',
      title: 'Modelyn Saris',
      subtitle: 'is now following you',
      time: '1h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
      hasFollowButton: true,
      isFollowing: false,
    ),
    NotificationItem(
      id: 'n3',
      title: 'Omar Merditz',
      subtitle: 'commented on your shared article "Russian warship sinks in Black Sea"',
      time: '1h ago',
      avatarUrl: 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150&auto=format&fit=crop&q=80',
    ),
  ];

  final List<NotificationItem> _yesterdayNotifications = [
    NotificationItem(
      id: 'n4',
      title: 'Marley Botosh',
      subtitle: 'is now following you',
      time: '1 Day ago',
      avatarUrl: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=150&auto=format&fit=crop&q=80',
      hasFollowButton: true,
      isFollowing: true,
    ),
    NotificationItem(
      id: 'n5',
      title: 'Modelyn Saris',
      subtitle: 'liked your news collection "Renewable energy milestone surge"',
      time: '1 Day ago',
      avatarUrl: 'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=150&auto=format&fit=crop&q=80',
    ),
    NotificationItem(
      id: 'n6',
      title: 'CNN',
      subtitle: 'has posted new travel news "Her train broke down. Her phone died..."',
      time: '1 Day ago',
      sourceName: 'CNN',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notification',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All notifications marked as read.')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          _buildDateHeader('Today, November 11', isDark),
          ..._todayNotifications.map((n) => _buildNotificationCard(n, isDark)),
          const SizedBox(height: 16),
          _buildDateHeader('Yesterday, November 10', isDark),
          ..._yesterdayNotifications.map((n) => _buildNotificationCard(n, isDark)),
        ],
      ),
    );
  }

  Widget _buildDateHeader(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: isDark ? const Color(0xFF9EA3AE) : const Color(0xFF6B7280),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(NotificationItem item, bool isDark) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F222A) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9),
          width: 0.8,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar or Publisher logo
          if (item.sourceName != null)
            PublisherBadge(sourceName: item.sourceName!, size: 40)
          else if (item.avatarUrl != null)
            CircleAvatar(
              radius: 20,
              backgroundImage: NetworkImage(item.avatarUrl!),
              backgroundColor: const Color(0xFF2E333D),
            )
          else
            const CircleAvatar(
              radius: 20,
              backgroundColor: Color(0xFF1877F2),
              child: Icon(Icons.notifications_rounded, color: Colors.white, size: 20),
            ),

          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RichText(
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.35,
                      color: isDark ? Colors.white : const Color(0xFF1A1D20),
                    ),
                    children: [
                      TextSpan(
                        text: '${item.title} ',
                        style: const TextStyle(fontWeight: FontWeight.w800),
                      ),
                      TextSpan(
                        text: item.subtitle,
                        style: TextStyle(
                          color: isDark ? const Color(0xFFC5C9D3) : const Color(0xFF4B5563),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.time,
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? const Color(0xFF8E93A0) : const Color(0xFF9CA3AF),
                  ),
                ),
              ],
            ),
          ),

          // Follow button if applicable
          if (item.hasFollowButton) ...[
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                setState(() {
                  item.isFollowing = !item.isFollowing;
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: item.isFollowing
                      ? (isDark ? const Color(0xFF2E333D) : const Color(0xFFE2E4E9))
                      : const Color(0xFF1877F2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: item.isFollowing ? Colors.transparent : const Color(0xFF1877F2),
                  ),
                ),
                child: Text(
                  item.isFollowing ? 'Following' : '+ Follow',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: item.isFollowing
                        ? (isDark ? Colors.white : const Color(0xFF1A1D20))
                        : Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
