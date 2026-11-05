# 数字生活系统实际测试报告 — 2026-11-05

环境：Windows、Godot 4.7.2、OpenGL Compatibility。以下均为实际启动引擎执行结果，不以文件存在替代测试。

复现命令：`& D:\Godot_v4.7.2-stable_win64_console.exe --path . --script res://scripts/<测试名>.gd --log-file artifacts/digital_systems/<测试名>.log`。UI相关脚本使用图形运行；测试使用独立测试存档，不覆盖玩家正式存档。

| 测试 | PASS | 错误/警告 |
|---|---:|---:|
| messaging_core_test | 24 | 0 |
| messaging_ui_test | 8 | 0 |
| messaging_integration_test | 30 | 0 |
| messaging_reload_test | 1 | 0 |
| ch01_qa_test | 225 | 0 |
| ch01_alternate_qa | 209 | 0 |
| ch01_edge_test | 36 | 0 |
| ch01_reload_qa | 1 | 0 |
| night_system_test | 50 | 0 |
| night_reload_test | 17 | 0 |
| round2_smoke | 29 | 0 |
| cruise_boundary_test | 19 | 0 |
| ch01_opening_test | 13 | 0 |
| ch01_walk_qa | 223 | 0 |
| ch01_visual_qa | 13 | 0 |

合计898 PASS；包含截图保存、重复分支断言，不代表898个不同功能或测试覆盖率。最终15份日志没有FAIL、SCRIPT ERROR、ERROR、WARNING。旧诊断日志不作为最终通过记录。

## 已验证
- 稳定ID、防重复、未来消息隐藏、条件过滤；UI秒数不改变游戏分钟；预设回复真实按钮点击；输入状态、历史与左右气泡。
- 关闭窗口后继续送达，隐藏窗口不已读；手机/电脑消息顺序、已读、未读同步；HUD即时刷新；通知实际挂载。
- 新闻逐阶段发布且独立已读，来电接听防重；旧存档迁移、非法快照拒绝、剩余演出倒计时恢复、独立进程读档。
- 原第一章主线/分支/实际步行交互脚本、配送巡航边界、旧夜间应用回归。

## 视觉检查
artifacts/digital_systems/01_live_group.png 至09_world_notification.png均为运行时viewport PNG，已逐张送入模型视觉上下文检查。中文、昵称、气泡、按钮、滚动、电话、通知与两端布局可见；修复滚动/通知/身份提示后重新运行截图。既有artifacts/ch01_qa截图由回归更新，未声称本轮逐张美术复验。提示音调用已运行，但没有主观听感验收。

## 缺陷修复记录及限制
初期发现通知toast挂载语句被误置lambda返回后，造成未挂载节点与退出泄漏；已修复并重新跑最终回归。另修复新闻read递归、HUD滞后与显示排序。
macOS、真人从头盲玩、长时压力、听感未验证。此处测试不等同第一章正式美术完成或用户最终验收。

## 查看
F6运行scenes/messaging_test.tscn：等待逐条聊天、选择回复、滚动历史。F5主游戏按既有第一章流程回家，手机消息/电脑消息共享历史；完成该段阅读及回复后关闭应用继续剧情。接听来电通过手机接听按钮。无需调试跳转。

## 本轮新增和修改文件清单

以交接基线920c606为比较点；无删除。代码/配置用于统一数据与接入，测试用于回归，文档用于接口/状态追溯，PNG与日志为实际运行证据，UID为Godot资源标识。

