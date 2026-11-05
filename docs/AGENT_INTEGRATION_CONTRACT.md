# Agent 协作契约

**项目**: 《人类暂未下线》  
**日期**: 2026-11-05  
**参与方**: Claude (Architecture Agent) & Codex (Content & Gameplay Agent)  
**目的**: 明确数字生活系统重构期间的职责边界、协作接口和冲突解决机制

---

## 1. 协作原则

### 1.1 基本原则

1. **互不覆盖** — 每个文件在同一时间只由一个 Agent 修改
2. **接口优先** — 通过明确的接口通信，而非直接修改对方的模块
3. **版本控制** — 使用 Git 分支隔离并行工作，避免直接冲突
4. **文档驱动** — 任何架构变更都必须先更新文档，再修改代码
5. **测试保护** — 修改前运行相关测试，修改后立即验证

### 1.2 沟通机制

**正式沟通**:
- 修改共享文件前，必须在 `docs/AI_COLLABORATION.md` 中声明
- 每次交接时，更新交接记录并提交基线 commit
- 重大架构变更需要生成设计文档供用户审查

**非正式沟通**:
- 在 commit message 中标注相关 Agent (`[Claude]`, `[Codex]`)
- 使用 Git branch 命名约定 (`claude/feature-name`, `codex/feature-name`)

---

## 2. 职责划分

### 2.1 Claude 的职责

**模块**:
- `scripts/message_manager.gd` (新建)
- `scripts/notification_manager.gd` (新建)
- `scripts/news_manager.gd` (新建)
- `scripts/time_manager.gd` (新建)
- `scenes/phone.tscn` (新建)
- `scripts/phone.gd` (新建)
- `scripts/desktop.gd` (重构 — 需协调)
- `ui/desktop_window.gd` (轻微修改 — 需协调)

**数据文件**:
- `data/message_schemas.json` (新建)
- `data/contacts.json` (新建)
- `data/news_templates.json` (新建)

**文档**:
- `docs/DIGITAL_SYSTEMS_AUDIT.md` (本文档)
- `docs/DIGITAL_SYSTEMS_ARCHITECTURE.md`
- `docs/AGENT_INTEGRATION_CONTRACT.md` (本文档)
- `docs/MESSAGE_SYSTEM_API.md` (新建)

**不可触碰**:
- `scripts/ch01_director.gd` — **Codex 的核心文件，除非明确协调**
- `scripts/ch01_play.gd` — **Codex 的核心文件，除非明确协调**
- `scripts/ch01_map.gd` — **Codex 独有**
- `scripts/world_courier.gd` — **Codex 独有**
- `data/ch01_story.json` — **Codex 的剧情数据，只读**
- `scenes/ch01_maps/*.tscn` — **Codex 的场景文件**

### 2.2 Codex 的职责

**模块**:
- `scripts/ch01_director.gd` (第一章剧情管理器)
- `scripts/ch01_play.gd` (第一章主场景)
- `scripts/ch01_map.gd` (第一章地图逻辑)
- `scripts/ch01_peephole.gd` (猫眼视觉)
- `scripts/world_courier.gd` (配送系统)
- `scripts/world_delivery.gd` (订单系统)
- `scripts/world_loop.gd` (游戏循环)
- `scripts/world_third.gd` (基础数据)
- `scenes/ch01_maps/*.tscn` (所有第一章场景)

**数据文件**:
- `data/ch01_story.json` (第一章剧情数据)
- `data/ch01_sources.json` (第一章素材索引)
- `data/courier_events.json` (配送事件)
- `data/delivery_routes.json` (配送路线)

**美术素材**:
- `assets/art/ch01/` (所有第一章美术资源)
- `assets/audio/ch01/` (所有第一章音频)

**不可触碰**:
- `scripts/message_manager.gd` — **Claude 的核心模块**
- `scripts/notification_manager.gd` — **Claude 的核心模块**
- `scripts/news_manager.gd` — **Claude 的核心模块**
- `scripts/time_manager.gd` — **Claude 的核心模块**
- `scenes/phone.tscn` — **Claude 的新UI**

