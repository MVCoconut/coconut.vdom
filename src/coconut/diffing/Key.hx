package coconut.diffing;

typedef Key = {}

class KeyMap<T> {
  var strings = new Map<String, T>();
  var objects = new Map<{}, T>();
  public function new() {}

  public function get(key:Key):T
    return 
      if (Std.is(key, String)) strings.get(cast key);
      else objects.get(key);

  public function set(key:Key, value:T):Void
    if (Std.is(key, String)) strings.set(cast key, value);
    else objects.set(key, value);

  public function delete(key:Key):Bool
    return
      if (Std.is(key, String)) strings.remove(cast key);
      else objects.remove(key);

  public function has(key:Key):Bool
    return 
      if (Std.is(key, String)) strings.exists(cast key);
      else objects.exists(key);
}