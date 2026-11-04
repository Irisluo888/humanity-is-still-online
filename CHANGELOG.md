# CHANGELOG

本文件从项目 V1.0 基线开始记录实际开发变更。只记录已实施并验证的代码、资源或配置变更；设计规划不应写成已完成的开发成果。

## V1.0 — 项目基线

- 建立项目设计文档与 Codex 开发规范。
- 技术路线：Godot 4.x + GDScript。
- 目标平台：Windows / macOS。
- 开发原则：免费工具优先、离线优先、不使用付费 API。
- 确定核心调性：黑色幽默 + 潮酷 Y2K。
- 确定原创虚构平台及知识产权、素材许可证规范。
- 确定第一阶段 MVP 范围与分阶段验收标准。
- 当前尚未创建或测试 Godot 工程；实际游戏开发尚未开始。

## 2026-11-04 — 首个可视化原型
- 新建 Godot 4 工程、启动菜单、六应用本地桌面及正交 3D 灰盒。
- 所有示例内容原创；无外部资产、插件及网络依赖。
- 尚无存档、角色移动、音频与完整生存系统。
- 环境未发现 PATH 中的 Godot，未进行引擎运行验证。

## 2026-11-04 — 开发报告规范
- AGENTS.md：加入长期强制执行的七项开发报告格式、操作日志维护与开发纪律。
- CHANGELOG.md：记录本次规范变更。
- 测试：Python 文本核对通过，确认七项标题、日志规则和开发纪律均已写入且章节无重复；本次未修改游戏代码，未执行 Godot 测试。

## 2026-11-04 — 正式像素方向与桌面框架
- AGENTS.md、GDD_LITE.md、MVP_TASKS.md、IP_AND_ASSET_RULES.md：同步像素美术与功能型应用名称；新增 ART_DIRECTION.md 记录参考用途、像素规则、信息架构及现有冲突。
- scripts/desktop.gd、ui/desktop_window.gd、ui/kit.gd：程序壁纸与图标、任务栏、时间、六种布局、窗口拖动/关闭/最小化/置前及滚动；本地检索与分类/联系人交互。
- scripts/world_data.gd、project.godot、scripts/city.gd：共享人物/地点/订单/事件数据与刷新信号；灰盒展示同源订单摘要。
- data/apps.json 退役独立内容副本；RUN_PROTOTYPE.md 更新体验步骤；scripts/desktop_smoke.gd 新增自动检查。
- Godot 4.7.2 headless：编辑器加载、启动菜单、灰盒启动完成；六布局、恢复、关闭及共享事件刷新测试输出 PASS。沙箱初次运行出现证书/日志/设置权限错误，正常权限重跑无该错误。
- 尚未人工验收鼠标拖动、滚动、焦点与视觉效果；未生成截图。视频为占位，配送未实现，共享数据无持久化，旧灰盒未替换为正式美术。

## 2026-11-04 — 八图导入与桌面视觉样板
- 安全检查：当前目录为Godot项目根目录；git status报告非Git仓库，无法识别提交状态。修改前脚本/场景/数据/规范快照保存于 artifacts/pre_visual_pack_snapshot/，原脚本未重写。
- 解压视觉参考整合包，原名复制8张PNG至 references/visual/ 两分类；逐张实际查看，新增 REFERENCE_ANALYSIS.md、UI_STYLE_GUIDE.md、ASSET_PLAN.md。参考及快照目录加入.gdignore。
- 新增 tools/draw_desktop_assets.py 与 assets/pixel_desktop/ 下23张原创PNG及Godot导入元数据：1壁纸、6图标、8头像、4缩略图、4控制/状态图标。无新增依赖或在线调用。
- 新增 scripts/desktop_visual.gd（及UID），复用旧桌面与窗口管理；scenes/desktop.tscn 改为加载视觉子类。实现三栏图文动态、分类/点赞、联系人/未读点/时间/气泡/本地留言；保留其他四应用和共享事件读取。
- 新增 scripts/visual_smoke.gd、scripts/capture_ui.gd（及引擎生成UID）；ART_DIRECTION.md、RUN_PROTOTYPE.md补充规范与体验入口。
- Godot 4.7.2：原桌面冒烟与新视觉冒烟均输出PASS（分类、联系人、本地留言、最小化恢复、置前、拖动事件处理、共享刷新、六应用、关闭）。真实OpenGL运行生成1280×720四状态截图和1920×1080叠放截图，已查看并修正消息输入行横向溢出。
- 限制：拖动为自动事件处理检查，未做人工鼠标全流程；素材仍为原创程序像素样板，环境细节低于参考精度。原项目尚无真实配送昼夜闭环，不声称已实现；本地留言不持久化，未验收macOS。

## 2026-11-04 — Git 仓库接入
- 新增 .gitignore，排除Godot缓存、本地存档、敏感配置、未授权再分发的参考图与本地快照；保留原创资产、视觉规范和运行截图。
- 检查用户提供的GitHub远程仓库，当前无分支；准备以main作为工程初始分支。
- 本次仅整理版本控制，不修改游戏逻辑；未重复执行Godot测试。
