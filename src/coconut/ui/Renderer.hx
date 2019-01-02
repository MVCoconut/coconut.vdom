package coconut.ui;

import coconut.diffing.*;
import coconut.vdom.Child;
import js.Browser.*;
import js.html.*;

class Renderer extends coconut.diffing.Widget<Node> {
  
  static var DIFFER = new DomDiffer();

  static public function mount(target:Node, vdom:Child)
    DIFFER.render([vdom], target);

  static public function getNative(view:View):Null<Node>
    return getAllNative(view)[0];// not quite the pinnacle of efficiency, but let's see if anyone complains

  static public function getAllNative(view:View):Array<Node>
    return switch @:privateAccess view._coco_lastRender {
      case null: [];
      case r: r.flatten(null);
    }

}

private class DomDiffer extends Differ<js.html.Node> {

  static var PLACEHOLDER:Child = '';

  public function new() {}

  override function unsetLastRender(target:Node):Rendered<Node> {
    var ret = untyped target._coco_;
    untyped __js__('delete {0}._coco_', target);
    return ret;
  }

  override function placeholder(target):Child
    return PLACEHOLDER;

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
          else if(name.charCodeAt(0) == 'o'.code && name.charCodeAt(1) == 'n'.code) Reflect.setField(element, name, null);
          else untyped __js__('delete {0}[{1}]', element, name);
        else      
          Reflect.setField(element, name, newVal);
    }
    
  inline function updateAttribute(element:Element, name:String, newVal:Dynamic, oldVal:Dynamic) 
    if (newVal == null) element.removeAttribute(name);
    else element.setAttribute(name, newVal);
}