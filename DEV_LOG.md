# DEV_LOG — 阶段开发日志

本日志从2026-11-04建立。此前历史以CHANGELOG与artifacts/third_round_preview/DEVELOPMENT_REPORT.md为来源；不补造执行时间、用户验收或提交记录。
状态/任务ID以ROADMAP.md为准。技术检查通过与用户阶段验收分开记录。当前阶段0；本次交付后等待用户确认。

## 历史成果纳入基线

| 既有成果 | 对应任务 | 本次复验证据 | 边界 |
|---|---|---|---|
| Godot菜单、桌面与住所入口 | P0-01 | E1/E3/E4 | 城市只有静态灰盒 |
| 六应用、多窗口、内容与共享订单联动 | P0-02、P2-02、P3-01—05 | E1/E2 | 静态视频、内存数据、无真实昼夜 |
| 住所有限移动与电脑交互 | P1-01 | E3 | 站立图位移、只开放床前/电脑前 |
| 原创像素资源及精修房间/双服装 | P5-01、P5-02 | E4/E6 | 接入验证通过，正式美术质量未整体验收 |

历史Git基点为 b7d415e。后续大量文件仍未提交，不能将该提交等同当前可玩版本。本次未重置、暂存、提交或推送。

## 2026-11-04 / MGMT-001 / 阶段0管理基线

### 目标与范围
建立八阶段ROADMAP、阶段DEV_LOG、更新CHANGELOG。只建立开发管理文档，未改游戏核心脚本、场景、配置、资源或剧情。建立本地恢复快照，并按用户要求运行现有工程。

### 检查与判断
读取AGENTS、GDD_LITE、MVP_TASKS、CHANGELOG及实际工程入口、共享数据和城市脚本；检查Git状态、已有测试/素材记录。确认已有桌面与室内原型，未实现完整3D配送/昼夜/存档。当前阶段0仍IN_PROGRESS；任务DONE限定为证据覆盖的技术验收，八阶段用户整体验收均未记录。

### 文件记录
- 新增 ROADMAP.md：八阶段任务ID、状态、验收条件/证据、依赖/执行顺序、恢复和验收关卡。
- 新增 DEV_LOG.md：基线、历史来源、实际检查、命令、结果、限制与后续日志模板。
- 修改 CHANGELOG.md：追加本次管理文档/复验记录，保留旧条目的历史含义。
- 新增 artifacts/dev_management/：310文件恢复ZIP、SHA256清单、操作前Git状态、4份运行日志、17张运行PNG，以及2个仅用于本次证据采集的脚本副本（capture_baseline.gd、room_walk_baseline.gd）。副本只改变证据输出目录，capture副本额外运行菜单和灰盒；不替换正式脚本、不参与主场景。
- 删除：无。恢复ZIP中不含.git、用户存档、外部参考、引擎缓存；不能据此声称完整Git备份。

### 实际运行与证据
引擎 D:/Godot_v4.7.2-stable_win64_console.exe；项目根目录执行：
```powershell
& 'D:/Godot_v4.7.2-stable_win64_console.exe' --path . --script res://scripts/round2_smoke.gd --quit-after 600
& 'D:/Godot_v4.7.2-stable_win64_console.exe' --path . --script res://scripts/third_smoke.gd --quit-after 600
& 'D:/Godot_v4.7.2-stable_win64_console.exe' --path . --script res://artifacts/dev_management/room_walk_baseline.gd --quit-after 600
& 'D:/Godot_v4.7.2-stable_win64_console.exe' --path . --script res://artifacts/dev_management/capture_baseline.gd --quit-after 600
```
结果：29+22+17=68个PASS，其中65功能检查、3截图保存；三套失败计数均0，控制台未见SCRIPT ERROR。日志见同目录round2_test.log、third_test.log、room_test.log、capture.log。这些是自动输入/断言和实际OpenGL运行，不是人工长时间试玩。

共17张PNG：00_start、00_city、01_desktop、02_feed、03_messages、04_news、05_video、06_assistant、07_orders、08_rider、09_bedroom、10_linked_feed、11_linked_messages、12_news_1080p、13_room_movement、14_room_near_computer、15_room_1080p。
实际作为图像输入查看4张：00_start.png、00_city.png、01_desktop.png、14_room_near_computer.png。确认中文可见、菜单和电脑按钮显示、灰盒确为静态占位、住所人物/交互提示显示正常。其他13张本次仅生成，未声称逐张查看。

ZIP经CRC和310个文件SHA256核对通过；尚未实际解压到隔离目录启动。交付前逐文件SHA256复核通过：快照内除授权追加的CHANGELOG.md以外，其余309个已有文件全部未变。八阶段标题、任务ID唯一性、本地证据链接和17张PNG存在性校验通过；本次核心代码无修改。

### 当前未完成与风险
- 路线图尚待用户确认；未进行新的玩法开发，未授权跨阶段推进。
- 白天城市没有玩家移动/实际配送，昼夜与存档未实现；不得将桌面模拟结算等同闭环。
- 正式像素质量、角色动画、家具遮挡层、音效均未完整验收。
- 参考图目前未在references对应目录发现图片，历史“已导入”记录不作为现在完整归档的证据。
- macOS、干净机器导出、断网测试、长时间玩法与发行流程未验证。

