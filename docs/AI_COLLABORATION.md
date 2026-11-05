# 双工具协作与交接

日期：2026-11-05。规则主文件：根目录AGENTS.md；CLAUDE.md只导入主文件。

## 当前交接
- 当前工作：Codex已停止游戏逻辑修改，已将历次成果与本轮CH01技术整改建立基线提交`e1c5c0f`；本次只补Git协作规则。
- 写入方：本轮收尾后无活动写入方；由用户指定下一位工具。Claude开始写入前应先确认本轮已结束、工作树干净。
- CH01整体仍IN_PROGRESS：核心技术路径已实测，建筑/家具/人物与动作演出仍简化，不能当作正式视觉验收完成。
- 继续前必读：CH01_IMPLEMENTATION_STATUS.md、CH01_BUGFIX_REPORT.md、CH01_TEST_REPORT.md、CH01_ART_ASSET_GAP.md。
- 原始HISO_CH01_Development_Pack保持原位，原始Markdown/JSON/CSV哈希不变；不使用旧PHASE4_DESIGN中的追逐提案。

## 每次切换工具
1. 当前工具完成授权范围，停止运行中的测试游戏，不再改文件。
2. 检查diff、运行对应测试、只暂存需要提交的文件；不得纳入凭据/缓存/备份。
3. 本地commit并报告短ID、测试、未完成事项；确认`git status --short`无意外变化。
4. 下一个工具重新检查状态和最近提交，再开始修改。不要仅凭聊天说“已提交”判断。

已有用户未提交改动不是本工具的成果：先保留，确认归属和任务范围。不要自动stash/pop、checkout覆盖或reset/clean。干净工作树不必空提交。

## 本地命令（在工程根目录）
```powershell
git status --short
git log -3 --oneline
git diff --stat
# 任务结束后，用明确文件列表暂存，再提交：
git add -- <本次修改的文件>
git diff --cached --check
git commit -m "fix: 描述本次变更"
```

若Git提示目录所有权不匹配，可对当前调用使用：
```powershell
git -c safe.directory=D:/IRISgame/Humanity_Is_Still_Online_V1.0/Humanity_Is_Still_Online status --short
```
不要设置通配`safe.directory=*`。现有仓库已初始化，不需要再git init。本轮未推送远端。

## Godot与验证
- 正式入口：project.godot / scenes/start.tscn，F5；第一章直接预览scenes/ch01.tscn，F6。
- 专门调试入口：scenes/ch01_debug.tscn，默认正式界面不启用F8。
- 本机引擎：`D:\Godot_v4.7.2-stable_win64_console.exe`；新机器自行定位4.x引擎，不要求同盘符。
- 示例：`& 'D:\Godot_v4.7.2-stable_win64_console.exe' --path . --script res://scripts/ch01_qa_test.gd`
- 其他测试：ch01_alternate_qa、ch01_edge_test、ch01_reload_qa（先运行edge产生独立测试存档）、ch01_walk_qa、ch01_visual_qa；旧系统night_system_test、round2_smoke、cruise_boundary_test。
- 实际截图在artifacts/ch01_qa/；不可把脚本通过当作视觉验收。修改活跃场景之前停止游戏。
- 编辑器有未保存场景时先由操作者保存或关闭，再让外部工具改同一文件；完成后重新加载磁盘内容。

## 分支与恢复
同目录顺序开发优先；只有用户明确授权并行时才创建独立worktree与分支。Git能追溯历史，不能自动防止覆盖。需要比较旧版时优先`git show <commit>:<file>`；需要完整旧版时另建worktree，不对有未提交修改的当前目录强制重置。

备份ZIP与历史大截图留本地并忽略；当前源代码、原创素材、整合包文档、26张本轮截图与最终测试日志纳入基线。已跟踪的少量旧截图不会因为新ignore规则消失。

## Claude Code载入检查
CLAUDE.md首行实际为`@AGENTS.md`，不放代码块、不加引号。启动Claude Code后用`/memory`或`/context all`检查加载的规则；本轮没有启动Claude Code，因此不声称验证过客户端实际载入。
官方依据：https://code.claude.com/docs/en/memory （Import additional files / AGENTS.md）。不要依赖各版本的隐式回退行为；显式导入共享主文件。

## 2026-11-05 / Codex接管数字生活系统（实施前声明）
用户已将原Claude职责整体授权给Codex，覆盖message service、聊天UI、手机、desktop_night、Chapter及存档桥接、project.godot。当前只有Codex写入，不启动并行Agent。
审计纠正：第一章两端已共用Chapter；WorldNight已有发送/持久化，desktop.gd是旧基类而非当前唯一实现。四份原文中的完成勾选不作为测试证据。
实施采用一个MessageManager（含news/notification/call记录），稳定数据ID、JSON字典、业务送达分钟与UI演出秒分离；不新建TimeManager，不删历史，不重构继承链。共用聊天控件，旧字段仅作迁移/兼容投影。八阶段连续实施，以Godot实测为内部关卡。
