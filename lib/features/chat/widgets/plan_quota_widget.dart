import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tgm_ai_chat/core/services/plan_enforcement_service.dart';
import 'package:provider/provider.dart';
import 'package:tgm_ai_chat/features/chat/providers/chat_provider.dart';

/// Widget pour afficher le quota de messages de l'utilisateur
class PlanQuotaWidget extends StatefulWidget {
  final String userId;
  
  const PlanQuotaWidget({
    super.key,
    required this.userId,
  });

  @override
  State<PlanQuotaWidget> createState() => _PlanQuotaWidgetState();
}

class _PlanQuotaWidgetState extends State<PlanQuotaWidget> {
  final PlanEnforcementService _planService = PlanEnforcementService();
  UserPlanInfo? _planInfo;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.addListener(_onChatProviderChanged);
      _loadPlanInfo();
    });
  }

  @override
  void dispose() {
    try {
      final chatProvider = context.read<ChatProvider>();
      chatProvider.removeListener(_onChatProviderChanged);
    } catch (e) {
      // Ignorer si le provider n'est plus disponible
    }
    super.dispose();
  }

  void _onChatProviderChanged() {
    if (mounted) {
      _loadPlanInfo();
    }
  }

  Future<void> _loadPlanInfo() async {
    final info = await _planService.getUserPlanInfo(widget.userId);
    if (mounted) {
      setState(() {
        _planInfo = info;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return SizedBox(
        height: 40.h,
        child: Center(
          child: SizedBox(
            width: 16.w,
            height: 16.h,
            child: const CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }

    if (_planInfo == null) {
      return const SizedBox.shrink();
    }

    // Affichage pour les plans illimités
    if (_planInfo!.isUnlimited) {
      // 🆕 Détection du plan Free Illimité
      final isPlanFreeUnlimited = _planInfo!.planName.contains('Free') && 
                                  _planInfo!.planName.contains('Illimité');
      
      return Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          border: Border(
            bottom: BorderSide(color: Colors.green.shade200, width: 1),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green.shade700, size: 16.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                // 🆕 Affichage optimisé pour Free Illimité
                isPlanFreeUnlimited 
                    ? 'Plan ${_planInfo!.planName}' // "Plan Free Illimité" (sans redondance)
                    : 'Plan ${_planInfo!.planName} - Messages Illimités',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.green.shade700,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Affichage pour les plans avec quota
    final usagePercentage = _planInfo!.usagePercentage;
    final isNearLimit = usagePercentage >= 80;
    final isAtLimit = _planInfo!.hasReachedLimit;

    Color statusColor = Colors.green.shade600;
    if (isAtLimit) {
      statusColor = Colors.red.shade600;
    } else if (isNearLimit) {
      statusColor = Colors.orange.shade600;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: isAtLimit 
            ? Colors.red.shade50 
            : isNearLimit 
                ? Colors.orange.shade50 
                : Colors.blue.shade50,
        border: Border(
          bottom: BorderSide(
            color: isAtLimit 
                ? Colors.red.shade200 
                : isNearLimit 
                    ? Colors.orange.shade200 
                    : Colors.blue.shade200,
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isAtLimit ? Icons.block : Icons.chat_bubble_outline,
                color: statusColor,
                size: 16.sp,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'Plan ${_planInfo!.planName}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              if (isNearLimit || isAtLimit)
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/plans');
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Mettre à niveau',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_planInfo!.messageCount} / ${_planInfo!.messageQuota} messages',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                        Text(
                          '${usagePercentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.h),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4.r),
                      child: LinearProgressIndicator(
                        value: usagePercentage / 100,
                        backgroundColor: Colors.grey.shade300,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                        minHeight: 6.h,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (isAtLimit)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'Vous avez atteint votre limite mensuelle. Passez au plan Individuel pour des messages illimités.',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.red.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
        ],
      ),
    );
  }
}