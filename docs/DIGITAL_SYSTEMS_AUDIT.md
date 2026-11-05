# 数字生活系统审计报告

**项目**: 《人类暂未下线》  
**审计日期**: 2026-11-05  
**审计范围**: 电脑、手机、消息、新闻、通知、时间、剧情触发、存档系统  
**审计人**: Claude (Architecture Agent)

---

## 执行摘要

本次审计针对《人类暂未下线》的数字生活系统进行了全面检查。审计发现当前系统存在**严重的架构缺陷**：

1. **消息系统不是真正的消息系统** — 只是静态文本数组的展示层
2. **电脑和手机各自管理数据** — 缺乏统一的底层消息模型
3. **消息没有时间概念** — 无法支持"到达时间"和"延迟到达"
4. **缺乏消息队列机制** — 剧情对话、手机、电脑和游戏时间存在冲突
5. **第一章实现与原始设计严重偏离** — 骑手群变成了预加载的固定文本列表

**结论**: 当前实现可以完成第一章的线性剧情演示，但**无法扩展到第二章及后续内容**。需要重构底层消息架构。

---

## 1. 当前实现审计

### 1.1 核心 Autoload 分析

#### **Chapter** (`scripts/ch01_director.gd`)

**职责**: 第一章剧情管理器  
**数据来源**: `data/ch01_story.json`

**关键发现**:
```gdscript
# 第61行：publish_chat 实现
func publish_chat(thread: String) -> void:
 for i in range(catalog.chat[thread].size()):
  var id=thread+"_%03d"%i
  if not state.messages.any(func(m):return m.id==id):
      state.messages.append({"id":id,"thread":thread,"text":catalog.chat[thread][i]})
```

**问题**:
1. ✗ 一次性将整个线程的所有消息加载到 `state.messages`
2. ✗ 消息没有 `timestamp` 或 `arrived_at` 字段
3. ✗ 消息没有 `sender` 字段，只有 `thread`
4. ✗ `publish_chat()` 在特定剧情节点被调用，无法支持动态到达
5. ✗ 玩家打开聊天窗口后，所有消息立即可见

**数据结构**:
```gdscript
state.messages = [
  {"id": "rider_group_000", "thread": "rider_group", "text": "小鱼：今天谁还活着"},
  {"id": "rider_group_001", "thread": "rider_group", "text": "阿强：我"},
  // ... 整个对话一次性加载
]
```

#### **WorldData** (`scripts/world_data.gd`)

**职责**: 最基础的世界数据管理  
**当前状态**: 仅 12 行代码，几乎是空的

```gdscript
extends Node
signal changed
var people: Dictionary = {"resident_07": "七号住户"}
var places: Dictionary = {"lane_07": "榆灯巷 07 号"}
var orders: Array = [...]
var events: Array = []
func record_event(id: String, person_id: String, place_id: String, text: String) -> void:
 events.append({"id": id, "person_id": person_id, "place_id": place_id, "text": text})
 changed.emit()
```

**问题**:
1. ✗ 没有管理消息
2. ✗ 没有管理新闻
3. ✗ 没有管理通知
4. ✗ `events` 只是简单的数组追加，无查询接口

#### **WorldNight** (`scripts/world_night.gd`)

**继承**: `world_courier.gd` → `world_delivery.gd` → `world_loop.gd` → `world_third.gd` → `world_data.gd`

**职责**: 夜间系统（电脑桌面）  
**独有数据**:
```gdscript
var night_catalog: Array  # 从 data/night_content.json 加载
var desktop_state: Dictionary = {"chat": {}, "read": []}
var unlocked_content: Dictionary = {}
var followups: Array = []
```

**关键功能**:
```gdscript
# 第35-40行：计算未读消息
func unread_for(person_id: String) -> int:
 var count=0
 for message in night_messages:
  if message.person_id==person_id and message.message_id not in desktop_state.read:
      count+=1
 return count
```

**问题**:
1. ✗ `night_messages` 是在 `world_loop.gd` 中定义的 `Array`
2. ✗ 消息模型是 `{"person_id": String, "text": String, "message_id": String}`
3. ✗ 没有时间戳、发送者身份、已读状态的统一管理
4. ✗ 电脑桌面有自己的 `desktop_state.read: Array`，与其他系统隔离

---

### 1.2 UI层分析

#### **desktop.gd** (电脑桌面)