### 恢复与验收
恢复点：[pre_roadmap_baseline.zip](artifacts/dev_management/pre_roadmap_baseline.zip)及[清单](artifacts/dev_management/baseline_manifest.json)。恢复应到新空目录，不覆盖当前脏工作区；方法见ROADMAP。用户阶段验收：待确认，无发布/阶段通过声明。
下一项建议：先确认本路线图，再明确授权P0-04隔离恢复演练；其后阶段1依次P1-02→03→04优先完成。

## 后续每任务记录模板（尚未发生，不计为开发成果）

- 日期 / 任务ID / 当前阶段 / 用户授权范围：
- 开始Git状态与需保留改动：
- 目标 / 实际完成 / 未完成 / 设计差异：
- 新增 / 修改 / 删除文件与原因：
- 实际运行命令 / 退出或失败结果 / 错误及修复复验：
- 真实截图路径 / 哪些图已作为图像输入查看 / 观察结果：
- 恢复点 / 清单校验 / 是否做过恢复启动：
- ROADMAP状态变化与证据 / CHANGELOG记录：
- 用户验收状态 / 唯一下一项建议（未授权不执行）：

## 2026-11-04 / P0-04 / 隔离恢复演练
- 授权：用户回复ok确认路线图，执行此前明确建议的阶段0恢复演练，未进入阶段1。
- 开始检查Git，保留原脏工作区。快照安全解压到新的artifacts/dev_management/recovery_workspace；验证所有归档路径未越界，310文件SHA256完全一致。未覆盖原工程。
- 实际命令：Godot --headless --path artifacts/dev_management/recovery_workspace --editor --quit；随后相同--path运行--script res://scripts/round2_smoke.gd、third_smoke.gd、res://artifacts/dev_management/room_walk_baseline.gd、capture_baseline.gd，均加--quit-after 600。重新生成资源缓存，实际OpenGL启动；29+22+17 PASS，其中3项截图保存，0失败，未见SCRIPT ERROR。
- 日志：artifacts/dev_management/recovery_logs/import.log、round2.log、third.log、room.log、capture.log。运行截图17张位于recovery_workspace/artifacts/dev_management/；00_start、01_desktop、14_room_near_computer确实作为图像输入查看，中文/图片/提示显示正常，其他截图不声称逐张复看。
- 文件：修改ROADMAP.md、DEV_LOG.md、CHANGELOG.md；新增上述恢复目录（包含310个恢复文件、2个证据脚本副本、运行缓存和截图）、5份日志，以及stage0_verified_baseline.zip和stage0_verified_manifest.json。无删除，无游戏核心代码修改，无Git提交/推送。原工程309个非CHANGELOG基线文件哈希仍一致。
- 状态：P0-04技术验收DONE；P0-05路线图管理任务DONE。阶段0保持IN_PROGRESS，等待用户对本次恢复结果的最终阶段验收，不以此前ok预先替代本次验收。
- 恢复版本：pre_roadmap_baseline.zip已实际恢复运行；stage0_verified_baseline.zip在相同游戏文件基础上包含当前管理文档，配套清单逐文件校验。后一包未再次单独恢复运行，不将两者混称。
- 限制：同一Windows机器、新目录恢复，不是另一台干净机器/导出包测试；无macOS验证，不含.git历史、参考附件、用户存档和引擎缓存。
- 下一项建议：验收阶段0后，只执行P1-02最小日期与昼夜/休息状态。本次未执行。

## 阶段1集中开发增量（进行中）
新增world_loop/start_loop/bedroom_loop/desktop_loop、loop_panel、city_delivery场景脚本、phase1_smoke测试；修改autoload及三个场景脚本入口。实现日期/昼夜、现场取送餐、回家揭示消息、核对后休息、三类补给、本地JSON存读档和菜单继续。before_phase1.zip保留313文件前置恢复点。实际Godot导入及城市启动无报错；状态流程断言与同进程存读档通过；运行截图city/bedroom已作为图像输入查看。城市旧说明与标签大小已修正，待最终视觉复看。尚未验证完整键盘路线、跨进程恢复、损坏存档、旧功能全回归；阶段1未通过最终验收。

## 阶段1输入闭环与跨进程验收
- 实际通过输入动作驱动CharacterBody3D移动（不是传送角色），完成取餐、3补给点、送达、回家，住所注入方向键事件走到电脑前、E打开、消息核对、次日休息。路线测试28 PASS（含3张截图）。初跑发现E优先匹配登记顺序，改为最近地点；补给点移出建筑碰撞区。修复后全流程通过。
- 新Godot进程读取路线存档：12 PASS（含1张截图），验证日期/位置、物品消耗、收入消息、独立测试槽备份、损坏schema拒绝且不改内存、缺失文件拒绝、备份恢复、急救包使用。只使用phase1_*测试槽，不覆盖玩家正式campaign_v1存档。未验证所有畸形JSON组合或磁盘故障。
- round2/third/room原有回归29+22+17 PASS；本次合计108 PASS，其中7项截图保存。日志artifacts/phase1/route.log、reload.log、regression_round2.log、regression_third.log、regression_room.log，未见运行报错。
- 新增scripts/phase1_route_test.gd、phase1_reload_test.gd及生成UID；修改scripts/city_delivery.gd的补给坐标、最近地点选择、标签大小及可见性；修改ROADMAP、DEV_LOG、CHANGELOG、RUN_PROTOTYPE。新增route_delivered/route_night/route_messages/reloaded_day2 PNG，原回归重新生成3张住所截图。无删除、无Git提交。
- 四张阶段1截图均实际进入视觉上下文；发现城市标签过大与遮挡，改小并使标记可见；修复后重跑路线、恢复测试，再看最终城市/读档图。城市仍为灰盒、角色尺寸小且没有动画，不宣称正式美术验收通过。
- 保存phase1_verified.zip和SHA256清单，包含当前源码/素材/配置/根文档。P1-02至05技术验收DONE；P1-06保留IN_PROGRESS等待用户完整体验验收。没有进入阶段2，未实现感染者/剧情。

