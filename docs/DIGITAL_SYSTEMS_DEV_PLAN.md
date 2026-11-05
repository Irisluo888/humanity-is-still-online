# 数字生活系统重构开发计划

**项目**: 《人类暂未下线》  
**日期**: 2026-11-05  
**规划周期**: 3周（21天）  
**负责模型建议**: 见各阶段说明

---

## 开发路线图总览

```
阶段0: 审查与批准 (2天)
    ↓
阶段1: 基础架构开发 (5天) — Claude 主导
    ↓
阶段2: UI层适配 (5天) — Claude 主导
    ↓
阶段3: 第一章集成 (7天) — Codex 主导, Claude 协助
    ↓
阶段4: 全面测试与文档 (2天) — 双方协作
```

**总计**: 21天（约3周）

---

## 阶段0: 审查与批准

**时间**: 2天  
**负责人**: 用户  
**目标**: 审查审计报告和架构设计，决定是否批准重构

### 任务清单

- [ ] 阅读 `docs/DIGITAL_SYSTEMS_AUDIT.md`
- [ ] 阅读 `docs/DIGITAL_SYSTEMS_ARCHITECTURE.md`
- [ ] 阅读 `docs/AGENT_INTEGRATION_CONTRACT.md`
- [ ] 评估重构的必要性和风险
- [ ] 决定是否批准进入阶段1

### 决策点

**如果批准**:
- 进入阶段1，Claude 开始开发
- 确认是否需要调整优先级或时间表

**如果不批准**:
- 保持现有架构
- 第二章使用补丁式开发（不推荐）

**如果需要调整**:
- Claude 修改架构设计
- 重新提交审查

---

## 阶段1: 基础架构开发

**时间**: 5天  
**负责人**: Claude  
**并行工作**: Codex 可以继续第一章内容开发（不影响）  
**目标**: 创建消息系统、时间系统、通知系统、新闻系统的核心模块

### 第1天: 数据模型与 MessageManager

**任务**:
1. 创建 `scripts/message.gd` (Message 类)
2. 创建 `scripts/message_thread.gd` (MessageThread 类)
3. 创建 `scripts/message_manager.gd` (MessageManager Autoload)
4. 实现核心接口:
   - `queue_message()`
   - `send_message()`
   - `_process_queue()`
   - `get_thread_messages()`
   - `mark_read()`

**验收标准**:
- [ ] Message 对象能够正确创建，ID 唯一
- [ ] MessageThread 对象能够正确创建
- [ ] MessageManager 能够管理消息队列
- [ ] 单元测试通过

**产出**:
- `scripts/message.gd`
- `scripts/message_thread.gd`
- `scripts/message_manager.gd`
- `tests/test_message_manager.gd`

### 第2天: TimeManager 与时间系统

**任务**:
1. 创建 `scripts/time_manager.gd` (TimeManager Autoload)
2. 实现核心接口:
   - `advance_time()`
   - `get_time_text()`
   - `jump_to()`
3. 连接 TimeManager 与 MessageManager
4. 实现时间推进触发消息到达

**验收标准**:
- [ ] TimeManager 能够正确管理游戏时间
- [ ] 时间推进时，MessageManager 收到通知
- [ ] 消息按时到达收件箱
- [ ] 单元测试通过

**产出**:
- `scripts/time_manager.gd`
- `tests/test_time_manager.gd`
- `tests/test_message_integration.gd`

### 第3天: NotificationManager 与 NewsManager

**任务**:
1. 创建 `scripts/news_article.gd` (NewsArticle 类)
2. 创建 `scripts/notification_manager.gd` (NotificationManager Autoload)
3. 创建 `scripts/news_manager.gd` (NewsManager Autoload)
4. 实现通知系统和新闻系统的核心接口

**验收标准**:
- [ ] NotificationManager 能够发出通知信号
- [ ] NewsManager 能够管理新闻队列
- [ ] 新闻按时发布
- [ ] 单元测试通过

