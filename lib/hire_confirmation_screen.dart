import 'package:flutter/material.dart';
import 'api_service.dart';
import 'dart:async';

class HireConfirmationScreen extends StatefulWidget {
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
  State<HireConfirmationScreen> createState() => _HireConfirmationScreenState();
}

class _HireConfirmationScreenState extends State<HireConfirmationScreen> {
  String? orderStatus;
  bool isLoading = true;
  Map<String, dynamic>? orderDetail;
  Timer? _countdownTimer;
  Duration? remainingTime;

  @override
  void initState() {
    super.initState();
    fetchOrder();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> fetchOrder() async {
    setState(() { isLoading = true; });
    final detail = await ApiService.fetchOrderDetail(widget.orderId);
    setState(() {
      orderDetail = detail;
      orderStatus = detail != null ? detail['status']?.toString() : null;
      isLoading = false;
    });
    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    if (orderStatus != null && orderStatus != 'PENDING') return;
    final startTimeStr = orderDetail?['startTime']?.toString() ?? widget.startTime;
    DateTime? startTime;
    try {
      startTime = DateTime.parse(startTimeStr);
    } catch (_) {
      return;
    }
    void updateTime() {
      final now = DateTime.now();
      final diff = startTime!.difference(now);
      setState(() {
        remainingTime = diff.isNegative ? Duration.zero : diff;
      });
      if (diff.inSeconds <= 0 && (orderStatus == null || orderStatus == 'PENDING')) {
        _countdownTimer?.cancel();
        _rejectOrder();
      }
    }
    updateTime();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) => updateTime());
  }

  String _formatDuration(Duration? d) {
    if (d == null) return '--:--';
    final h = d.inHours;
    final m = d.inMinutes % 60;
    final s = d.inSeconds % 60;
    if (h > 0) {
      return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    } else {
      return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _confirmOrder() async {
    try {
      final success = await ApiService.confirmHire(widget.orderId);
      if (success == true) {
        setState(() { orderStatus = 'CONFIRMED'; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xác nhận đơn thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Xác nhận đơn thất bại!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  Future<void> _rejectOrder() async {
    try {
      final success = await ApiService.rejectHire(widget.orderId);
      if (success == true) {
        setState(() { orderStatus = 'REJECTED'; });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã từ chối đơn thành công!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Từ chối đơn thất bại!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Lấy dữ liệu từ widget hoặc orderDetail nếu có
    final playerName = orderDetail?['playerName'] ?? widget.playerName;
    final playerAvatarUrl = orderDetail?['playerAvatarUrl'] ?? widget.playerAvatarUrl;
    final playerRank = orderDetail?['playerRank'] ?? widget.playerRank;
    final game = orderDetail?['game'] ?? widget.game;
    final hours = orderDetail?['hours'] ?? widget.hours;
    final totalCoin = orderDetail?['totalCoin'] ?? widget.totalCoin;
    final startTime = orderDetail?['startTime']?.toString() ?? widget.startTime;
    final customerNote = orderDetail?['customerNote'] ?? 'Không có';
    final servicePrice = totalCoin;
    final hireTime = '';
    final hireDate = startTime.length >= 10 ? startTime.substring(0, 10) : startTime;
    final confirmTime = '26:50';

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
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                                'Bạn cần xác nhận đơn hàng trong vòng ${_formatDuration(remainingTime)} để tránh mất đơn',
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
                  // Nút hành động hoặc thông báo trạng thái
                  if (orderStatus == 'PENDING' || orderStatus == null)
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _rejectOrder,
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
                            onPressed: _confirmOrder,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text('Xác nhận đơn', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    )
                  else if (orderStatus == 'CONFIRMED')
                    Center(
                      child: Column(
                        children: const [
                          Icon(Icons.check_circle, color: Colors.green, size: 48),
                          SizedBox(height: 8),
                          Text('Đơn đã xác nhận thành công', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    )
                  else if (orderStatus == 'REJECTED')
                    Center(
                      child: Column(
                        children: const [
                          Icon(Icons.cancel, color: Colors.red, size: 48),
                          SizedBox(height: 8),
                          Text('Đơn đã từ chối thành công', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
    );
  }
} 