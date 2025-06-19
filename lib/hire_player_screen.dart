import 'package:flutter/material.dart';
import 'api_service.dart';
import 'hire_confirmation_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class HirePlayerScreen extends StatefulWidget {
  final Map<String, dynamic> player;
  const HirePlayerScreen({super.key, required this.player});

  @override
  State<HirePlayerScreen> createState() => _HirePlayerScreenState();
}

class _HirePlayerScreenState extends State<HirePlayerScreen> {
  int selectedHour = 1;
  final TextEditingController messageController = TextEditingController();
  final List<int> hours = [1, 2, 3, 4, 5];
  int? walletBalance;
  bool isLoading = false;
  DateTime? selectedStartTime;
  DateTime? selectedEndTime;
  String? token;
  final baseUrl = 'http://10.0.2.2:8080';
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadWalletBalance();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    final user = await ApiService.getCurrentUser();
    setState(() {
      userId = user?['id'];
    });
  }

  Future<void> _loadWalletBalance() async {
    setState(() { isLoading = true; });
    final balance = await ApiService.fetchWalletBalance();
    setState(() {
      walletBalance = balance;
      isLoading = false;
    });
  }

  int get totalHours {
    if (selectedStartTime == null || selectedEndTime == null) return 0;
    return selectedEndTime!.difference(selectedStartTime!).inMinutes ~/ 60;
  }

  int get totalCoin {
    final pricePerHour = (widget.player['pricePerHour'] is int)
        ? widget.player['pricePerHour']
        : (widget.player['pricePerHour'] is double)
            ? (widget.player['pricePerHour'] as double).toInt()
            : int.tryParse(widget.player['pricePerHour'].toString().split('.').first) ?? 0;
    return pricePerHour * (totalHours > 0 ? totalHours : 1);
  }

  Future<void> _handleHire() async {
    if (totalHours <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn số giờ thuê')),
      );
      return;
    }

    if (walletBalance == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không lấy được số dư ví!')),
      );
      return;
    }

    if (totalCoin > walletBalance!) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Số dư ví không đủ')),
      );
      return;
    }

    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Không lấy được thông tin người dùng!')),
      );
      return;
    }

    setState(() { isLoading = true; });

    try {
      final result = await ApiService.hirePlayer(
        playerId: widget.player['id'] is int ? widget.player['id'] : int.tryParse(widget.player['id'].toString()) ?? 0,
        coin: totalCoin,
        startTime: selectedStartTime!,
        endTime: selectedEndTime!,
        hours: totalHours > 0 ? totalHours : 1,
        userId: userId,
        message: messageController.text.trim(),
      );
      setState(() { isLoading = false; });

      if (result != null && result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Yêu cầu thuê đã được gửi. Vui lòng chờ player xác nhận.'),
            duration: Duration(seconds: 3),
          ),
        );
        Navigator.pop(context);
      } else {
        final errorMsg = result?['message'] ?? 'Thuê player thất bại!';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMsg)),
        );
      }
    } catch (e) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thuê người chơi'),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        titleTextStyle: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.orange[100],
                    child: const Icon(Icons.person, size: 36, color: Colors.deepOrange),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.player['username'] ?? '',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(width: 6),
                            const Text('🍊', style: TextStyle(fontSize: 18)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFFFF7E5F), Color(0xFFFFB347)]),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${widget.player['pricePerHour'] ?? '0'} xu/h',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text('Số dư hiện tại', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 4),
            Text(
              walletBalance != null ? walletBalance.toString() : '...',
              style: const TextStyle(color: Colors.red, fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Tổng xu cần: $totalCoin', style: const TextStyle(fontSize: 15, color: Colors.black54)),
            const SizedBox(height: 24),
            Row(
              children: [
                const Text('Thời gian bắt đầu:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final now = DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 7)),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(minutes: 1))),
                      );
                      if (time != null) {
                        setState(() {
                          selectedStartTime = DateTime(
                            picked.year, picked.month, picked.day, time.hour, time.minute,
                          );
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(selectedStartTime == null
                      ? 'Chọn thời gian'
                      : '${selectedStartTime!.day}/${selectedStartTime!.month} ${selectedStartTime!.hour}:${selectedStartTime!.minute.toString().padLeft(2, '0')}'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Thời gian kết thúc:', style: TextStyle(fontSize: 16)),
                const SizedBox(width: 16),
                ElevatedButton(
                  onPressed: () async {
                    final now = selectedStartTime ?? DateTime.now();
                    final picked = await showDatePicker(
                      context: context,
                      initialDate: now,
                      firstDate: now,
                      lastDate: now.add(const Duration(days: 7)),
                    );
                    if (picked != null) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
                      );
                      if (time != null) {
                        setState(() {
                          selectedEndTime = DateTime(
                            picked.year, picked.month, picked.day, time.hour, time.minute,
                          );
                        });
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepOrange,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: Text(selectedEndTime == null
                      ? 'Chọn thời gian'
                      : '${selectedEndTime!.day}/${selectedEndTime!.month} ${selectedEndTime!.hour}:${selectedEndTime!.minute.toString().padLeft(2, '0')}'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Gửi tin nhắn', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: messageController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Nhập tin nhắn',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Color(0xFFF7F7F9),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepOrange,
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
                ),
                onPressed: isLoading || walletBalance == null || walletBalance! < 1 || selectedStartTime == null || selectedEndTime == null || !selectedEndTime!.isAfter(selectedStartTime!)
                    ? null
                    : _handleHire,
                child: isLoading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Thuê người chơi', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
