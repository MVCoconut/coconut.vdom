package coconut.diffing;

@:forward(map, filter, iterator, length)
abstract ReadonlyArray<T>(Array<T>) from Array<T> {
  @:arrayAccess inline function get(index:Int):T return this[index];
}

class Differ {

  static public function updateChildren<N, K>(
    driver:Driver<N>, 
    target:N, 
    newChildren:ReadonlyArray<VNode<N, K>>, 
    oldChildren:ReadonlyArray<VNode<N, K>>
  ) {

    var newLength = newChildren.length,
        oldLength = oldChildren.length,
        oldNative = driver.all(target);

    var used = new haxe.ds.Vector<Bool>(oldLength);

    var oldKeyed = {
      var ret = new Key.KeyMap();
      var newKeys = new Key.KeyMap();

      for (c in newChildren)
        if (c != null && c.key != null) 
          newKeys.set(c.key, true);

      for (i in 0...oldLength) {
        var old = oldChildren[i];
        if (old == null) continue;
        var k = old.key;
        if (k != null && newKeys.get(k) && !ret.has(k)) 
          ret.set(k, i);
      }
      ret;
    }

    var oldIndex = 0;
    var newDomChildren = [
      for (i in 0...newLength) {
        var newChild = newChildren[i];
        if (newChild == null) continue;
        var oldChildIndex = 
          switch oldKeyed.get(newChild.key) {
            case null: 

              while (oldIndex < oldLength) {
                if (used[oldIndex]) oldIndex++;
                else {
                  var oldChild = oldChildren[oldIndex];
                  if (oldChild == null || oldKeyed.has(oldChild.key))
                    oldIndex++; 
                  else break;
                }
              }

              if (oldIndex < oldLength)
                oldIndex++;
              else
                oldIndex;
            case v: 
              oldKeyed.delete(newChild.key);
              v;
          }

        switch oldNative[oldChildIndex] {
          case null:
            newChild.create();
          case target:
            var oldChild = oldChildren[oldChildIndex];
            used[oldChildIndex] = true;
            if (oldChild == newChild)
              target;
            else {
              var ret = newChild.patch(target, oldChild);
              if (ret != target)
                oldChild.teardown(target);
              ret;
            }
        }

      }
    ];
    
    for (i in 0...newDomChildren.length) {
      var newDom = newDomChildren[i];
      if (newDom != driver.get(target, i))
        driver.insertAt(target, newDom, i);
    }

    for (i in newLength...driver.total(target))
      driver.removeAt(target, newLength);

    for (i in 0...oldChildren.length)
      switch oldChildren[i] {
        case null:
        case o:
          o.teardown(oldNative[i]);
      }

  }

  static var EMPTY:Dict<Any> = {};  

  static public inline function updateObject<Target>(element:Target, newProps:Dict<Any>, oldProps:Dict<Any>, updateProp:Target->String->Any->Any->Void) {
    if (newProps == oldProps) return;
    var keys = new haxe.DynamicAccess<Bool>();
    
    if (newProps == null) newProps = EMPTY;
    if (oldProps == null) oldProps = EMPTY;

    for(key in newProps.keys()) keys[key] = true;
    for(key in oldProps.keys()) keys[key] = true;
    
    for(key in Dict.getKeys(keys)) 
      updateProp(element, key, newProps[key], oldProps[key]);    
  }

  static public inline function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    if (oldVal != newVal) 
      Reflect.setField(target, name, newVal);
}