### 2.3 共享区域（需协调）

**高风险共享文件**:
| 文件 | 主要负责人 | 修改规则 |
|------|------------|----------|
| `scripts/desktop.gd` | Claude | Codex 只读，Claude 重构时通知 |
| `ui/desktop_window.gd` | Claude | Codex 只读，Claude 修改时通知 |
| `project.godot` | 双方 | 新增 Autoload 需协调 |
| `data/night_content.json` | Codex | Claude 可建议格式变更 |

**存档系统**:
- `Chapter.save()` / `Chapter.restore()` — Codex 负责
- `MessageManager.save_data()` / `load_data()` — Claude 负责
- **集成**: Codex 需要在 `Chapter.save()` 中调用 `MessageManager.save_data()`

**时间系统**:
- `TimeManager` (Claude) 提供时间推进接口
- `Chapter` / `WorldLoop` (Codex) 调用 `TimeManager.advance_time()`
- **集成**: Codex 需要将时间推进逻辑迁移到 `TimeManager`

---

## 3. 协作接口

### 3.1 消息系统接口

**Claude 提供** (`MessageManager`):

```gdscript
# Codex 调用这些方法来触发消息
MessageManager.queue_message(thread_id: String, sender_id: String, text: String, arrive_at: int) -> Message
MessageManager.send_message(thread_id: String, text: String) -> Message
MessageManager.get_thread_messages(thread_id: String) -> Array[Message]
MessageManager.get_unread_count(thread_id: String) -> int
MessageManager.mark_read(thread_id: String) -> void

# Codex 订阅这些信号
signal message_arrived(message: Message)
signal player_sent_message(message: Message)
signal unread_count_changed(thread_id: String, count: int)
```

**Codex 调用示例**:

```gdscript
# ch01_director.gd 第31行改造后
if id=="group":
 # 旧代码：publish_chat("rider_group")
 # 新代码：
 for i in range(catalog.chat["rider_group"].size()):
  var text = catalog.chat["rider_group"][i]
  var sender_id = _extract_sender(text)
  MessageManager.queue_message(
   "rider_group",
   sender_id,
   text,
   TimeManager.minute + i * 2  # 消息间隔2分钟
  )
```

### 3.2 时间系统接口

**Claude 提供** (`TimeManager`):

```gdscript
# Codex 调用这些方法来管理时间
TimeManager.advance_time(minutes: int) -> void
TimeManager.get_time_text() -> String
TimeManager.jump_to(day: int, minute: int) -> void

# 只读属性
TimeManager.day: int (当前天数)
TimeManager.minute: int (当前分钟)
TimeManager.period: String ("day" | "night")

# Codex 订阅这些信号
signal time_updated(current_minute: int)
signal day_changed(day: int)
signal period_changed(period: String)
```

**Codex 调用示例**:

```gdscript
# world_delivery.gd 第62行改造后
func pickup_order() -> bool:
 # ...
 # 旧代码：minute += 45
 # 新代码：
 TimeManager.advance_time(45)
 stamina = maxi(0, stamina-8)
 # ...
```

### 3.3 新闻系统接口

**Claude 提供** (`NewsManager`):

```gdscript
NewsManager.queue_news(title: String, content: String, category: String, publish_at: int) -> NewsArticle
NewsManager.get_all_news() -> Array[NewsArticle]
NewsManager.get_unread_news() -> Array[NewsArticle]
NewsManager.mark_read(article_id: String) -> void

signal news_published(article: NewsArticle)
```

**Codex 调用示例**:

```gdscript
# ch01_director.gd 第35行改造后
if id=="night":
 # 旧代码：for i in range(3):publish_news(i)
 # 新代码：
 for i in range(3):
  var news = catalog.news[i]
  NewsManager.queue_news(
   news.title,
   news.text,
   "normal",
   TimeManager.minute
  )
```

