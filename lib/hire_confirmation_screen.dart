import 'package:flutter/material.dart';
import 'api_service.dart';

class HireConfirmationScreen extends StatelessWidget {
  final String playerName;
  final String playerAvatarUrl;
  final String playerRank;
  final String game;
  final int hours;
  final int totalCoin;
  final String orderId;
  final String startTime;

  const HireConfirmationScreen({
    Key? key,
    required this.playerName,
    required this.playerAvatarUrl,
    required this.playerRank,
    required this.game,
    required this.hours,
    required this.totalCoin,
    required this.orderId,
    required this.startTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Giả lập dữ liệu mẫu cho các phần chưa có từ BE
    final String customerNote =
        '"Mình muốn chơi với một người có thể hướng dẫn mình cách chơi tốt hơn và có thể voice chat. Mình muốn tập trung vào vị trí đi rừng."';
    final int servicePrice = totalCoin; // Giá dịch vụ đúng bằng totalCoin
    final int platformFee = 0; // Không còn phí nền tảng
    final int balance = 2500; // Số dư xu mẫu
    final String hireTime = '19:00 - 22:00'; // Thời gian thuê mẫu
    final String hireDate = startTime.length >= 10 ? startTime.substring(0, 10) : startTime;
    final String confirmTime = '26:50'; // Thời gian còn lại xác nhận mẫu

    // Format lại thời gian đặt đơn
    String formattedOrderTime = '';
    try {
      final dt = DateTime.parse(startTime);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      final day = dt.day.toString().padLeft(2, '0');
      final month = dt.month.toString().padLeft(2, '0');
      final year = dt.year.toString();
      formattedOrderTime = '$hour:$minute - $day/$month/$year';
    } catch (_) {
      formattedOrderTime = startTime;
    }

    // Format lại thời gian thuê
    String hireTimeDisplay = '';
    String hireDateDisplay = '';
    try {
      final dt = DateTime.parse(startTime);
      final hour = dt.hour.toString().padLeft(2, '0');
      final minute = dt.minute.toString().padLeft(2, '0');
      hireTimeDisplay = '$hour:$minute';
      hireDateDisplay = '${dt.year.toString().padLeft(4, '0')}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
      // Nếu có endTime, hiển thị khoảng thời gian
      // TODO: Nếu có biến endTime, hãy lấy và format tương tự, ví dụ:
      // final dtEnd = DateTime.parse(endTime);
      // final hourEnd = dtEnd.hour.toString().padLeft(2, '0');
      // final minuteEnd = dtEnd.minute.toString().padLeft(2, '0');
      // hireTimeDisplay = '$hour:$minute - $hourEnd:$minuteEnd';
    } catch (_) {
      hireTimeDisplay = hireTime;
      hireDateDisplay = hireDate;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F9),
      appBar: AppBar(
        title: const Text('Xác nhận đơn hàng'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 20),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thông tin người chơi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundImage: (playerAvatarUrl.isNotEmpty && playerAvatarUrl != 'null')
                        ? NetworkImage(playerAvatarUrl)
                        : null,
                    child: (playerAvatarUrl.isEmpty || playerAvatarUrl == 'null')
                        ? const Icon(Icons.person, size: 32, color: Colors.grey)
                        : null,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(playerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade100,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text('Đã xác thực', style: TextStyle(fontSize: 11, color: Colors.blue)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: const [
                            Icon(Icons.star, color: Colors.amber, size: 18),
                            SizedBox(width: 2),
                            Text('4.5', style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(width: 6),
                          ],
                        ),
                        const SizedBox(width: 6),
                        Text('Đặt lúc: $formattedOrderTime', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Chi tiết đơn hàng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.access_time, color: Colors.blue),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Thời gian thuê', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(hireTimeDisplay, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                      const Spacer(),
                      Text(hireDateDisplay, style: const TextStyle(color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.purple.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.purple),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Loại game', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text(game, style: const TextStyle(fontSize: 15)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Rank yêu cầu:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(width: 8),
                      Icon(Icons.verified, color: Colors.blue.shade700, size: 18),
                      Text(' $playerRank', style: const TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Yêu cầu đặc biệt:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(customerNote, style: const TextStyle(color: Colors.black87)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Giá mỗi giờ:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('${servicePrice ~/ hours} xu'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng thời gian:', style: TextStyle(fontWeight: FontWeight.bold)),
                      Text('$hours giờ'),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Tổng tiền:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('$servicePrice xu', style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 16),
            // Lưu ý quan trọng
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Lưu ý quan trọng', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.timer, color: Colors.red, size: 18),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'Bạn cần xác nhận đơn hàng trong vòng $confirmTime để tránh mất đơn',
                          style: const TextStyle(color: Colors.red),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Nếu từ chối đơn, vui lòng cung cấp lý do để chúng tôi hỗ trợ khách hàng tốt hơn.'),
                  const SizedBox(height: 4),
                  const Text('Sau khi xác nhận, bạn sẽ được kết nối với khách hàng qua ứng dụng chat.'),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Nút hành động
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () async {
                      final success = await ApiService.rejectHire(orderId);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã từ chối đơn thành công!')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Từ chối đơn thất bại!')),
                        );
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Từ chối đơn', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () async {
                      final success = await ApiService.confirmHire(orderId);
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Đã xác nhận đơn thành công!')),
                        );
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Xác nhận đơn thất bại!')),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Xác nhận đơn', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
} 