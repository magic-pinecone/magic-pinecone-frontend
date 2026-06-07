import 'package:flutter/material.dart';
import 'package:magic_pinecone/features/portal/models/portal_shortcut.dart';

List<PortalShortcutSection> get defaultPortalShortcutSections => [
  PortalShortcutSection(
    title: '常用服務',
    items: [
      _directWebShortcut(
        '新ee-class',
        Icons.book,
        Uri.parse('https://ncueeclass.ncu.edu.tw/'),
      ),
      _directWebShortcut(
        '選課系統',
        Icons.event,
        Uri.parse('https://cis.ncu.edu.tw/Course/'),
      ),
      _portalSystemShortcut('服務櫃台', Icons.support_agent, '/system/incu'),
      _portalSystemShortcut('NCU Mail', Icons.mail, '/system/129'),
      _portalSystemShortcut('成績查詢', Icons.grading, '/system/incu-studentscore'),
      _portalSystemShortcut('人事系統', Icons.badge, '/system/humanoauth'),
      _portalSystemShortcut(
        '圖書館服務平台',
        Icons.local_library,
        '/system/library-cloud-services',
      ),
      _portalSystemShortcut('宿舍網路系統', Icons.wifi, '/system/dormnet'),
    ],
  ),
  PortalShortcutSection(
    title: '課務相關',
    items: [
      _directWebShortcut(
        '新ee-class',
        Icons.book,
        Uri.parse('https://ncueeclass.ncu.edu.tw/'),
      ),
      _directWebShortcut(
        '選課系統',
        Icons.event,
        Uri.parse('https://cis.ncu.edu.tw/Course/'),
      ),
      _portalSystemShortcut('成績查詢', Icons.grading, '/system/incu-studentscore'),
      _portalSystemShortcut(
        '期中預警查詢',
        Icons.warning_amber_rounded,
        '/system/incu-ewarningstudent',
      ),
    ],
  ),
  PortalShortcutSection(
    title: '學務相關',
    items: [
      _portalSystemShortcut('學生證掛失', Icons.credit_card_off, '/system/32'),
      _portalSystemShortcut(
        '學籍系統',
        Icons.account_balance,
        '/system/incu-registrationflow',
      ),
      _portalSystemShortcut('畢業資格審查', Icons.school, '/system/incu-graduate-2'),
      _portalSystemShortcut('學費繳費證明', Icons.receipt_long, '/system/tuition'),
    ],
  ),
  PortalShortcutSection(
    title: '可利用資源',
    items: [
      _portalSystemShortcut(
        '個別諮商',
        Icons.volunteer_activism,
        '/system/consult',
      ),
      _portalSystemShortcut(
        '圖書館服務平台',
        Icons.local_library,
        '/system/library-cloud-services',
      ),
    ],
  ),
  PortalShortcutSection(
    title: '電算中心',
    items: [
      _portalSystemShortcut('宿舍網路', Icons.router, '/system/dormnet'),
      _portalSystemShortcut('客服中心', Icons.headset_mic, '/system/sdsystem'),
      _portalSystemShortcut(
        'Office365',
        Icons.workspaces_outline,
        '/system/office365',
      ),
      _portalSystemShortcut('G Suite', Icons.apps, '/system/gsuite'),
    ],
  ),
  PortalShortcutSection(
    title: '財務相關',
    items: [
      _portalSystemShortcut('學費繳費單', Icons.request_quote, '/system/82'),
      _portalSystemShortcut('學費繳費證明', Icons.receipt_long, '/system/tuition'),
      _portalSystemShortcut('人事系統', Icons.badge, '/system/humanoauth'),
      _portalSystemShortcut(
        '獎助學金暨工讀管理系統',
        Icons.workspace_premium,
        '/system/134',
      ),
      _portalSystemShortcut('就學補助系統', Icons.savings, '/system/42'),
      _portalSystemShortcut('撥帳系統', Icons.account_balance_wallet, '/system/46'),
    ],
  ),
];

PortalShortcutItem _portalSystemShortcut(
  String label,
  IconData icon,
  String path,
) {
  return PortalShortcutItem(
    label: label,
    icon: icon,
    destination: PortalWebShortcutDestination(
      title: label,
      targetPath: path,
      authEntryUrl: Uri(scheme: 'https', host: portalHost),
      sessionProbeHosts: const {portalHost},
    ),
  );
}

PortalShortcutItem _directWebShortcut(String label, IconData icon, Uri url) {
  return PortalShortcutItem(
    label: label,
    icon: icon,
    destination: PortalWebShortcutDestination(
      title: label,
      targetUrl: url,
      openExternally: true,
    ),
  );
}