**产出**:
- `scripts/news_article.gd`
- `scripts/notification_manager.gd`
- `scripts/news_manager.gd`
- `tests/test_notification_manager.gd`
- `tests/test_news_manager.gd`

### 第4天: 存档系统

**任务**:
1. 实现 MessageManager 的存档接口:
   - `save_data()`
   - `load_data()`
   - `_serialize_*()` 系列辅助函数
2. 实现 NewsManager 的存档接口
3. 测试存档/读档完整性

**验收标准**:
- [ ] 消息队列能够正确保存和恢复
- [ ] 新闻队列能够正确保存和恢复
- [ ] 存档文件格式符合规范
- [ ] 存档测试通过

**产出**:
- MessageManager 和 NewsManager 的存档功能
- `tests/test_save_load.gd`

### 第5天: 注册 Autoload 与文档

**任务**:
1. 在 `project.godot` 中注册所有 Autoload
2. 创建 API 文档 `docs/MESSAGE_SYSTEM_API.md`
3. 创建示例脚本 `examples/message_system_demo.gd`
4. 运行所有单元测试，确保全部通过

**验收标准**:
- [ ] 游戏能够正常启动，Autoload 正确加载
- [ ] API 文档完整清晰
- [ ] 示例脚本能够正常运行
- [ ] 所有单元测试通过

**产出**:
- 修改后的 `project.godot`
- `docs/MESSAGE_SYSTEM_API.md`
- `examples/message_system_demo.gd`

**阶段1交接**:
- Claude 提交 commit: `[Claude] feat: add message system core modules`
- 更新 `docs/AI_COLLABORATION.md` 交接记录
- 通知 Codex 和用户：阶段1完成，可以开始阶段2

---

## 阶段2: UI层适配

**时间**: 5天  
**负责人**: Claude  
**并行工作**: Codex 可以继续第一章内容开发，但**暂停修改 `scripts/desktop.gd`**  
**目标**: 重构电脑和手机 UI，使用新的消息系统

### 第6天: 手机UI设计

**任务**:
1. 创建 `scenes/phone.tscn`
2. 创建 `scripts/phone.gd`
3. 实现手机UI的基础框架:
   - 应用切换（消息、接单、地图、新闻、背包）
   - 手机打开/关闭动画
   - 通知徽章

**验收标准**:
- [ ] 手机场景能够正常加载
- [ ] 应用切换功能正常
- [ ] UI 样式符合项目视觉规范

**产出**:
- `scenes/phone.tscn`
- `scripts/phone.gd`

### 第7天: 手机消息应用

**任务**:
1. 实现手机的消息应用:
   - 线程列表（显示未读数）
   - 消息列表（按线程显示）
   - 标记已读功能
2. 连接 MessageManager:
   - 订阅 `message_arrived` 信号
   - 调用 `get_thread_messages()` 查询消息
   - 调用 `mark_read()` 标记已读

**验收标准**:
- [ ] 手机能够显示所有消息线程
- [ ] 点击线程能够查看消息列表
- [ ] 未读消息有正确的徽章提示
- [ ] 标记已读功能正常

**产出**:
- 完整的手机消息应用
- `tests/test_phone_ui.gd`

### 第8天: 手机其他应用

**任务**:
1. 适配手机的接单应用（保持原有逻辑）
2. 适配手机的新闻应用（使用 NewsManager）
3. 适配手机的背包应用（保持原有逻辑）
4. 适配手机的地图应用（保持原有逻辑）

**验收标准**:
- [ ] 所有应用能够正常切换
- [ ] 新闻应用使用 NewsManager
- [ ] 其他应用功能保持不变

**产出**:
- 完整的手机UI

### 第9天: 电脑UI重构

**任务**:
1. 重构 `scripts/desktop.gd` 的消息应用:
   - 移除 `WorldData.events` 的展示
   - 改为调用 `MessageManager.get_thread_messages()`
   - 统一已读状态管理