## 2026-11-04 / P2-03 / 街道—便利店—走廊入口扩展

### 授权与范围
用户“OK继续”承接阶段1报告；开始检查Git并保留全部未提交工作。执行阶段2一项P2-03，不同时展开多订单或美术重构。before_phase2.zip及before_manifest.json保存本轮开始状态。

### 实现
街道保留既有取餐、送达、补给、回家；新增“便利店/E进入”和“居民楼走廊/E进入”入口。室内有角色控制、地面/墙壁/货架碰撞、靠近才能使用的出口；返回街道恢复入口位置。统一入口与原配送点的实际最近距离选择，避免范围相交时抢占。室内安全出生点拒绝墙外和货架内位置。新存档记录室内地点与位置，旧schema缺少可选字段仍能加载；只增加可选字段，未作破坏性版本迁移。

### 文件记录
新增scripts/city_district.gd、district_interior.gd、phase2_district_test.gd、phase2_reload_test.gd及生成UID；scenes/district_interior.tscn。修改scripts/world_loop.gd（室内状态/距离门槛/持久化）、scenes/city_delivery.tscn（接入入口子类）、ROADMAP.md、DEV_LOG.md、CHANGELOG.md、RUN_PROTOTYPE.md。新增artifacts/phase2/下前后恢复ZIP/清单、import.log、district.log、reload.log、phase1_route.log、phase1_reload.log、round2.log、third.log、room.log、test_summary.json及四张PNG。原阶段1与住所回归会刷新其既有证据PNG，本次不将其当新美术。无删除、无提交或推送。

### 实测命令与结果
使用D:/Godot_v4.7.2-stable_win64_console.exe，项目根目录运行：
- --headless --path . --editor --quit：导入成功。
- --path . --script res://scripts/phase2_district_test.gd --quit-after 16000：33 PASS，真实Input动作驱动位移、E事件切换；远程入口拒绝、货架/后墙碰撞、出口距离、返回出生点、探索前后订单时间收入不变。
- --path . --script res://scripts/phase2_reload_test.gd --quit-after 600：7 PASS，新进程恢复室内及旧存档可选字段兼容。
- phase1_route_test.gd（15000帧）、phase1_reload_test.gd、round2_smoke.gd、third_smoke.gd、room_walk_smoke.gd（后四600帧）：28+12+29+22+17 PASS。
最终148 PASS，其中11项截图保存；失败计数均0，日志未见SCRIPT ERROR。初次新增相邻入口检查错误假设目标坐标就是实际停点，导致4项级联失败；实际角色距目标有步进容差，修正测试为按实际位置计算期望最近目标，并在进入室内后正确退出，复跑全绿。未隐瞒这次失败，不把失败日志当通过证据。
测试仅用phase2_*、phase1_*隔离user://槽，未写玩家campaign_v1正式存档。

### 实际视觉检查
artifacts/phase2/street_shop_entrance.png、convenience_shop.png、resident_corridor.png、corridor_reloaded.png均实际输入图像上下文查看。中文、提示、角色和灰盒正常显示；出口标签与人物头部相叠，已向上移动，停止游戏修改后重跑并再次查看最终便利店/走廊图。资源无外部图片依赖，未将参考图铺底。只是功能灰盒，不称正式像素资产已完成。

### 未完成/限制与验收
住户门不可进入；便利店无交易、NPC或取餐室内化，原取餐在街道；没有改变剧情、没有新增音频/动画/最终美术。当前只验证Windows、720p和自动输入，没有人工长测或macOS验证。阶段2未完成，P2-03技术DONE，本次交付等待用户验收。
下一项仅建议P2-04：在现有路线基础上完善多订单状态与接取/取消规则；本次未执行。

### 可恢复版本
artifacts/phase2/phase2_verified.zip及phase2_verified_manifest.json包含当前游戏源/素材/配置/根文档；CRC和逐文件SHA256验证。不是Git提交，不含.git、外部参考、用户存档、引擎缓存。尚未另行解压该新包运行。

## 2026-11-04 / P2-04、P2-05及P2-06技术增量

### 授权和实现范围
用户要求一次多完成一些，执行阶段2剩余配送体验；开始检查Git并保存artifacts/phase2_delivery/before.zip和SHA256清单。保留旧脚本基类和已验证入口功能，以新子类接入，无第三方依赖、在线API或新美术/剧情扩张。

- 每天3份原创新订单：七号住户热汤¥6.50、早市摊主早餐热饮¥7、旧书摊主午餐¥5。基础配送自动接取，其余可选；可接单→待取餐→配送中→已送达，未取餐加单可以取消，基础单及取餐后禁止取消。未接加单收工转已结束，不影响收入；未处理的已接单阻止收工。完成三单实测总收入¥18.50，重复送达不再付费。
- Tab/按钮打开同源订单板，可接取、追踪和取消；打开时暂停城市移动。电脑接单窗口同一份订单数据，不再硬编码七号住户。修正保存按钮导致任务栏应用位置偏后的问题。
- 早市、书摊两个有头像标记的静态人物入口，现场E交谈/送达；地点到访、NPC遇见和交谈事件使用稳定ID去重。本轮不是NPC日程/自由行走系统。交谈消息和三单帖子回家后揭示；记录、收入、事件、人物、队列和取消状态随已有存档保存。
- 当前目标显示直线距离和屏幕方向；当前单完成但还有任务时要求切换追踪，避免错误引导回家。不是绕障自动寻路；仍需沿街道绕行。