**实现**: 740 行代码，完整的窗口管理系统  
**架构**: 类 Windows 95 桌面，支持多窗口、拖拽、任务栏

**应用列表**:
```gdscript
for app in ["动态", "热榜", "视频", "消息", "AI助手", "接单"]:
```

**消息应用实现** (第105-113行):
```gdscript
elif app == "消息":
 var chat = column(body,470)
 text(chat,"选择联系人查看记录")
 for id in WorldData.people:
  var person: String = id
  left.add_child(Kit.button(str(WorldData.people[id]),func():
   for child in chat.get_children(): child.queue_free()
   text(chat,str(WorldData.people[person]) + "\n\n" + event_text() + "\n当前仅浏览缓存，不发送消息。")
  ))
```

**问题**:
1. ✗ 显示的是 `WorldData.events` (事件日志)，不是真正的消息
2. ✗ 明确标注"当前仅浏览缓存，不发送消息"
3. ✗ 没有消息输入框，没有发送功能
4. ✗ 联系人列表来自 `WorldData.people`，但消息内容来自 `events`

#### **ch01_play.gd** (手机UI)

**实现**: 320 行代码，第一章的主游戏场景  
**手机应用**: 消息、接单、地图、新闻、背包

**消息应用实现** (第158-175行):
```gdscript
"消息":
 for record in Chapter.state.messages:
  if record.thread==selected_thread:Chapter.mark_read(record.id)
 for pair in [["骑手群","rider_group"],["小鱼","xiaoyu"],["夜间骑手群","night_group"],...]:
  var thread: String=pair[1]; var unread=0
  for m in Chapter.state.messages:
   if m.thread==thread and m.id not in Chapter.state.read:unread+=1
  button(box,pair[0]+(" / 未读%d"%unread if unread else ""),func():selected_thread=thread;render_phone(computer))
 for m in Chapter.state.messages:
  if m.thread==selected_thread:
   var message_row=HBoxContainer.new(); box.add_child(message_row)
   # ... 渲染消息
```

**数据来源**:
- 消息列表: `Chapter.state.messages`
- 已读状态: `Chapter.state.read: Array`

**问题**:
1. ✗ 手机和电脑使用**不同的数据源**
2. ✗ 手机: `Chapter.state.messages` / `Chapter.state.read`
3. ✗ 电脑: `WorldData.events` / `desktop_state.read`
4. ✗ 玩家关闭手机后，新消息无法"到达"
5. ✗ 玩家打开手机后，会看到所有已发布的消息（包括"未来"消息）

---

### 1.3 数据文件分析

#### **data/ch01_story.json**

**结构**:
```json
{
  "beats": [...],  // 剧情节点
  "chat": {
    "rider_group": [
      "小鱼：今天谁还活着",
      "阿强：我",
      "小鱼：没问你",
      "阿强：？",
      "老周：都活着。",
      "老周：没人出事。没人失联。",
      // ... 共 20 条消息
    ],
    "xiaoyu": [
      "小鱼：姐，明天中午吃砂锅吗？",
      "小鱼：我负责陪吃，你负责付款。",
      // ... 共 4 条消息
    ],
    "night_group": [...],
    "zhou_warning": [...],
    "xiaoyu_late": [...]
  },
  "news": [...],
  "places": {...},
  "outcomes": {...}
}
```

**关键发现**:
1. ✗ 聊天记录是**字符串数组**，不是消息对象数组
2. ✗ 没有时间戳
3. ✗ 没有发送者ID（发送者名字直接写在文本里）
4. ✗ 没有消息状态（未读/已读/已送达）
5. ✗ 整个线程一次性加载，无法支持分段到达

#### **data/night_content.json**

**结构**:
```json
[
  {
    "id": "door_followup",
    "kind": "post",
    "title": "七号门口的便签",
    "person_id": "resident_07",
    "place_id": "lane_07",
    "min_day": 1,
    "prefixes": ["delivered_"],
    "text": "今天收到了配送。门铃旁的便签挪过位置...",
    "image": 2,
    "followup": true
  }
]
```

**用途**: 夜间解锁的内容卡片（动态、新闻、视频）

**问题**:
1. ✗ 这是"内容卡片"，不是"消息"
2. ✗ 解锁逻辑在 `WorldNight.sync_unlocks()` 中，基于白天的事件匹配
3. ✗ 没有统一的消息/通知系统

---

### 1.4 存档系统分析

#### **Chapter 存档** (`ch01_director.gd` 第156-163行)

