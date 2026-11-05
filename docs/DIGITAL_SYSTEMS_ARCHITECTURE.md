# 数字生活系统架构设计

**项目**: 《人类暂未下线》  
**设计日期**: 2026-11-05  
**适用范围**: 第二章及后续所有章节  
**设计者**: Claude (Architecture Agent)

---

## 1. 设计目标

基于 [DIGITAL_SYSTEMS_AUDIT.md](DIGITAL_SYSTEMS_AUDIT.md) 的审计结论，重新设计一套**可扩展、可维护、数据驱动**的数字生活系统。

### 1.1 核心原则

1. **统一的消息数据模型** — 电脑、手机、通知、新闻共享同一套底层数据
2. **时间驱动的消息队列** — 消息有到达时间，可以延迟到达
3. **双向通信能力** — 玩家可以发送消息，NPC可以回复
4. **状态持久化** — 存档能够保存消息队列、历史记录、未来事件
5. **模块化设计** — 各系统职责清晰，低耦合，易测试

### 1.2 非目标

本架构**不**涉及以下内容（由 Codex 负责）:
- 地图和场景渲染
- NPC 动作演出
- 生存玩法机制（饥饿、口渴、战斗）
- 美术素材和音效

---

## 2. 核心架构

### 2.1 系统层次

```
┌─────────────────────────────────────────────┐
│         UI 层 (Presentation Layer)          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │  手机UI  │  │  电脑UI  │  │ 通知UI   │  │
│  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────┘
                     ▲
                     │ 订阅/查询
                     ▼
┌─────────────────────────────────────────────┐
│       服务层 (Service Layer / Autoload)     │
│  ┌──────────────────────────────────────┐  │
│  │      MessageManager (消息管理器)      │  │
│  ├──────────────────────────────────────┤  │
│  │   NotificationManager (通知管理器)    │  │
│  ├──────────────────────────────────────┤  │
│  │       NewsManager (新闻管理器)        │  │
│  ├──────────────────────────────────────┤  │
│  │      TimeManager (时间管理器)         │  │
│  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────┘
                     ▲
                     │ 读写
                     ▼
┌─────────────────────────────────────────────┐
│        数据层 (Data Layer)                  │
│  ┌──────────────┐  ┌──────────────┐        │
│  │ 消息数据库   │  │ 新闻数据库   │        │
│  └──────────────┘  └──────────────┘        │
│  ┌──────────────┐  ┌──────────────┐        │
│  │ 联系人数据库 │  │ 模板数据库   │        │
│  └──────────────┘  └──────────────┘        │
└─────────────────────────────────────────────┘
```

### 2.2 数据流

**消息到达流程**:
1. 剧情触发器 / 时间触发器 → 调用 `MessageManager.queue_message()`
2. `MessageManager` 将消息添加到队列，设置 `arrive_at` 时间
3. 游戏时间推进 → `TimeManager` 通知 `MessageManager`
4. `MessageManager` 检查队列，将 `arrive_at <= 当前时间` 的消息移入收件箱
5. `MessageManager` 发出 `message_arrived` 信号
6. 手机UI / 电脑UI 订阅信号 → 显示未读提示

**玩家发送消息流程**:
1. 玩家在UI输入消息 → 调用 `MessageManager.send_message()`
2. `MessageManager` 创建消息对象，设置 `sender = "player"`
3. 消息立即进入历史记录（不进入队列）
4. 剧情系统可以监听 `player_sent_message` 信号 → 触发NPC回复

---

## 3. 统一消息数据模型

### 3.1 核心消息对象

