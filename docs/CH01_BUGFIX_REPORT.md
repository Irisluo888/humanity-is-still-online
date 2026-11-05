# CH01 全面整改问题记录 / 2026-11-05

本文件记录实际修复及剩余质量差距，不把已有报告当作功能证据。

| 问题 | 根因与实际修复 | 验证 |
|---|---|---|
| garden仍是street | 公用if分支；改为六个独立tscn映射、不同布局与相机尺度 | 完整路线检查kind与scene_file_path、截图 |
| hallway/elevator/store同景 | 通用else商店；拆分独立楼道、电梯、商店构造 | 六场景实际运行 |
| 地图位置丢失/写错 | 未接入position；增positions按地图保存，并禁止旧地图在切换同帧写新地图位置 | 往返、独立进程恢复 |
| 调试面板混入游戏 | 删除正常UI的通用传送/无限拾取/修数值；独立ch01_debug.tscn，默认developer_mode=false | 正常UI检查、截图 |
| 剧情长日志 | 数据pages、角色/旁白、头像、78字分页、逐字显示、空格/点击继续、选项与输入锁 | 实际UI路线、长选项截图 |
| 便利店缺实体与消耗 | 增陈姨/同一衬衫男、货架冷柜、柜台灭火器、公文包/玻璃、袭击姿态和持久破损状态；四方法消费/结果 | 四方法数值、陈姨生死、场景恢复 |
| 敲门首次揭晓风险 | 匿名轮廓/声控灯/血迹/联系小鱼/来电/震动/揭晓分步数据；揭晓统一老周头像资源 | 前后截图、固定顺序测试 |
| 结局与选择同时显示 | 先回复群聊，再设置complete并显示自然语言后果 | 两条UI路径、五结局枚举覆盖 |
| 手机/电脑数据分叉 | Chapter消息ID/新闻ID/已读作为同一源，接原桌面消息和热榜窗口 | 两端实际读取、跨进程存档 |
| 普通遭遇无限弹窗 | 真实Area3D接触，触发时物理分离，重建后2秒冷却；无追逐无感染 | 实际重叠/分离/冷却 |
| 物理回调移除碰撞体 | updated同步重建；改为延迟且合并重建 | 最终边界日志无该报错 |
| 字幕无法结束 | visible_characters=-1判断错误；正确区分已显示与逐字中 | 空格实际推进 |
| JSON新档拒绝 | Array成员判断严格类型造成2.0不属于[1,2]；改为数值比较 | 新/旧schema、坏档、跨进程 |
| 桌面保存覆盖旧档风险 | 第一章桌面保存改用Chapter独立路径，关闭电脑返回第一章；旧模式保留原行为 | 原夜间回归与章节路线 |

## 尚未达到的质量目标
- 场景已不同且使用原创像素贴图/道具，不再是原始纯色灰盒；但建筑、家具与人物仍属简化美术，尚未达到正式精致像素品质。不能将本次整体任务标DONE。
- 便利店袭击是短分镜/姿态变化，没有完整动作动画与真人配音。
- 手机地图是区域关系图文本，未制作完整地图缩略图；电话为剧情来电，不提供自由拨号。
- 第一章临时角色均为单帧，缺行走/方向/精细遮挡表现。
- 未验证macOS、发行导出、长时间真人试玩与75–110分钟节奏。

详细证据见CH01_TEST_REPORT.md，素材差距见CH01_ART_ASSET_GAP.md。保留旧配送场景和原整合包，不执行reset/clean或push。

## 2026-11-05 — 修复开场卡顿与越级地图
- 新档最后一单明确为已取餐/配送中；E送达只执行一次交付并提示到账及老周修车位置，兼容开场旧订单的待取餐状态。
- 增加地图邻接与剧情门槛：1203取餐前不进幸福花园，电梯剧情前不进便利店；群聊/私信阶段不允许直接出门跳过。免费回家仍保留，未完成主线不会被结算掉。
- 关键送餐/取餐/修车/出入口改为可读文字标记，开场目标明确位置；对白支持E/空格/回车继续。
- 修改scripts/ch01_director.gd、ch01_play.gd、ch01_map.gd；新增ch01_opening_test.gd及Godot UID。未覆盖原整合包和用户存档。
- 实测opening.log 13 PASS/0失败；连续物理步行主线walk.log 216 PASS/0失败。实际查看opening_fixed.png：目标、送餐处、修车与入口文字可见，无明显遮挡。
- 限制：未读取或诊断用户实际卡住的存档；未宣称所有旧异常存档自动修复。当前修复覆盖复现到的开场状态/提示与越级入口问题。

## 2026-11-05 消息自动推送与12/14楼分离修复
- 消息达到时间/剧情条件后自动启动逐条演出，不再等待逐个打开联系人；手机打开时保留新消息横幅，点击切换到对应会话。新挂载通知控件补显尚未展示的通知，保留已展示标记。
- 新增hallway12.tscn；12楼仅1201—1203，14楼仅1403—1405。三栋入口只进楼，1203门口才结算；选择调查后从楼梯交互进入14楼，1404门口触发剧情，跳过调查仍直接进入下行事件。
- 旧1203存档的hallway位置迁移到hallway12。补测发现读档后原配送位置未同步会导致交付失败，已在门口交付时适配。可中途回家再入楼，楼层位置分别保存。
- 实际Godot4.7.2 Windows图形运行：message_floor_fix_test 20、messaging_core_test 24、messaging_ui_test 8、ch01_qa_test 228、ch01_alternate_qa 210 PASS；最终日志均无FAIL/ERROR/WARNING。合计490次断言含截图，不等于490个功能。首次受限运行缓存目录报错，后续允许写入测试目录后重新运行通过。
- 真实截图artifacts/digital_systems/10_private_push.png、11_floor12.png、12_floor14.png已输入模型视觉检查：手机旁横幅可见，中文正常，两层门牌独立，目标指引匹配。楼梯仍为交互入口，未制作可逐级行走的楼梯美术；楼道沿用现有简化美术。macOS未验证。
- F5主场景；群聊到达后等待推送，手机内也可点击其他联系人横幅；三栋入楼后到1203按E，选择调查后到楼梯标记按E，再到1404按E。用户体验验收待确认。

本次修改/新增（无删除）：
- `CHANGELOG.md`
- `DEV_LOG.md`
- `ROADMAP.md`
- `artifacts/ch01_qa/03_hallway.png`
- `artifacts/ch01_qa/08_home.png`
- `artifacts/digital_systems/10_private_push.png`
- `artifacts/digital_systems/11_floor12.png`
- `artifacts/digital_systems/12_floor14.png`
- `artifacts/digital_systems/ch01_alternate_qa.log`
- `artifacts/digital_systems/ch01_qa_test.log`
- `artifacts/digital_systems/message_floor_fix_test.log`
- `data/ch01_story.json`
- `docs/CH01_BUGFIX_REPORT.md`
- `docs/DEVELOPMENT_LOG.md`
- `docs/DIGITAL_SYSTEMS_TEST_REPORT.md`
- `docs/MESSAGING_SYSTEM_SPEC.md`
- `scenes/ch01_maps/hallway12.tscn`
- `scripts/ch01_director.gd`
- `scripts/ch01_map.gd`
- `scripts/ch01_play.gd`
- `scripts/ch01_qa_test.gd`
- `scripts/message_floor_fix_test.gd`
- `scripts/message_manager.gd`
- `ui/message_panel.gd`
- `ui/notification_toast.gd`