### 3.4 通知系统接口

**Claude 提供** (`NotificationManager`):

```gdscript
NotificationManager.post_notification(type: NotificationType, title: String, body: String) -> void

signal notification_posted(type: NotificationType, title: String, body: String)
```

**Codex 订阅示例**:

```gdscript
# ch01_play.gd 中
func _ready() -> void:
 # ...
 NotificationManager.notification_posted.connect(_show_notification_toast)

func _show_notification_toast(type, title, body) -> void:
 # 显示桌面通知气泡
```

---

## 4. 集成步骤

### 4.1 阶段划分

**阶段0: 准备（当前）**
- [x] Claude 完成审计报告
- [x] Claude 完成架构设计
- [x] Claude 完成协作契约
- [ ] 用户审查三份文档
- [ ] 确认是否批准重构

**阶段1: Claude 独立开发（1周）**

**目标**: 创建新的消息系统，不影响现有代码

**Claude 的任务**:
1. 创建 `scripts/message_manager.gd`
2. 创建 `scripts/time_manager.gd`
3. 创建 `scripts/notification_manager.gd`
4. 创建 `scripts/news_manager.gd`
5. 在 `project.godot` 中注册 Autoload
6. 编写单元测试 (`tests/test_message_manager.gd` 等)
7. 创建 API 文档 (`docs/MESSAGE_SYSTEM_API.md`)

**Codex 的任务**:
- 继续第一章的内容开发（不影响）
- 审查 Claude 的 API 文档
- 提出接口设计建议

**交接点**:
- Claude 完成后，提交 commit: `feat: add message system core modules`
- 更新 `docs/AI_COLLABORATION.md`，标记阶段1完成
- 通知 Codex 可以开始查看新API

**阶段2: UI 层适配（1周）**

**目标**: 重构电脑和手机 UI，使用新的消息系统

**Claude 的任务**:
1. 创建 `scenes/phone.tscn` 和 `scripts/phone.gd`
2. 重构 `scripts/desktop.gd` ← **高风险**
3. 修改 `ui/desktop_window.gd` ← **中风险**
4. 测试手机和电脑UI的独立功能

**Codex 的任务**:
- **暂停修改 `scripts/desktop.gd`**
- 如果必须修改，使用独立分支并通知 Claude

**协调点**:
- Claude 开始修改 `scripts/desktop.gd` 前，检查 Git 状态
- 如果 Codex 有未提交的修改，先保护并协商
- Claude 完成后，运行现有测试确保无破坏

**交接点**:
- Claude 提交 commit: `refactor: adapt desktop and phone UI to MessageManager`
- 更新 `docs/AI_COLLABORATION.md`
- Codex 验证桌面UI功能正常

**阶段3: 第一章集成（1周）**

**目标**: 修改 `Chapter` 和 `ch01_play.gd`，使用新系统

**分工策略**: **由 Codex 主导，Claude 协助**

**原因**:
1. `ch01_director.gd` 和 `ch01_play.gd` 是 Codex 最熟悉的文件
2. 第一章的剧情逻辑只有 Codex 完全理解
3. Claude 提供技术支持和代码审查

**Codex 的任务**:
1. 修改 `Chapter.publish_chat()` 调用 `MessageManager.queue_message()`
2. 实现 `_extract_sender()` 辅助函数
3. 修改 `ch01_play.gd` 的手机UI，调用 `MessageManager` API
4. 移除 `state.messages` 和 `state.read`
5. 实现存档迁移逻辑 `_migrate_old_messages()`
6. 运行第一章全流程测试

**Claude 的任务**:
1. 提供 `_extract_sender()` 的参考实现
2. 提供存档迁移的参考代码
3. 审查 Codex 的修改
4. 协助调试集成问题

**协调点**:
- Codex 修改前，先在测试分支实验
- 每完成一个子任务，提交一个小 commit
- Claude 实时 review Codex 的 commit
- 如果遇到技术问题，Codex 在 commit message 中标记 `[HELP]`

