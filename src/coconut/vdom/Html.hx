package coconut.vdom;

import coconut.diffing.*;
import coconut.diffing.VNode;
import coconut.diffing.NodeType;
import coconut.vdom.RenderResult;
import js.html.*;
import js.Browser.document;

using StringTools;

@:build(coconut.vdom.macros.Setup.addTags())
class Html {

  static var nodeTypes = new Map<String, NodeType<Dynamic, Node>>();

  static public function nodeType<A>(tag:String):NodeType<A, Node>
    return cast switch nodeTypes[tag] {
      case null:
        nodeTypes[tag] = switch tag.split(':') {
          case ['svg', tag]: cast new Svg(tag);
          case [unknown, _]: throw 'unknown namespace $unknown';
          case [_]: cast new Elt(tag);
          default: throw 'invalid tag $tag';
        }
      case v: v;
    }

  static public inline function text(value:String):RenderResult
    return VNative(Text.inst, null, null, value, null);

  static inline function h(tag:String, ref:Dynamic->Void, key:Key, attr:Dynamic, ?children:coconut.vdom.Children):RenderResult
    return VNode.native(nodeType(tag), ref, key, attr, children);

  static public function raw(hxxMeta:HxxMeta<Element>, attr:HtmlFragmentAttr & { ?tag:String }):RenderResult {
    return VNode.native(HtmlFragment.byTag(attr.tag), cast hxxMeta.ref, hxxMeta.key, attr);
  }
}

private typedef HxxMeta<T> = {
  @:optional var key(default, never):Key;
  @:optional var ref(default, never):coconut.ui.Ref<T>;
}

private typedef HtmlFragmentAttr = { content:String, ?className:tink.domspec.ClassName };

private class HtmlFragment implements NodeType<HtmlFragmentAttr, Element> {
  static final tags = new Map();
  static public function byTag(?tag:String):NodeType<HtmlFragmentAttr, Node> {
    if (tag == null)
      tag = 'span';
    tag = tag.toUpperCase();

    return switch tags[tag] {
      case null: tags[tag] = cast new HtmlFragment(tag);
      case v: v;
    }
  }
  public final tag:String;
  public function new(tag)
    this.tag = tag;

  public function create(a:HtmlFragmentAttr):Element {
    var ret = document.createElement(tag);
    ret.className = a.className;
    ret.innerHTML = a.content;
    return ret;
  }

  public function update(w:Element, old:HtmlFragmentAttr, nu:HtmlFragmentAttr) {
    w.className = nu.className;
    if (old.content != nu.content)
      w.innerHTML = nu.content;
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

private class Svg<Attr:{}> implements NodeType<Attr, Element> {
  static inline var SVG = 'http://www.w3.org/2000/svg';
  final tag:String;

  public function new(tag:String) {
    this.tag = tag;
  }

  public function create(attr:Attr) {
    var ret = document.createElementNS(SVG, tag);
    Differ.updateObject(ret, attr, null, setSvgProp);
    return ret;
  }

  public function update(target:Element, old:Attr, nu:Attr)
    Differ.updateObject(target, nu, old, setSvgProp);

  static inline function setSvgProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'viewBox' | 'className':
        if (newVal == null)
          element.removeAttributeNS(SVG, name);
        else
          element.setAttributeNS(SVG, name, newVal);
      case 'xmlns':
      case 'style':
        Differ.updateObject(element.style, newVal, oldVal, @:privateAccess Elt.setStyle);
      // case _ if (js.Syntax.code('{0} in {1}', name, element)):
      //   Elt.setProp(element, name, newVal, oldVal);
      default:
        if (newVal == null)
          element.removeAttribute(name);
        else
          element.setAttribute(name, newVal);
    }

}

private class Elt<Attr:{}> implements NodeType<Attr, Element> {

  final tag:String;

  public function new(tag:String) {
    this.tag = tag;
  }

  public function create(attr:Attr) {
    var ret = document.createElement(tag);
    Differ.updateObject(ret, attr, null, setProp);
    return ret;
  }

  public function update(target:Element, old:Attr, nu:Attr)
    Differ.updateObject(target, nu, old, setProp);

  static inline function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, newVal);

  static inline function setStyle(target:CSSStyleDeclaration, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    Reflect.setField(target, name, if (newVal == null) null else newVal);

  static function noop(_) {}

  static public inline function setProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'style':
        Differ.updateObject(element.style, newVal, oldVal, setStyle);
      case 'attributes':
        Differ.updateObject(element, newVal, oldVal, updateAttribute);
      case 'className' if (!newVal):
        element.removeAttribute('class');
      case event if (event.fastCodeAt(0) == 'o'.code && event.fastCodeAt(1) == 'n'.code):

        var event = event.substr(2);
        var handler:haxe.DynamicAccess<Event->Void> = untyped element.__eventHandler;
        if (handler == null) {
          untyped element.__eventHandler = handler = { handleEvent: function (e:Event) js.Lib.nativeThis[e.type](e) };
        }

        if (!handler.exists(event))
          element.addEventListener(event, cast handler);

        handler[event] = switch newVal {
          case null: noop;
          default: newVal;
        }
      default:
        if (newVal == null)
          if (element.hasAttribute(name)) element.removeAttribute(name);
          else js.Syntax.delete(element, name);
        else
          Reflect.setField(element, name, newVal);
    }

  static inline function updateAttribute(element:Element, name:String, newVal:Dynamic, oldVal:Dynamic)
    if (newVal == null) element.removeAttribute(name);
    else element.setAttribute(name, newVal);

}