### 文件修改记录
新增data/delivery_routes.json；scripts/world_delivery.gd、city_routes.gd、desktop_routes.gd、delivery_multi_test.gd、delivery_reload_test.gd（以及实际生成的Godot导入UID如存在）；ui/delivery_board.gd及UID。修改project.godot自动加载、scenes/city_delivery.tscn及desktop.tscn脚本入口；ROADMAP.md、DEV_LOG.md、CHANGELOG.md、RUN_PROTOTYPE.md。无删除、无Git提交或推送。
新增artifacts/phase2_delivery/下前后恢复ZIP/清单、import.log、multi.log、reload.log、phase1_route.log、phase1_reload.log、district.log、district_reload.log、round2.log、third.log、room.log、test_summary.json，以及01_order_board、02_market_delivery、03_desktop_orders、04_night_posts、05_restored_orders共5PNG。回归脚本另会刷新原证据PNG，不冒称新增艺术资产。

### 实际测试
使用D:/Godot_v4.7.2-stable_win64_console.exe：--headless --path . --editor --quit导入成功；--path . --script res://scripts/delivery_multi_test.gd --quit-after 20000（54 PASS）；独立新进程delivery_reload_test.gd --quit-after 600（14 PASS）。新测试实际输入驱动移动、E交互，订单板按钮通过信号触发，不是人工试玩。取消/基础单限制、重复接单/送达、错误地点拒绝、已接单阻止收工、三单队列夜间揭示、NPC交谈去重和保留、次日新增3单/历史保留、旧单拒绝再接、非法订单状态不改内存、取消后不付费均有检查。
原回归phase1_route_test.gd（15000帧）、phase1_reload_test.gd（600）、phase2_district_test.gd（16000）、phase2_reload_test.gd（600）、round2_smoke.gd/third_smoke.gd/room_walk_smoke.gd（均600）分别28、12、33、7、29、22、17 PASS。
最终216 PASS，其中16项为截图保存检查；失败0，日志无SCRIPT ERROR。初跑直线路径试图穿过中央占位碰撞物被阻挡，测试产生失败后停止该进程，增加沿街道绕行点，未修改碰撞或传送角色，复跑通过。测试仅使用multi_*、phase1_*、phase2_*独立user://文件，未覆盖正式campaign_v1存档。

### 真实视觉检查
5张新增PNG均实际作为图像输入查看。看见城市订单板与电脑接单布局正常、中文/按钮可读、三人夜间帖子及收入显示正确；初图发现已完成当前单时距离仍指回家而任务要求切换，已修复并重跑，最终5图再次查看。城市仍为原灰盒，人物仅头像/站立图，面板存在留白，不作为最终发行美术。

### 状态/未完成/下一步
P2-04、P2-05技术DONE；P2-06等待新玩家人工操作和整体验收，阶段2仍IN_PROGRESS。没有自动寻路、配送倒计时失败、NPC自主行为、正式街区像素替换或音效；取消是本轮实现的异常处理分支，不声称实现全部失败类型。旧存档当日订单保持原样，休息到下一天生成新3单。macOS、更多屏幕比例、长时间操作未验证。
交付后等待用户阶段2验收；唯一下一项建议为人工试玩多单路线，确认引导可读性后再决定阶段3。

### 恢复版本
verified.zip和verified_manifest.json覆盖当前源/资源/数据/根文档，CRC与逐文件SHA256核对；before.zip保留改前状态。未做新包隔离恢复启动，不包含.git、用户存档、缓存、参考附件或历史截图档案。

## 2026-11-04 / P2-07、P2-08、P4-06 / 巡航与配送插曲

### 范围与实际实现
用户明确要求自动巡航、每日外卖变化、配送概率触发剧情。检查Git，保留未提交工作；artifacts/cruise_events/before.zip及before_manifest.json保存改前版本。未并行重构美术或确定主线真相。
- F/按钮自动巡航当前已接订单，完成取餐、送达后选下一份已接任务，全部处理后回家；未接加单不自动接。基于AStarGrid2D的0.5米网格，胶囊与向下屋顶射线检测现有物理障碍，经CharacterBody3D移动而非传送。绘制路线，WASD/方向键/F/E/Tab/失焦可停止或暂停，卡住1.5秒安全停止。打开订单板或出现插曲时暂停，恢复需主动按F；读档不自动恢复巡航。
- 每路线4种餐品、共12种；从本地池抽取，并排除前一天同路线餐品。只改变餐品与相应收件回复，不虚称收件人/地图每天更换。订单生成后保存具体内容，旧档不强制重写，下一天生成新菜单。
- 配置每次成功送达35%触发轻量插曲，3条原创事件：便签、共用伞、重复招呼。抽签与候选随订单保存，已保存订单不因重读档而重新随机；同一天不重复相同插曲。事件暂停巡航，选择记下会花5分钟存线索，继续配送不花时间，两种结果均有事件及夜间反馈。非法概率元数据拒绝读取。不存在在线API或新增依赖。