```gdscript
func save() -> bool:
 var data={"orders":WorldData.orders,"active_order_id":WorldData.active_order_id,
           "state":state,"health":WorldData.health,"stamina":WorldData.stamina,
           "inventory":WorldData.inventory}
 data.world={"events":WorldData.events,"daytime_orders":WorldData.daytime_orders,
             "encountered_npcs":WorldData.encountered_npcs,
             "pending_posts":WorldData.pending_posts,
             "pending_messages":WorldData.pending_messages}
 // ... 写入文件
```

**存档内容**:
- `state.messages: Array` — 所有已发布的消息
- `state.read: Array` — 已读消息ID列表
- `state.news: Array` — 新闻列表

**问题**:
1. ✗ 消息没有"队列"概念，只有"已发布"列表
2. ✗ 没有保存"未来将要到达的消息"
3. ✗ 重新加载存档后，消息系统无法继续运行

#### **WorldNight 存档** (`world_night.gd` 第79-88行)

```gdscript
func extra_save_data() -> Dictionary:
 return {"night_system":{"schema":1,"desktop":desktop_state,"unlocks":unlocked_content,"followups":followups}}

func apply_extra_save(data: Dictionary) -> void:
 var state: Dictionary=data.get("night_system",{})
 desktop_state=state.get("desktop",{"chat":{},"read":[]}).duplicate(true)
 unlocked_content=state.get("unlocks",{}).duplicate(true)
 followups=state.get("followups",[]).duplicate(true)
```

**存档内容**:
- `desktop_state.chat: Dictionary` — 玩家发送的聊天记录（空字典，因为没有实现发送功能）
- `desktop_state.read: Array` — 电脑桌面的已读消息ID
- `unlocked_content: Dictionary` — 已解锁的内容卡片
- `followups: Array` — 回访任务

**问题**:
1. ✗ 电脑和手机的已读状态**分开存储**
2. ✗ `desktop_state.read` vs `Chapter.state.read`
3. ✗ 玩家在手机上标记已读的消息，在电脑上可能仍显示未读

---

### 1.5 游戏时间管理分析

#### **时间表示**

**WorldLoop** (`world_loop.gd` 第10行):
```gdscript
var minute := 480  # 游戏内分钟数，从480（8:00）开始
```

**Chapter** (`ch01_director.gd` 第146-156行):
```gdscript
func clock_text() -> String:
 var id: String=beat().id
 if id in ["delivery","repair"]:return "第0天 21:36"
 if id in ["group","lunch"]:return "第0天 23:47"
 if id in ["orders","1203","1404","elevator"]:return "第1天 午后"
 // ... 硬编码的时间文本
```

**问题**:
1. ✗ 时间是**剧情节点的硬编码标签**，不是真实的游戏时间
2. ✗ `WorldLoop.minute` 存在，但 `Chapter` 不使用它
3. ✗ 玩家无法感知时间流逝
4. ✗ 消息没有"到达时间"概念

#### **时间推进机制**

**发现**:
```gdscript
# world_delivery.gd 第62行
order.status="配送中"; minute+=45; stamina=maxi(0,stamina-8)

# world_delivery.gd 第74行
minute+=75; stamina=maxi(0,stamina-12)

# world_loop.gd 第116行
minute += 20  # 核对消息消耗20分钟
```

**问题**:
1. ✓ 时间会因玩家行为推进
2. ✗ 但这个时间**不影响消息到达**
3. ✗ 消息是由剧情节点触发，不是由时间触发

---

## 2. 核心问题总结

### 2.1 为什么骑手群像静态文本列表？

**原因**:
1. 聊天数据是字符串数组，在 `Chapter.publish_chat()` 中一次性加载
2. 没有消息对象、没有时间戳、没有发送者ID
3. 玩家打开手机 → 立即看到整个线程的所有消息

**设计意图 vs 实际实现**:
- **设计意图**: 骑手群应该是动态的，消息逐条到达，玩家可以看到实时聊天
- **实际实现**: 骑手群是一个固定的20条消息列表，在剧情节点"group"时全部加载

### 2.2 手机和电脑是否各自维护聊天数据？

**是的，而且使用不同的数据源**:

| 系统 | 数据源 | 已读状态 | 用途 |
|------|--------|----------|------|
| 手机 | `Chapter.state.messages` | `Chapter.state.read` | 第一章线性剧情 |
| 电脑 | `WorldData.events` | `WorldNight.desktop_state.read` | 旧系统的缓存展示 |

