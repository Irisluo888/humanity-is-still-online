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

## 2026-11-05 开场盲玩引导、手机通知与剧情近景
- 送餐/修车/修好回家添加常驻任务卡、WASD/E操作提示和金色方向点线/目标箭头。点线表示方向，不是避障导航。交互与配送仍走原逻辑。
- 新增原创本地96×64电动车PNG（配送箱、后视镜、电池及脚踏板），用于任务卡、开场角色旁与车辆近景；生成源tools/generate_delivery_scooter.py，仅Python标准库。
- 送达切入修车时播放3.5秒电动车断电/接线闪烁近景，结束恢复移动并指向老周；已播放状态保存在Chapter flags。未新增驾驶物理或骑行动画。
- 从原始第一章剧本恢复送餐中小鱼“姐，别跑了吧”私信及两条原预设回复，使用同一xiaoyu线程，稳定ID去重。回复为聊天选择，不额外改变原配送主线。
- 通知增加手机外壳、状态条和0.65秒轻微摆动，显示7秒；电脑通知置顶，并可切换已打开消息窗口的联系人。剧情近景期间将通知放到左侧。
- 电梯原“八楼开门…夹伤手”对白页绑定原创程序绘制近景：门缝收窄、手部、浅色衣袖和原有暗红袖口痕迹；继续后回到原男人对白，无新增剧情结果。
- 实际Windows Godot4.7.2：资源导入通过；ch01_onboarding_test 17、ch01_qa_test 228、ch01_walk_qa 229 PASS，最终日志无FAIL/ERROR/WARNING。共474断言含重复分支与截图，非474项独立功能。
- 五张真实PNG（artifacts/digital_systems/13_delivery_guidance至17_elevator_hand）已输入模型视觉上下文检查；中文/任务卡/手机外壳/电脑通知层级/特写位置可见，最终素材更新后重新截图查看。既有回归截图也由脚本更新。
- F5新游戏可体验送餐消息→交付→断电→找老周；WASD跟随金色指引，接近按E。电脑打开多个窗口仍可接收通知。夹手近景在第一章电梯对应对白自动出现。
- 限制：自动化步行测试不等于陌生玩家盲玩验收；macOS、真人试玩改善程度和主观音效未验证。人物车辆没有完整骑行动画，夹手是简化原创像素近景，不宣称最终美术。无新在线服务、插件或第三方素材。

本次文件清单（新增/修改，无删除；message_floor_fix_test.gd.uid为上一轮脚本的Godot生成标识，保留纳入）：
- `CHANGELOG.md`
- `DEV_LOG.md`
- `ROADMAP.md`
- `artifacts/ch01_qa/01_street.png`
- `artifacts/ch01_qa/03_hallway.png`
- `artifacts/ch01_qa/12_desktop_chat.png`
- `artifacts/ch01_qa/13_desktop_news.png`
- `artifacts/digital_systems/13_delivery_guidance.png`
- `artifacts/digital_systems/14_bike_fault.png`
- `artifacts/digital_systems/15_repair_guidance.png`
- `artifacts/digital_systems/16_desktop_phone_push.png`
- `artifacts/digital_systems/17_elevator_hand.png`
- `artifacts/digital_systems/ch01_onboarding_test.log`
- `artifacts/digital_systems/ch01_walk_qa.log`
- `assets/art/ch01/delivery_scooter.png`
- `assets/art/ch01/delivery_scooter.png.import`
- `data/ch01_story.json`
- `data/messaging.json`
- `docs/CH01_ART_ASSET_GAP.md`
- `docs/CH01_BUGFIX_REPORT.md`
- `docs/CH01_TEST_REPORT.md`
- `docs/DEVELOPMENT_LOG.md`
- `docs/MESSAGING_SYSTEM_SPEC.md`
- `scripts/ch01_director.gd`
- `scripts/ch01_map.gd`
- `scripts/ch01_onboarding_test.gd`
- `scripts/ch01_onboarding_test.gd.uid`
- `scripts/ch01_play.gd`
- `scripts/ch01_qa_test.gd`
- `scripts/ch01_walk_qa.gd`
- `scripts/desktop_night.gd`
- `scripts/message_floor_fix_test.gd.uid`
- `tools/generate_delivery_scooter.py`
- `ui/ch01_closeup.gd`
- `ui/ch01_closeup.gd.uid`
- `ui/ch01_guidance.gd`
- `ui/ch01_guidance.gd.uid`
- `ui/notification_toast.gd`