### 文件记录
新增data/courier_events.json；scripts/world_courier.gd、cruise_planner.gd、city_cruise.gd、cruise_event_test.gd、courier_reload_test.gd及实际Godot生成UID。修改project.godot、scenes/city_delivery.tscn接入新子类；scripts/city_routes.gd抽取可复用引导刷新；scripts/phase1_route_test.gd公共回归初始化固定不触发插曲的抽签值，避免旧流程检查被随机剧情干扰，新专用测试分别强制命中/未命中。修改ROADMAP.md、DEV_LOG.md、CHANGELOG.md、RUN_PROTOTYPE.md。无删除、无Git提交/推送；旧基类和资源保留。
新增artifacts/cruise_events/下前后ZIP/清单、import.log、cruise.log、reload.log、multi_regression.log、multi_reload_regression.log、phase1_route.log、phase1_reload.log、district.log、district_reload.log、round2.log、third.log、room.log、test_summary.json；5张最终PNG：01_cruise_route、02_delivery_event、03_event_night、04_restored_choice、05_next_day_orders。first_attempt.log和debug_stop.png是失败诊断资料，不算最终验收图。回归另刷新其原有截图。

### 实际测试与修复
Godot4.7.2 --headless --path . --editor --quit导入完成；实际OpenGL运行cruise_event_test.gd --quit-after 24000（25 PASS），courier_reload_test.gd --quit-after 1200（51 PASS）。前者实际巡航三单并回家、手动输入打断、下一天餐品变化、触发/不触发、事件暂停与记下选择、夜间反馈；后者独立新进程恢复未决/已决选择与抽签值、不自动重启巡航、继续分支无时间/线索消耗、非法元数据原子拒绝、事件不重复、连续11天相邻日不重复。
既有delivery_multi/reload、phase1_route/reload、phase2_district/reload、round2/third/room分别54/14/28/12/33/7/29/22/17 PASS。所有命令形式 --path . --script res://scripts/对应脚本 --quit-after（多单20000、阶段1路线15000、街区16000、其他600）。最终共292 PASS，其中21项是截图保存；无最终失败或SCRIPT ERROR。
初跑失败：胶囊形状查询无法识别完全处于三角面盒体内部的格点，巡航实际在墙边停住，后续测试因状态未完成又出现数组越界。停止该测试进程，保存first_attempt.log，测试加失败退出保护；规划增加从上方向下检测屋顶和0.4米安全边距，复跑三单通过。没有关闭碰撞或用传送掩盖。截图还发现事件期间旧时间/目标未刷新，已停止游戏修改后重新运行并截图检查。
概率两分支用固定抽签验证，正常游戏使用本地RNG；没有声称通过统计试验测得35%分布。独立user://courier_*测试槽及既有测试槽不覆盖正式campaign_v1存档。

### 真实视觉验收
5张最终图均进入图像上下文；核对巡航路线/按钮、事件面板文字和双选择、读档恢复一致、第二天不同餐品及夜间记录。修复事件时钟和目标陈旧提示后重新查看最终截图；没有将代码检查替代实际运行截图。

### 当前状态与限制
P2-07/P2-08/P4-06技术DONE，整阶段和人工体验仍待验收；事件仅3条轻量插曲，不是完整主线或感染者系统。巡航只限静态街道，室内仍手动；遇动态阻挡暂停等待处理；不自动领取补给、接取加单或代替选择。角色单帧、灰盒、缺少音效仍存在。未做macOS、长时间人工操作或所有屏幕比例验证。餐品有限池允许隔天之后重复，不宣称永久不重复；未来尚未生成的订单不属于已保存抽签承诺。
唯一下一步建议：设计一条跨两天的事件链（配送见闻→夜间调查→次日回访），本次不执行。

### 恢复点
before.zip保留改前版本；verified.zip和verified_manifest.json覆盖当前源码/数据/素材/根文档，CRC及SHA256逐文件核对。未把新包另行恢复运行，不包含Git历史、用户存档、缓存或参考附件。

## 2026-11-04 / P2-07修正 / 配送与收工分离
- 用户指出自动收工容易被误认为正在接下一单。开始检查Git，保留未提交工作并保存artifacts/cruise_boundary/before.zip及清单。
- scripts/city_cruise.gd删除自动return_home及其场景切换路径；启动、规划和运行三个位置均检查未完成已接订单。送完队列即原地停止、清除路线，不接新单、不移动到住所、不进入夜间。没有任务时禁用按钮，快捷键F同样拒绝；显式接新单后恢复，提示同步更新。剧情暂停/恢复也遵守该边界；玩家主动回家按E仍正常收工。
- 新增scripts/cruise_boundary_test.gd；修改scripts/cruise_event_test.gd的旧自动收工假设，改为实际输入手动回家。测试遇到操作系统失焦暂停时用F恢复，而不是禁用游戏安全暂停。更新ROADMAP、DEV_LOG、CHANGELOG、RUN_PROTOTYPE。无删除、无数据格式修改或Git提交。
- 实际Godot导入成功；cruise_boundary_test.gd --quit-after 16000（19 PASS）、cruise_event_test.gd --quit-after 24000（33 PASS）、courier_reload_test.gd --quit-after 1200（51 PASS）、phase1_route_test.gd --quit-after 15000（28 PASS），均--path . --script res://scripts/对应文件，用Godot4.7.2 OpenGL运行。合计131 PASS，其中10项截图保存，最终日志无FAIL/SCRIPT ERROR。没有声称重新跑本次范围之外的全部旧桌面测试。
- 检查覆盖一单结束留城/白天、未接加单保持可接、无任务F拒绝且位置不变、夜间队列未揭示、新接单启用、第二单再停止、多单队列、最后一单剧情处理后不巡航回家，以及手动回家/调查/休息。
- 实际查看本目录01_stopped_after_delivery.png、02_new_order_available.png图像；发现接新单后底部残留“暂无订单”，已修复，停止游戏修改后重新运行并再次查看两图，文字和按钮状态一致。都是游戏真实运行画面。
- 一次复测因真实窗口失焦触发安全暂停，导致测试后续状态不满足并级联失败，历史日志focus_interruption.log保留；没有移除安全暂停。调整测试恢复操作后最终通过，不将中断那次称为通过。
- 证据新增artifacts/cruise_boundary/import.log、boundary.log、cruise_event.log、reload.log、manual_route.log、test_summary.json、两张新PNG；其余测试按原路径刷新旧截图。before/verified.zip及SHA256清单为前后恢复点，压缩包CRC/哈希已校验，未另行解压启动。
- 限制：城市仍灰盒、人工长时间与macOS未验证；巡航不会自动寻找或接受新单。完成当前明确修正，等待用户验收。下一项仅建议试玩确认“配送结束”和“主动收工”的提示是否足够清楚，不自动执行其他任务。