**冲突**:
1. 玩家在手机上看到的消息，在电脑上不一定看得到
2. 玩家在电脑上标记已读，在手机上可能仍显示未读
3. 没有统一的"消息ID"和"消息对象"

### 2.3 消息是否具有独立ID、到达时间、已读状态？

| 属性 | 手机消息 | 电脑消息 | 结论 |
|------|----------|----------|------|
| 独立ID | ✓ `thread_%03d` | ✗ 使用 `event.id` | 不统一 |
| 到达时间 | ✗ 无 | ✗ 无 | 缺失 |
| 发送者 | ✗ 写在文本里 | ✓ `person_id` | 不统一 |
| 已读状态 | ✓ `state.read` | ✓ `desktop_state.read` | 分开存储 |

**结论**: 消息没有统一的数据模型。

### 2.4 玩家关闭聊天窗口后，消息是否仍能正常到达？

**不能**。

**原因**:
1. 消息不是"到达"的，而是在剧情节点时"发布"的
2. `Chapter.publish_chat()` 将消息添加到 `state.messages`
3. 玩家无论何时打开手机，看到的都是**当前已发布的所有消息**
4. 没有"消息队列"、"延迟到达"、"后台接收"等机制

### 2.5 玩家打开聊天窗口后，是否会提前看到未来消息？

**会**。

**场景**:
1. 玩家在剧情节点"group"时，`Chapter.publish_chat("rider_group")` 执行
2. `rider_group` 的全部20条消息立即添加到 `state.messages`
3. 玩家打开手机 → 看到20条消息，全部可见
4. 如果设计意图是"消息逐条到达"，则这是错误的

**验证**: `ch01_story.json` 第86行
```json
"group": {
  "place": "home",
  "text": "出租屋，第0天23:47。打开电脑或手机查看骑手群，消息完整保留，可随时重读。"
}
```
→ "消息完整保留" = 全部消息已存在

### 2.6 剧情对话、手机、电脑和游戏时间是否存在冲突？

**存在严重冲突**。

**问题1**: 剧情对话会锁定游戏
```gdscript
# ch01_director.gd 第20行
func modal() -> bool:return state.event_active or state.encounter
```
→ 剧情进行中，玩家无法打开手机

**问题2**: 手机和电脑使用不同的数据源  
→ 两者之间没有同步机制

**问题3**: 游戏时间不影响消息到达  
→ `WorldLoop.minute` 存在但不控制消息系统

**问题4**: 存档只保存"当前状态"，无法保存"未来事件"  
→ 无法实现"玩家今天做A，明天收到B的回复"

### 2.7 存档能否保存消息队列、历史消息和剧情分支？

| 内容 | 是否保存 | 位置 |
|------|----------|------|
| 已发布的消息 | ✓ | `state.messages` |
| 历史消息 | ✓ | 同上 |
| 已读状态 | ✓ | `state.read` |
| **消息队列** | ✗ | **不存在** |
| **未来消息** | ✗ | **不存在** |
| 剧情分支 | ✓ | `state.flags` |

**结论**: 存档可以保存当前状态，但无法保存"尚未到达的消息"。

### 2.8 当前是否存在重复管理器和不合理的模块依赖？

**是的**。

**继承链**:
```
world_data.gd (12行)
  ↓
world_third.gd (50行)
  ↓
world_loop.gd (230行)
  ↓
world_delivery.gd (119行)
  ↓
world_courier.gd (98行)
  ↓
world_night.gd (133行)
```

**问题**:
1. ✗ 6层继承，职责不清晰
2. ✗ `world_third.gd` 是什么？为什么叫"third"？
3. ✗ `world_courier.gd` 管理配送插曲，但也继承了夜间系统
4. ✗ `world_night.gd` 是最终的 Autoload `WorldData`，但它继承了所有上层
5. ✗ 第一章 `Chapter` 是独立的 Autoload，与 `WorldData` 平行存在

**重复**:
- `Chapter.state.messages` vs `WorldData.night_messages`
- `Chapter.state.read` vs `WorldData.desktop_state.read`
- `Chapter.state.news` vs 无对应项（新闻没有统一管理）

---

## 3. 测试验证

### 3.1 检查现有测试文件

