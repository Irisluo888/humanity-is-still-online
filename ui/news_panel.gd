extends VBoxContainer
const Kit=preload("res://ui/kit.gd")
var selected_id=""
var picker: OptionButton
var content: RichTextLabel
var timestamp: Label
var signature=""
func _ready() -> void:
 size_flags_horizontal=SIZE_EXPAND_FILL;size_flags_vertical=SIZE_EXPAND_FILL
 add_child(Kit.label("城市资讯 / 本地新闻浏览器",20))
 picker=OptionButton.new();picker.custom_minimum_size.y=38;add_child(picker)
 picker.item_selected.connect(func(i):selected_id=picker.get_item_metadata(i);show_article())
 timestamp=Kit.label("",14);add_child(timestamp)
 var scroll=ScrollContainer.new();scroll.size_flags_vertical=SIZE_EXPAND_FILL;scroll.custom_minimum_size.y=265;add_child(scroll)
 content=RichTextLabel.new();content.bbcode_enabled=false;content.fit_content=true;content.scroll_active=false;content.size_flags_horizontal=SIZE_EXPAND_FILL;content.custom_minimum_size.x=180;content.add_theme_font_size_override("normal_font_size",19);scroll.add_child(content)
 MessageManager.changed.connect(refresh)
 refresh()
func refresh() -> void:
 var articles=MessageManager.get_news();var latest=JSON.stringify(articles)
 if signature==latest:return
 signature=latest;picker.clear()
 var selected=0
 for i in range(articles.size()):
  var article: Dictionary=articles[i];picker.add_item(article.title+(" · 未读" if not article.read else ""));picker.set_item_metadata(i,article.id)
  if article.id==selected_id:selected=i
 if not articles.is_empty():
  picker.select(selected);selected_id=articles[selected].id;show_article()
 else:timestamp.text="暂无新新闻";content.text="新闻会随城市事件和游戏时间逐步发布。"
func show_article() -> void:
 if not MessageManager.articles.has(selected_id):return
 var article: Dictionary=MessageManager.articles[selected_id]
 timestamp.text=MessageManager.format_time(int(article.published_at))+" · 本地留存"
 var lines: PackedStringArray=article.text.split("\n")
 if not lines.is_empty() and lines[0].begins_with("标题："):lines.remove_at(0)
 content.text=article.title+"\n\n"+"\n".join(lines).replace("正文：","").replace("摘要：","")
 MessageManager.read_news(selected_id)