## 2026-11-04 / P3-06、P3-07、P3-08 / 夜间信息与次日行动

### 范围及实际完成
用户明确确认前阶段并允许进入阶段3。开始核对Git及AGENTS/GDD/ROADMAP，保留未提交修改；artifacts/phase3/before.zip和before_manifest.json是改前恢复点。沿用所有配送、巡航、菜单和原桌面基类。
1. 新data/night_content.json包含4条原创条件内容：七号门口便签动态、早市通道资讯、便利店货架资讯、回访后第二晚模拟视频。解锁需游戏日期/夜晚/地点/来源事件满足；来源稳定ID保存，界面展示可读地点来源。8帖/10资讯/6视频公共缓存保留，静态帖子时间标明往期；今日事件不再塞入往期门口帖子。追加的视频复用原有合法本地图片，不请求网络或冒称真实视频。
2. 消息采用稳定person_id和message_id，单独保存收件已读ID、用户本地留言；不会重复收件、不会把其他联系人同时标为已读。旧记录没有日期时显示既有存档记录，不伪造收到日期。便签、离线助手历史和线索继续使用共享存档，新增可选night_system扩展存放聊天/已读、解锁与回访。加入保存扩展钩子，没有在外层重复改写存档或丢弃旧字段；旧schema无该扩展仍可导入，解锁可依据已有事件恢复，缺失的聊天/预约不凭空捏造。
3. 一条原创便签回访链：夜间动态帖子详情中主动点击“记录线索/预约次日回访”，次日出现明确门口提示，实际移动到场按E核对；不与配送混为一谈，不增加配送收入，未到日期/未到场/重复核对均无效。回访记录下次收工后显示在动态/消息，且满足第二晚视频条件。没有确定感染源等主线事实。

### 文件记录
新增data/night_content.json；scripts/world_night.gd、desktop_night.gd、city_night_followup.gd、night_system_test.gd、night_reload_test.gd及实际生成UID。修改scripts/world_loop.gd（小型可选存档扩展钩子）、project.godot（WorldData子类）、scenes/desktop.tscn和city_delivery.tscn（新入口子类）；ROADMAP、DEV_LOG、CHANGELOG、RUN_PROTOTYPE。无删除、无第三方依赖、无Git提交或推送。
新增artifacts/phase3/下before/verified ZIP和清单、import.log、night.log、reload.log、cruise_boundary.log、multi.log、multi_reload.log、manual_route.log、manual_reload.log、district.log、district_reload.log、round2.log、third.log、room.log、courier.log、courier_reload.log、test_summary.json。新增01_source_and_followup、02_persistent_messages、03_daytime_followup、04_unlocked_video、05_restored_chat、06_followup_completed、07_unlocked_news共7张PNG。原回归按原路径刷新其既有截图，不将其声称为新增素材。

### 实际运行、结果和修正
D:/Godot_v4.7.2-stable_win64_console.exe实际OpenGL运行；首次--headless --path . --editor --quit成功导入。
--path . --script res://scripts/night_system_test.gd --quit-after 30000：50 PASS，实际输入走到店铺/配送、手动回家/开电脑、帖子详情按钮预约、发送留言、关闭重开、便签与线索保存、次日现场E回访、第二晚视频。
--path . --script res://scripts/night_reload_test.gd --quit-after 1800：17 PASS，新进程验证聊天、不同联系人的读/未读、便签、线索/助手历史、目标和解锁持久化；未知聊天对象、重复消息ID拒绝且不部分污染现状；兼容无night_system的旧档；完成的任务不重复。
原回归：cruise_boundary（16000帧）19、delivery_multi（20000）54、delivery_reload（600）14、phase1_route（15000）28、phase1_reload（600）12、phase2_district（16000）33、phase2_reload（600）7、round2（600）29、third（600）22、room_walk（600）17、cruise_event（24000）33、courier_reload（1200）51，均相同--path/--script形式。
最终386 PASS，其中30项为截图保存，失败0、最终日志无SCRIPT ERROR。测试为真实渲染+自动输入/按钮回调，不是人工连续游玩。概率相关旧回归仍固定抽签分支，新阶段没有更改概率值。一次旧巡航测试遇系统失焦后按既有测试逻辑F恢复，未取消游戏失焦安全暂停。
本次没有阻塞性运行报错。实际看图发现回访入口初在折叠区下方，移到帖子上部；内部事件编号改为可读来源，ID留在数据；新视频长文自动换行、资讯封面匹配来源；第二晚视频条件从仅日期/配送进一步收紧到已完成回访。停止运行后修改，重新跑新流程和恢复测试，最终7图查看。