**发现**:
```
scripts/ch01_qa_test.gd          — 第一章全流程测试
scripts/ch01_alternate_qa.gd     — 备选路径测试
scripts/ch01_edge_test.gd        — 边界测试
scripts/ch01_reload_qa.gd        — 存档加载测试
scripts/ch01_walk_qa.gd          — 步行测试
scripts/ch01_visual_qa.gd        — 视觉测试
scripts/night_system_test.gd     — 夜间系统测试
```

**问题**: 这些测试都是**功能性测试**（能否通关），不是**架构测试**（消息系统是否正确）。

### 3.2 需要的架构测试

**测试1**: 消息到达时间
- [ ] 玩家在 23:00 收到消息A
- [ ] 玩家在 23:30 打开手机
- [ ] 应该只看到 ≤23:30 的消息

**测试2**: 消息队列持久化
- [ ] 玩家存档时，有3条消息在队列中（未到达）
- [ ] 玩家加载存档
- [ ] 时间推进后，这3条消息应该到达

**测试3**: 手机和电脑同步
- [ ] 玩家在手机上标记消息A为已读
- [ ] 玩家打开电脑
- [ ] 消息A应该也显示为已读

**测试4**: 关闭窗口后接收消息
- [ ] 玩家在手机上阅读消息
- [ ] 玩家关闭手机
- [ ] 游戏时间推进
- [ ] 新消息应该"到达"（进入收件箱）
- [ ] 玩家再次打开手机，应该看到新消息

**结论**: 当前实现**无法通过**任何一个架构测试。

---

## 4. 第一章当前实现评估

### 4.1 第一章是否能正常完成？

**是的**，但有严重限制。

**原因**:
1. 第一章是**线性剧情**，消息在固定的剧情节点发布
2. 玩家必须按顺序完成剧情，不能跳过
3. 消息系统的问题被"线性流程"掩盖了

**验证**: `ch01_director.gd` 第23-36行
```gdscript
if id=="orders" and not state.flags.get("chapter_orders_created",false):
 // 创建订单
if id=="group":publish_chat("rider_group")
if id=="lunch":publish_chat("xiaoyu")
if id=="night":
 publish_chat("night_group"); publish_chat("zhou_warning"); publish_chat("xiaoyu_late")
 for i in range(3):publish_news(i)
```

→ 消息发布是**硬编码在剧情节点中的**

### 4.2 为什么第一章看起来"可以工作"？

**因为第一章做了以下简化**:
1. 所有消息都在固定时间点发布
2. 玩家必须先完成A，才能进入B
3. 不存在"玩家今天做X，明天收到Y的回复"
4. 骑手群的20条消息一次性发布，设计成"完整保留"

**这意味着**:
- ✓ 第一章可以完成
- ✗ 第二章无法使用相同的架构
- ✗ 如果需要动态对话、延迟回复、分支剧情，当前系统无法支持

### 4.3 第一章与原始设计的偏离

**原始设计** (根据 `AGENTS.md` 和 `CLAUDE.md`):
> 夜晚回到住所，通过原创桌面软件调查信息、管理物资和联系幸存者。

**当前实现**:
1. 桌面软件存在，但"消息"应用显示的是 `WorldData.events`（事件日志），不是消息
2. 手机的"消息"应用显示的是 `Chapter.state.messages`（固定文本数组），不是动态消息
3. 没有"联系幸存者"功能（明确标注"不发送消息"）

**偏离程度**: ★★★★★ (严重)

---

## 5. 扩展性评估

### 5.1 第二章需要什么？

根据游戏设计，第二章可能需要:
1. 玩家今天完成配送 → 明天收到订单方的感谢消息
2. 玩家在骑手群发言 → 其他骑手回复（异步）
3. 新闻推送（基于游戏时间，不是剧情节点）
4. 幸存者私聊（双向对话）
5. 系统通知（配送提醒、危险警告）

### 5.2 当前架构能否支持？

| 需求 | 当前支持 | 问题 |
|------|----------|------|
| 延迟到达消息 | ✗ | 没有消息队列 |
| 双向对话 | ✗ | 没有发送功能 |
| 基于时间的推送 | ✗ | 时间不控制消息 |
| 消息持久化 | △ | 只能保存当前状态 |
| 统一的已读状态 | ✗ | 手机和电脑分开 |
| 消息去重 | △ | 有ID，但逻辑不完善 |

**结论**: 当前架构**无法支持第二章**的基本需求。

### 5.3 如果强行扩展会发生什么？

**场景**: 玩家今天完成配送，明天应该收到感谢消息

