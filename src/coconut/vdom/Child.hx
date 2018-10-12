package coconut.vdom;

import coconut.diffing.*;
import js.html.*;
import js.Browser.*;

typedef VDom = {
  var attributes:Dynamic<Any>;
  var children:coconut.ui.Children;
}

abstract Child(VNode<VDom, Node>) to VNode<VDom, Node> {
  
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

  public function mountInto(target:Node) {
    var root = new VRoot(target, [this], new DomDiffer());
  }

}

private class DomDiffer extends Differ<VDom, js.html.Node> {

  public function new() {}

  override function create(tag:String, vdom:VDom, root, parent):js.html.Node 
    return switch tag {
      case '': 
        document.createTextNode(vdom.attributes.text);
      case other: 
        var elt = document.createElement(tag);
        updateObject(elt, vdom.attributes, null, setProp);
        switch vdom.children {
          case null:
          case c:
            var rendered = renderAll(cast c, root, parent);
            untyped elt._coco_rendered = rendered;
            for (node in flatten(rendered.childList))
              elt.appendChild(node);
        }
        elt;
    }

  override function nativeParent(node:Node)
    return node.parentNode;

  override function updateNative(node:Node, tag:String, nu:VDom, old:VDom, root, parent) 
    if (tag == '') {
      var text = nu.attributes.text;
      if (text != old.attributes.text)
        node.textContent = text;
    }
    else {
      var elt:Element = cast node;
      if (old.children.length + nu.children.length > 0) {
        var o:{ _coco_rendered: Rendered<VDom, Node> } = cast node;
        updateObject(elt, nu.attributes, old.attributes, setProp);
        o._coco_rendered = updateAll(o._coco_rendered, cast nu.children, root, parent);
      }
    }

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
  
  override function spliceChildren(target:js.html.Node, children:Array<js.html.Node>, start:js.html.Node, oldCount:Int) {
    if (untyped target.className == 'todo-list') {
      trace(target);
      trace(children.length);
    }
    var pos = 
      if (start == null) 0;
      else {
        var found = -1;
        for (i in 0...target.childNodes.length)
          if (target.childNodes[i] == start) {
            found = i;
            break;
          }
        if (found == -1) throw 'start node not found';
        0;
      }

    var created = 0;

    function add(nu:js.html.Node) {
      var old = target.childNodes[pos];
      if (old != nu) {
        if (nu.parentNode == null) created++;
        target.insertBefore(nu, old);
      }
      pos++;
    }
    
    for (c in children)
      add(c);

    // trace(oldCount + created - children.length);

    for (i in 0...oldCount + created - children.length)
      target.removeChild(target.childNodes[pos]);
  }

  override function setChildren(target:js.html.Node, children:Array<js.html.Node>) 
    spliceChildren(target, children, target.childNodes[0], target.childNodes.length);
}