## 2026-11-05 开场续聊、次日过场与设备通知
- data/messaging.json：开场回复后增加小鱼两句关心与女主报平安回应，沿用逐条队列，避免突然结束。两种预设回复共用自然收尾。
- scripts/ch01_director.gd、scripts/ch01_play.gd：夜间午餐邀约结束后，进入约4秒深色到晨光淡入淡出过场，提示第二天清晨出门取餐；结束恢复移动，待播放标记进入存档状态。
- ui/notification_toast.gd、scripts/desktop_night.gd：手机打开时抑制弹窗，未展示通知保留，关闭后继续；电脑采用直角桌面通知，无手机状态栏或震动，点击进入对应会话。
- 新增scripts/ch01_transition_test.gd；实际Godot Windows运行专项11 PASS、第一章主线228 PASS，最终日志无错误；共239断言含截图/重复分支，不是239功能。截图18_phone_followup、19_morning_transition、20_desktop_notification已实际作为图像检查；发现并修复过场通知遮挡后重新截图。
- 更新既有artifacts/ch01_qa/01_street.png、12_desktop_chat.png、13_desktop_news.png为回归运行输出；新增artifacts/digital_systems/ch01_transition_test.log及上述3张PNG。无删除。
- F5新游戏：回复小鱼后等待连续消息；手机关闭后恢复通知；完成首夜聊天后查看清晨过场；电脑通知“查看”打开聊天。
- 限制：过场为文字/色调渐变，不是完整日出场景动画；macOS及真人盲玩未验收。旧message_floor_fix_test中的“手机打开仍显示横幅”是已被本次需求取代的历史断言，本次以transition专项为准。

## 2026-11-05 手机联系人列表与便利店入场顺序
- 新增ui/phone_messages.gd：骑手群、小鱼、老周独立头像行、最近消息、红色未读数字；列表不标记已读，点击进入聊天并返回列表。晚间同联系人归为一行，旧时段可用历史入口查看。保留原创配色/素材，不使用真实平台标识。
- 修改ui/message_panel.gd增加明确选择联系人时禁用自动跳转；scripts/ch01_play.gd接入手机列表，通知点击仍直接进入指定聊天。
- 修改scripts/ch01_map.gd：入店及陈姨第一段对白时不生成男人；门铃对应第二段才从入口用2秒移动到柜台，后续仍使用同一人物和原袭击结果。
- 新增scripts/phone_store_test.gd：最终11 PASS；原ch01_qa_test实际运行228 PASS，最终日志无错误。首次专项因调试跳转尚在清晨过场而未能触发对话，调整测试等待/隔离后通过；未伪报首次通过。
- 新增artifacts/digital_systems/21_contact_list.png、22_contact_chat.png、23_store_before_arrival.png、24_store_entrance.png及phone_store_test.log。4图均实际送入视觉上下文；联系人、徽标、聊天布局及陈姨单独在店确认可见。
- 回归更新artifacts/ch01_qa/01_street.png、05_store_before.png、06_attack.png；保留上轮自动生成scripts/ch01_transition_test.gd.uid。无删除。
- F5打开手机“消息”查看列表，点联系人进入、返回列表；便利店先与陈姨对话，继续到门铃页观察男人进店。
- 限制：仍使用既有人物Sprite位移，没有完整行走帧；第一章仅现有群聊与联系人。手机入口变化后的老专项脚本可能需按列表交互更新，本次专项与主线已实际通过；macOS未验证。

