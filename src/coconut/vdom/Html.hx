package coconut.vdom;

import coconut.diffing.Factory.Properties;
import coconut.diffing.*;
import coconut.vdom.RenderResult;
import js.html.*;
import js.Browser.document;

using StringTools;

@:build(coconut.vdom.macros.Setup.addTags())
class Html {

  static var nodeTypes = new Map<String, Factory<Dynamic, Node, Dynamic>>();

  static public function nodeType<A, E:Node>(tag:String):Factory<A, Node, E>
    return cast switch nodeTypes[tag] {
      case null:
        nodeTypes[tag] = switch tag.split(':') {
          case ['svg', tag]: new Svg(tag);
          case [unknown, _]: throw 'unknown namespace $unknown';
          case [_]: new Elt(tag);
          default: throw 'invalid tag $tag';
        }
      case v: v;
    }

  static public function text(value:String):RenderResult
    return inline TextNode.inst.vnode(value, null, null, null);//TODO: would be faster to have a dedicated text node type insteat of going through factories and all that

  static public function raw(hxxMeta:HxxMeta<Element>, attr:HtmlFragmentAttr & { ?tag:String }):RenderResult {
    return HtmlFragment.byTag(attr.tag).vnode(attr, hxxMeta.key, hxxMeta.ref);
  }
}

private typedef HxxMeta<T> = {
  @:optional var key(default, never):Key;
  @:optional var ref(default, never):coconut.ui.Ref<T>;
}

private typedef Attrs = haxe.DynamicAccess<String>;

private typedef HtmlFragmentAttr = { content:String, ?className:tink.domspec.ClassName };

private class HtmlFragment extends Factory<HtmlFragmentAttr, Node, Element> {
  static final tags = new Map();
  static public function byTag(?tag:String):Factory<HtmlFragmentAttr, Node, Element> {
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
    this.tag = tag.toUpperCase();

  override public function adopt(target:Node):Null<Element>
    return
      if (target.nodeName == tag) cast target;
      else null;

  public function create(a:HtmlFragmentAttr):Element {
    var ret = document.createElement(tag);
    ret.className = a.className != null ? a.className : "";
    ret.innerHTML = a.content;
    return ret;
  }

  public function update(w:Element, nu:HtmlFragmentAttr, old:HtmlFragmentAttr) {
    w.className = nu.className != null ? nu.className : "";
    if (old.content != nu.content)
      w.innerHTML = nu.content;
  }

}

private class TextNode extends Factory<String, Node, Text> {
  static public var inst(default, null):TextNode = new TextNode();

  function new() {}

  override public function adopt(target:Node):Text
    return
      if (target.nodeType == Node.TEXT_NODE) cast target;
      else null;

  override function hydrate(target:Text, data:String) 
    if (target.textContent.length > data.length)
      target.splitText(data.length);

  public function create(text)
    return document.createTextNode(text);

  public function update(target:Text, nu, old)
    if (nu != old) target.textContent = nu;
}

private class Svg<Attr:{}> extends Factory<Attr, Node, Element> {
  static inline var SVG = 'http://www.w3.org/2000/svg';
  final tag:String;

  public function new(tag:String) {
    this.tag = tag.toLowerCase();
  }

  override public function adopt(node:Node):Element
    return
      if ((cast node).namespaceURI == SVG && node.nodeName == tag) cast node;
      else null;

  override public function hydrate(target:Element, attr:Attr)
    Elt.hydrateEvents(target, attr);

  public function create(attr:Attr) {
    var ret = document.createElementNS(SVG, tag);
    update(ret, attr, null);
    return ret;
  }

  public function update(target:Element, nu:Attr, old:Attr)
    Properties.set(target, nu, old, setSvgProp);

  static inline function setSvgProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'className':
        setSvgProp(element, 'class', newVal, oldVal);
      case 'xmlns':
      case 'attributes':
        Elt.setAttributes(element, newVal, oldVal);
      case _.startsWith('on') => true:
        Elt.setEvent(element, name, newVal, oldVal);
      case 'style':
        @:privateAccess Elt.updateStyle(element.style, newVal, oldVal);
      default:
        if (newVal == null)
          element.removeAttribute(name);
        else
          element.setAttribute(name, newVal);
    }

}

private class Elt<Attr:{}> extends Factory<Attr, Node, Element> {

  final tag:String;

  public function new(tag:String) {
    this.tag = tag.toUpperCase();
  }

  public function create(attr:Attr) {
    var ret = document.createElement(tag);
    ELEMENTS.update(ret, attr, null);
    return ret;
  }

  override public function adopt(node:Node):Element
    return
      if (node.nodeName == tag)
        cast node;
      else
        null;

  static var events = new Array<String>();
  static public function hydrateEvents<Attr:{}>(target:Element, attr:Attr) {
    var events = events;

    js.Syntax.code('for (var name in {0}) {
      if (name.startsWith("on")) {
        {1}.push(name);
      }
    }', attr, events);

    if (events.length > 0) {
      var handler:haxe.DynamicAccess<Event->Void> = untyped target.__eventHandler = { handleEvent: function (e:Event) js.Lib.nativeThis[e.type](e) };
      for (event in events) {
        var fn = Reflect.field(attr, event);
        event = event.substr(2);
        target.addEventListener(event, cast handler);
        Reflect.setField(handler, event, fn);
      }
      events.resize(0);
    }
  }

  override public function hydrate(target:Element, attr:Attr)
    hydrateEvents(target, attr);

  public function update(target:Element, nu:Attr, old:Attr)
    ELEMENTS.update(target, nu, old);

