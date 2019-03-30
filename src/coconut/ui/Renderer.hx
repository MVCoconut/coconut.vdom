package coconut.ui;

import coconut.diffing.*;
import coconut.vdom.Child;
import js.Browser.*;
import js.html.*;

class Renderer {
  
  static var DIFFER = new Differ(new DomBackend());

  static public function mount(target:Element, vdom:Child)
    DIFFER.render([vdom], target);

  static public function getNative(view:View):Null<Node>
    return getAllNative(view)[0];// not quite the pinnacle of efficiency, but let's see if anyone complains

  static public function getAllNative(view:View):Array<Node>
    return switch @:privateAccess view._coco_lastRender {
      case null: [];
      case r: r.flatten(null);
    }

  static public inline function updateAll()
    tink.state.Observable.updateAll();

}

private class DomCursor implements Cursor<Node> {
  var parent:Node;
  var cur:Node;
  public function new(target:Node) {
    this.cur = target;
    this.parent = target.parentNode;
  }

  public function insert(real:Node):Void 
    parent.insertBefore(real, cur);

  public function step():Bool 
    return switch cur {
      case null: false;
      case v: (cur = v.nextSibling) != null;
    }

  public function current():Node 
    return cur;
}

private class DomBackend implements Applicator<Node> {

  static var PLACEHOLDER:Child = '';

  public function new() {}

  public function unsetLastRender(target:Node):Rendered<Node> {
    var ret = untyped target._coco_;
    untyped __js__('delete {0}._coco_', target);
    return ret;
  }

  public function removeChild(parent:Node, child:Node)
    parent.removeChild(child);

  public function createCursor(target:Node)
    return new DomCursor(target);

  public  function placeholder(target):Child
    return PLACEHOLDER;

  public function getLastRender(target:Node):Null<Rendered<Node>> 
    return untyped target._coco_;

  public function setLastRender(target:Node, r:Rendered<Node>) 
    untyped target._coco_ = r;

  public function setChildren(target:Node, children:Array<Node>) {
    var pos = 0;
    if (children != null)
      for (nu in children) {
        var old = target.childNodes[pos++];
        if (old != nu) 
          target.insertBefore(nu, old);
      }
    for (i in pos...target.childNodes.length)
      target.removeChild(target.childNodes[pos]);
  }

  public function getParent(target:Node)
    return target.parentNode;
}