```gdscript
class_name Message extends Resource

# 必需字段
@export var id: String              # 唯一ID，格式: "msg_YYYYMMDD_HHMMSS_random"
@export var thread_id: String       # 线程ID，例如 "rider_group", "xiaoyu_private"
@export var sender_id: String       # 发送者ID，"player" 或 NPC的 person_id
@export var text: String            # 消息文本
@export var sent_at: int            # 发送时间（游戏内分钟数）
@export var arrive_at: int          # 到达时间（游戏内分钟数）

# 可选字段
@export var read: bool = false      # 是否已读
@export var attachments: Array = [] # 附件（照片、视频引用）
@export var reply_to: String = ""   # 回复的消息ID
@export var metadata: Dictionary = {} # 扩展数据

func _init(
    p_thread_id: String,
    p_sender_id: String,
    p_text: String,
    p_sent_at: int,
    p_arrive_at: int = -1
) -> void:
    id = generate_id()
    thread_id = p_thread_id
    sender_id = p_sender_id
    text = p_text
    sent_at = p_sent_at
    arrive_at = p_arrive_at if p_arrive_at >= 0 else p_sent_at

static func generate_id() -> String:
    var time = Time.get_datetime_dict_from_system()
    var random = randi() % 10000
    return "msg_%04d%02d%02d_%02d%02d%02d_%04d" % [
        time.year, time.month, time.day,
        time.hour, time.minute, time.second, random
    ]
```

### 3.2 线程对象

```gdscript
class_name MessageThread extends Resource

@export var id: String              # 线程ID，例如 "rider_group"
@export var type: String            # "group" | "private" | "system"
@export var name: String            # 显示名称
@export var participants: Array[String] = [] # 参与者ID列表
@export var icon: String = ""       # 图标路径
@export var metadata: Dictionary = {}

func _init(p_id: String, p_type: String, p_name: String) -> void:
    id = p_id
    type = p_type
    name = p_name
```

### 3.3 新闻对象

```gdscript
class_name NewsArticle extends Resource

@export var id: String
@export var title: String
@export var content: String
@export var category: String        # "urgent" | "normal" | "background"
@export var published_at: int       # 发布时间（游戏内分钟数）
@export var arrive_at: int          # 推送时间
@export var read: bool = false
@export var source: String = ""     # 新闻来源
@export var attachments: Array = []
```

---

## 4. MessageManager (消息管理器)

### 4.1 职责

1. 管理所有消息的生命周期（队列 → 收件箱 → 历史）
2. 处理玩家发送消息
3. 管理已读/未读状态
4. 提供消息查询接口
5. 发出消息到达信号

### 4.2 数据结构

```gdscript
extends Node

signal message_arrived(message: Message)
signal player_sent_message(message: Message)
signal unread_count_changed(thread_id: String, count: int)

# 核心数据
var threads: Dictionary = {}        # thread_id → MessageThread
var message_queue: Array[Message] = []  # 尚未到达的消息
var inbox: Dictionary = {}          # thread_id → Array[Message]
var contacts: Dictionary = {}       # person_id → 联系人信息

# 状态
var current_time: int = 0           # 当前游戏时间（分钟）
```

### 4.3 核心接口

```gdscript
# 队列消息（剧情触发）
func queue_message(
    thread_id: String,
    sender_id: String,
    text: String,
    arrive_at: int,
    sent_at: int = -1
) -> Message:
    if sent_at < 0: sent_at = current_time
    var msg = Message.new(thread_id, sender_id, text, sent_at, arrive_at)
    message_queue.append(msg)
    return msg

# 玩家发送消息
func send_message(thread_id: String, text: String) -> Message:
    var msg = Message.new(thread_id, "player", text, current_time, current_time)
    _add_to_inbox(msg)
    player_sent_message.emit(msg)
    return msg

# 时间更新（由 TimeManager 调用）
func update_time(new_time: int) -> void:
    current_time = new_time
    _process_queue()

# 处理队列（将到达的消息移入收件箱）
func _process_queue() -> void:
    var arrived: Array[Message] = []
    for msg in message_queue:
        if msg.arrive_at <= current_time:
            arrived.append(msg)
    
    for msg in arrived:
        message_queue.erase(msg)
        _add_to_inbox(msg)
        message_arrived.emit(msg)
    
    if not arrived.is_empty():
        _update_unread_counts()

# 获取线程消息（UI调用）
func get_thread_messages(thread_id: String) -> Array[Message]:
    return inbox.get(thread_id, [])

# 获取未读数量
func get_unread_count(thread_id: String) -> int:
    var count = 0
    for msg in inbox.get(thread_id, []):
        if not msg.read and msg.sender_id != "player":
            count += 1
    return count

# 标记已读
func mark_read(thread_id: String) -> void:
    for msg in inbox.get(thread_id, []):
        if not msg.read:
            msg.read = true
    unread_count_changed.emit(thread_id, 0)

# 存档
func save_data() -> Dictionary:
    return {
        "schema": 1,
        "threads": _serialize_threads(),
        "queue": _serialize_messages(message_queue),
        "inbox": _serialize_inbox(),
        "contacts": contacts
    }

# 读档
func load_data(data: Dictionary) -> bool:
    if data.get("schema") != 1: return false
    threads = _deserialize_threads(data.threads)
    message_queue = _deserialize_messages(data.queue)
    inbox = _deserialize_inbox(data.inbox)
    contacts = data.get("contacts", {})
    return true
```

