# 原创素材清单与制作顺序
位置 assets/pixel_desktop/，RGBA PNG；tools/draw_desktop_assets.py 为原创、确定性生成源，无新增依赖。
1. wallpaper.png：640×360，雨夜窗景、远近楼层、暖窗、电线、窗台灯杯植物。
2. app_0…5.png：24×24，动态/热榜/视频/消息/AI助手/接单，六种独立图形。
3. avatar_0…7.png：32×32，八个人物头像，发色、衣色与刘海不同。
4. thumb_0…3.png：160×88，雨街、店面、楼门、配送箱；thumb_0兼作现有视频封面。
5. close.png、minimize.png、status.png、notification.png：16×16，窗口控制与状态。
合计23张。图像均为本轮离线程序原创，不使用参考图像素或第三方图像；参考只用于内部分析，不打包为运行资产。优先制作壁纸、图标、头像、缩略图、控制图形，再接入UI。