**交接点**:
- Codex 提交 commit: `feat: integrate Chapter with MessageManager`
- 运行 `scripts/ch01_qa_test.gd` 确保第一章可通关
- 测试存档兼容性（加载旧存档 → 验证迁移成功）
- 更新 `docs/AI_COLLABORATION.md`

**阶段4: 全面测试与文档（3天）**

**Claude 的任务**:
1. 编写集成测试
2. 更新 `README.md` 和用户文档
3. 生成迁移指南 (`docs/MIGRATION_GUIDE.md`)

**Codex 的任务**:
1. 人工测试第一章完整流程
2. 测试极端情况（快进、回溯、存档/读档）
3. 报告 bug 给 Claude

**最终交接**:
- 双方确认所有测试通过
- 提交最终 commit: `chore: finalize message system integration`
- 更新 `CHANGELOG.md`

---

## 5. 冲突解决机制

### 5.1 文件冲突

**场景1**: Claude 和 Codex 同时修改了同一个文件

**解决步骤**:
1. 后提交的一方检查 Git 状态，发现冲突
2. 后提交方回滚本地修改，拉取最新代码
3. 重新应用自己的修改（手动合并）
4. 测试无误后提交，并在 commit message 中注明 `[MERGE]`

**预防措施**:
- 每次修改前先 `git pull`
- 修改共享文件前，在 `docs/AI_COLLABORATION.md` 中声明

**场景2**: 无法手动合并（逻辑冲突）

**解决步骤**:
1. 后提交方创建分支 `conflict-resolution`
2. 在分支中尝试合并
3. 在 `docs/AI_COLLABORATION.md` 中记录冲突详情
4. 等待用户裁决

### 5.2 API 变更冲突

**场景**: Claude 修改了 `MessageManager` 的接口，Codex 的代码调用旧接口

**解决步骤**:
1. Claude 必须**提前通知** API 变更
2. 在 `docs/MESSAGE_SYSTEM_API.md` 中标记 `[BREAKING CHANGE]`
3. Claude 提供迁移脚本或辅助函数
4. Codex 适配新接口

**预防措施**:
- 重大 API 变更需要用户审查
- 尽量保持向后兼容（Deprecation 机制）

### 5.3 设计分歧

**场景**: Codex 认为 Claude 的设计不合理

**解决步骤**:
1. Codex 在 `docs/DESIGN_FEEDBACK.md` 中详细说明问题
2. Claude 在同一文档中回应
3. 双方无法达成一致时，提交给用户决策

---

## 6. Git 工作流

### 6.1 分支策略

**主分支**: `main`
- 始终保持可运行状态
- 只接受经过测试的 merge

**开发分支**:
- `claude/message-system` — Claude 的消息系统开发分支
- `claude/ui-refactor` — Claude 的 UI 重构分支
- `codex/ch01-integration` — Codex 的第一章集成分支
- `codex/content-development` — Codex 的内容开发分支

**临时分支**:
- `conflict-resolution` — 解决冲突时使用
- `experiment/*` — 实验性功能

### 6.2 Commit 约定

**格式**:
```
[Agent] type(scope): subject

Body (optional)

Footer (optional)
```

**示例**:
```
[Claude] feat(message): add MessageManager core

- Implement queue_message()
- Implement _process_queue()
- Add unit tests

Closes #123
```

**Type**:
- `feat`: 新功能
- `fix`: 修复 bug
- `refactor`: 重构（不改变功能）
- `docs`: 文档
- `test`: 测试
- `chore`: 杂项（构建、依赖等）

### 6.3 Merge 策略

**阶段1-2**: Claude 独立开发
- Claude 完成后，直接 merge 到 `main`
- `git merge --no-ff claude/message-system`

**阶段3**: 第一章集成
- Codex 完成后，创建 Pull Request
- Claude review
- 测试通过后 merge

**原则**:
- 每个阶段结束时 merge 一次
- 阶段内的小改动可以直接 push 到开发分支
- 不要在 `main` 上直接 commit