### 4.4 初始化

```gdscript
func _ready() -> void:
    # 注册内置线程
    register_thread("rider_group", "group", "骑手群")
    register_thread("system", "system", "系统通知")
    
    # 连接时间管理器
    TimeManager.time_updated.connect(update_time)
```

---

## 5. TimeManager (时间管理器)

### 5.1 职责

1. 管理游戏内时间（天数、小时、分钟）
2. 处理时间推进（玩家行为消耗时间）
3. 发出时间更新信号
4. 提供时间查询接口

### 5.2 数据结构

```gdscript
extends Node

signal time_updated(current_minute: int)
signal day_changed(day: int)
signal period_changed(period: String) # "day" | "night"

var day: int = 1
var minute: int = 480  # 从 08:00 开始
var period: String = "day"
```

### 5.3 核心接口

```gdscript
# 推进时间
func advance_time(minutes: int) -> void:
    minute += minutes
    
    # 处理跨天
    while minute >= 1440:
        minute -= 1440
        day += 1
        day_changed.emit(day)
    
    # 处理昼夜切换
    var new_period = "night" if minute >= 1140 or minute < 360 else "day"
    if new_period != period:
        period = new_period
        period_changed.emit(period)
    
    time_updated.emit(minute)

# 获取时间文本
func get_time_text() -> String:
    var hour = minute / 60
    var min = minute % 60
    return "第%d天 %s %02d:%02d" % [day, "白天" if period == "day" else "夜晚", hour, min]

# 跳转到特定时间
func jump_to(target_day: int, target_minute: int) -> void:
    day = target_day
    minute = target_minute
    period = "night" if minute >= 1140 or minute < 360 else "day"
    time_updated.emit(minute)
    day_changed.emit(day)
```

---

## 6. NotificationManager (通知管理器)

### 6.1 职责

1. 管理系统通知（新消息、新新闻、任务提醒）
2. 显示桌面通知气泡
3. 管理未读徽章

### 6.2 通知类型

```gdscript
enum NotificationType {
    NEW_MESSAGE,    # 新消息
    NEW_NEWS,       # 新新闻
    TASK_REMINDER,  # 任务提醒
    SYSTEM_ALERT    # 系统警告
}
```

### 6.3 核心接口

```gdscript
extends Node

signal notification_posted(type: NotificationType, title: String, body: String)

func post_notification(type: NotificationType, title: String, body: String) -> void:
    notification_posted.emit(type, title, body)

func _ready() -> void:
    # 订阅消息管理器
    MessageManager.message_arrived.connect(_on_message_arrived)
    NewsManager.news_published.connect(_on_news_published)

func _on_message_arrived(message: Message) -> void:
    var thread = MessageManager.threads.get(message.thread_id)
    if thread:
        post_notification(
            NotificationType.NEW_MESSAGE,
            thread.name,
            message.text.substr(0, 50)
        )
```

---

## 7. NewsManager (新闻管理器)

### 7.1 职责

