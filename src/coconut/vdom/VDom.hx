package coconut.vdom;

import js.html.*;
import js.Browser.document;
import coconut.vdom.Attr;

class VDom {
  static var EMPTY:Dict<Any> = {};
  
  static inline function h(type:String, ?attributes:{}, ?children:Children):Child 
    return ({ 
      t: type, 
      k: if (attributes == null) null else untyped attributes.key, 
      a: attributes, 
      c: children 
    });

static function updateNode(domNode:Node, newNode:Child, oldNode:Child) {
		if (newNode == oldNode) return domNode;
    var ret = domNode;
    function replace(with)
      domNode.parentNode.replaceChild(ret = with, domNode);

		switch [newNode.isWidget, oldNode.isWidget] {
      case [true, true]:
        var n:Widget = cast newNode,
            o:Widget = cast oldNode;

        replace(n.update(o, cast domNode));

      case [false, false]:
        if (newNode.type != oldNode.type) 
          replace(createNode(newNode));//TODO: consider preserving children
        else if (newNode.isText) {
          if (newNode.key != oldNode.key)//oldNode is text too, so `key` is the text content
            replace(createNode(newNode));
        }
        else if (newNode.getNative() != null)//oldNode is native too
          replace(newNode.getNative())
        else {
          var elt:Element = cast domNode;
          
          updateElement(elt, newNode.attributes, oldNode.attributes);

          var oldChildren = oldNode.children;

          var newChildren = {
            //TODO: this doesn't handle the case that nodes from the old and new child list are physically equal
            var oldKeys = [for (c in oldChildren) if (c.key != null) c.key => true];
            var newWithKeys = new Map();
            var keylessNew = [for (c in newNode.children) 
              if (c.key != null && oldKeys[c.key]) {
                newWithKeys[c.key] = c;//TODO: deal with duplicate keys
                continue;
              }
              else c
            ];
            keylessNew.reverse();
            
            [for (i in 0...newNode.children.length) 
              switch oldChildren[i] {
                case null | { key: null }: keylessNew.pop();
                case { key: k }:
                  switch newWithKeys[k] {
                    case null: keylessNew.pop();
                    case v: v;
                  }
              }
            ];
          }

				  var newLength = newChildren.length,
              oldLength = oldChildren.length;

          var max = 
            if (newLength > oldLength) oldLength 
            else newLength;

          for (i in 0...max) 
            updateNode(elt.childNodes[i], newChildren[i], oldChildren[i]);
          if (newLength > oldLength)
            for (i in max...newLength)
              elt.appendChild(createNode(newChildren[i]));
          else
            for (i in max...oldLength)
              elt.removeChild(elt.childNodes[max]);       
        }
      case [false, true]:
        (cast oldNode:Widget).destroy();
        replace(createNode(newNode));
      case [true, false]:
        replace((cast newNode:Widget).init());
    }
    return ret;
	}

	static function setProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
		switch name {
      case 'key':
      case 'attributes':
        updateObject(element, newVal, oldVal, updateAttribute);
      default:
        if (newVal == null)
          js.Syntax.delete(element, name);
        else      
          Reflect.setField(element, name, newVal);
    }
		
	static function updateAttribute(element:Element, name:String, newVal:Dynamic, oldVal:Dynamic) 
    if (newVal == null) element.removeAttribute(name);
    else element.setAttribute(name, newVal);

	static function updateProp(element:Element, name:String, newVal:Dynamic, oldVal:Dynamic) 
    if (oldVal != newVal) 
      setProp(element, name, newVal, oldVal);
	
	static function updateElement(element:Element, newProps:Dict<Any>, oldProps:Dict<Any>) 
    updateObject(element, newProps, oldProps, updateProp);

	static function updateObject<Target>(element:Target, newProps:Dict<Any>, oldProps:Dict<Any>, updateProp:Target->String->Any->Any->Void) {
		var keys:Dynamic<Bool> = {};
    
    if (newProps == null) newProps = EMPTY;
    if (oldProps == null) oldProps = EMPTY;

		for(key in newProps.keys()) Reflect.setField(keys, key, true);
		for(key in oldProps.keys()) Reflect.setField(keys, key, true);
		
    for(key in js.Object.getOwnPropertyNames(cast keys)) 
      updateProp(element, key, newProps[key], oldProps[key]);		
	}    

	static function createNode(c:Child):Node 
		return 
      if (c.isWidget) (cast c:Widget).init();
      else if (c.isText) document.createTextNode(c.key);
      else switch c.getNative() {
        case null:
          var ret = document.createElement(c.type),
              attributes = c.attributes;

          updateElement(ret, attributes, null);
          
          for (c in c.children) if (c != null)
            ret.appendChild(createNode(c));

          ret;
        case v: v;
      }

  static public inline function iframe(attr: IframeAttr, ?children:Children):Child return h('iframe', attr, children);

