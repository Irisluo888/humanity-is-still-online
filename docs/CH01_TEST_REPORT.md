# 第一章整改测试报告 / 2026-11-05

运行环境：Godot 4.7.2 / Windows / OpenGL Compatibility / NVIDIA RTX 4060 Ti。以下为实际运行，不以文件存在作为验收。

命令模板：`Godot_v4.7.2-stable_win64_console.exe --path . --script res://scripts/脚本名.gd --log-file artifacts/ch01_qa/脚本名.log`
项目资源导入：同引擎 `--headless --path . --editor --quit`，最终import.log无解析错误。

最终逐项数量见artifacts/ch01_qa/test_summary.json。最终日志均无FAIL行及SCRIPT ERROR。
- ch01_qa_test：完整交互路线，包含1404、灭火器救陈姨、隔门医疗救援；实际E输入与选择按钮。该测试为提速把角色放至交互范围，不当作完整步行证明。
- ch01_alternate_qa：跳过1404、离开便利店、二次确认开门的另一条完整UI路线。
- ch01_walk_qa：从新档沿物理通路连续步行到每个必达交互点，使用CharacterBody3D及碰撞而非传送；测试寻路仅供自动化，未加入玩家游戏。
- ch01_edge_test：四救援成本与陈姨结果、容量/物资/收入去重、普通接触实际Area3D重叠/分离/冷却、墙体碰撞、手机锁移动、危险中途读档、坏档不覆盖内存、旧schema接受。
- ch01_reload_qa：另一引擎进程恢复正确garden资源、玩家坐标、陈姨状态。
- ch01_visual_qa：手机五应用实际切换、正常菜单无灰盒入口、1920×1080截图。
- night_system_test / round2_smoke / cruise_boundary_test：原夜间调查、六应用多窗口、已接单巡航边界回归。

## 实际视觉检查
artifacts/ch01_qa/01至26命名PNG均已进入模型视觉上下文查看（其中18为960×540、25为1920×1080，其余1280×720）。检查文字、遮挡、控件、场景差异与身份前后变化。修复对白结束、猫眼纹理资源白块、早期血迹时点、手机已读HUD与输入互斥等问题。最终未观察到明显文字溢出或开发状态按钮。

## 失败与修复记录
开发过程中发生地图for变量解析错误；子视口键盘不传递；逐字显示-1状态无法结束；JSON数值版本比较错误；物理回调同步移除碰撞体；旧地图同帧写新位置；旧夜间测试按钮兼容性；坏档测试夹具误共享引用。均已定位并修复，最终重跑无上述错误。首次失败日志不冒充通过。

## 验证限制
- 自动化按键/按钮不等于真人长时间试玩；未验证75–110分钟节奏、macOS和导出发行包。
- 音效仅验证本地加载/触发，未进行完整听觉混音验收；林晓是字幕配非语言门内声效，无真人配音。
- 原创建筑/家具/人物仍属简化资产，尚未通过正式美术质量验收；整体整改不标DONE。
- 10条结局组合由逻辑覆盖，另两条完整UI路径；不声称五种结局均经过真人试玩。
- 本轮原系统回归重新生成phase3/cruise_boundary目录旧测试截图，这些不作为本轮逐图验收对象。
测试存档使用独立user://ch01_qa.json等路径，不覆盖正式chapter或campaign存档。

## 2026-11-05 — 修复开场卡顿与越级地图
- 新档最后一单明确为已取餐/配送中；E送达只执行一次交付并提示到账及老周修车位置，兼容开场旧订单的待取餐状态。
- 增加地图邻接与剧情门槛：1203取餐前不进幸福花园，电梯剧情前不进便利店；群聊/私信阶段不允许直接出门跳过。免费回家仍保留，未完成主线不会被结算掉。
- 关键送餐/取餐/修车/出入口改为可读文字标记，开场目标明确位置；对白支持E/空格/回车继续。
- 修改scripts/ch01_director.gd、ch01_play.gd、ch01_map.gd；新增ch01_opening_test.gd及Godot UID。未覆盖原整合包和用户存档。
- 实测opening.log 13 PASS/0失败；连续物理步行主线walk.log 216 PASS/0失败。实际查看opening_fixed.png：目标、送餐处、修车与入口文字可见，无明显遮挡。
- 限制：未读取或诊断用户实际卡住的存档；未宣称所有旧异常存档自动修复。当前修复覆盖复现到的开场状态/提示与越级入口问题。

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

