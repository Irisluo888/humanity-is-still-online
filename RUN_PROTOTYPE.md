# 查看原型
Godot 4.x 导入 project.godot，F5 启动菜单；桌面预览进入电脑。
直接打开 scenes/desktop.tscn 按 F6：点击六图标打开不同布局，拖动标题栏移动；_ 最小化，任务栏按钮恢复并置前，× 关闭。内容区可滚动；消息选联系人，动态选分类，AI助手输入“榆灯巷”回车检索缓存。
scenes/city.tscn 按 F6 查看保留的静态灰盒及同源订单摘要。白天配送尚未实现，数据为原型缓存；未来白天调用 WorldData.record_event 后桌面自动刷新。
验证命令：Godot --headless --path . --script res://scripts/desktop_smoke.gd
界面未做截图验收；实际布局、鼠标拖动与跨平台中文字体需人工检查。参考 ART_DIRECTION.md。

## 视觉样板
F5 → 桌面预览，或打开 scenes/desktop.tscn 按 F6。动态：点击全部/邻里/配送，滚轮浏览四条图文留言，点赞切换。消息：选联系人清除未读点，输入文字按回车或“记录”，仅保存在当前运行。标题栏拖动，右上横线最小化、叉关闭；底部应用按钮恢复并置前。
四个其他应用保留原有原型功能，不属于本轮精修范围。
真实运行截图：artifacts/ui_preview/01_desktop.png、02_feed_window.png、03_message_window.png、04_multi_window.png；05_multi_window_1080p.png 为1920×1080补充检查。
自动测试：Godot --headless --path . --script res://scripts/visual_smoke.gd
重拍截图：Godot --path . --script res://scripts/capture_ui.gd（需要图形显示环境，非headless）。
