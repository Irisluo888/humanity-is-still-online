extends SceneTree
func _initialize():call_deferred("run")
func run():
 DirAccess.make_dir_recursive_absolute("res://assets/art/phone_portraits")
 var paths={"player":"refined/rider_uniform", "xiaoyu":"ch01/xiaoyu", "zhou":"ch01/zhou", "aqiang":"avatars/avatar_3", "laoma":"avatars/avatar_4", "chen":"ch01/chen", "lin":"ch01/lin"}
 for id in paths:
  var source=load("res://assets/art/"+paths[id]+".png") as Texture2D
  var atlas=AtlasTexture.new();atlas.atlas=source;var bounds=source.get_image().get_used_rect()
  atlas.region=Rect2(bounds.position,Vector2(bounds.size.x,bounds.size.y*.42)) if id not in ["aqiang","laoma"] else Rect2(Vector2.ZERO,source.get_size())
  ResourceSaver.save(atlas,"res://assets/art/phone_portraits/"+id+".tres")
 print("Exported 7 non-destructive portrait resources from project original pixel art")
 quit()
