package coconut.vdom;

import coconut.diffing.*;
import js.Browser.*;
import js.html.*;

class Renderer {

  static var DIFFER = new Differ(new DomBackend());

  static public function mountInto(target:Element, vdom:RenderResult)
    DIFFER.render([vdom], target);

  static public macro function mount(target, markup);

  static public function getNative(view:View):Null<Node>
    return getAllNative(view)[0];// not quite the pinnacle of efficiency, but let's see if anyone complains

  static public function getAllNative(view:View):Array<Node>
    return switch @:privateAccess view._coco_lastRender {
      case null: [];
      case r: r.flatten(null);
    }

  static public inline function updateAll()
    tink.state.Observable.updateAll();

  static public macro function hxx(e);
}

private class DomCursor implements Cursor<Node> {
  var parent:Node;
  var cur:Node;
  public function new(parent:Node, cur:Node) {
    this.parent = parent;
    this.cur = cur;
  }

  public function insert(real:Node) {
    var inserted = real.parentNode != parent;
    if (cur == null)
      parent.appendChild(real);
    else {
      var next = real.nextSibling;
      parent.insertBefore(real, cur);
      if (!inserted) {
        parent.insertBefore(cur, next);
        cur = real.nextSibling;
      }
    }
    return inserted;
  }

  public function step():Bool
    return switch cur {
      case null: false;
      case v: (cur = v.nextSibling) != null;
    }

  public function delete():Bool
    return
      switch cur {
        case null: false;
        case v:
          cur = v.nextSibling;
          parent.removeChild(v);
          // Clearing event handlers is not really necessary, but some extensions (in particular adblockers) keep references to detatched nodes, so this reduces leaks
          var handler:haxe.DynamicAccess<Event->Void> = untyped v.__eventHandler;
          if (handler != null) {
            js.Syntax.delete(v, '__eventHandler');
            for (k in handler.keys())
              v.removeEventListener(k, handler[k]);
          }
          true;
      }

  public function current():Node
    return cur;
}

private class DomBackend implements Applicator<Node> {

  static var PLACEHOLDER:RenderResult = '';

  public function new() {}

  public function unsetLastRender(target:Node):Rendered<Node> {
    var ret = untyped target._coco_;
    untyped js.Syntax.delete(target, '_coco_');
    return ret;
  }

  public function traverseSiblings(first:Node)
    return new DomCursor(first.parentNode, first);

  public function traverseChildren(parent:Node)
    return new DomCursor(parent, parent.firstChild);

  public function placeholder(target):RenderResult
    return PLACEHOLDER;

  public function getLastRender(target:Node):Null<Rendered<Node>>
    return untyped target._coco_;

  public function setLastRender(target:Node, r:Rendered<Node>)
    untyped target._coco_ = r;
}