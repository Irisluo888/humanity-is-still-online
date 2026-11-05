# 消息系统实际接口 / 2026-11-05

当前实现：MessageManager单一Autoload，ui/message_panel.gd共用控件；未新增TimeManager、NewsManager或NotificationManager。

## 时间与数据
- current_minute：游戏绝对分钟，D0 23:47=1427，D1 22:17=2777。由Chapter/WorldData适配层提供，不由UI计时推进。
- _process(delta)/tick_presentation：只消耗秒级演出剩余时间，不修改current_minute。窗口关闭后Autoload继续运行已开始的线程。
- records按稳定id存储；包含thread_id、sender_id、text、sent_at、arrive_at、ordinal、requires、delivered/revealed/read、delay_seconds、choices、attachments。
- 送达资格与演出可见性分离。查询UI仅返回delivered且revealed；未开始线程提示“收到新消息”，不提前展示未来台词或消息总数。
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
Phase1–2独立模块已通过实际测试；第一章和旧配送适配需另跑集成验收。旧字段只能作兼容投影，不另维护可写历史。不能将Claude建议中的成功标准/勾选当作已实现。
