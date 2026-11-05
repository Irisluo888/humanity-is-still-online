# 消息系统实际接口 / 2026-11-05

当前实现：MessageManager单一Autoload，ui/message_panel.gd共用控件；未新增TimeManager、NewsManager或NotificationManager。

## 时间与数据
- current_minute：游戏绝对分钟，D0 23:47=1427，D1 22:17=2777。由Chapter/WorldData适配层提供，不由UI计时推进。
- _process(delta)/tick_presentation：只消耗秒级演出剩余时间，不修改current_minute。窗口关闭后Autoload继续运行已开始的线程。
- records按稳定id存储；包含thread_id、sender_id、text、sent_at、arrive_at、ordinal、requires、delivered/revealed/read、delay_seconds、choices、attachments。
- 送达资格与演出可见性分离。查询UI仅返回delivered且revealed；达到送达条件的线程自动开始逐条演出，不需要先打开联系人；未来台词仍不可见。
- 联系人/线程/台词配置data/messaging.json；头像使用现有原创本地资源。玩家可选回复在该消息位置阻塞演出，选择一次后继续NPC消息。

## 公共接口
- reset(profile)、set_context(absolute_minute,flags,scene)：新档/时钟与条件适配。
- queue_message(spec)->bool、queue_script(id,at,requires)：稳定ID去重，requires支持flags、scene、read_ids、replies，必须全部满足。
- begin_thread(id)：开始该线程秒级演出；get_thread_messages(id)：只读深拷贝已演出历史；get_unread_count(id)：两端统一可见未读计数。
- waiting_reply(id)、choose_reply(message_id,choice_id)：数据驱动预设回复；send_message(thread,text,stable_id)：本地玩家留言，不调用API。
- mark_read(thread,ids)、is_read(message_id)、thread_finished(thread)：只标记已演出的消息，不将未来消息读掉。
- queue_news(spec)、get_news()、read_news(id)：统一新闻发布/已读。
- queue_call(id,sender,at,requires)、answer_call(id)：来电排队/响铃/单次接听。
- notifications：稳定ID记录；notification_posted信号供两端展示。
- save_data、valid_data、load_data：保存待送达、历史、演出剩余秒、回复、已读、新闻、通知和来电；验证失败不改变现有状态。
- migrate_legacy(messages,read,news,minute)：旧Chapter条目保留id和已读，作为已演出历史导入。

信号：changed、message_arrived、message_revealed、player_sent_message、unread_count_changed、news_published、notification_posted。changed不等同剧情推进，UI不得据此重建整张地图。

## 开发边界
Phase1—8已完成本轮技术集成验收，详见DIGITAL_SYSTEMS_TEST_REPORT.md；用户试玩验收待进行。旧字段只能作兼容投影，不另维护可写历史。不能将Claude建议中的成功标准/勾选当作已实现。

## 集成与兼容约定
- Chapter.game_minute 适配 WorldData 的 day/minute 与剧情里程碑（data/digital_timeline.json）；Chapter 第0天对应 WorldData 第1天。打开窗口不推进分钟。
- MessageManager是唯一可写消息源；Chapter.state.messages/read/news与旧desktop_state仅为兼容投影。UI禁止直接维护第二份聊天记录。
- ordinal用于待演出排序，display_order用于已显示消息排序，避免玩家回复后新NPC台词插回其上方。旧桌面静态历史cached优先，不重播。
- get_notifications/read_notification提供共享通知读写；来电只能由answer_call接听一次。隐藏、最小化窗口不读取新消息。
- save_data含schema、profile、current_minute、serial、记录、新闻、通知、电话、started、remaining、choices；valid_data先验证全部字段，失败不污染现场。Chapter快照限chapter，旧夜间限legacy。
- 旧私人聊天存档未记录预设回复时，保留原午餐选择对话，不擅自推断玩家拒绝。未知旧历史进入recovered线程。
- 公共接口所有权：本轮Codex单一写入；后续Agent先阅读本规格与接口合同，禁止同时改共享文件。

2026-11-05：process_due自动启动已送达线程，begin_thread幂等；UI只选择展示对象，不控制是否送达。通知可保存presented标记，新控件补显未展示通知。
