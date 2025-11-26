import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../data/datasources/remote/stylist_schedule_service.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class StylistScheduleScreen extends StatefulWidget {
  const StylistScheduleScreen({super.key});

  @override
  State<StylistScheduleScreen> createState() => _StylistScheduleScreenState();
}

class _StylistScheduleScreenState extends State<StylistScheduleScreen> {
  DateTime _focusedDay = DateTime.now();
  CalendarFormat _calendarFormat = CalendarFormat.month;
  Set<DateTime> _selectedDates = {};
  Set<DateTime> _scheduledDates = {};
  bool _isLoading = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _loadMySchedule();
  }

  Future<void> _loadMySchedule() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load schedule for the next 3 months
      final now = DateTime.now();
      final endDate = DateTime(now.year, now.month + 3, now.day);
      
      final schedules = await StylistScheduleService.getMySchedule(
        startDate: _formatDate(now),
        endDate: _formatDate(endDate),
      );

      // Filter các ngày đã qua
      final today = DateTime.now();
      final todayNormalized = DateTime(today.year, today.month, today.day);
      
      setState(() {
        _scheduledDates = schedules
            .map((schedule) {
              final dateStr = schedule['date'];
              if (dateStr != null) {
                return _normalizeDate(DateTime.parse(dateStr));
              }
              return null;
            })
            .whereType<DateTime>()
            .where((date) {
              // Chỉ giữ các ngày từ hôm nay trở đi
              return date.isAtSameMomentAs(todayNormalized) || date.isAfter(todayNormalized);
            })
            .toSet();
        _selectedDates = Set.from(_scheduledDates);
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải lịch làm việc: ${e.toString()}'),
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

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Normalize date to start of day for comparison
  DateTime _normalizeDate(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  Future<void> _saveSchedule() async {
    if (_selectedDates.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn ít nhất một ngày làm việc'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final dates = _selectedDates.map((date) => _formatDate(date)).toList();
      
      final result = await StylistScheduleService.createOrUpdateSchedule(
        dates: dates,
        startTime: '09:00',
        endTime: '21:00',
      );

      if (mounted) {
        if (result['success'] == true) {
          // Reload schedule
          await _loadMySchedule();
          
          final errors = result['errors'] as List?;
          if (errors != null && errors.isNotEmpty) {
            final errorMessages = errors
                .map((e) => e['error'] as String)
                .join(', ');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Đã lưu lịch làm việc. Một số ngày không thể chọn: $errorMessages'),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Đã lưu lịch làm việc thành công!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message'] ?? 'Lưu lịch làm việc thất bại'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _removeDate(DateTime date) async {
    final normalizedDate = _normalizeDate(date);
    final isScheduled = _scheduledDates.any((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate));

    // Nếu date chưa được lưu (chưa scheduled), chỉ cần remove khỏi selected dates
    if (!isScheduled) {
      setState(() {
        _selectedDates.removeWhere((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate));
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã bỏ chọn ngày'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    // Nếu date đã được lưu, cần gọi API để xóa
    setState(() {
      _isSaving = true;
    });

    try {
      // Find the schedule ID for this date
      final schedules = await StylistScheduleService.getMySchedule(
        startDate: _formatDate(date),
        endDate: _formatDate(date),
      );

      if (schedules.isNotEmpty) {
        final scheduleId = schedules.first['_id'] as String?;
        if (scheduleId != null) {
          final result = await StylistScheduleService.deleteSchedule(scheduleId);
          if (result['success'] == true) {
            setState(() {
              _selectedDates.removeWhere((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate));
              _scheduledDates.removeWhere((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate));
            });
            
            // Reload schedule để đảm bảo UI được cập nhật
            await _loadMySchedule();
            
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa ngày làm việc'),
                  backgroundColor: Colors.green,
                ),
              );
            }
          } else {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(result['message'] ?? 'Xóa ngày làm việc thất bại'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        } else {
          // Nếu không tìm thấy scheduleId, chỉ cần remove khỏi selected dates
          setState(() {
            _selectedDates.removeWhere((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate));
            _scheduledDates.removeWhere((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate));
          });
        }
      } else {
        // Nếu không tìm thấy schedule, chỉ cần remove khỏi selected dates
        setState(() {
          _selectedDates.remove(date);
          _scheduledDates.remove(date);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi xóa: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      appBar: AppBar(
        title: const Text('Lịch làm việc của tôi'),
        backgroundColor: _darkGreen,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _saveSchedule,
              tooltip: 'Lưu lịch làm việc',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(_darkGreen),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Info card
                  Card(
                    margin: const EdgeInsets.all(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.info_outline, color: _darkGreen),
                              const SizedBox(width: 8),
                              Text(
                                'Thông tin',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: _darkGreen,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chọn các ngày bạn muốn làm việc. Giờ làm việc cố định: 9:00 AM - 9:00 PM',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tối đa 3 thợ cắt tóc có thể làm việc trong một ngày.',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Colors.grey[700],
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Calendar
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    child: TableCalendar(
                      firstDay: DateTime.now(),
                      lastDay: DateTime.now().add(const Duration(days: 365)),
                      focusedDay: _focusedDay,
                      selectedDayPredicate: (day) {
                        final normalizedDay = _normalizeDate(DateTime(day.year, day.month, day.day));
                        return _selectedDates.any((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDay));
                      },
                      calendarFormat: _calendarFormat,
                      eventLoader: (day) {
                        final date = _normalizeDate(DateTime(day.year, day.month, day.day));
                        if (_scheduledDates.any((d) => _normalizeDate(d).isAtSameMomentAs(date))) {
                          return [1]; // Return non-empty list to show marker
                        }
                        return [];
                      },
                      startingDayOfWeek: StartingDayOfWeek.monday,
                      calendarStyle: CalendarStyle(
                        outsideDaysVisible: false,
                        weekendTextStyle: TextStyle(color: Colors.grey[600]),
                        selectedDecoration: BoxDecoration(
                          color: _darkGreen,
                          shape: BoxShape.circle,
                        ),
                        todayDecoration: BoxDecoration(
                          color: _darkGreen.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        markerDecoration: BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        selectedTextStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      headerStyle: HeaderStyle(
                        formatButtonVisible: true,
                        titleCentered: true,
                        formatButtonShowsNext: false,
                        formatButtonDecoration: BoxDecoration(
                          color: _darkGreen,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        formatButtonTextStyle: const TextStyle(
                          color: Colors.white,
                        ),
                      ),
                      onDaySelected: (selectedDay, focusedDay) {
                        final date = DateTime(
                          selectedDay.year,
                          selectedDay.month,
                          selectedDay.day,
                        );
                        final today = DateTime.now();

                        // Don't allow selecting past dates
                        final todayNormalized = DateTime(today.year, today.month, today.day);
                        final dateNormalized = DateTime(date.year, date.month, date.day);
                        if (dateNormalized.isBefore(todayNormalized)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không thể chọn ngày trong quá khứ'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                          return;
                        }

                        setState(() {
                          _focusedDay = focusedDay;
                          final normalizedDate = _normalizeDate(date);
                          
                          final existingDate = _selectedDates.firstWhere(
                            (d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate),
                            orElse: () => DateTime(0),
                          );
                          
                          if (existingDate.year != 0) {
                            _selectedDates.remove(existingDate);
                          } else {
                            _selectedDates.add(normalizedDate);
                          }
                        });
                      },
                      onFormatChanged: (format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      },
                      onPageChanged: (focusedDay) {
                        _focusedDay = focusedDay;
                      },
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Selected dates list - chỉ hiển thị các ngày từ hôm nay trở đi
                  Builder(
                    builder: (context) {
                      final today = DateTime.now();
                      final todayNormalized = DateTime(today.year, today.month, today.day);
                      final futureSelectedDates = _selectedDates
                          .where((date) {
                            final normalizedDate = _normalizeDate(date);
                            return normalizedDate.isAtSameMomentAs(todayNormalized) || 
                                   normalizedDate.isAfter(todayNormalized);
                          })
                          .toList();
                      
                      if (futureSelectedDates.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      
                      return Column(
                        children: [
                          Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Các ngày đã chọn (${futureSelectedDates.length})',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _darkGreen,
                                        ),
                                  ),
                                  const SizedBox(height: 12),
                                  ...(futureSelectedDates
                                    ..sort((a, b) => a.compareTo(b)))
                                    .map((date) {
                                      final normalizedDate = _normalizeDate(date);
                                      final isScheduled = _scheduledDates.any((d) => _normalizeDate(d).isAtSameMomentAs(normalizedDate));
                                      return ListTile(
                                        dense: true,
                                        contentPadding: EdgeInsets.zero,
                                        leading: Icon(
                                          Icons.calendar_today,
                                          size: 20,
                                          color: _darkGreen,
                                        ),
                                        title: Text(
                                          _formatDateDisplay(date),
                                          style: const TextStyle(fontSize: 14),
                                        ),
                                        trailing: IconButton(
                                          icon: Icon(
                                            isScheduled 
                                                ? Icons.delete_outline 
                                                : Icons.close,
                                            size: 20,
                                          ),
                                          color: Colors.red,
                                          onPressed: _isSaving 
                                              ? null 
                                              : () => _removeDate(date),
                                          tooltip: isScheduled 
                                              ? 'Xóa ngày làm việc' 
                                              : 'Bỏ chọn ngày',
                                        ),
                                      );
                                    }).toList(),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),

                  // Save button
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _saveSchedule,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _darkGreen,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'LƯU LỊCH LÀM VIỆC',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
    );
  }

  String _formatDateDisplay(DateTime date) {
    final weekdays = [
      'Chủ nhật',
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
    ];
    return '${weekdays[date.weekday % 7]}, ${date.day}/${date.month}/${date.year}';
  }
}