1. 管理新闻文章的生命周期
2. 处理新闻推送（基于时间或剧情触发）
3. 管理新闻分类和已读状态

### 7.2 核心接口

```gdscript
extends Node

signal news_published(article: NewsArticle)

var news_queue: Array[NewsArticle] = []
var published_news: Array[NewsArticle] = []

func queue_news(
    title: String,
    content: String,
    category: String,
    publish_at: int
) -> NewsArticle:
    var article = NewsArticle.new()
    article.id = "news_" + str(Time.get_ticks_msec())
    article.title = title
    article.content = content
    article.category = category
    article.published_at = TimeManager.minute
    article.arrive_at = publish_at
    news_queue.append(article)
    return article

func update_time(current_time: int) -> void:
    var arrived: Array[NewsArticle] = []
    for article in news_queue:
        if article.arrive_at <= current_time:
            arrived.append(article)
    
    for article in arrived:
        news_queue.erase(article)
        published_news.append(article)
        news_published.emit(article)

func get_all_news() -> Array[NewsArticle]:
    return published_news

func get_unread_news() -> Array[NewsArticle]:
    return published_news.filter(func(a): return not a.read)

func mark_read(article_id: String) -> void:
    for article in published_news:
        if article.id == article_id:
            article.read = true
            break
```

---

## 8. UI 层适配

### 8.1 手机UI重构

**新建场景**: `scenes/phone.tscn`

**核心逻辑** (`scripts/phone.gd`):
```gdscript
extends Control

var current_app: String = "messages"
var current_thread: String = "rider_group"

func _ready() -> void:
    MessageManager.message_arrived.connect(_on_message_arrived)
    MessageManager.unread_count_changed.connect(_refresh_badge)

func _on_message_arrived(message: Message) -> void:
    if visible and current_thread == message.thread_id:
        # 自动标记已读
        MessageManager.mark_read(message.thread_id)
    _refresh_badge()

func show_messages_app() -> void:
    current_app = "messages"
    _render_thread_list()

func _render_thread_list() -> void:
    for thread_id in MessageManager.threads:
        var thread = MessageManager.threads[thread_id]
        var unread = MessageManager.get_unread_count(thread_id)
        # 渲染线程按钮，显示未读数
        _add_thread_button(thread, unread)

func show_thread(thread_id: String) -> void:
    current_thread = thread_id
    var messages = MessageManager.get_thread_messages(thread_id)
    _render_messages(messages)
    MessageManager.mark_read(thread_id)

func send_message(text: String) -> void:
    MessageManager.send_message(current_thread, text)
    _render_messages(MessageManager.get_thread_messages(current_thread))
```

### 8.2 电脑UI重构

**修改文件**: `scripts/desktop.gd`

**关键变更**:
1. 移除 `WorldData.events` 的展示
2. 改为调用 `MessageManager.get_thread_messages()`
3. 统一已读状态管理

```gdscript
# desktop.gd 第105-113行 (旧代码)
elif app == "消息":
 var chat = column(body,470)
 text(chat,"选择联系人查看记录")
 for id in WorldData.people:
  var person: String = id
  left.add_child(Kit.button(str(WorldData.people[id]),func():
   for child in chat.get_children(): child.queue_free()
   text(chat,str(WorldData.people[person]) + "\n\n" + event_text() + "\n当前仅浏览缓存，不发送消息。")
  ))

# 新代码
elif app == "消息":
 var chat = column(body,470)
 for thread_id in MessageManager.threads:
  var thread = MessageManager.threads[thread_id]
  var unread = MessageManager.get_unread_count(thread_id)
  left.add_child(Kit.button(thread.name + (" (%d)" % unread if unread > 0 else ""), func():
   for child in chat.get_children(): child.queue_free()
   var messages = MessageManager.get_thread_messages(thread_id)
   for msg in messages:
    text(chat, _format_message(msg))
   MessageManager.mark_read(thread_id)
  ))
```

---

## 9. 第一章适配方案

### 9.1 保留 Chapter Autoload

**策略**: `Chapter` 继续管理第一章的线性剧情，但消息系统迁移到 `MessageManager`

