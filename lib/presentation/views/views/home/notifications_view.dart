import 'package:flutter/material.dart';
import 'package:ztajir_furniture/core/constants/app_colors.dart';
import 'package:ztajir_furniture/core/localization/app_localizations.dart';
import 'package:ztajir_furniture/presentation/views/widgets/AppBar/static_app_bar.dart';
import 'package:ztajir_furniture/core/utiles/size_config.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  late List<Map<String, dynamic>> _notifications;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    var loc = AppLocalizations.of(context)!;
    _notifications = [
      {
        "id": "1",
        "title": loc.translate('notification_promo'),
        "body": loc.translate('notification_promo_desc'),
        "time": "منذ دقيقتين",
        "isRead": false,
        "icon": Icons.local_offer_rounded,
        "color": AppColors.greenColor,
      },
      {
        "id": "2",
        "title": loc.translate('notification_order_shipped'),
        "body": loc.translate('notification_order_shipped_desc'),
        "time": "منذ ساعة",
        "isRead": false,
        "icon": Icons.local_shipping_rounded,
        "color": AppColors.primaryColor,
      },
      {
        "id": "3",
        "title": loc.translate('notification_system'),
        "body": loc.translate('notification_system_desc'),
        "time": "منذ يوم",
        "isRead": true,
        "icon": Icons.info_outline_rounded,
        "color": const Color(0xFF2196F3),
      },
    ];
  }

  void _deleteNotification(String id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n['isRead'] = true;
      }
    });
  }

  int get _unreadCount => _notifications.where((n) => !n['isRead']).length;

  @override
  Widget build(BuildContext context) {
    var loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColors.secondaryColor,
      appBar: StaticAppBar(
        appBarName: loc.translate('notifications_title'),
        actions: [
          if (_unreadCount > 0)
            TextButton(
              onPressed: _markAllAsRead,
              child: Text(
                loc.translate('mark_all_read'),
                style: TextStyle(color: AppColors.whiteColor, fontSize: 12.sp),
              ),
            ),
        ],
      ),
      body: _notifications.isEmpty
          ? _buildEmptyState(loc)
          : ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(16.w),
              itemCount: _notifications.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                final item = _notifications[index];
                return _NotificationCard(
                  title: item['title'],
                  body: item['body'],
                  time: item['time'],
                  isRead: item['isRead'],
                  icon: item['icon'],
                  color: item['color'],
                  onDelete: () => _deleteNotification(item['id']),
                  onTap: () {
                    setState(() {
                      item['isRead'] = true;
                    });
                  },
                );
              },
            ),
    );
  }

  Widget _buildEmptyState(AppLocalizations loc) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_outlined,
              size: 60.w,
              color: AppColors.primaryColor.withOpacity(0.5),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            loc.translate('no_notifications'),
            style: TextStyle(
              color: AppColors.darkGreyColor,
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final String title;
  final String body;
  final String time;
  final bool isRead;
  final IconData icon;
  final Color color;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.title,
    required this.body,
    required this.time,
    required this.isRead,
    required this.icon,
    required this.color,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.whiteColor,
          borderRadius: BorderRadius.circular(16.w),
          border: !isRead
              ? Border.all(color: color.withOpacity(0.4), width: 1.5.w)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10.w,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(14.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // الأيقونة
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12.w),
                ),
                child: Icon(icon, color: color, size: 24.w),
              ),
              SizedBox(width: 12.w),

              // المحتوى
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (!isRead)
                          Container(
                            width: 8.w,
                            height: 8.h,
                            margin: EdgeInsets.only(left: 6.w),
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                            ),
                          ),
                        Expanded(
                          child: Text(
                            title,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: isRead
                                  ? FontWeight.w500
                                  : FontWeight.bold,
                              color: AppColors.textColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      body,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: AppColors.darkGreyColor,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      time,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: AppColors.darkGreyColor,
                      ),
                    ),
                  ],
                ),
              ),

              // زر الحذف
              InkWell(
                onTap: onDelete,
                borderRadius: BorderRadius.circular(10.w),
                child: Container(
                  padding: EdgeInsets.all(8.w),
                  decoration: BoxDecoration(
                    color: AppColors.redColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 16.w,
                    color: AppColors.redColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
