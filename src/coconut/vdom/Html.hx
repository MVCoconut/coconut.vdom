package coconut.vdom;

import coconut.diffing.*;
import coconut.diffing.VNode;
import coconut.diffing.NodeType;
import coconut.vdom.RenderResult;
import js.html.*;
import js.Browser.document;

@:build(coconut.vdom.macros.Setup.addTags())
class Html {

  static var nodeTypes = new Map<String, NodeType<Dynamic, Node>>();

  static public function nodeType<A>(tag:String):NodeType<A, Node>
    return cast switch nodeTypes[tag] {
      case null:
        nodeTypes[tag] = cast new Elt(tag);
      case v: v;
    }

  static public inline function text(value:String):RenderResult
    return VNative(Text.inst, null, null, value, null);

  static inline function h(tag:String, ref:Dynamic->Void, key:Key, attr:Dynamic, ?children:coconut.vdom.Children):RenderResult
    return VNode.native(nodeType(tag), ref, key, attr, children);

  static public inline function raw(hxxMeta, attr):RenderResult
    return HtmlFragment.fromHxx(hxxMeta, attr);
}

private class HtmlFragment extends coconut.vdom.View {
  @:tracked @:attribute var content:String;
  @:attribute var tag:String = 'span';
  @:attribute var className:tink.domspec.ClassName = null;

  var root:Element;
  var lastTag:String;
  var lastContent:String;

  function render()
    return @:privateAccess Html.h(tag, function (e) this.root = e, null, { className: className });

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

  static inline var SVG = 'http://www.w3.org/2000/svg';
  static var namespaces = [
    'svg' => SVG,
  ];

  var ns:String;
  var tag:String;

  public function new(tag:String) {
    this.tag = switch tag.split(':') {
      case [namespaces[_] => ns, tag]:
        this.ns = ns;
        tag;
      default: tag;
    }
  }

  public function create(attr:Attr) {
    var ret =
      if (ns == null) document.createElement(tag);
      else document.createElementNS(ns, tag);
    Differ.updateObject(ret, attr, null, switch ns {
      case SVG: setSvgProp;
      default: setProp;
    });
    return ret;
  }

  public function update(target:Element, old:Attr, nu:Attr)
    Differ.updateObject(target, nu, old, switch target.namespaceURI {
      case SVG: setSvgProp;
      default: setProp;
    });

  static inline function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, newVal);

  static inline function setSvgProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'viewBox' | 'className':
        if (newVal == null)
          element.removeAttributeNS(SVG, name);
        else
          element.setAttributeNS(SVG, name, newVal);
      case 'xmlns':
      case _ if (untyped __js__('{0} in {1}', name, element)):
        setProp(element, name, newVal, oldVal);
      default:
        if (newVal == null)
          element.removeAttribute(name);
        else
          element.setAttribute(name, newVal);
    }

  static inline function setStyle(target:CSSStyleDeclaration, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, if (newVal == null) null else newVal);

  static inline function setProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'style':
        Differ.updateObject(element.style, newVal, oldVal, setStyle);
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
