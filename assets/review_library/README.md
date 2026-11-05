# 下载素材整理与适用性评估 — 2026-11-05

原始10个ZIP与4个散文件留在assets原位置，未移动、覆盖或提交原下载文件。本目录为分类解包副本，.gdignore禁止Godot导入，不是已接入游戏的资产。

目录：audio（音乐/音效）、environment（建筑/纹理）、characters（角色）、unverified_loose（散文件）。原包完整保留；解包排除__MACOSX、.DS_Store、._资源分叉及.sfk波形缓存。未删原包中的内容。

## 使用优先级与授权

| 原文件 | 作者 | 证据/状态 | 用途候选 |
|---|---|---|---|
| cat sprite.zip | 未知 | 授权待补 | 猫的GIF动画，授权补齐后可评估城市小动物；需转SpriteSheet |
| EssentialGameAudiopackFixed.zip | Ove Melaa | 发布页CC-BY3.0，待核对下载来源 | Dark Loop、Tube Ambient Loop为夜间候选；click/door为交互候选。未试听，不按名字判定最终效果 |
| GameOver-Music.zip | Cleyton Kauffman | 发布页CC0，待核对下载来源 | No Hope/Retro_No hope为失败结算候选，不建议日常配送循环 |
| human.zip | 未知 | 授权待补 | 只有human.blend；未打开Blender，不作为女主资产 |
| kenney_pattern-pack-lines.zip | Kenney | 包内CC0 | 窗格、墙纸、屏幕底纹；需缩小并统一像素网格 |
| kenney_pattern-pack.zip | Kenney | 包内CC0 | 低对比桌面壁纸/织物/包装纹样；不是建筑模型 |
| kenney_retro-textures-fantasy.zip | Kenney | 包内CC0 | 只选石砖、木板、金属门等通用材质；中世纪窗/旗帜不适合现代城市 |
| kenney_retro-urban-kit.zip | Kenney | 包内CC0 | 老城区墙体/门窗/阳台/路面/围栏/路灯/货车；优先GLB，需统一像素比例、色板、碰撞 |
| RPGsounds_Kenney.zip | Kenney | 包内CC0 | 脚步、开关门、金属锁扣、衣物：优先候选 |
| rpg_sound_pack.zip | artisticdude | 发布页CC0，待核对下载来源 | interface、bottle、cloth、coin、world/door候选；魔法与怪兽音不优先 |
| b423b42.wav | 未知 | 授权待补 | 未知音频：未试听，不能判断用途 |
| song18.mp3 | cynicmusic / The Cynic Project | 匹配同名同大小发布页CC0，待核对来源及附加署名说明 | Crystal Cave：调查/离线助手氛围候选，未经试听 |
| the_field_of_dreams.mp3 | pauliuw | 匹配同名同大小发布页CC0，待核对来源 | 回忆/章末/清晨过场候选，未经试听 |
| zeepkats.png | 未知 | 授权待补 | 未知图片：不接入游戏 |

## 来源与署名
Kenney五包均完整保留包内许可证，声明CC0、商业使用可行、署名非强制；仍建议credits列Kenney。其他匹配页仅凭文件名/容量/目录作者信息定位，未下载原站文件做逐字节比对，不能把来源匹配当成确切文件授权证据。

Ove素材若采用：按实际曲目列“曲名 — written and produced by Ove Melaa”，附来源、CC-BY3.0链接并说明修改。发布页还给出作者联系信息，接入时保留完整署名要求。song18页列CC0，同时作者要求署名/链接与通知，需在接入前记录处理，不自动发消息。

- EssentialGameAudiopackFixed.zip: https://opengameart.org/content/oves-essential-game-audio-pack-collection-160-files-updated
- GameOver-Music.zip: https://opengameart.org/content/game-over-theme
- rpg_sound_pack.zip: https://opengameart.org/node/5311
- song18.mp3: https://opengameart.org/content/crystal-cave-song18
- the_field_of_dreams.mp3: https://opengameart.org/content/the-field-of-dreams

## 实际检查及边界
10个ZIP均通过CRC校验；原文件SHA256与整理前一致；全部解包文件按清单哈希校验。inventory.json逐文件列路径/大小/哈希，重复文件（不同模型格式的贴图、音频多编码版本）保留，不自动去重。
实际看过四张包内预览：Retro Urban、Retro Textures Fantasy、Pattern Pack、Pattern Pack Lines。建筑是低多边形配像素纹理，具备可用基础，但不能整套直接宣称符合最终场景美术。未打开human.blend；未验证GLB引擎导入、碰撞或动画。未试听音频，因此用途只作候选。没有更改游戏场景，无需把本轮目录整理描述为游戏运行验收。

打开preview.html可在本地浏览器试听候选原文件并查看素材预览；页面不联网，不使用API。未知授权内容不接入运行时。游戏模型优先只取GLB，音效优先OGG/WAV，音乐同一曲不要同时打包三种格式。

整理数量：保留原始14项下载；分类副本共1578文件（包含预览、许可证、多格式模型及音频，不是1578个独立可用资产）。
