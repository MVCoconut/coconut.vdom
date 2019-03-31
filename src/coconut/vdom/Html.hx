package coconut.vdom;

import coconut.diffing.Differ;
import coconut.diffing.VNode;
import coconut.diffing.NodeType;
import js.html.*;
import js.Browser.document;

@:build(coconut.vdom.macros.Setup.addTags())
class Html {

  static var nodeTypes = new Map<String, NodeType<Dynamic, Element>>();

  static public function nodeType<A>(tag:String):NodeType<A, Element> 
    return cast switch nodeTypes[tag] {
      case null:
        nodeTypes[tag] = new Elt(tag);
      case v: v;
    }

  static public inline function text(value:String):Child
    return VNative(Text.inst, null, null, value, null);

  static inline function h(tag:String, attr:Dynamic, ?children:coconut.ui.Children):Child 
    return cast VNative(nodeType(tag), attr.ref, attr.key, attr, cast children);

  static public inline function raw(attr):Child
    return HtmlFragment.fromHxx(attr);
}

private class HtmlFragment extends coconut.ui.View {
  @:attribute var content:String;
  @:attribute var tag:String = 'span'; 
  @:attribute var className:tink.domspec.ClassName = null;
  
  var root:Element;
  var lastTag:String;
  var lastContent:String;

  function render()
    return @:privateAccess Html.h(tag, { className: className, ref: function (e) this.root = e });

  function viewDidMount() {
    lastContent = tag;
    root.innerHTML = lastContent = content;
  }

  function viewDidUpdate() 
    if (lastContent != content || lastTag != tag) {
      root.innerHTML = content;
      lastContent = content;
      lastTag = tag;
    }    
}

private class Text implements NodeType<String, Node> {
  static public var inst(default, null):Text = new Text();
  
  function new() {}

  public function create(text) 
    return document.createTextNode(text);
  public function update(target:Node, old, nu) 
    if (nu != old) target.textContent = nu;
}

private class Elt<Attr:{}> implements NodeType<Attr, Element> {
  var ns:String;
  var tag:String;

  public function new(tag:String) {
    this.tag = switch tag.split(':') {
      case [ns, tag]: 
        this.ns = ns;
        tag;
      default: tag;
    }
  }

  public function create(attr:Attr) {
    var ret =
      if (ns == null) document.createElement(tag);
      else document.createElementNS(ns, tag);
    Differ.updateObject(ret, attr, null, setProp);
    return ret;
  }

  public function update(target, old:Attr, nu:Attr) 
    Differ.updateObject(target, nu, old, setProp);

  static inline function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, newVal);        

  static inline function setProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'key' | 'ref':
      case 'style':
        Differ.updateObject(element.style, newVal, oldVal, setField);
      case 'attributes':
        Differ.updateObject(element, newVal, oldVal, updateAttribute);
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
    
  static inline function updateAttribute(element:Element, name:String, newVal:Dynamic, oldVal:Dynamic) 
    if (newVal == null) element.removeAttribute(name);
    else element.setAttribute(name, newVal);  

}