---

## 7. 测试策略

### 7.1 测试分类

**单元测试** (Claude 负责):
- `tests/test_message_manager.gd`
- `tests/test_time_manager.gd`
- `tests/test_notification_manager.gd`
- `tests/test_news_manager.gd`

**集成测试** (Claude 负责):
- `tests/test_message_integration.gd` — 消息队列 + 时间推进
- `tests/test_phone_ui.gd` — 手机 UI + MessageManager
- `tests/test_desktop_ui.gd` — 电脑 UI + MessageManager

**功能测试** (Codex 负责):
- `scripts/ch01_qa_test.gd` — 第一章全流程（已存在）
- `scripts/ch01_edge_test.gd` — 第一章边界情况（已存在）
- `scripts/ch01_reload_qa.gd` — 存档兼容性（已存在）

### 7.2 测试要求

**Claude 的测试**:
- 每个新功能必须有单元测试
- 集成测试覆盖主要场景
- 测试通过后才能 merge

**Codex 的测试**:
- 修改后运行第一章全流程测试
- 确保旧存档能正常加载
- 人工测试关键剧情节点

### 7.3 测试命令

```bash
# Claude 运行单元测试
godot --headless --script res://tests/test_message_manager.gd

# Codex 运行第一章测试
godot --headless --script res://scripts/ch01_qa_test.gd
```

---

## 8. 文档维护

### 8.1 必须维护的文档

| 文档 | 负责人 | 更新时机 |
|------|--------|----------|
| `docs/AI_COLLABORATION.md` | 双方 | 每次交接 |
| `docs/DIGITAL_SYSTEMS_ARCHITECTURE.md` | Claude | API 变更时 |
| `docs/MESSAGE_SYSTEM_API.md` | Claude | 接口变更时 |
| `docs/CH01_IMPLEMENTATION_STATUS.md` | Codex | 第一章修改后 |
| `CHANGELOG.md` | 双方 | 每次 merge |

### 8.2 文档模板

**交接记录** (`docs/AI_COLLABORATION.md`):
```markdown
## 交接记录 / YYYY-MM-DD HH:MM

- **交接方**: Claude
- **接收方**: Codex
- **阶段**: 阶段2完成
- **已完成**:
  - 创建 MessageManager
  - 重构 desktop.gd
  - 通过所有单元测试
- **未完成**:
  - 第一章集成（阶段3）
- **注意事项**:
  - desktop.gd 现在依赖 MessageManager
  - 旧的 WorldData.events 已弃用
- **下一步**: Codex 开始阶段3，修改 ch01_director.gd
```

---

## 9. 风险管理

### 9.1 高风险操作

**操作1**: 修改 `ch01_director.gd` 或 `ch01_play.gd`

**风险**: 破坏第一章功能  
**缓解**:
1. 先在测试分支实验
2. 每次修改后运行 `ch01_qa_test.gd`
3. 保留回滚点（commit SHA）

**操作2**: 修改 `project.godot` 的 Autoload

**风险**: 游戏无法启动  
**缓解**:
1. 修改前备份 `project.godot`
2. 修改后立即测试启动
3. 如果失败，立即回滚

**操作3**: 删除 `state.messages` 或 `state.read`

**风险**: 旧存档无法加载  
**缓解**:
1. 先实现存档迁移逻辑
2. 测试旧存档加载
3. 保留迁移代码至少一个版本

### 9.2 应急响应

**场景1**: 阶段2完成后，第一章无法运行

**响应**:
1. 立即回滚到阶段1的 commit
2. Claude 检查 `desktop.gd` 的修改
3. Codex 检查 UI 调用是否正确
4. 修复后重新测试

**场景2**: 阶段3完成后，存档无法加载

**响应**:
1. 检查 `_migrate_old_messages()` 逻辑
2. 手动检查旧存档的数据结构
3. 修复迁移代码
4. 重新测试

