package coconut.vdom;

import coconut.diffing.*;
import coconut.diffing.VNode;
import js.html.*;
import js.Browser.*;

@:pure
abstract Child(VNode<Node>) to VNode<Node> from VNode<Node> {
  
  inline function new(n) this = n;

  static function element(tag, attr:Dynamic, ?children) 
    return VNative(tag, attr.ref, attr.key, attr, children);
  
  @:from static function ofText(s:String):Child
    return element('', { text: s });

  @:from static function ofInt(i:Int):Child
    return Std.string(i);

  @:from static function ofNode(n:Node):Child
    return VNativeInst(n);

  @:from static function ofView(v:coconut.ui.View):Child
    return VWidgetInst(v);

  static function widget<A>(name, key, ref:Dynamic, attr:A, type:WidgetType<A, Node>)
    return new Child(VWidget(name, ref, key, attr, type));

  public function renderInto(target:Node) 
    differ.render([this], target);

  static var differ = new DomDiffer();
  static public var PLACEHOLDER(default, never):Child = '';

}

private class DomDiffer extends Differ<js.html.Node> {

  public function new() {}

  override function unsetLastRender(target:Node):Rendered<Node> {
    var ret = untyped target._coco_;
    untyped __js__('delete {0}._coco_', target);
    return ret;
  }

  override function placeholder(target):Child
    return Child.PLACEHOLDER;

  override function getLastRender(target:Node):Null<Rendered<Node>> 
    return untyped target._coco_;

  override function setLastRender(target:Node, r:Rendered<Node>) 
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

  override function updateAttr<Attr>(real:Node, nuAttr:Attr, oldAttr:Attr) 
    if (real.nodeType == Node.TEXT_NODE) {
      var text = untyped nuAttr.text;
      if (text != untyped oldAttr.text) real.nodeValue = text;
    }
    else updateObject((cast real:Element), cast nuAttr, cast oldAttr, setProp);

  override function initAttr<Attr>(tag:NodeType, attr:Attr):Node 
    return switch tag {
      case '': 
        document.createTextNode(untyped attr.text);
      case other: 
        updateObject(document.createElement(tag), cast attr, null, setProp);
    }

  override function replaceWidgetContent(prev:Map<Node, Bool>, cursor:Node, total:Int, next:Rendered<Node>, later:Later) {
    
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
      case 'className' if (!newVal):
        element.removeAttribute('class');
      default:
        if (newVal == null)
          if (element.hasAttribute(name)) element.removeAttribute(name);
          else untyped __js__('delete {0}[{1}]', element, name);
        else      
          Reflect.setField(element, name, newVal);
    }
    
  inline function updateAttribute(element:Element, name:String, newVal:Dynamic, oldVal:Dynamic) 
    if (newVal == null) element.removeAttribute(name);
    else element.setAttribute(name, newVal);
}