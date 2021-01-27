package coconut.vdom;

import coconut.diffing.*;
import js.Browser.*;
import js.html.*;

class Renderer {

  static final BACKEND = new DomBackend();
  static public function mountInto(target:Element, vdom:RenderResult)
    Root.fromNative((target:Node), BACKEND).render(vdom);

  static public macro function mount(target, markup);

  // static public function getNative(view:View):Null<Node>
  //   return getAllNative(view)[0];// not quite the pinnacle of efficiency, but let's see if anyone complains

  // static public function getAllNative(view:View):Array<Node>
  //   return switch @:privateAccess view._coco_lastRender {
  //     case null: [];
  //     case r: r.flatten(null);
  //   }

  static public inline function updateAll()
    tink.state.Observable.updateAll();

  static public macro function hxx(e);
}

private class DomCursor implements Cursor<Node> {
  public final applicator:Applicator<Node>;
  final parent:Node;
  var cur:Node;
  public function new(applicator, parent, cur) {
    this.applicator = applicator;
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
  }

  public function markForDeletion(v:Node) {
    if (v == null || v.parentNode != parent) throw 'assert';
    if (v == cur)
      cur = v.nextSibling;

    parent.removeChild(v);
    // Clearing event handlers is not really necessary, but some extensions (in particular adblockers) keep references to detatched nodes, so this reduces leaks
    var handler:haxe.DynamicAccess<Event->Void> = untyped v.__eventHandler;
    if (handler != null) {
      js.Syntax.delete(v, '__eventHandler');
      for (k in handler.keys())
        v.removeEventListener(k, handler[k]);
    }
  }

  public function close() {

  }

  public function step():Bool
    return switch cur {
      case null: false;
      case v: (cur = v.nextSibling) != null;
    }
}

private class DomBackend implements Applicator<Node> {

  public function new() {}

  public function emptyMarker()
    return document.createTextNode('');

  public function siblings(first:Node)
    return new DomCursor(this, first.parentNode, first);

  public function children(parent:Node)
    return new DomCursor(this, parent, parent.firstChild);
}