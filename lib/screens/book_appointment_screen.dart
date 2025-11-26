import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/service.dart';
import '../models/stylist.dart';
import '../providers/stylist_provider.dart';
import '../providers/appointment_provider.dart';
import '../services/availability_service.dart';
import '../services/stylist_schedule_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'home_screen.dart';

// Color scheme matching the design
const Color _darkGreen = Color(0xFF2D5016);
const Color _lightBeige = Color(0xFFF5E6D3);

class BookAppointmentScreen extends StatefulWidget {
  final Service service;
  final Stylist? stylist; // Optional stylist parameter

  const BookAppointmentScreen({super.key, required this.service, this.stylist});

  @override
  State<BookAppointmentScreen> createState() => _BookAppointmentScreenState();
}

class _BookAppointmentScreenState extends State<BookAppointmentScreen> {
  Stylist? _selectedStylist;
  // Sử dụng local date (không có time, chỉ có year, month, day)
  late DateTime _selectedDate;
  String? _selectedTimeSlot;
  List<String> _availableSlots = [];
  bool _isLoadingSlots = false;
  Set<String> _availableStylistIds = {}; // IDs của các stylists có schedule vào ngày được chọn
  bool _isLoadingStylists = false;

  // Tất cả các time slots có thể có (như trong hình)
  final List<String> _allTimeSlots = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
    '06:00 PM',
    '07:00 PM',
    '08:00 PM',
    '09:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    // Khởi tạo _selectedDate với local date (không có time)
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day);
    _selectedStylist = widget.stylist;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final stylistProvider = Provider.of<StylistProvider>(
        context,
        listen: false,
      );
      stylistProvider.loadStylists();
      _loadAvailableStylistsForDate(_selectedDate);
      if (_selectedStylist == null && stylistProvider.stylists.isNotEmpty) {
        // Sẽ set sau khi load available stylists
      }
      _loadAvailableSlots();
    });
  }

  Future<void> _loadAvailableStylistsForDate(DateTime date) async {
    setState(() {
      _isLoadingStylists = true;
    });

    try {
      // Format date string sử dụng local date (không bị ảnh hưởng bởi timezone)
      // Đảm bảo sử dụng year, month, day từ local DateTime
      final localDate = DateTime(date.year, date.month, date.day);
      final dateStr = '${localDate.year}-${localDate.month.toString().padLeft(2, '0')}-${localDate.day.toString().padLeft(2, '0')}';
      final schedules = await StylistScheduleService.getSchedulesByDate(dateStr);
      
      print('📅 Loading schedules for date: $dateStr');
      print('📋 Schedules received: ${schedules.length}');
      
      // Lấy danh sách stylist IDs có schedule vào ngày này
      final availableIds = <String>{};
      
      for (final schedule in schedules) {
        final stylistId = schedule['stylistId'];
        String? id;
        
        print('🔍 Processing schedule: ${schedule['_id']}, stylistId type: ${stylistId.runtimeType}');
        print('🔍 stylistId value: $stylistId');
        
        if (stylistId is Map) {
          // Nếu stylistId là object đã populate
          id = stylistId['_id']?.toString();
          if (id == null) {
            // Thử lấy từ 'id' nếu không có '_id'
            id = stylistId['id']?.toString();
          }
        } else if (stylistId is String) {
          // Nếu stylistId là string
          id = stylistId;
        }
        
        if (id != null && id.isNotEmpty) {
          availableIds.add(id);
          print('✅ Found stylist ID: $id');
        } else {
          print('⚠️ Invalid stylistId in schedule: $stylistId (type: ${stylistId.runtimeType})');
        }
      }
      
      print('📊 Available stylist IDs: $availableIds');

      if (mounted) {
        final stylistProvider = Provider.of<StylistProvider>(
          context,
          listen: false,
        );
        
        print('📋 All stylists in provider: ${stylistProvider.stylists.map((s) => s.id).toList()}');
        
        // Kiểm tra xem có stylist nào match không
        // Normalize IDs để so sánh (loại bỏ khoảng trắng, chuyển về lowercase)
        final normalizedAvailableIds = availableIds.map((id) => id.trim().toLowerCase()).toSet();
        final matchingStylists = stylistProvider.stylists
            .where((s) {
              final normalizedId = s.id.trim().toLowerCase();
              final matches = normalizedAvailableIds.contains(normalizedId);
              if (!matches) {
                print('❌ Stylist ${s.fullName} (ID: ${s.id}) not in available IDs');
              }
              return matches;
            })
            .toList();
        
        print('🎯 Matching stylists: ${matchingStylists.map((s) => s.fullName).toList()}');
        
        setState(() {
          _availableStylistIds = availableIds;
          _isLoadingStylists = false;
        });

        // Nếu selected stylist không có trong danh sách available, chọn stylist đầu tiên có schedule
        final normalizedSelectedId = _selectedStylist?.id.trim().toLowerCase();
        final isSelectedStylistAvailable = normalizedSelectedId != null && 
            normalizedAvailableIds.contains(normalizedSelectedId);
        
        if (_selectedStylist == null || !isSelectedStylistAvailable) {
          if (matchingStylists.isNotEmpty) {
            setState(() {
              _selectedStylist = matchingStylists.first;
            });
            _loadAvailableSlots();
          } else {
            setState(() {
              _selectedStylist = null;
            });
          }
        }
      }
    } catch (e, stackTrace) {
      print('❌ Error loading available stylists: $e');
      print('Stack trace: $stackTrace');
      if (mounted) {
        setState(() {
          _isLoadingStylists = false;
        });
      }
    }
  }

  Future<void> _loadAvailableSlots() async {
    if (_selectedStylist == null) {
      setState(() {
        _availableSlots = [];
        _selectedTimeSlot = null;
      });
      return;
    }

    setState(() {
      _isLoadingSlots = true;
      _selectedTimeSlot = null; // Reset selected time when loading new slots
    });

    try {
      final slots = await AvailabilityService.getAvailableSlots(
        stylistId: _selectedStylist!.id,
        serviceId: widget.service.id,
        date: _selectedDate,
      );

      print('Raw slots from API: $slots');

      // Convert "HH:mm" format to "HH:MM AM/PM" format
      final formattedSlots = slots
          .map((slot) {
            final parts = slot.split(':');
            if (parts.length != 2) {
              print('Invalid slot format: $slot');
              return null;
            }
            final hour = int.parse(parts[0]);
            final minute = parts[1];
            final period = hour >= 12 ? 'PM' : 'AM';
            final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
            final formatted =
                '${displayHour.toString().padLeft(2, '0')}:$minute $period';
            return formatted;
          })
          .whereType<String>()
          .toList();

      print('Formatted slots: $formattedSlots');
      print('All time slots: $_allTimeSlots');
      print(
        'Matching slots: ${formattedSlots.where((s) => _allTimeSlots.contains(s)).toList()}',
      );

      if (mounted) {
        setState(() {
          _availableSlots = formattedSlots;
          _isLoadingSlots = false;
        });
      }
    } catch (e) {
      print('Error loading available slots: $e');
      if (mounted) {
        setState(() {
          _availableSlots = [];
          _isLoadingSlots = false;
        });
      }
    }
  }

  Future<void> _submitBooking() async {
    if (_selectedStylist == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn thợ cắt tóc')),
      );
      return;
    }

    if (_selectedTimeSlot == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Vui lòng chọn giờ')));
      return;
    }

    final appointmentProvider = Provider.of<AppointmentProvider>(
      context,
      listen: false,
    );

    // Parse time slot
    final timeParts = _selectedTimeSlot!.split(' ');
    final timeStr = timeParts[0];
    final period = timeParts[1];
    final hourMin = timeStr.split(':');
    int hour = int.parse(hourMin[0]);
    final minute = int.parse(hourMin[1]);

    if (period == 'PM' && hour != 12) {
      hour += 12;
    } else if (period == 'AM' && hour == 12) {
      hour = 0;
    }

    final startAt = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      hour,
      minute,
    );

    // Check if selected time is in the past
    if (startAt.isBefore(DateTime.now())) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn thời gian trong tương lai'),
        ),
      );
      return;
    }

    final success = await appointmentProvider.createAppointment(
      serviceId: widget.service.id,
      stylistId: _selectedStylist!.id,
      startAt: startAt,
      note: null,
    );

    if (success && mounted) {
      // Reload appointments to show the new one
      await appointmentProvider.loadMyAppointments();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đặt lịch thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop all routes until we reach HomeScreen, then navigate to HomeScreen with appointments tab selected
      Navigator.of(context).popUntil((route) => route.isFirst);
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const HomeScreen(
            initialTabIndex: 3,
          ), // 3 is the appointments tab index
        ),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appointmentProvider.errorMessage ?? 'Đặt lịch thất bại',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _lightBeige,
      body: SafeArea(
        child: Column(
          children: [
            // Top Section - Dark Green Header
            _HeaderSection(
              stylist: _selectedStylist,
              selectedDate: _selectedDate,
              availableStylistIds: _availableStylistIds,
              isLoadingStylists: _isLoadingStylists,
              onDateSelected: (date) {
                // Normalize date để đảm bảo không có time component
                final normalizedDate = DateTime(date.year, date.month, date.day);
                setState(() {
                  _selectedDate = normalizedDate;
                  _selectedTimeSlot = null; // Reset time when date changes
                });
                _loadAvailableStylistsForDate(normalizedDate);
                _loadAvailableSlots();
              },
              onStylistChanged: (stylist) {
                setState(() {
                  _selectedStylist = stylist;
                  _selectedTimeSlot = null;
                });
                _loadAvailableSlots();
              },
              onBack: () => Navigator.of(context).pop(),
            ),

            // Bottom Section - Light Beige with Time Selection
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        'CHOOSE YOUR TIME',
                        style: TextStyle(
                          color: _darkGreen,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: _isLoadingSlots
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(32.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    _darkGreen,
                                  ),
                                ),
                              ),
                            )
                          : _TimeSlotGrid(
                              timeSlots: _allTimeSlots,
                              availableSlots: _availableSlots,
                              selectedTimeSlot: _selectedTimeSlot,
                              onTimeSelected: (timeSlot) {
                                print('Time slot selected: $timeSlot');
                                setState(() {
                                  _selectedTimeSlot = timeSlot;
                                });
                              },
                            ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // BOOK NOW Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: _lightBeige,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Consumer<AppointmentProvider>(
                builder: (context, appointmentProvider, _) {
                  return ElevatedButton(
                    onPressed: appointmentProvider.isLoading
                        ? null
                        : _submitBooking,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _darkGreen,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: appointmentProvider.isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                        : const Text(
                            'BOOK NOW',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  final Stylist? stylist;
  final DateTime selectedDate;
  final Set<String> availableStylistIds;
  final bool isLoadingStylists;
  final Function(DateTime) onDateSelected;
  final Function(Stylist)? onStylistChanged;
  final VoidCallback onBack;

  const _HeaderSection({
    required this.stylist,
    required this.selectedDate,
    required this.availableStylistIds,
    required this.isLoadingStylists,
    required this.onDateSelected,
    this.onStylistChanged,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final dateOptions = _getDateOptions();

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(color: _darkGreen),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Back button
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: IconButton(
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            ),
          ),

          // Stylist info
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            child: Row(
              children: [
                // Profile picture
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: _lightBeige, width: 3),
                    color: Colors.white,
                  ),
                  child: ClipOval(
                    child: stylist?.avatarUrl != null
                        ? CachedNetworkImage(
                            imageUrl: stylist!.avatarUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _darkGreen,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.person,
                              size: 40,
                              color: _darkGreen,
                            ),
                          )
                        : const Icon(Icons.person, size: 40, color: _darkGreen),
                  ),
                ),
                const SizedBox(width: 16),
                // Name and profession
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stylist?.fullName.toUpperCase() ?? 'SELECT STYLIST',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Barberman',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                // Stylist selector button
                if (onStylistChanged != null)
                  IconButton(
                    onPressed: () => _showStylistSelector(context),
                    icon: const Icon(Icons.swap_horiz, color: Colors.white),
                    tooltip: 'Chọn thợ khác',
                  ),
              ],
            ),
          ),

          // CHOOSE YOUR SLOT heading
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Text(
              'CHOOSE YOUR SLOT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),

          // Date selection horizontal scroll
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: dateOptions.length,
              itemBuilder: (context, index) {
                final date = dateOptions[index];
                final isSelected =
                    date.year == selectedDate.year &&
                    date.month == selectedDate.month &&
                    date.day == selectedDate.day;

                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: InkWell(
                    onTap: () => onDateSelected(date),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? _lightBeige : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white, width: 1),
                      ),
                      child: Center(
                        child: Text(
                          _formatDateShort(date),
                          style: TextStyle(
                            color: isSelected ? _darkGreen : Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  List<DateTime> _getDateOptions() {
    final dates = <DateTime>[];
    // Sử dụng local date (không bị ảnh hưởng bởi timezone)
    final today = DateTime.now();
    final todayLocal = DateTime(today.year, today.month, today.day);
    for (int i = 0; i < 14; i++) {
      dates.add(DateTime(todayLocal.year, todayLocal.month, todayLocal.day + i));
    }
    return dates;
  }

  String _formatDateShort(DateTime date) {
    // Format weekday manually to avoid locale initialization
    final weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final weekday = weekdays[date.weekday - 1];
    final day = date.day;
    return '$weekday $day';
  }

  void _showStylistSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Consumer<StylistProvider>(
        builder: (context, stylistProvider, _) {
          // Chỉ hiển thị những stylists có schedule vào ngày được chọn
          // Normalize IDs để so sánh
          final normalizedAvailableIds = availableStylistIds.map((id) => id.trim().toLowerCase()).toSet();
          final availableStylists = stylistProvider.stylists
              .where((s) => normalizedAvailableIds.contains(s.id.trim().toLowerCase()))
              .toList();
          
          return Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Chọn thợ cắt tóc',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                if (isLoadingStylists)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (availableStylists.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text(
                      'Không có thợ cắt tóc nào có lịch làm việc vào ngày này',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                else ...[
                  Text(
                    'Có ${availableStylists.length} thợ cắt tóc có lịch làm việc',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...availableStylists.map(
                    (s) => ListTile(
                      leading: CircleAvatar(
                        backgroundImage: s.avatarUrl != null
                            ? NetworkImage(s.avatarUrl!)
                            : null,
                        child: s.avatarUrl == null
                            ? const Icon(Icons.person)
                            : null,
                      ),
                      title: Text(s.fullName),
                      subtitle: Text('Rating: ${s.ratingAvg.toStringAsFixed(1)}'),
                      selected: stylist?.id == s.id,
                      onTap: () {
                        onStylistChanged?.call(s);
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TimeSlotGrid extends StatelessWidget {
  final List<String> timeSlots;
  final List<String> availableSlots;
  final String? selectedTimeSlot;
  final Function(String) onTimeSelected;

  const _TimeSlotGrid({
    required this.timeSlots,
    required this.availableSlots,
    required this.selectedTimeSlot,
    required this.onTimeSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.5,
      ),
      itemCount: timeSlots.length,
      itemBuilder: (context, index) {
        final timeSlot = timeSlots[index];
        final isSelected = selectedTimeSlot == timeSlot;

        return GestureDetector(
          onTap: () {
            print('Time slot tapped: $timeSlot');
            onTimeSelected(timeSlot);
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? _darkGreen : Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _darkGreen, width: 1),
            ),
            child: Center(
              child: Text(
                timeSlot,
                style: TextStyle(
                  color: isSelected ? Colors.white : _darkGreen,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