**修改点**:

**步骤1**: 修改 `Chapter.publish_chat()`
```gdscript
# 旧代码 (ch01_director.gd 第59-62行)
func publish_chat(thread: String) -> void:
 for i in range(catalog.chat[thread].size()):
  var id=thread+"_%03d"%i
  if not state.messages.any(func(m):return m.id==id):
      state.messages.append({"id":id,"thread":thread,"text":catalog.chat[thread][i]})

# 新代码
func publish_chat(thread: String) -> void:
 var chat_data: Array = catalog.chat[thread]
 for i in range(chat_data.size()):
  var text: String = chat_data[i]
  var sender_id = _extract_sender(text)  # 从文本提取发送者
  MessageManager.queue_message(
   thread,
   sender_id,
   text,
   TimeManager.minute + i * 2  # 消息间隔2分钟到达
  )
```

**步骤2**: 移除 `state.messages` 和 `state.read`
- 所有消息查询改为调用 `MessageManager`
- 已读状态由 `MessageManager` 管理

**步骤3**: 适配 `ch01_play.gd` 的手机UI
```gdscript
# 旧代码 (ch01_play.gd 第159-172行)
"消息":
 for record in Chapter.state.messages:
  if record.thread==selected_thread:Chapter.mark_read(record.id)
 # ...

# 新代码
"消息":
 var messages = MessageManager.get_thread_messages(selected_thread)
 for msg in messages:
  # 渲染消息
 MessageManager.mark_read(selected_thread)
```

### 9.2 数据迁移

**挑战**: `data/ch01_story.json` 的聊天数据是字符串数组

**解决方案**: 创建转换函数

```gdscript
# scripts/ch01_director.gd

func _extract_sender(text: String) -> String:
    # 从消息文本提取发送者
    # "小鱼：今天谁还活着" → 返回 "xiaoyu"
    # "阿强：我" → 返回 "aqiang"
    # "老周：都活着。" → 返回 "zhou"
    
    var sender_map = {
        "小鱼": "xiaoyu",
        "阿强": "aqiang",
        "老周": "zhou",
        "老马": "laoma"
    }
    
    for name in sender_map:
        if text.begins_with(name + "："):
            return sender_map[name]
    
    return "unknown"
```

### 9.3 兼容性策略

**目标**: 第一章的存档能够加载，并自动迁移到新架构

```gdscript
# ch01_director.gd

func restore() -> bool:
 var d=JSON.parse_string(FileAccess.get_file_as_string(save_path))
 if not valid(d):return false
 var s: Dictionary=d.state
 
 # 迁移旧消息数据
 if s.has("messages"):
  _migrate_old_messages(s.messages, s.get("read", []))
 
 # ... 其他恢复逻辑

func _migrate_old_messages(old_messages: Array, old_read: Array) -> void:
 for old_msg in old_messages:
  var sender_id = _extract_sender(old_msg.text)
  var msg = Message.new(
   old_msg.thread,
   sender_id,
   old_msg.text,
   TimeManager.minute,
   TimeManager.minute
  )
  msg.id = old_msg.id
  msg.read = old_msg.id in old_read
  MessageManager._add_to_inbox(msg)
```

---

## 10. 第二章扩展能力

### 10.1 延迟回复示例

**场景**: 玩家今天完成配送，明天收到感谢消息

```gdscript
# world_delivery.gd 或剧情脚本

func deliver_order(id: String) -> bool:
 # ... 完成配送
 
 # 队列明天的感谢消息
 var tomorrow_morning = (TimeManager.day + 1) * 1440 + 480  # 次日早上8点
 MessageManager.queue_message(
  "xiaoyu_private",
  "xiaoyu",
  "姐，昨天的单子送完了吗？辛苦啦！",
  tomorrow_morning
 )
 
 return true
```

### 10.2 双向对话示例

**场景**: 玩家在骑手群发言，老周回复

