package coconut.vdom;

import coconut.diffing.*;
import js.html.*;
import js.Browser.*;

typedef VDom = {
  var attributes:Dynamic<Any>;
  var children:coconut.ui.Children;
}

@:pure
abstract Child(VNode<VDom, Node>) to VNode<VDom, Node> from VNode<VDom, Node> {
  
  inline function new(n) this = n;

  static function element(tag, attr:Dynamic, ?children) 
    return new Child({
      type: tag,
      key: attr.key,
      ref: attr.ref,//TODO: it seems unfortunate that these are here
      kind: VNative({
        attributes: attr,
        children: children
      })
    });
  
  @:from static function ofText(s:String):Child
    return element('', { text: s });

  @:from static function ofInt(i:Int):Child
    return Std.string(i);

  static function widget<A>(name, key, ref:Dynamic, attr:A, type:WidgetType<VDom, A, Node>)
    return new Child({
      type: name,
      key: key,
      ref: ref,
      kind: VWidget(attr, type)
    });

  public function renderInto(target:Node) 
    differ.render([this], target);

  static var differ = new DomDiffer();
  static public var PLACEHOLDER(default, never):Child = '';

}


private class DomDiffer extends Differ<VDom, js.html.Node> {

  public function new() {}

  override function unsetLastRender(target:Node):Rendered<VDom, Node> {
    var ret = untyped target._coco_ = null;
    untyped __js__('delete {0}._coco_', target);
    return ret;
  }

  override function placeholder(target):Child
    return Child.PLACEHOLDER;

  override function getLastRender(target:Node):Null<Rendered<VDom, Node>> 
    return untyped target._coco_;

  override function setLastRender(target:Node, r:Rendered<VDom, Node>) 
    untyped target._coco_ = r;

  override function setChildren(target:Node, children:Array<Node>) {
    var e:Element = cast target;
    if (children == null) e.innerHTML = '';
    else {
      var pos = 0;
      for (nu in children) {
        var old = e.childNodes[pos++];
        if (old != nu) 
          e.insertBefore(nu, old);
      }
      for (i in pos...e.childNodes.length)
        e.removeChild(e.childNodes[pos]);
    }
  }

  override function updateNative(real:Node, nu:VDom, old:VDom, parent:Null<Widget<VDom, Node>>, later:Later) 
    if (real.nodeType == Node.TEXT_NODE) {
      var text = nu.attributes.text;
      if (text != old.attributes.text) real.nodeValue = text;
    }
    else {
      var elt:Element = cast real;
      updateObject(elt, nu.attributes, old.attributes, setProp);
      _render(cast nu.children, elt, parent, later);
    }

  override function createNative(tag:NodeType, vdom:VDom, parent:Null<Widget<VDom, Node>>, later:Later):Node 
    return switch tag {
      case '': 
        document.createTextNode(vdom.attributes.text);
      case other: 
        var elt = document.createElement(tag);
        updateObject(elt, vdom.attributes, null, setProp);
        _render(cast vdom.children, elt, parent, later);
        elt;
    }

  override function replaceWidgetContent(prev:Map<Node, Bool>, cursor:Node, total:Int, next:Rendered<VDom, Node>, later:Later) {
    
    var parent = cursor.parentNode;
    
    next.each(later, function (r) {
      prev.remove(r);
      if (r == cursor) cursor = r.nextSibling;
      else parent.insertBefore(r, cursor);
    });

    for (r in prev.keys())
      parent.removeChild(r);
  }

  override function removeChild(real:Node, child:Node) 
    real.removeChild(child);

  override function nativeParent(node:Node)
    return node.parentNode;

  inline function setProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'key' | 'ref':
      case 'style':
        updateObject(element.style, newVal, oldVal, setField);
      case 'attributes':
        updateObject(element, newVal, oldVal, updateAttribute);
      default:
        if (newVal == null)
          untyped __js__('delete {0}[{1}]', element, name);
        else      
          Reflect.setField(element, name, newVal);
    }
    
  inline function updateAttribute(element:Element, name:String, newVal:Dynamic, oldVal:Dynamic) 
    if (newVal == null) element.removeAttribute(name);
    else element.setAttribute(name, newVal);
}