- `.gitignore`
- `CHANGELOG.md`
- `DEV_LOG.md`
- `ROADMAP.md`
- `RUN_PROTOTYPE.md`
- `artifacts/ch01_qa/01_street.png`
- `artifacts/ch01_qa/02_garden.png`
- `artifacts/ch01_qa/03_hallway.png`
- `artifacts/ch01_qa/04_elevator.png`
- `artifacts/ch01_qa/05_store_before.png`
- `artifacts/ch01_qa/06_attack.png`
- `artifacts/ch01_qa/07_store_after.png`
- `artifacts/ch01_qa/08_home.png`
- `artifacts/ch01_qa/09_knock.png`
- `artifacts/ch01_qa/10_reveal.png`
- `artifacts/ch01_qa/11_ending.png`
- `artifacts/ch01_qa/12_desktop_chat.png`
- `artifacts/ch01_qa/13_desktop_news.png`
- `artifacts/ch01_qa/14_attack_choices.png`
- `artifacts/ch01_qa/15_final_choices.png`
- `artifacts/ch01_qa/16_phone_call.png`
- `artifacts/ch01_qa/17_second_knock.png`
- `artifacts/ch01_qa/18_scaled_960.png`
- `artifacts/ch01_qa/19_alternate_ending.png`
- `artifacts/ch01_qa/20_phone_chat.png`
- `artifacts/ch01_qa/21_phone_news.png`
- `artifacts/ch01_qa/22_phone_orders.png`
- `artifacts/ch01_qa/23_phone_map.png`
- `artifacts/ch01_qa/24_phone_inventory.png`
- `artifacts/ch01_qa/25_home_1080p.png`
- `artifacts/digital_systems/01_live_group.png`
- `artifacts/digital_systems/02_reply.png`
- `artifacts/digital_systems/03_bubbles.png`
- `artifacts/digital_systems/04_phone_live.png`
- `artifacts/digital_systems/05_desktop_live.png`
- `artifacts/digital_systems/06_private_message.png`
- `artifacts/digital_systems/07_phone_news.png`
- `artifacts/digital_systems/08_phone_call.png`
- `artifacts/digital_systems/09_world_notification.png`
- `artifacts/digital_systems/ch01_alternate_qa.log`
- `artifacts/digital_systems/ch01_edge_test.log`
- `artifacts/digital_systems/ch01_opening_test.log`
- `artifacts/digital_systems/ch01_qa_test.log`
- `artifacts/digital_systems/ch01_reload_qa.log`
- `artifacts/digital_systems/ch01_visual_qa.log`
- `artifacts/digital_systems/ch01_walk_qa.log`
- `artifacts/digital_systems/core.log`
- `artifacts/digital_systems/cruise_boundary_test.log`
- `artifacts/digital_systems/import.log`
- `artifacts/digital_systems/messaging_core_test.log`
- `artifacts/digital_systems/messaging_integration_test.log`
- `artifacts/digital_systems/messaging_reload_test.log`
- `artifacts/digital_systems/messaging_ui_test.log`
- `artifacts/digital_systems/night_reload_test.log`
- `artifacts/digital_systems/night_system_test.log`
- `artifacts/digital_systems/round2_smoke.log`
- `artifacts/digital_systems/test_summary.json`
- `artifacts/digital_systems/ui.log`
- `data/digital_timeline.json`
- `data/messaging.json`
- `docs/AGENT_INTEGRATION_CONTRACT.md`
- `docs/AI_COLLABORATION.md`
- `docs/DEVELOPMENT_LOG.md`
- `docs/DIGITAL_SYSTEMS_ARCHITECTURE.md`
- `docs/DIGITAL_SYSTEMS_DEV_PLAN.md`
- `docs/DIGITAL_SYSTEMS_TEST_REPORT.md`
- `docs/MESSAGING_SYSTEM_SPEC.md`
- `project.godot`
- `scenes/messaging_test.tscn`
- `scripts/ch01_director.gd`
- `scripts/ch01_play.gd`
- `scripts/ch01_qa_test.gd`
- `scripts/desktop_night.gd`
- `scripts/message_manager.gd`
- `scripts/message_manager.gd.uid`
- `scripts/messaging_core_test.gd`
- `scripts/messaging_core_test.gd.uid`
- `scripts/messaging_demo.gd`
- `scripts/messaging_demo.gd.uid`
- `scripts/messaging_integration_test.gd`
- `scripts/messaging_integration_test.gd.uid`
- `scripts/messaging_reload_test.gd`
- `scripts/messaging_reload_test.gd.uid`
- `scripts/messaging_ui_test.gd`
- `scripts/messaging_ui_test.gd.uid`
- `scripts/world_night.gd`
- `ui/message_panel.gd`
- `ui/message_panel.gd.uid`
- `ui/news_panel.gd`
- `ui/news_panel.gd.uid`
- `ui/notification_toast.gd`
- `ui/notification_toast.gd.uid`