## 2026-11-05 首批本地音效与城市建筑接入
- 开始时目录在旧main(2a1e8d5)，确认无已跟踪未提交修改后安全切回最新codex/digital-life(806420c)，保留素材解包副本。
- assets/third_party/kenney/：从用户包复制6个OGG、4个GLB及其依赖纹理，保留两份原始CC0许可证与ASSET_RECORD.json逐文件哈希。实际使用三种脚步、开门/关门，metalLatch及屋顶GLB备用未触发。未接入授权未明音乐或付费依赖。
- 新增scripts/local_audio.gd，project.godot注册LocalAudio：4播放器复用，移动距离触发交替脚步，静止/剧情锁定不触发；scripts/ch01_director.gd成功出入口切换触发门声。未替换剧情敲门/电话原音效。
- scripts/ch01_map.gd：街道/花园建筑改用像素纹理墙窗、门模块和店铺雨棚，保持原碰撞外框与交互点。截图后修正正面朝向和屋顶拼接，连续平顶仍用现有本地纹理。属于首批素材适配，不宣称最终城市美术完成。
- 新增scripts/asset_integration_test.gd：最终8PASS，实际音频播放器启动、移动/静止条件、场景门声及两地图截图；ch01_walk_qa实际229PASS，验证第一章路径/碰撞/交互。最终专项日志无错误；一次过早退出产生资源释放警告，测试等待异步资源释放后重跑消除。未主观试听，不宣称听感、音量混音验收通过。
- 截图artifacts/digital_systems/27_urban_street.png、28_urban_garden.png均实际作为图像读取；门窗朝向、中文与交互标记、像素采样可见。日志asset_integration_test.log、ch01_walk_qa.log。
- F5新游戏，在街道WASD移动听脚步，停止或打开手机无新增脚步；经入口切换听门声；依第一章流程到幸福花园查看三栋/便利店外部。
- 限制：音量尚为固定值，未增加音乐/音量设置、雨声；街道与花园的建筑仍需更丰富布局/照明。macOS和人工听感待验证。下一步建议只做音效听感与音量设置验收。

## 2026-11-05 骑行/脚步分流、剧情音效与建筑清晰文字
- 修改local_audio.gd、ch01_map.gd：首夜delivery骑车移动使用低音量电机循环，不触发脚步；停止/剧情锁定停电机；步行脚步从-17dB降为-29dB，其他短音-19dB。户外雨声-30dB，室内停止。声音为原创程序合成，未主观试听。
- 新增tools/generate_scene_audio.py、assets/audio/generated/六个WAV与ASSET_RECORD.md；雨声、电机、夹手、重击、玻璃破碎、撞门。原始素材包没有找到明确适用的对应声音，未使用授权未知素材。
- 修改ch01_story.json/ch01_play.gd：电梯夹手页与碎瓶页触发对应音效，撞门文本页接入撞门音；ch01_director.gd灭火器成功选择播放重物撞击，消耗/结果逻辑不变。原剧情其他提示音从-10dB降至-20dB。
- 建筑名称与交互文字用ch01_play全分辨率2D标签跟随3D位置，避免半分辨率贴图模糊；原3D文字隐藏，保留像素场景。29_clear_signs.png已实际输入视觉上下文检查：字号/描边/位置清楚。
- 实际Godot4.7.2：scene_sound_test 11 PASS，ch01_qa_test 228 PASS，最终日志无解析/运行错误。复现：--path . --script res://scripts/scene_sound_test.gd；场景F5，骑行/步行/停止、出入室内及原剧情事件试听。音频验证播放器启动及条件，不代表主观听感验收。
- 尚未完成：女性尖叫（缺少授权明确且合适的人声录音），BGM及独立音量设置未在本轮扩展。合成声音质量需玩家试听，不将本轮描述为全部音效完成；macOS未测。
- 保留任务开始已存在的project.godot空行变化与5个.import变化，不混入本次提交。asset_integration_test.gd.uid为上轮脚本自动生成标识，保留。

## 2026-11-05 音量设置与低音量背景音乐
- ui/audio_settings.gd新增四滑杆：总音量、背景音乐、环境音、音效，0独立静音/恢复推荐值，实时生效并保存user://audio_settings.cfg。LocalAudio创建对应总线，读取时检查数值并限幅；默认80/55/65/80%。
- scripts/start.gd替换占位设置；ch01_play游戏底部“声音设置”、desktop_night任务栏“声音”共用设置界面。打开设置暂停人物移动，关闭恢复。
- scripts/local_audio.gd新增音乐播放器、场景路由和淡入淡出；菜单/menu、配送/city、住所和电脑/night；Chapter对话/危险/深夜敲门等音乐退出。雨声走Environment，脚步/电机/剧情/手机消息通知走SFX，均受总音量控制。
- 新增tools/generate_background_music.py，assets/audio/music/menu.wav、city.wav、night.wav及ASSET_RECORD.md；各16秒原创器乐短循环，无第三方采样/在线API。播放-17dB叠加默认Music55%以轻量背景为目标；未人工试听，不把参数设置等同听感验收。
- 实际Godot4.7.2：audio_settings_test 12PASS（真实滑杆、独立静音、ConfigFile保存重读、场景音乐、危险退出、设置阻止移动）；ch01_qa_test 228PASS。最终日志无错误。测试写独立audio_settings_test.cfg，未修改玩家正式音量文件。
- 截图artifacts/digital_systems/30_audio_settings.png、31_ingame_audio_settings.png已实际作为图像读取，检查中文/滑杆/百分比/按钮与游戏底部入口；既有回归图更新。主菜单scenes/start.tscn按F5→设置；游戏内点击声音设置；电脑任务栏声音入口。
- 限制：音乐为短循环，主观听感、长时耐听程度、macOS尚未验收；女性尖叫仍待素材，不扩大本轮。保留开始已存在project.godot与5个.import变化，不混入提交；scene_sound_test.gd.uid为前轮脚本生成标识。