### 截图验收
以上7图都实际作为图像输入查看。核对文字、按钮、窗口遮挡与比例、消息保存后的实际内容、次日目标标记及完成后隐藏、第二晚视频来源/封面、资讯来源。Windows720p可读；界面风格沿用现有窗口体系，未重做正式美术。

### 已知限制和验收
当前只有4条解锁内容和1条回访链；原公共缓存保留，并非所有互联网内容均需玩家先到场。视频仍为静态封面/模拟进度，无真实解码或音频。留言本地存储，不假称NPC在线回复；仍需点击保存才保证跨重启恢复。未做macOS、长时间人工试玩和所有屏幕比例测试。回访需手动前往，巡航只负责已接配送且不收工，边界回归通过。
P3-06/P3-07/P3-08技术DONE；阶段3等待用户整体验收，不自动开展阶段4。唯一下一项建议为试玩这条两日调查链，确认信息到行动的引导足够清楚。

### 恢复版本
before.zip保存改前版本；verified.zip和verified_manifest.json保存当前源/资源/数据/根文档，CRC与逐文件SHA256核对。尚未把这个新包另行解压运行。不含.git、用户存档、缓存或外部参考附件。测试使用phase3_*及既有独立user://槽，不覆盖正式campaign_v1存档。

## 2026-11-05 — P4-01首段异常规则提案
- 用户允许进入阶段4，阶段3当前技术原型归档DONE；P4-01保持IN_PROGRESS待规则批准。
- 新增PHASE4_DESIGN.md：首段目标、五状态、声音/视线边界、非致命撤离、昼夜来源链、存档及巡航兼容、验收方法；全部为提案，未实现异常功能。
- 仅修改管理文档，不修改游戏核心代码、场景或素材。保留全部既有未提交修改。
- Godot 4.7.2 OpenGL实际运行城市，current_city.png保存成功并实际读图：中文/按钮可读、HUD无明显遮挡，城市仍为灰盒；不是异常玩法截图。
- cruise_boundary_test.gd实际运行19 PASS（含2次截图保存），0失败、进程退出0；巡航仅已接单、送完不收工、手动回家正常。测试重新生成artifacts/cruise_boundary/01_stopped_after_delivery.png和02_new_order_available.png，未作为本轮逐图视觉验收。
- 证据：artifacts/phase4_design/capture.log、cruise_boundary.log、current_city.png、capture.gd。macOS、异常状态机和剧情链尚未验证/实现。
- 恢复：before.zip及before_manifest.json保留376文件；verified.zip附SHA256清单并校验CRC/逐文件哈希。未做本轮隔离恢复启动。

## 2026-11-05 / CH01连续实施（部分完成）
- 审计完整开发包，原文件哈希保护，未移动/覆盖；docs已创建。此前P4规则提案被新包无追逐规格替代。
- 新增data/ch01_story.json、ch01_sources.json，15节点、章节共享聊天/五新闻；新增scripts/ch01_director.gd、ch01_play.gd、ch01_map.gd、ch01_peephole.gd、ch01_test.gd与scenes/ch01.tscn。
- 修改project.godot添加Chapter；start_loop.gd新增章节入口与继续；desktop_night.gd新增章节收件箱/返回按钮。原订单/生命/物资数据复用，但章节真实配送衔接未完成。
- 新增docs四份状态/日志/测试/素材文件；更新ROADMAP、DEV_LOG、CHANGELOG、RUN_PROTOTYPE。
- 实测：十逻辑分支与六截图保存0失败；巡航19 PASS、夜间50 PASS。图片实际读取并修复手机遮挡。详见docs/CH01_TEST_REPORT.md。
- 未达到整包80–90%目标：地图灰盒、空间触发/手机分栏/真实订单/正式立绘和音效仍缺。没有把Phase1–6标DONE。
- 无删除，无提交，无push。artifacts/ch01/pre_ch01.zip为实施前源代码快照，不包含用户存档、.git和整包；原包单独保留。恢复前应先备份当前工作树，不建议直接覆盖解压。

## 2026-11-05 — CH01质量整改技术检查点
- 实现六场景资源映射、按图位置/状态持久化、开发入口分离、数据分页对白/头像/逐字/输入锁、五NPC统一素材、便利店四方法与破损状态、敲门分阶段/来电/身份延迟、自然语言结尾。
- 手机与原电脑共用章节消息/新闻/已读；章节桌面保存独立，不覆盖旧配送存档；原配送API、收入、有限拾取/购物/消耗/负重/耐久和接触遭遇验证。
- 新增原创PNG与5本地合成WAV、六地图、测试脚本；未使用在线API或第三方资产。
- 已实际运行完整交互路线、另一结局UI路线、连续物理步行、边界与跨进程、旧夜间/窗口/巡航回归；逐项结果见artifacts/ch01_qa/test_summary.json，最终无FAIL/SCRIPT ERROR。26张实际PNG已逐图读取。
- 初期解析/输入/对白/版本校验/物理回调/位置竞争等错误已修复并复跑。美术仍简化，全面整改保持IN_PROGRESS，非正式发行验收。
- 详见docs/CH01_IMPLEMENTATION_STATUS.md、CH01_BUGFIX_REPORT.md、CH01_TEST_REPORT.md、CH01_ART_ASSET_GAP.md。保留artifacts/ch01_qa/before.zip及SHA256清单。