## 2026-11-05 消息自动推送与12/14楼分离修复
- 消息达到时间/剧情条件后自动启动逐条演出，不再等待逐个打开联系人；手机打开时保留新消息横幅，点击切换到对应会话。新挂载通知控件补显尚未展示的通知，保留已展示标记。
- 新增hallway12.tscn；12楼仅1201—1203，14楼仅1403—1405。三栋入口只进楼，1203门口才结算；选择调查后从楼梯交互进入14楼，1404门口触发剧情，跳过调查仍直接进入下行事件。
- 旧1203存档的hallway位置迁移到hallway12。补测发现读档后原配送位置未同步会导致交付失败，已在门口交付时适配。可中途回家再入楼，楼层位置分别保存。
- 实际Godot4.7.2 Windows图形运行：message_floor_fix_test 20、messaging_core_test 24、messaging_ui_test 8、ch01_qa_test 228、ch01_alternate_qa 210 PASS；最终日志均无FAIL/ERROR/WARNING。合计490次断言含截图，不等于490个功能。首次受限运行缓存目录报错，后续允许写入测试目录后重新运行通过。
- 真实截图artifacts/digital_systems/10_private_push.png、11_floor12.png、12_floor14.png已输入模型视觉检查：手机旁横幅可见，中文正常，两层门牌独立，目标指引匹配。楼梯仍为交互入口，未制作可逐级行走的楼梯美术；楼道沿用现有简化美术。macOS未验证。
- F5主场景；群聊到达后等待推送，手机内也可点击其他联系人横幅；三栋入楼后到1203按E，选择调查后到楼梯标记按E，再到1404按E。用户体验验收待确认。

## 2026-11-05 下载素材整理与双端最新消息置顶
- 素材：保留assets根目录10个ZIP、4个散文件；分类解包到assets/review_library/audio、environment、characters、unverified_loose，共1578文件（含多格式/说明，不等于独立资产数）。新增.gdignore、README.md、inventory.json、preview.html；原件不覆盖、不混入提交；解包大文件本地保留并由.gitignore排除。
- 校验：10ZIP CRC通过、14原文件SHA256未变、解包文件哈希通过。实际查看四包图片预览。Kenney五包自带CC0证据；其他音乐/音效部分找到对应发布页，但未完成二进制来源比对。未知来源不接入。音频未试听；GLB未导入游戏验证；preview.html为本地试听入口，未声称完成网页浏览器测试。详细适配/署名/来源见assets/review_library/README.md。
- 消息：ui/phone_messages.gd按实际显示消息的display_order降序排联系人，新消息自动置顶；阅读不会改变排序。scripts/desktop_night.gd复用同一头像行/摘要/红色未读数字与聊天入口，移除第一章电脑下拉联系人；通知点击同样进入对应会话。修复桌面主题造成浅底白字的问题。
- 新增scripts/contact_order_test.gd、artifacts/digital_systems/contact_order_test.log、25_phone_latest_first.png、26_desktop_contacts.png；专项8 PASS，第一章主线228 PASS，最终运行日志无错误。两张截图均实际送入视觉上下文；修正对比度后重拍复看。既有主线截图由测试更新。
- 保留新增Godot UID：scripts/phone_store_test.gd.uid、ui/phone_messages.gd.uid（上轮组件生成标识）。无删除。未接入第三方素材，不扩展剧情。
- F5进入第一章，手机/电脑打开消息：联系人按最近消息置顶，点击查看并同步已读；聊天内部仍由旧到新。旧配送自由模式沿用原聊天实现，本次改动范围为第一章双端。
- 限制：素材可用性不是最终美术/音效验收；作者来源或授权待补的素材暂存评估，macOS未测；部分旧专项按原下拉组件操作需同步升级。

## 2026-11-05 / 手机 Y2K UI 实测

### 结果与范围
- Godot4.7.2 Windows/OpenGL实际运行，phone_y2k_test.gd：36 PASS / 0 FAIL（含13张截图保存检查）；ch01_qa_test.gd：228 PASS / 0 FAIL。最终运行日志未见解析错误或运行时错误。
- 手机专项覆盖实际鼠标点击通讯录/会话/发送、6联系人搜索、列表滚动、预设填充后发送、逐条送达、未读共享、最新置顶、关闭会话仍送达、未来消息不投递、游戏时间不随UI推进、长文本不横向溢出、原存档schema载入、手机关闭释放移动锁、电脑宽界面保留。
- 本地图像与音频附件扩展实测，音频只使用振动测试片段验证播放状态，不是人物语音，不声称试听质量完成。
- 1280×720及960×540截图已实际作为图像输入检查。确认文字、头像、行列、底部按钮、渐变与左右气泡可见；滚动边缘的部分内容裁切属于ScrollContainer正常行为。
- 初次运行发现头像上裁、默认灰输入栏；一次修正又发现自动换行使短按钮收缩，已修复并重新运行截图。非提权导入曾遇编辑器配置保存错误，随后授权Godot运行导入成功；不将其计为最终游戏运行错误。

