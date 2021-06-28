package coconut.vdom;

import coconut.diffing.*;
import js.Browser.*;
import js.html.*;

class Renderer {

  static final BACKEND = new DomBackend();
  static public function mountInto(target:Element, vdom:RenderResult)
    Root.fromNative((target:Node), BACKEND).render(vdom);

  static public function hydrateInto(target:Element, vdom:RenderResult)
    new Root((target:Node), BACKEND, vdom, Into);

  static public function hydrateOnto(target:Element, vdom:RenderResult)
    new Root((target:Node), BACKEND, vdom, Onto);

  static public macro function mount(target, markup);

  static public function getNative(view:View):Null<Node>
    return getAllNative(view)[0];// not quite the pinnacle of efficiency, but let's see if anyone complains

  static public function getAllNative(view:View):Array<Node>
    return Widget.getAllNative(view);

  static public inline function updateAll()
    tink.state.Observable.updateAll();

  static public macro function hxx(e);
}

private class DomCursor extends Cursor<Node> {
  final parent:Node;
  var cur:Node;
  public function new(applicator, parent, cur) {
    super(applicator);
    this.parent = parent;
    this.cur = cur;
  }

  override public function current()
    return cur;

  public function insert(real:Node) {
    if (cur == null)
      parent.appendChild(real);
    else if (cur == real)
      cur = real.nextSibling;
    else {
      var next = real.nextSibling,
          inserted = real.parentNode != parent;

      parent.insertBefore(real, cur);

      if (!inserted) {
        parent.insertBefore(cur, next);
        cur = real.nextSibling;
      }
    }
  }

  public function delete(count:Int) {
    var v = cur;
    for (i in 0...count) {
      if (v == null || v.parentNode != parent) throw 'assert';
      // Clearing event handlers is not really necessary, but some extensions (in particular adblockers) keep references to detatched nodes, so this reduces leaks
      var handler:haxe.DynamicAccess<Event->Void> = untyped v.__eventHandler;
      if (handler != null) {
        js.Syntax.delete(v, '__eventHandler');
        for (k in handler.keys())
          v.removeEventListener(k, handler[k]);
      }
      var next = v.nextSibling;
      parent.removeChild(v);
      v = next;
    }
    cur = v;
  }

  public function step():Bool
    return switch cur {
      case null: false;
      case v: (cur = v.nextSibling) != null;
    }
}

private class DomBackend implements Applicator<Node> {

  public function new() {}

  var markers = new Array<Node>();
  public function createMarker()
    return switch markers.pop() {
      case null: document.createTextNode('');
      case v: v;
    }

  public function releaseMarker(marker) {
    markers.push(marker);// TODO: perhaps a max count wouldn't hurt
  }

  public function siblings(first:Node)
    return new DomCursor(this, first.parentNode, first);

  public function children(parent:Node)
    return new DomCursor(this, parent, parent.firstChild);
}