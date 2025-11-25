import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/appointment.dart';
import '../services/appointment_service.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class StylistAppointmentsScreen extends StatefulWidget {
  const StylistAppointmentsScreen({super.key});

  @override
  State<StylistAppointmentsScreen> createState() =>
      _StylistAppointmentsScreenState();
}

class _StylistAppointmentsScreenState extends State<StylistAppointmentsScreen> {
  List<Appointment> _appointments = [];
  bool _isLoading = false;
  String _selectedFilter =
      'all'; // all, pending, confirmed, completed, cancelled

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  Future<void> _loadAppointments() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final appointments = await AppointmentService.getMyAppointments();
      setState(() {
        _appointments = appointments;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải lịch hẹn: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  List<Appointment> get _filteredAppointments {
    if (_selectedFilter == 'all') {
      return _appointments;
    }
    return _appointments.where((apt) {
      return apt.status.toUpperCase() == _selectedFilter.toUpperCase();
    }).toList();
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'CONFIRMED':
        return Colors.blue;
      case 'COMPLETED':
        return Colors.green;
      case 'CANCELLED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _formatDate(DateTime dateTime) {
    final dateFormat = DateFormat('dd/MM/yyyy');
    return dateFormat.format(dateTime);
  }

  String _formatTime(DateTime dateTime) {
    final timeFormat = DateFormat('HH:mm');
    return timeFormat.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Lịch hẹn của tôi'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadAppointments,
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadAppointments,
              color: _darkGreen,
              child: Column(
                children: [
                  // Filter chips
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    color: Colors.white,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip('all', 'Tất cả'),
                          const SizedBox(width: 8),
                          _buildFilterChip('pending', 'Chờ xác nhận'),
                          const SizedBox(width: 8),
                          _buildFilterChip('confirmed', 'Đã xác nhận'),
                          const SizedBox(width: 8),
                          _buildFilterChip('completed', 'Hoàn thành'),
                          const SizedBox(width: 8),
                          _buildFilterChip('cancelled', 'Đã hủy'),
                        ],
                      ),
                    ),
                  ),

                  // Appointments list
                  Expanded(
                    child: _filteredAppointments.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.event_busy,
                                  size: 64,
                                  color: Colors.grey[400],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedFilter == 'all'
                                      ? 'Chưa có lịch hẹn nào'
                                      : 'Không có lịch hẹn với trạng thái này',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: _filteredAppointments.length,
                            itemBuilder: (context, index) {
                              final appointment = _filteredAppointments[index];
                              return _buildAppointmentCard(appointment);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: _darkGreen.withOpacity(0.2),
      checkmarkColor: _darkGreen,
      labelStyle: TextStyle(
        color: isSelected ? _darkGreen : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildAppointmentCard(Appointment appointment) {
    final customer = appointment.customer;
    final customerName = customer?['fullName'] ?? 'Khách hàng';
    final customerPhone = customer?['phone'] ?? customer?['email'] ?? '';
    final service = appointment.service;
    final serviceName = service?['name'] ?? appointment.serviceNameSnapshot;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        customerName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      if (customerPhone.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.phone,
                              size: 14,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              customerPhone,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor(appointment.status).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: _getStatusColor(appointment.status),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    appointment.statusText,
                    style: TextStyle(
                      color: _getStatusColor(appointment.status),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),

            const Divider(height: 24),

            // Service info
            Row(
              children: [
                Icon(Icons.content_cut, size: 20, color: _darkGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    serviceName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  appointment.formattedPrice,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: _darkGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Date and time
            Row(
              children: [
                Icon(Icons.calendar_today, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  _formatDate(appointment.startAt),
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
                const SizedBox(width: 16),
                Icon(Icons.access_time, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  '${_formatTime(appointment.startAt)} - ${_formatTime(appointment.endAt)}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                ),
              ],
            ),

            // Note if exists
            if (appointment.note != null && appointment.note!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.note, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        appointment.note!,
                        style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action buttons
            if (appointment.status.toUpperCase() == 'PENDING' ||
                appointment.status.toUpperCase() == 'CONFIRMED') ...[
              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (appointment.status.toUpperCase() == 'PENDING') ...[
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(appointment, 'CONFIRMED'),
                      icon: const Icon(Icons.check, size: 18),
                      label: const Text('Xác nhận'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (appointment.status.toUpperCase() == 'CONFIRMED') ...[
                    ElevatedButton.icon(
                      onPressed: () => _updateStatus(appointment, 'COMPLETED'),
                      icon: const Icon(Icons.check_circle, size: 18),
                      label: const Text('Hoàn thành'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  OutlinedButton.icon(
                    onPressed: () => _cancelAppointment(appointment),
                    icon: const Icon(Icons.close, size: 18),
                    label: const Text('Hủy'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(Appointment appointment, String newStatus) async {
    final actionText = newStatus == 'CONFIRMED'
        ? 'xác nhận'
        : newStatus == 'COMPLETED'
        ? 'đánh dấu hoàn thành'
        : 'cập nhật trạng thái';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận'),
        content: Text('Bạn có chắc chắn muốn $actionText lịch hẹn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: _darkGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Xác nhận'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await AppointmentService.updateStatus(
        appointment.id,
        newStatus,
      );

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newStatus == 'CONFIRMED'
                  ? 'Đã xác nhận lịch hẹn'
                  : 'Đã đánh dấu hoàn thành',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Reload appointments
        await _loadAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Cập nhật thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _cancelAppointment(Appointment appointment) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hủy lịch hẹn'),
        content: const Text('Bạn có chắc chắn muốn hủy lịch hẹn này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Không'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hủy lịch'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    // Show loading
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final result = await AppointmentService.cancelAppointment(appointment.id);

      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã hủy lịch hẹn'),
            backgroundColor: Colors.orange,
          ),
        );
        // Reload appointments
        await _loadAppointments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Hủy lịch hẹn thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