  static final ELEMENTS = new Updater<Element, {}>(
    (target, field) -> '$target.removeAttribute("$field")',
    (target, field, value) -> '$target.$field = $value',
    {
      className: function (t:Element, _, v:String, _) if (!(cast v)) t.removeAttribute('class') else t.className = v,
      style: function (t:Element, _, nu, old) updateStyle(t.style, nu, old),
      role: function (t:Element, _, nu, old) if (nu == null) t.removeAttribute('role') else t.setAttribute('role', nu),// TODO: would be good to have a more generic solution
      attributes: function (t, _, nu, old) setAttributes(t, nu, old),
      on: setEvent,
    },
    (rules, field) ->
      if (rules.exists(field)) field
      else if (field.startsWith('on')) 'on'
      else null
  );

  static public function setAttributes(t:Element, nu:Attrs, old:Attrs)
    Properties.set(t, nu, old, (t, k, v, _) -> switch v {
      case null: t.removeAttribute(k);
      default: t.setAttribute(k, v);
    });

  static public function setEvent(element:Element, event:String, newVal:Null<Event->Void>, _) {
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
  }

	static final STYLES = new Updater<CSSStyleDeclaration, tink.domspec.Style>(
		(target, field) -> if (field.contains('-')) '$target.removeProperty("$field")' else '$target.$field = null',
		(target, field, value) -> if (field.contains('-')) 'target.setProperty("$field", $value)' else '$target.$field = $value',
		null,
		(_, _) -> null
	);

  static function updateStyle(target:CSSStyleDeclaration, newVal:tink.domspec.Style, ?oldVal:tink.domspec.Style)
    STYLES.update(target, newVal, oldVal);

  static function noop(_) {}
}

private typedef Rules<Target> = haxe.DynamicAccess<(target:Target, field:String, nu:Dynamic, old:Null<Dynamic>)->Void>;

private class Updater<Target:{}, Value:{}> {//TODO: extract to coconut.diffing
	final unset:(target:String, field:String)->String;
	final set:(target:String, field:String, value:String)->String;
	final rules:Rules<Target>;
	final getRule:(rules:Rules<Target>, field:String)->Null<String>;
	public function new(unset, set, rules, getRule) {
		this.unset = unset;
		this.set = set;
		this.rules = rules;
		this.getRule = getRule;
	}

	static public function get(target, property:String)
		return switch property.indexOf('-') {
			case -1: '$target.$property';
			default: '$target["$property"]';
		}

	public function update(target:Target, newVal:Value, ?oldVal:Value) {
		if (newVal != null)
			getApplicator(newVal)(target, newVal, oldVal);

		if (oldVal != null)
			getDeleter(oldVal, newVal)(target);
	}

	final applicators = new js.lib.Map<String, (target:Target, nu:Value, ?old:Value)->Void>();
	function getApplicator(obj:{}) {
		var props = getFields(obj);
		var key = props.toString();
		var apply = applicators.get(key);

		if (apply == null) {
			var source = 'if (old) {';

			function add(prefix) {
				for (p in props)
					source += '\n  ${prefix(p)}' + switch getRule(rules, p) {
						case null:
							var nu = get('nu', p);
							'if ($nu == null) { ${unset('target', p)} } else ${set('target', p, nu)}';
						case rule: 'this.$rule(target, "$p", ${get('nu', p)}, old && ${get('old', p)});';
					}
			}

			add(p -> 'if (${get('nu', p)} !== ${get('old', p)}) ');

			source += '\n} else {';

			add(p -> '');

			source += '\n}';
			apply = cast new js.lib.Function('target', 'nu', 'old', source).bind(rules);
			applicators.set(key, apply);
		}

		return apply;
	}

	function noop(target:Target) {}
	final deleters = new js.lib.Map<String, (target:Target)->Void>();
	function getDeleter(old:{}, ?nu:{}) {

		function forFields(fields:haxe.ds.ReadOnlyArray<String>) {
			var key = fields.toString();
			var ret = deleters.get(key);
			if (ret == null) {
				var body = '';
				for (f in fields)
					body += '\n' + switch getRule(rules, f) {
            case null: unset('target', f);
            case rule: 'this.$rule(target, "$f", null);';
          }
        deleters.set(key, ret = cast new js.lib.Function('target', body).bind(rules));
			}
			return ret;
		}

		return
			if (nu == null)
				forFields(getFields(old));
			else {
				var oldFields = getFields(old),
						nuFields = getFields(nu);

				var nuKey = nuFields.toString(),
						oldKey = oldFields.toString();

				if (nuKey == oldKey) noop;
				else {
					var key = '${nuKey}:${oldKey}';
					var ret = deleters.get(key);

					if (ret == null)
						deleters.set(key, ret = forFields([for (f in oldFields) if (!nuFields.contains(f)) f]));

					ret;
				}
			}
	}

	static function getFields(o:{}) {
		var ret = js.lib.Object.getOwnPropertyNames(o);
		switch ret {
			case [], [_]:
			case [a, b]:
				if (a > b) {
					ret[0] = b;
					ret[1] = a;
				}
			default:
				(cast ret).sort();
		}
		return ret;
		// TODO: check the caching attempt below again. Thus far profiling suggested this causes a slow down.
		// var ret:haxe.ds.ReadOnlyArray<String> = untyped o._coco_keys;
		// if (ret == null) {
		//   ret = untyped Object.getOwnPropertyNames(o).sort();
		//   js.lib.Object.defineProperty(o, '_coco_keys', { value: ret, enumerable: false });
		//   var joined = ret.toString();
		//   untyped ret.toString = function () return joined;
		// }
		// return ret;
	}
}