  static public inline function object(attr: {> Attr, type:String, data:String }, ?children:Children):Child return h('object', attr, children);

  static public inline function param(attr: {> Attr, name:String, value:String }):Child return h('param', attr);
  static public inline function div(attr:EditableAttr, ?children:Children):Child return h('div', attr, children);
  static public inline function aside(attr:EditableAttr, ?children:Children):Child return h('aside', attr, children);
  static public inline function section(attr:EditableAttr, ?children:Children):Child return h('section', attr, children);

  static public inline function header(attr:EditableAttr, ?children:Children):Child return h('header', attr, children);
  static public inline function footer(attr:EditableAttr, ?children:Children):Child return h('footer', attr, children);
  static public inline function main(attr:EditableAttr, ?children:Children):Child return h('main', attr, children);
  static public inline function nav(attr:EditableAttr, ?children:Children):Child return h('nav', attr, children);

  static public inline function table(attr:EditableAttr, ?children:Children):Child return h('table', attr, children);
  static public inline function thead(attr:EditableAttr, ?children:Children):Child return h('thead', attr, children);
  static public inline function tbody(attr:EditableAttr, ?children:Children):Child return h('tbody', attr, children);
  static public inline function tfoot(attr:EditableAttr, ?children:Children):Child return h('tfoot', attr, children);
  static public inline function tr(attr:EditableAttr, ?children:Children):Child return h('tr', attr, children);
  static public inline function td(attr:TableCellAttr, ?children:Children):Child return h('td', attr, children);
  static public inline function th(attr:TableCellAttr, ?children:Children):Child return h('th', attr, children);

  static public inline function h1(attr:EditableAttr, ?children:Children):Child return h('h1', attr, children);
  static public inline function h2(attr:EditableAttr, ?children:Children):Child return h('h2', attr, children);
  static public inline function h3(attr:EditableAttr, ?children:Children):Child return h('h3', attr, children);
  static public inline function h4(attr:EditableAttr, ?children:Children):Child return h('h4', attr, children);
  static public inline function h5(attr:EditableAttr, ?children:Children):Child return h('h5', attr, children);

  static public inline function strong(attr:EditableAttr, ?children:Children):Child return h('strong', attr, children);
  static public inline function em(attr:EditableAttr, ?children:Children):Child return h('em', attr, children);
  static public inline function span(attr:EditableAttr, ?children:Children):Child return h('span', attr, children);
  static public inline function a(attr:AnchorAttr, ?children:Children):Child return h('a', attr, children);

  static public inline function p(attr:EditableAttr, ?children:Children):Child return h('p', attr, children);
  static public inline function i(attr:EditableAttr, ?children:Children):Child return h('i', attr, children);
  static public inline function b(attr:EditableAttr, ?children:Children):Child return h('b', attr, children);
  static public inline function small(attr:EditableAttr, ?children:Children):Child return h('small', attr, children);
  static public inline function menu(attr:EditableAttr, ?children:Children):Child return h('menu', attr, children);
  static public inline function ul(attr:EditableAttr, ?children:Children):Child return h('ul', attr, children);
  static public inline function ol(attr:EditableAttr, ?children:Children):Child return h('ol', attr, children);
  static public inline function li(attr:EditableAttr, ?children:Children):Child return h('li', attr, children);
  static public inline function label(attr:LabelAttr, ?children:Children):Child return h('label', attr, children);
  static public inline function button(attr:InputAttr, ?children:Children):Child return h('button', attr, children);
  static public inline function textarea(attr:TextAreaAttr, ?children:Children):Child return h('textarea', attr, children);
  
  static public inline function pre(attr:EditableAttr, ?children:Children):Child return h('pre', attr, children);

  static public inline function hr(attr: Attr):Child return h('hr', attr);
  static public inline function br(attr: Attr):Child return h('br', attr);
  static public inline function wbr(attr: Attr):Child return h('wbr', attr);

  static public inline function canvas(attr: CanvasAttr):Child return h('canvas', attr);
  static public inline function img(attr: ImgAttr):Child return h('img', attr);
  static public inline function audio(attr: AudioAttr, ?children:Children):Child return h('audio', attr, children);
  static public inline function video(attr: VideoAttr, ?children:Children):Child return h('video', attr, children);
  static public inline function source(attr: SourceAttr):Child return h('source', attr);
  static public inline function input(attr: InputAttr):Child return h('input', attr);
  static public inline function form(attr: FormAttr, ?children:Children):Child return h('form', attr, children);

  static public inline function select(attr: SelectAttr, ?children:Children):Child return h('select', attr, children);
  static public inline function option(attr: OptionAttr, ?children:Children):Child return h('option', attr, children);
  static public inline function script(attr: ScriptAttr, ?children:Children):Child return h('script', attr, children);
  
  static public inline function raw(attr: HtmlFragment.RawAttr):Child return HtmlFragment.create(attr);
}