**场景3**: 性能问题（消息队列卡顿）

**响应**:
1. Claude 优化 `_process_queue()`
2. 使用 Profiler 分析瓶颈
3. 如果无法优化，考虑限制消息数量

---

## 10. 成功标准

### 10.1 技术标准

- [x] 消息系统通过所有单元测试
- [ ] 第一章可以正常通关
- [ ] 旧存档可以正常加载
- [ ] 手机和电脑显示相同的消息
- [ ] 没有 Git 冲突遗留

### 10.2 协作标准

- [ ] 所有阶段按时完成
- [ ] 没有未解决的设计分歧
- [ ] 文档完整且最新
- [ ] 双方对最终结果满意

### 10.3 用户验收标准

- [ ] 第一章体验与之前一致
- [ ] 没有新的 bug
- [ ] 存档兼容性完美
- [ ] 为第二章开发铺平道路

---

## 11. 附录

### 11.1 文件清单

**Claude 创建的新文件**:
```
scripts/message_manager.gd
scripts/time_manager.gd
scripts/notification_manager.gd
scripts/news_manager.gd
scenes/phone.tscn
scripts/phone.gd
data/message_schemas.json
data/contacts.json
data/news_templates.json
tests/test_message_manager.gd
tests/test_time_manager.gd
tests/test_notification_manager.gd
tests/test_news_manager.gd
tests/test_message_integration.gd
tests/test_phone_ui.gd
tests/test_desktop_ui.gd
docs/DIGITAL_SYSTEMS_AUDIT.md
docs/DIGITAL_SYSTEMS_ARCHITECTURE.md
docs/AGENT_INTEGRATION_CONTRACT.md
docs/MESSAGE_SYSTEM_API.md
docs/MIGRATION_GUIDE.md
```

**Claude 修改的现有文件**:
```
project.godot (新增 Autoload)
scripts/desktop.gd (重构)
ui/desktop_window.gd (轻微修改)
```

**Codex 修改的现有文件**:
```
scripts/ch01_director.gd (适配 MessageManager)
scripts/ch01_play.gd (适配 MessageManager)
docs/CH01_IMPLEMENTATION_STATUS.md (更新状态)
```

**双方共同维护**:
```
docs/AI_COLLABORATION.md
CHANGELOG.md
```

### 11.2 关键 Commit SHA

**记录格式**:
```
阶段1完成: <SHA> - [Claude] feat: add message system core modules
阶段2完成: <SHA> - [Claude] refactor: adapt desktop and phone UI
阶段3完成: <SHA> - [Codex] feat: integrate Chapter with MessageManager
最终集成: <SHA> - [Both] chore: finalize message system integration
```

### 11.3 联系方式

**紧急情况**:
- 在 `docs/AI_COLLABORATION.md` 中留言
- 在 commit message 中标记 `[URGENT]` 或 `[HELP]`
- 通过用户转达（最后手段）

---

**契约生效日期**: 2026-11-05  
**契约审查周期**: 每阶段结束后  
**契约修订**: 双方协商后更新本文档

---

**签署**:
- Claude (Architecture Agent) — 2026-11-05
- Codex (Content & Gameplay Agent) — 待签署
- 用户 (Project Owner) — 待审查批准

## 2026-11-05 / Codex接管数字生活系统（实施前声明）
用户已将原Claude职责整体授权给Codex，覆盖message service、聊天UI、手机、desktop_night、Chapter及存档桥接、project.godot。当前只有Codex写入，不启动并行Agent。
审计纠正：第一章两端已共用Chapter；WorldNight已有发送/持久化，desktop.gd是旧基类而非当前唯一实现。四份原文中的完成勾选不作为测试证据。
实施采用一个MessageManager（含news/notification/call记录），稳定数据ID、JSON字典、业务送达分钟与UI演出秒分离；不新建TimeManager，不删历史，不重构继承链。共用聊天控件，旧字段仅作迁移/兼容投影。八阶段连续实施，以Godot实测为内部关卡。