## 2026-11-05 — Git检查点与双工具统一规则
- 沿用既有Git历史，基线提交e1c5c0f收录当前工程与实际CH01验收记录；没有重新初始化或推送。
- 新增CLAUDE.md首行@AGENTS.md；AGENTS.md新增交替写入/提交/交接规则；新增docs/AI_COLLABORATION.md和.gitattributes。
- .gitignore在基线中补齐缓存、备份、生成翻译、本地配置忽略，并保留本轮26张PNG和最终日志。Godot .uid仍跟踪。
- 检查原整合包哈希不变、暂存文本无凭据模式命中、无大于10MB的新文件、Git diff检查。Claude Code未启动，不声称客户端导入测试通过。
- 游戏逻辑在本次协作配置任务中未继续修改；本地checkpoint后准备交给用户选择的下一工具。

## 2026-11-05 — 修复开场卡顿与越级地图
- 新档最后一单明确为已取餐/配送中；E送达只执行一次交付并提示到账及老周修车位置，兼容开场旧订单的待取餐状态。
- 增加地图邻接与剧情门槛：1203取餐前不进幸福花园，电梯剧情前不进便利店；群聊/私信阶段不允许直接出门跳过。免费回家仍保留，未完成主线不会被结算掉。
- 关键送餐/取餐/修车/出入口改为可读文字标记，开场目标明确位置；对白支持E/空格/回车继续。
- 修改scripts/ch01_director.gd、ch01_play.gd、ch01_map.gd；新增ch01_opening_test.gd及Godot UID。未覆盖原整合包和用户存档。
- 实测opening.log 13 PASS/0失败；连续物理步行主线walk.log 216 PASS/0失败。实际查看opening_fixed.png：目标、送餐处、修车与入口文字可见，无明显遮挡。
- 限制：未读取或诊断用户实际卡住的存档；未宣称所有旧异常存档自动修复。当前修复覆盖复现到的开场状态/提示与越级入口问题。

## 2026-11-05 数字生活系统接管：Phase 1—8 技术交付

- MessageManager 统一消息、演出队列、已读、新闻、通知、电话与存档；手机/电脑共用 MessagePanel、NewsPanel。保留 Chapter 原剧情、地图、配送与继承链。
- 骑手群逐条消息、固定人物素材/昵称/时间、左右气泡、输入中、自动滚动、预设回复；关闭窗口继续演出，隐藏窗口不自动已读。
- WorldData 游戏分钟与 UI 秒级演出分离；稳定 ID 去重，时间/剧情/场景/阅读/回复条件控制发布。夜间 20:30、22:17、23:35 分阶段解锁，不提前发布结尾新闻。
- Chapter/旧夜间存档均保存统一快照，保留旧字段作兼容投影；旧档历史迁移、不重播已读，未知旧联系人历史保留在恢复线程。恢复演出剩余时间与回复顺序。
- 修复消息 HUD 未即时刷新、滚动布局时序、新闻已读递归、通知节点未挂载造成资源泄漏、电话接听状态与提前身份暗示。未新增网络服务、依赖、TimeManager 或美术资产。
- Windows Godot 4.7.2 实际运行 15 个测试脚本：898 PASS、0 FAIL/ERROR/WARNING（计数包含重复断言与截图保存，不是898项独立功能）。详细日志见 artifacts/digital_systems/test_summary.json。
- 新的9张专用运行截图已作为图像实际检查；既有回归截图同步重新生成，未将其全部视为本轮逐张美术验收。
- 限制：macOS、真人完整盲玩、主观音效试听与长时性能未验收；本次不宣称第一章正式美术或完整游戏完成。等待用户试玩确认，不进入新阶段。

## 2026-11-05 消息自动推送与12/14楼分离修复
- 消息达到时间/剧情条件后自动启动逐条演出，不再等待逐个打开联系人；手机打开时保留新消息横幅，点击切换到对应会话。新挂载通知控件补显尚未展示的通知，保留已展示标记。
- 新增hallway12.tscn；12楼仅1201—1203，14楼仅1403—1405。三栋入口只进楼，1203门口才结算；选择调查后从楼梯交互进入14楼，1404门口触发剧情，跳过调查仍直接进入下行事件。
- 旧1203存档的hallway位置迁移到hallway12。补测发现读档后原配送位置未同步会导致交付失败，已在门口交付时适配。可中途回家再入楼，楼层位置分别保存。
- 实际Godot4.7.2 Windows图形运行：message_floor_fix_test 20、messaging_core_test 24、messaging_ui_test 8、ch01_qa_test 228、ch01_alternate_qa 210 PASS；最终日志均无FAIL/ERROR/WARNING。合计490次断言含截图，不等于490个功能。首次受限运行缓存目录报错，后续允许写入测试目录后重新运行通过。
- 真实截图artifacts/digital_systems/10_private_push.png、11_floor12.png、12_floor14.png已输入模型视觉检查：手机旁横幅可见，中文正常，两层门牌独立，目标指引匹配。楼梯仍为交互入口，未制作可逐级行走的楼梯美术；楼道沿用现有简化美术。macOS未验证。
- F5主场景；群聊到达后等待推送，手机内也可点击其他联系人横幅；三栋入楼后到1203按E，选择调查后到楼梯标记按E，再到1404按E。用户体验验收待确认。

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