2. 适配电脑的新闻应用（使用 NewsManager）
3. 保持其他应用不变

**验收标准**:
- [ ] 电脑消息应用显示与手机一致
- [ ] 已读状态与手机同步
- [ ] 新闻应用使用 NewsManager
- [ ] 其他应用功能正常

**产出**:
- 重构后的 `scripts/desktop.gd`
- `tests/test_desktop_ui.gd`

### 第10天: 通知UI与测试

**任务**:
1. 创建通知气泡UI (`ui/notification_toast.gd`)
2. 连接 NotificationManager 的信号
3. 测试通知显示逻辑
4. 运行所有UI测试，确保无破坏

**验收标准**:
- [ ] 新消息到达时显示通知气泡
- [ ] 新新闻发布时显示通知气泡
- [ ] 通知UI样式符合项目规范
- [ ] 所有UI测试通过

**产出**:
- `ui/notification_toast.gd`
- 完整的通知系统

**阶段2交接**:
- Claude 提交 commit: `[Claude] refactor: adapt desktop and phone UI to MessageManager`
- 更新 `docs/AI_COLLABORATION.md` 交接记录
- Codex 验证桌面UI功能正常
- 用户验收UI体验

---

## 阶段3: 第一章集成

**时间**: 7天  
**负责人**: Codex（主导），Claude（协助）  
**目标**: 修改 `Chapter` 和 `ch01_play.gd`，使第一章使用新系统

### 第11天: 准备与设计

**Codex 的任务**:
1. 创建测试分支 `codex/ch01-integration`
2. 审查 Claude 的 API 文档
3. 设计第一章的集成方案:
   - 如何调用 `MessageManager.queue_message()`
   - 如何实现 `_extract_sender()`
   - 如何迁移旧存档

**Claude 的任务**:
1. 提供 `_extract_sender()` 的参考实现
2. 提供存档迁移的参考代码
3. 回答 Codex 的技术问题

**验收标准**:
- [ ] Codex 理解新API的使用方式
- [ ] 集成方案明确可行

**产出**:
- 集成方案文档（可选）

### 第12-13天: 修改 `ch01_director.gd`

**Codex 的任务**:
1. 修改 `Chapter.publish_chat()`:
   - 改为调用 `MessageManager.queue_message()`
   - 实现 `_extract_sender()` 辅助函数
2. 修改剧情节点触发逻辑:
   - 第31行: `if id=="group":publish_chat("rider_group")`
   - 第32行: `if id=="lunch":publish_chat("xiaoyu")`
   - 第33-35行: `if id=="night":...`
3. 移除 `state.messages` 和 `state.read` 的直接使用
4. 每完成一个子任务，提交一个小 commit

**Claude 的任务**:
1. 实时 review Codex 的 commit
2. 提供技术支持（如有需要）

**验收标准**:
- [ ] `Chapter.publish_chat()` 正确调用 MessageManager
- [ ] `_extract_sender()` 能够从文本提取发送者
- [ ] 代码编译通过，无语法错误

**产出**:
- 修改后的 `scripts/ch01_director.gd`

### 第14-15天: 修改 `ch01_play.gd`

**Codex 的任务**:
1. 修改手机UI的消息显示:
   - 第158-175行: 改为调用 `MessageManager.get_thread_messages()`
   - 移除 `Chapter.state.messages` 的直接访问
2. 修改已读状态管理:
   - 改为调用 `MessageManager.mark_read()`
3. 适配手机的关闭逻辑:
   - 第196-202行: 确保关闭手机后剧情能正确触发
4. 每完成一个子任务，提交一个小 commit

**Claude 的任务**:
1. 实时 review Codex 的 commit
2. 提供技术支持（如有需要）

