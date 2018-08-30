package coconut.diffing;

class Differ {

  static public function updateChildren<N, K>(
    driver:Driver<N>, 
    target:N, 
    newChildren:Array<VNode<N, K>>, 
    oldChildren:Array<VNode<N, K>>
  ) {

    var newLength = newChildren.length,
        oldLength = oldChildren.length,
        oldNative = driver.all(target);

    var oldKeyed = {
      var ret = new haxe.DynamicAccess();
      var newKeys = new haxe.DynamicAccess();

      for (c in newChildren) 
        if (c.key != null) 
          newKeys[c.key] = true;

      for (i in 0...oldLength) {
        var old = oldChildren[i];
        var k = old.key;
        if (k != null && newKeys[k] && !ret.exists(k)) 
          ret[k] = i;
      }
      ret;
    }

    var oldIndex = 0;
    var newDomChildren = [
      for (i in 0...newLength) {
        var newChild = newChildren[i];
        var oldChildIndex = 
          switch oldKeyed[newChild.key] {
            case null: 

              while (oldIndex < oldLength) {
                var oldChild = oldChildren[oldIndex];
                if (oldChild == null || oldKeyed.exists(oldChild.key))
                  oldIndex++; 
                else break;
              }

              if (oldIndex < oldLength)
                oldIndex++;
              else
                oldIndex;
            case v: 
              oldKeyed.remove(newChild.key);
              v;
          }

        switch oldNative[oldChildIndex] {
          case null:
            newChild.create();
          case target:
            var oldChild = oldChildren[oldChildIndex];
            oldChildren[oldChildIndex] = null;
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