```gdscript
# 剧情脚本

func _ready() -> void:
 MessageManager.player_sent_message.connect(_on_player_sent)

func _on_player_sent(message: Message) -> void:
 if message.thread_id == "rider_group":
  # 玩家在骑手群发言
  if message.text.contains("接单"):
   # 老周自动回复
   MessageManager.queue_message(
    "rider_group",
    "zhou",
    "别太拼，注意安全。",
    TimeManager.minute + 5  # 5分钟后到达
   )
```

### 10.3 条件触发示例

**场景**: 玩家访问某地点 → 触发新闻推送

```gdscript
# city_map.gd 或类似文件

func visit_location(place_id: String) -> void:
 WorldData.discover(place_id)
 
 # 如果是特定地点，触发新闻
 if place_id == "lane_07" and TimeManager.day == 2:
  NewsManager.queue_news(
   "榆灯巷07号门前异常",
   "居民报告门铃故障，配送请注意备注。",
   "normal",
   TimeManager.minute + 30  # 30分钟后推送
  )
```

---

## 11. 性能与优化

### 11.1 消息队列优化

**问题**: 如果队列中有大量未到达消息，每次时间更新都需要遍历

**解决方案**: 使用优先队列（按 `arrive_at` 排序）

```gdscript
# message_manager.gd

var message_queue: Array[Message] = []

func queue_message(...) -> Message:
 var msg = Message.new(...)
 message_queue.append(msg)
 message_queue.sort_custom(func(a, b): return a.arrive_at < b.arrive_at)
 return msg

func _process_queue() -> void:
 # 只检查队列头部
 while not message_queue.is_empty() and message_queue[0].arrive_at <= current_time:
  var msg = message_queue.pop_front()
  _add_to_inbox(msg)
  message_arrived.emit(msg)
```

### 11.2 存档压缩

**问题**: 消息历史可能非常长，存档文件会很大

**解决方案**:
1. 只保存最近N天的消息（例如7天）
2. 超过N天的消息归档到单独的文件
3. 提供"查看历史"功能按需加载

```gdscript
const MAX_DAYS_IN_SAVE = 7

func save_data() -> Dictionary:
 var cutoff_time = (TimeManager.day - MAX_DAYS_IN_SAVE) * 1440
 var recent_messages = {}
 
 for thread_id in inbox:
  recent_messages[thread_id] = inbox[thread_id].filter(
   func(msg): return msg.sent_at >= cutoff_time
  )
 
 return {
  "schema": 1,
  "recent_messages": _serialize_inbox(recent_messages),
  # ...
 }
```

---

## 12. 测试策略

### 12.1 单元测试

**需要测试的模块**:
1. `Message.generate_id()` — 确保ID唯一性
2. `MessageManager.queue_message()` — 消息正确加入队列
3. `MessageManager._process_queue()` — 消息按时到达
4. `TimeManager.advance_time()` — 时间正确推进
5. 存档/读档 — 数据完整性

**示例测试**:
```gdscript
# tests/test_message_manager.gd

func test_message_arrives_on_time() -> void:
 MessageManager.current_time = 1000
 var msg = MessageManager.queue_message("test_thread", "sender", "Hello", 1005)
 
 # 时间推进前，消息应该在队列中
 assert_eq(MessageManager.message_queue.size(), 1)
 assert_eq(MessageManager.get_thread_messages("test_thread").size(), 0)
 
 # 时间推进到1005
 MessageManager.update_time(1005)
 
 # 消息应该到达
 assert_eq(MessageManager.message_queue.size(), 0)
 assert_eq(MessageManager.get_thread_messages("test_thread").size(), 1)
```

### 12.2 集成测试

**场景1**: 玩家完成配送 → 次日收到感谢消息
```gdscript
func test_delayed_message_delivery() -> void:
 TimeManager.day = 1
 TimeManager.minute = 1200  # 第1天晚上8点
 
 # 触发配送完成事件
 deliver_order("order_001")
 
 # 应该有一条消息在队列中，到达时间是次日早上
 var queued = MessageManager.message_queue.filter(
  func(m): return m.thread_id == "xiaoyu_private"
 )
 assert_eq(queued.size(), 1)
 assert_eq(queued[0].arrive_at, 2 * 1440 + 480)
 
 # 推进到次日早上
 TimeManager.jump_to(2, 480)
 
 # 消息应该到达
 var arrived = MessageManager.get_thread_messages("xiaoyu_private")
 assert_eq(arrived.size(), 1)
```

