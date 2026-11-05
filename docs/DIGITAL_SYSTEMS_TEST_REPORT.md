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