**验收标准**:
- [ ] 手机UI正确显示消息
- [ ] 已读状态与电脑同步
- [ ] 剧情触发逻辑正常

**产出**:
- 修改后的 `scripts/ch01_play.gd`

### 第16天: 存档迁移

**Codex 的任务**:
1. 实现 `Chapter._migrate_old_messages()`:
   - 将旧的 `state.messages` 转换为新的 Message 对象
   - 恢复已读状态
2. 修改 `Chapter.restore()`:
   - 检查存档版本
   - 调用迁移函数
3. 测试旧存档加载:
   - 准备一个第一章的旧存档
   - 加载存档
   - 验证消息正确迁移

**Claude 的任务**:
1. 审查迁移代码
2. 协助调试迁移问题

**验收标准**:
- [ ] 旧存档能够正常加载
- [ ] 消息数据完整无损
- [ ] 已读状态正确恢复

**产出**:
- 存档迁移逻辑

### 第17天: 全流程测试与修复

**Codex 的任务**:
1. 运行 `scripts/ch01_qa_test.gd`
2. 人工测试第一章完整流程:
   - 从开始到结束
   - 测试所有剧情分支
   - 测试存档/读档
3. 记录所有发现的 bug
4. 修复 bug

**Claude 的任务**:
1. 协助调试复杂问题
2. 如果是新系统的 bug，Claude 修复

**验收标准**:
- [ ] `ch01_qa_test.gd` 全部通过
- [ ] 第一章能够正常通关
- [ ] 没有明显 bug

**产出**:
- Bug 修复 commits

**阶段3交接**:
- Codex 提交 commit: `[Codex] feat: integrate Chapter with MessageManager`
- Claude review 并 approve
- Merge `codex/ch01-integration` 到 `main`
- 更新 `docs/AI_COLLABORATION.md`

---

## 阶段4: 全面测试与文档

**时间**: 2天  
**负责人**: Claude & Codex 协作  
**目标**: 确保所有功能正常，文档完整

### 第18天: 全面测试

**Claude 的任务**:
1. 运行所有单元测试
2. 运行所有集成测试
3. 编写边界测试（极端情况）

**Codex 的任务**:
1. 运行所有功能测试
2. 人工测试极端情况:
   - 快速推进时间
   - 大量消息同时到达
   - 存档/读档反复测试
3. 报告任何发现的问题

**验收标准**:
- [ ] 所有自动化测试通过
- [ ] 人工测试未发现严重 bug
- [ ] 性能符合预期（无明显卡顿）

### 第19天: 文档与收尾

**Claude 的任务**:
1. 更新 `README.md`（如有必要）
2. 创建迁移指南 `docs/MIGRATION_GUIDE.md`
3. 更新 `CHANGELOG.md`

**Codex 的任务**:
1. 更新 `docs/CH01_IMPLEMENTATION_STATUS.md`
2. 检查所有文档的一致性

**验收标准**:
- [ ] 所有文档完整且最新
- [ ] 用户文档易于理解
- [ ] 开发文档详细准确

**最终交接**:
- 双方确认所有任务完成
- 提交最终 commit: `[Both] chore: finalize message system integration`
- 更新 `CHANGELOG.md`
- 向用户报告完成情况

---

## 依赖关系图

```
阶段1 (Claude)
  ├─ 第1天: Message + MessageManager
  ├─ 第2天: TimeManager ← 依赖第1天
  ├─ 第3天: Notification + News ← 依赖第1天、第2天
  ├─ 第4天: 存档系统 ← 依赖第1-3天
  └─ 第5天: Autoload + 文档 ← 依赖第1-4天

阶段2 (Claude)
  ├─ 第6天: 手机UI框架 ← 依赖阶段1
  ├─ 第7天: 手机消息应用 ← 依赖第6天
  ├─ 第8天: 手机其他应用 ← 依赖第7天
  ├─ 第9天: 电脑UI重构 ← 依赖阶段1
  └─ 第10天: 通知UI + 测试 ← 依赖第6-9天

阶段3 (Codex + Claude)
  ├─ 第11天: 准备 ← 依赖阶段2
  ├─ 第12-13天: ch01_director ← 依赖第11天
  ├─ 第14-15天: ch01_play ← 依赖第12-13天
  ├─ 第16天: 存档迁移 ← 依赖第14-15天
  └─ 第17天: 全流程测试 ← 依赖第16天

阶段4 (双方)
  ├─ 第18天: 全面测试 ← 依赖阶段3
  └─ 第19天: 文档 ← 依赖第18天
```

