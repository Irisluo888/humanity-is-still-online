# CH01分阶段操作记录

## 2026-11-05 / CH01连续实施（部分完成）
- 审计完整开发包，原文件哈希保护，未移动/覆盖；docs已创建。此前P4规则提案被新包无追逐规格替代。
- 新增data/ch01_story.json、ch01_sources.json，15节点、章节共享聊天/五新闻；新增scripts/ch01_director.gd、ch01_play.gd、ch01_map.gd、ch01_peephole.gd、ch01_test.gd与scenes/ch01.tscn。
- 修改project.godot添加Chapter；start_loop.gd新增章节入口与继续；desktop_night.gd新增章节收件箱/返回按钮。原订单/生命/物资数据复用，但章节真实配送衔接未完成。
- 新增docs四份状态/日志/测试/素材文件；更新ROADMAP、DEV_LOG、CHANGELOG、RUN_PROTOTYPE。
- 实测：十逻辑分支与六截图保存0失败；巡航19 PASS、夜间50 PASS。图片实际读取并修复手机遮挡。详见docs/CH01_TEST_REPORT.md。
- 未达到整包80–90%目标：地图灰盒、空间触发/手机分栏/真实订单/正式立绘和音效仍缺。没有把Phase1–6标DONE。
- 无删除，无提交，无push。artifacts/ch01/pre_ch01.zip为实施前源代码快照，不包含用户存档、.git和整包；原包单独保留。恢复前应先备份当前工作树，不建议直接覆盖解压。

阶段1–2：导演/共享消息增量。阶段3–5：场景模板、猫眼及资源规则增量。阶段6：分支/回归/截图自测。各阶段不足详见状态矩阵；不是阶段验收通过记录。

## 2026-11-05 — CH01质量整改技术检查点
- 实现六场景资源映射、按图位置/状态持久化、开发入口分离、数据分页对白/头像/逐字/输入锁、五NPC统一素材、便利店四方法与破损状态、敲门分阶段/来电/身份延迟、自然语言结尾。
- 手机与原电脑共用章节消息/新闻/已读；章节桌面保存独立，不覆盖旧配送存档；原配送API、收入、有限拾取/购物/消耗/负重/耐久和接触遭遇验证。
- 新增原创PNG与5本地合成WAV、六地图、测试脚本；未使用在线API或第三方资产。
- 已实际运行完整交互路线、另一结局UI路线、连续物理步行、边界与跨进程、旧夜间/窗口/巡航回归；逐项结果见artifacts/ch01_qa/test_summary.json，最终无FAIL/SCRIPT ERROR。26张实际PNG已逐图读取。
- 初期解析/输入/对白/版本校验/物理回调/位置竞争等错误已修复并复跑。美术仍简化，全面整改保持IN_PROGRESS，非正式发行验收。
- 详见docs/CH01_IMPLEMENTATION_STATUS.md、CH01_BUGFIX_REPORT.md、CH01_TEST_REPORT.md、CH01_ART_ASSET_GAP.md。保留artifacts/ch01_qa/before.zip及SHA256清单。

当前协作交接：用户要求优先建立Git检查点与Claude Code统一规则；停止继续修改游戏逻辑，交接后不得两工具同时写同目录。
