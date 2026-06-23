import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/news/domain/models/news_digest_item.dart';

const todayDigestItems = [
  NewsDigestItem(
    title: '本週課務重點',
    description: '優先確認選課、加退選與期中預警時程，避免集中在截止前處理。',
    icon: Icons.event_available,
    color: Color(0xFF4A90D9),
  ),
  NewsDigestItem(
    title: '校務入口整理',
    description: '常用入口已整合到首頁快速功能與 Portal 搜尋，降低跳轉成本。',
    icon: Icons.dashboard_customize_outlined,
    color: Color(0xFF66BB6A),
  ),
  NewsDigestItem(
    title: '獎助資訊提醒',
    description: '獎學金與工讀職缺公告建議每天檢查一次，避免錯過申請窗口。',
    icon: Icons.campaign_outlined,
    color: Color(0xFFFF9800),
  ),
];
