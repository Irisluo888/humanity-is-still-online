# 《人类暂未下线》项目资料

> 英文工作名：Humanity Is Still Online  
> 项目基线：V1.0  
> 技术路线：Godot 4.x + GDScript  
> 目标平台：Windows / macOS  
> 开发原则：免费工具、离线优先、原创内容、低上下文成本

## 项目定位

《人类暂未下线》是一款融合末日生存模拟、城市探索、动态叙事与轻度心理恐怖的单机游戏。

核心调性为**黑色幽默 + 潮酷 Y2K**：城市逐渐失常，但订单、通知、社区动态和日常抱怨仍以一本正经的方式继续。

## 项目文件

| 文件 | 用途 |
|---|---|
| `AGENTS.md` | Codex 常驻开发规范 |
| `GDD_LITE.md` | 精简游戏设计文档 |
| `MVP_TASKS.md` | 第一版可玩原型的开发任务与验收标准 |
| `IP_AND_ASSET_RULES.md` | 原创品牌、版权和素材授权规范 |
| `CHANGELOG.md` | 正式开发开始后的变更记录 |

## 开发环境

- Godot 4.x
- GDScript
- Blender / Krita / Git（按需使用，均优先采用免费版本）
- 本地存档、离线模拟数据
- 不使用付费 API 或强制在线服务

## Codex 使用方式

1. 将这些文件放在游戏项目根目录。
2. 先让 Codex 阅读 `AGENTS.md`。
3. 首次只执行 `MVP_TASKS.md` 的 Phase 0。
4. 每次只分配一个明确的小任务。
5. 完成后运行必要测试并更新 `CHANGELOG.md`。

### 首次执行指令

```text
请阅读项目根目录的 AGENTS.md、GDD_LITE.md、
MVP_TASKS.md 和 IP_AND_ASSET_RULES.md。

当前只执行 MVP_TASKS.md 的 Phase 0：
创建并验证最小 Godot 项目骨架。

不要提前实现后续功能，不要引入第三方插件、
在线服务或付费 API。

完成后说明修改文件、运行的测试、测试结果
和未解决问题，并更新 CHANGELOG.md。
```

## 第一阶段目标

制作一个可完整游玩的短垂直切片：

住所 → 外出探索 → 观察/干预感染者 → 搜集物资 → 回家 → 使用电脑调查 → 推进到下一天。

当前资料是 V1.0 设计基线；Godot 工程和实际玩法尚未创建。