---

## 模型分配建议

### 阶段1: Claude 主导（5天）

**推荐模型**: **Claude Opus 5.5** 或 **Claude Sonnet 5.5**

**理由**:
1. 需要深度理解架构设计
2. 需要编写高质量的核心代码
3. 需要设计合理的 API 接口
4. 单元测试需要覆盖各种边界情况

**备选**: Sonnet 也可以胜任，但 Opus 的架构思维更强

### 阶段2: Claude 主导（5天）

**推荐模型**: **Claude Sonnet 5.5**

**理由**:
1. UI 层的工作相对机械
2. 主要是调用已有 API
3. Sonnet 性价比更高，且足以完成任务

**备选**: Opus 可以做得更好，但不是必需

### 阶段3: Codex 主导（7天）

**推荐模型**: **Codex (GPT-4 或类似)**

**理由**:
1. Codex 最熟悉第一章的代码
2. 修改剧情逻辑需要理解剧情意图
3. Codex 已经维护这些文件很久

**Claude 的角色**: 技术支持和代码审查
**推荐模型**: **Claude Sonnet 5.5**（协助）

### 阶段4: 双方协作（2天）

**推荐模型**:
- Claude: **Sonnet 5.5**（测试和文档）
- Codex: **GPT-4**（人工测试）

---

## 风险缓解计划

### 风险1: 阶段1或阶段2延期

**缓解**:
- 每天检查进度
- 如果延期1天，后续每天多工作1小时
- 如果延期超过2天，重新评估时间表

### 风险2: 阶段3遇到技术难题

**缓解**:
- Codex 遇到问题立即标记 `[HELP]`
- Claude 提供快速响应（2小时内）
- 如果问题复杂，双方协商是否需要 Claude 接手

### 风险3: 测试发现严重 bug

**缓解**:
- 保留回滚点（每个阶段结束时的 commit）
- 优先修复阻塞性 bug
- 非阻塞性 bug 记录到 `TODO.md`，后续修复

---

## 成功标准检查清单

### 技术标准

- [ ] 所有单元测试通过
- [ ] 所有集成测试通过
- [ ] 第一章能够正常通关
- [ ] 旧存档能够正常加载
- [ ] 手机和电脑显示一致
- [ ] 消息能够延迟到达
- [ ] 时间推进正确触发消息
- [ ] 通知系统正常工作
- [ ] 新闻系统正常工作
- [ ] 存档文件大小合理（< 1MB）

### 协作标准

- [ ] 所有阶段按时完成
- [ ] 没有 Git 冲突遗留
- [ ] 文档完整且最新
- [ ] 双方对结果满意

### 用户验收标准

- [ ] 第一章体验与之前一致
- [ ] 没有新的明显 bug
- [ ] 存档兼容性完美
- [ ] 为第二章开发铺平道路

---

## 后续展望

**第二章开发**:
1. 使用新的消息系统设计动态对话
2. 实现延迟回复和条件触发
3. 扩展双向通信功能

**系统优化**:
1. 性能优化（如果需要）
2. 增加更多消息类型（语音、图片）
3. 支持消息搜索功能

---

**计划制定日期**: 2026-11-05  
**预计开始日期**: 待用户批准  
**预计完成日期**: 开始后21天  
**计划审查**: 每个阶段结束后