**当前实现的尝试**:
```gdscript
# world_delivery.gd 第71-76行
pending_posts.append({"order_id":id,"person_id":order.person_id,"place_id":order.place_id,"text":text})
pending_messages.append({"person_id":order.person_id,"text":text})
// ...
night_posts.append_array(pending_posts)
night_messages.append_array(pending_messages)
pending_posts.clear(); pending_messages.clear()
```

**问题**:
1. `pending_messages` 在玩家收工时立即转移到 `night_messages`
2. 玩家当晚就能看到所有消息，不是"明天"
3. 没有"延迟到达"机制

---

## 6. 风险评估

### 6.1 技术债务

| 债务 | 严重程度 | 影响范围 |
|------|----------|----------|
| 消息数据模型混乱 | ★★★★★ | 所有数字生活系统 |
| 手机和电脑数据不统一 | ★★★★☆ | 消息、新闻、通知 |
| 缺乏消息队列 | ★★★★★ | 第二章及后续 |
| 时间管理混乱 | ★★★☆☆ | 剧情触发、消息到达 |
| 继承链过深 | ★★★☆☆ | 代码维护 |

### 6.2 开发风险

**如果不重构**:
1. 第二章将需要大量补丁代码
2. 每个新功能都需要在多个地方修改
3. 存档系统将越来越复杂
4. 测试将变得不可能

**如果现在重构**:
1. 第一章需要适配新架构
2. 需要迁移现有数据格式
3. 需要2-3周的开发时间

### 6.3 建议

**立即重构**。

**理由**:
1. 第一章已经完成，是重构的最佳时机
2. 再拖延，技术债务会指数级增长
3. 当前架构无法支持后续开发

---

## 7. 与 Codex 的协作边界

### 7.1 当前分工

| 模块 | 负责人 | 文件 |
|------|--------|------|
| 地图、场景 | Codex | `scenes/ch01_maps/*.tscn` |
| NPC、动作演出 | Codex | `scripts/ch01_map.gd` 等 |
| 剧情对话 | Codex | `data/ch01_story.json` |
| **消息系统** | **待定** | **冲突区域** |
| 订单系统 | Codex | `world_delivery.gd` |
| 存档系统 | **共享** | **需协调** |

### 7.2 冲突文件

**高风险**:
- `scripts/ch01_director.gd` — Codex 的第一章管理器
- `scripts/world_night.gd` — Codex 的夜间系统
- `scripts/ch01_play.gd` — Codex 的主游戏场景

**如果 Claude 修改这些文件 → 可能覆盖 Codex 的工作**

### 7.3 安全的重构路径

**阶段1**: 创建新的消息系统（不影响现有代码）
- 新文件: `scripts/message_manager.gd`
- 新文件: `scripts/notification_manager.gd`
- 新文件: `data/message_schemas.json`

**阶段2**: 电脑和手机适配新系统
- 修改: `scripts/desktop.gd`
- 修改: `ui/desktop_window.gd`
- 新建: `scenes/phone.tscn` (独立场景)

**阶段3**: 集成到第一章
- 修改: `scripts/ch01_director.gd` ← **需与 Codex 协调**
- 修改: `scripts/ch01_play.gd` ← **需与 Codex 协调**

---

## 8. 总结与建议

### 8.1 主要发现

1. **消息系统名不副实** — 只是静态文本数组的展示层
2. **手机和电脑各自为政** — 没有统一的底层数据模型
3. **消息没有时间概念** — 无法支持延迟到达和队列机制
4. **第一章可以工作** — 但架构无法扩展到第二章
5. **存在严重冲突** — 手机/电脑/剧情/时间之间缺乏协调

### 8.2 必须重构的理由

1. 当前架构是**临时实现**，不是**长期方案**
2. 技术债务已经达到**临界点**
3. 第二章的任何功能都需要**先重构底层**
4. 继续堆砌补丁代码将导致**项目失控**

### 8.3 下一步行动

**推荐**: 生成 `DIGITAL_SYSTEMS_ARCHITECTURE.md`，提出统一的消息架构。

**优先级**:
1. 设计统一的消息数据模型
2. 实现消息队列机制
3. 统一手机和电脑的数据源
4. 集成游戏时间系统
5. 适配第一章

---

**审计完成日期**: 2026-11-05  
**下一份文档**: `DIGITAL_SYSTEMS_ARCHITECTURE.md`