## 2026-11-05 下载素材整理与双端最新消息置顶
- 素材：保留assets根目录10个ZIP、4个散文件；分类解包到assets/review_library/audio、environment、characters、unverified_loose，共1578文件（含多格式/说明，不等于独立资产数）。新增.gdignore、README.md、inventory.json、preview.html；原件不覆盖、不混入提交；解包大文件本地保留并由.gitignore排除。
- 校验：10ZIP CRC通过、14原文件SHA256未变、解包文件哈希通过。实际查看四包图片预览。Kenney五包自带CC0证据；其他音乐/音效部分找到对应发布页，但未完成二进制来源比对。未知来源不接入。音频未试听；GLB未导入游戏验证；preview.html为本地试听入口，未声称完成网页浏览器测试。详细适配/署名/来源见assets/review_library/README.md。
- 消息：ui/phone_messages.gd按实际显示消息的display_order降序排联系人，新消息自动置顶；阅读不会改变排序。scripts/desktop_night.gd复用同一头像行/摘要/红色未读数字与聊天入口，移除第一章电脑下拉联系人；通知点击同样进入对应会话。修复桌面主题造成浅底白字的问题。
- 新增scripts/contact_order_test.gd、artifacts/digital_systems/contact_order_test.log、25_phone_latest_first.png、26_desktop_contacts.png；专项8 PASS，第一章主线228 PASS，最终运行日志无错误。两张截图均实际送入视觉上下文；修正对比度后重拍复看。既有主线截图由测试更新。
- 保留新增Godot UID：scripts/phone_store_test.gd.uid、ui/phone_messages.gd.uid（上轮组件生成标识）。无删除。未接入第三方素材，不扩展剧情。
- F5进入第一章，手机/电脑打开消息：联系人按最近消息置顶，点击查看并同步已读；聊天内部仍由旧到新。旧配送自由模式沿用原聊天实现，本次改动范围为第一章双端。
- 限制：素材可用性不是最终美术/音效验收；作者来源或授权待补的素材暂存评估，macOS未测；部分旧专项按原下拉组件操作需同步升级。

## 2026-11-05 首批本地音效与城市建筑接入
- 开始时目录在旧main(2a1e8d5)，确认无已跟踪未提交修改后安全切回最新codex/digital-life(806420c)，保留素材解包副本。
- assets/third_party/kenney/：从用户包复制6个OGG、4个GLB及其依赖纹理，保留两份原始CC0许可证与ASSET_RECORD.json逐文件哈希。实际使用三种脚步、开门/关门，metalLatch及屋顶GLB备用未触发。未接入授权未明音乐或付费依赖。
- 新增scripts/local_audio.gd，project.godot注册LocalAudio：4播放器复用，移动距离触发交替脚步，静止/剧情锁定不触发；scripts/ch01_director.gd成功出入口切换触发门声。未替换剧情敲门/电话原音效。
- scripts/ch01_map.gd：街道/花园建筑改用像素纹理墙窗、门模块和店铺雨棚，保持原碰撞外框与交互点。截图后修正正面朝向和屋顶拼接，连续平顶仍用现有本地纹理。属于首批素材适配，不宣称最终城市美术完成。
- 新增scripts/asset_integration_test.gd：最终8PASS，实际音频播放器启动、移动/静止条件、场景门声及两地图截图；ch01_walk_qa实际229PASS，验证第一章路径/碰撞/交互。最终专项日志无错误；一次过早退出产生资源释放警告，测试等待异步资源释放后重跑消除。未主观试听，不宣称听感、音量混音验收通过。
- 截图artifacts/digital_systems/27_urban_street.png、28_urban_garden.png均实际作为图像读取；门窗朝向、中文与交互标记、像素采样可见。日志asset_integration_test.log、ch01_walk_qa.log。
- F5新游戏，在街道WASD移动听脚步，停止或打开手机无新增脚步；经入口切换听门声；依第一章流程到幸福花园查看三栋/便利店外部。
- 限制：音量尚为固定值，未增加音乐/音量设置、雨声；街道与花园的建筑仍需更丰富布局/照明。macOS和人工听感待验证。下一步建议只做音效听感与音量设置验收。