### 实际命令
```powershell
& 'D:\Godot_v4.7.2-stable_win64_console.exe' --headless --path . --editor --import --quit
& 'D:\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://scripts/phone_y2k_test.gd --log-file artifacts/phone_y2k/test.log
& 'D:\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://scripts/ch01_qa_test.gd --log-file artifacts/phone_y2k/chapter_regression.log
```

### 查看成果
F5进入第一章，P打开手机消息；通讯录→联系人→资料→聊天；有剧情回复时先选择，再点发送。发现页返回既有订单/地图/新闻等应用。四个独立F6入口：scenes/phone/chat_list.tscn、contacts.tscn、group_chat.tscn、private_chat.tscn。
截图在artifacts/phone_y2k：01列表、02通讯录、03资料、04群聊、05私聊、06缩放、07游戏内、08玩家回复、09长文本、10原电脑、11附件测试、12通讯录下半部分、13通知行。09/11含专项测试数据，仅在测试进程，不写入正式剧情。

### 限制与未完成
原有像素头像复用裁切，非全新精细肖像；电量/信号仅装饰。录音、表情/附件发送、自由输入未实现，按钮如实提示。新朋友当前为空，星标为既有小鱼/老周快捷入口。阿强/老马/陈姨/林晓未扩写私聊台词。没有macOS实机测试。视觉设计待用户验收；未声称第一章整体美术达到正式发布标准。

### 文件记录
修改（保留原有功能）：
- `AGENTS.md`
- `ART_DIRECTION.md`
- `CHANGELOG.md`
- `DEV_LOG.md`
- `ROADMAP.md`
- `docs/DEVELOPMENT_LOG.md`
- `docs/DIGITAL_SYSTEMS_ARCHITECTURE.md`
- `docs/MESSAGING_SYSTEM_SPEC.md`
- `docs/DIGITAL_SYSTEMS_TEST_REPORT.md`
- `data/messaging.json`
- `scripts/ch01_play.gd`
- `ui/message_panel.gd`

新增（组件/预览/头像适配/导出工具/测试证据）：
- `ui/phone/avatar_icon.gd`
- `ui/phone/avatar_icon.gd.uid`
- `ui/phone/contact_item.gd`
- `ui/phone/contact_item.gd.uid`
- `ui/phone/list_item.gd`
- `ui/phone/list_item.gd.uid`
- `ui/phone/message_bubble.gd`
- `ui/phone/message_bubble.gd.uid`
- `ui/phone/messenger.gd`
- `ui/phone/messenger.gd.uid`
- `ui/phone/ornament.gd`
- `ui/phone/ornament.gd.uid`
- `ui/phone/palette.gd`
- `ui/phone/palette.gd.uid`
- `ui/phone/preview.gd`
- `ui/phone/preview.gd.uid`
- `scenes/phone/chat_list.tscn`
- `scenes/phone/contacts.tscn`
- `scenes/phone/group_chat.tscn`
- `scenes/phone/private_chat.tscn`
- `assets/art/phone_portraits/aqiang.tres`
- `assets/art/phone_portraits/ASSET_RECORD.md`
- `assets/art/phone_portraits/chen.tres`
- `assets/art/phone_portraits/laoma.tres`
- `assets/art/phone_portraits/lin.tres`
- `assets/art/phone_portraits/player.tres`
- `assets/art/phone_portraits/xiaoyu.tres`
- `assets/art/phone_portraits/zhou.tres`
- `scripts/export_phone_portraits.gd`
- `scripts/export_phone_portraits.gd.uid`
- `scripts/phone_y2k_test.gd`
- `scripts/phone_y2k_test.gd.uid`
- `artifacts/phone_y2k/01_chat_list.png`
- `artifacts/phone_y2k/02_contacts.png`
- `artifacts/phone_y2k/03_profile.png`
- `artifacts/phone_y2k/04_group_chat.png`
- `artifacts/phone_y2k/05_private_chat.png`
- `artifacts/phone_y2k/06_scaled.png`
- `artifacts/phone_y2k/07_ingame.png`
- `artifacts/phone_y2k/08_player_reply.png`
- `artifacts/phone_y2k/09_long_text.png`
- `artifacts/phone_y2k/10_desktop_unchanged.png`
- `artifacts/phone_y2k/11_attachment_extension.png`
- `artifacts/phone_y2k/12_contacts_lower.png`
- `artifacts/phone_y2k/13_system_notification_row.png`
- `artifacts/phone_y2k/chapter_regression.log`
- `artifacts/phone_y2k/test.log`

删除：无。原图与整合包：未覆盖。project.godot及5项既有.import未提交改动：原样保留，不纳入本任务提交。未推送远程。
