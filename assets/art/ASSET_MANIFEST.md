# 统一像素资产记录

共41张项目原创PNG；包含旧轮素材复用、改进与本轮新增，不宣称全部从零重画。
- avatars/avatar_0…11.png：12个32×32头像；0—7复用前轮原创，8—11新增。
- social/thumb_0…7.png：8张320×180配图；0—3沿用雨街/店面/楼门/配送箱，4—7新增早市、洗衣店、骑手车、窗台，补充材质细节。
- video/video_0…5.png：6张320×180不同封面；与对应生活配图共享原始场景是有意复用，视频分类内部无重复文件。
- icons/app_0…5.png：6个原有原创应用图标；close/minimize为窗口控制，status/notification为不同的电源与通知图形。
- backgrounds/wallpaper.png：640×360雨街壁纸，沿用前轮原创。
- environment/bedroom.png：640×360等距出租屋，新增窗外雨夜楼景。
- characters/rider_home.png、rider_uniform.png：居家32×64与骑手服48×88站立像素图。骑手服包含头盔、低马尾、反光条、长裤、运动鞋与配送箱。
- furniture/delivery_gear.png：64×48头盔与外卖箱，用于住所。

来源：tools/draw_third_round_assets.py 与前轮项目原创绘图代码；Python标准库离线生成，未新增Pillow或外部依赖，不下载/调用外部图像服务，不使用参考图像素。基础蓝灰、炭灰、灰青与少量暖橘共用色板，纹理最近邻，场景640×360在1280×720为2倍；正文采用系统字体回退。

质量说明：这些是可运行的原创像素原型，不是最终发行资产。部分家具、头像和封面的造型、材质仍偏简化，尚未达到参考中的精致像素质量；骑手目前只有站立帧，不将其冒充完整角色动画。

## 文件清单
- avatars/avatar_0.png
- avatars/avatar_1.png
- avatars/avatar_10.png
- avatars/avatar_11.png
- avatars/avatar_2.png
- avatars/avatar_3.png
- avatars/avatar_4.png
- avatars/avatar_5.png
- avatars/avatar_6.png
- avatars/avatar_7.png
- avatars/avatar_8.png
- avatars/avatar_9.png
- backgrounds/wallpaper.png
- characters/rider_home.png
- characters/rider_uniform.png
- environment/bedroom.png
- furniture/delivery_gear.png
- icons/app_0.png
- icons/app_1.png
- icons/app_2.png
- icons/app_3.png
- icons/app_4.png
- icons/app_5.png
- icons/close.png
- icons/minimize.png
- icons/notification.png
- icons/status.png
- social/thumb_0.png
- social/thumb_1.png
- social/thumb_2.png
- social/thumb_3.png
- social/thumb_4.png
- social/thumb_5.png
- social/thumb_6.png
- social/thumb_7.png
- video/video_0.png
- video/video_1.png
- video/video_2.png
- video/video_3.png
- video/video_4.png
- video/video_5.png

## 2026-11-04 住所与角色精修增量
新增 refined/bedroom.png（640×360）、refined/rider_uniform.png 与 refined/rider_home.png（各48×96），共3张原创PNG；旧41张保留，累计44张。
来源 tools/draw_refined_room.py，以 AST 仅提取项目旧生成器的 Canvas/c/poly/ellipse 基础函数，不执行旧生成器的资源写入；全程 Python 标准库离线绘制，无第三方图片像素。
房间统一2:1等距投影；人物及场景均最近邻放大（720p房间2倍、预览人物4倍）。加入可见键盘按键、鼠标线、抽屉、书架、开放衣柜、布料纹理、雨窗、暖气、洗衣篮、头盔配送箱与局部暖光。两套角色共用脸型、低马尾与身体比例。
仍为待用户验收的精修像素稿，非最终发行资产；人物单帧，房间家具尚未拆为独立交互节点，暖光为烘焙像素颜色。