---

## 13. 迁移路线图

### 阶段1: 基础架构（1周）
- [ ] 创建 `Message.gd`, `MessageThread.gd`, `NewsArticle.gd`
- [ ] 实现 `MessageManager` 核心功能
- [ ] 实现 `TimeManager` 核心功能
- [ ] 实现 `NotificationManager` 核心功能
- [ ] 实现 `NewsManager` 核心功能
- [ ] 编写单元测试

### 阶段2: UI适配（1周）
- [ ] 重构手机UI (`scenes/phone.tscn`, `scripts/phone.gd`)
- [ ] 重构电脑UI (`scripts/desktop.gd`)
- [ ] 实现通知气泡UI
- [ ] 测试UI交互

### 阶段3: 第一章集成（1周）
- [ ] 修改 `Chapter.publish_chat()`
- [ ] 实现 `_extract_sender()` 转换函数
- [ ] 适配 `ch01_play.gd` 的手机UI
- [ ] 实现存档迁移逻辑
- [ ] 测试第一章完整流程
- [ ] 验证旧存档兼容性

### 阶段4: 第二章准备（可选）
- [ ] 设计第二章的消息剧情
- [ ] 实现双向对话示例
- [ ] 实现延迟回复示例
- [ ] 实现条件触发示例

---

## 14. 风险与缓解

| 风险 | 影响 | 缓解措施 |
|------|------|----------|
| 第一章适配破坏现有功能 | 高 | 保留 Chapter，逐步迁移；充分测试 |
| 旧存档无法加载 | 高 | 实现存档迁移逻辑；保留旧数据格式读取 |
| 性能问题 | 中 | 使用优先队列；限制存档消息数量 |
| UI重构工作量大 | 中 | 先重构底层，UI可以逐步迁移 |
| 与 Codex 的工作冲突 | 高 | 见下一份文档 `AGENT_INTEGRATION_CONTRACT.md` |

---

## 15. 成功标准

### 15.1 功能性标准

- [ ] 消息可以延迟到达
- [ ] 玩家可以发送消息，NPC可以回复
- [ ] 手机和电脑显示相同的消息和已读状态
- [ ] 存档能够保存消息队列和未来消息
- [ ] 第一章的所有功能正常工作

### 15.2 质量标准

- [ ] 单元测试覆盖率 > 80%
- [ ] 集成测试覆盖主要场景
- [ ] 存档文件大小 < 1MB（前7天消息）
- [ ] 消息队列处理 < 10ms（每次时间更新）

### 15.3 可维护性标准

- [ ] 代码职责清晰，低耦合
- [ ] 新增一个消息功能 < 30分钟
- [ ] 新增一个新闻分类 < 10分钟
- [ ] 文档完整，易于理解

---

**设计完成日期**: 2026-11-05  
**下一份文档**: `AGENT_INTEGRATION_CONTRACT.md`

## 2026-11-05 / Codex接管数字生活系统（实施前声明）
用户已将原Claude职责整体授权给Codex，覆盖message service、聊天UI、手机、desktop_night、Chapter及存档桥接、project.godot。当前只有Codex写入，不启动并行Agent。
审计纠正：第一章两端已共用Chapter；WorldNight已有发送/持久化，desktop.gd是旧基类而非当前唯一实现。四份原文中的完成勾选不作为测试证据。
实施采用一个MessageManager（含news/notification/call记录），稳定数据ID、JSON字典、业务送达分钟与UI演出秒分离；不新建TimeManager，不删历史，不重构继承链。共用聊天控件，旧字段仅作迁移/兼容投影。八阶段连续实施，以Godot实测为内部关卡。
