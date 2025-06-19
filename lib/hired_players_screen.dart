import 'package:flutter/material.dart';
import 'api_service.dart';
import 'hire_confirmation_screen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  List<dynamic> notifications = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchAllNotifications();
  }

  Future<void> fetchAllNotifications() async {
    final data = await ApiService.fetchNotifications();
    // Lọc bỏ thông báo tin nhắn
    final filtered = data.where((n) => n['type'] != 'message').toList();
    setState(() {
      notifications = filtered;
      isLoading = false;
    });
  }

  IconData _iconForType(String? type) {
    switch (type) {
      case 'system':
        return Icons.info_outline;
      case 'rent':
        return Icons.sports_esports;
      case 'promotion':
        return Icons.card_giftcard;
      default:
        return Icons.notifications;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.red),
            tooltip: 'Xóa tất cả',
            onPressed: () async {
              for (final n in notifications) {
                await ApiService.deleteNotification(n['id']);
              }
              fetchAllNotifications();
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text('Không có thông báo nào!'))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final item = notifications[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: ListTile(
                        leading: Icon(_iconForType(item['type']), color: Colors.deepOrange),
                        title: Text(item['title'] ?? ''),
                        subtitle: Text(item['message'] ?? ''),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(item['createdAt'] != null ? item['createdAt'].toString().substring(0, 16).replaceAll('T', ' ') : ''),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              tooltip: 'Xóa thông báo',
                              onPressed: () async {
                                await ApiService.deleteNotification(item['id']);
                                fetchAllNotifications();
                              },
                            ),
                          ],
                        ),
                        onTap: () async {
                          // Chỉ xử lý nếu là thông báo thuê mới và có orderId
                          if (item['type'] == 'rent' && item['orderId'] != null) {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (_) => const Center(child: CircularProgressIndicator()),
                            );
                            final order = await ApiService.fetchOrderDetail(item['orderId'].toString());
                            Navigator.pop(context); // Đóng loading
                            if (order != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HireConfirmationScreen(
                                    playerName: order['playerName'] ?? '',
                                    playerAvatarUrl: order['playerAvatarUrl'] ?? '',
                                    playerRank: order['playerRank'] ?? '',
                                    game: order['game'] ?? '',
                                    hours: order['hours'] ?? 0,
                                    totalCoin: order['totalCoin'] ?? 0,
                                    orderId: order['id'].toString(),
                                    startTime: order['startTime']?.toString() ?? '',
                                  ),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Không lấy được thông tin đơn thuê!')),
                              );
                            }
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }
} 