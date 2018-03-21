package coconut.vdom;

import js.html.*;
import js.Browser.*;
import coconut.vdom.Attr;

class VDom {
  static var EMPTY:Dict<Any> = {};
  
  static public inline function h(type:String, ?attributes:{}, ?children:Children):Child 
    return ({ 
      t: type, 
      k: if (attributes == null) null else untyped attributes.key, 
      a: attributes, 
      c: children 
    });

  static function updateNode(domNode:DomNode, newNode:Child) {
    var ret = doUpdateNode(domNode, newNode);
    ret.vdom = newNode;
    return ret;
  }
  static function doUpdateNode(domNode:DomNode, newNode:Child) {
    var oldNode = domNode.vdom;
		if (newNode == oldNode) return domNode;
    var ret = domNode;
    
    function replace(with) {
      ret = with;
      if (domNode.parentNode != null)
        domNode.parentNode.replaceChild(ret, domNode);
    }

		switch [newNode.isWidget, oldNode.isWidget] {
      case [true, true]:

        replace(newNode.asWidget().update(oldNode.asWidget(), domNode));

      case [false, false]:
        if (newNode.type != oldNode.type) 
          replace(createNode(newNode));//TODO: consider preserving children
        else if (newNode.isText) {
          var oldText = oldNode.asText(),
              newText = newNode.asText();

          if (oldText != newText)
            (domNode:Node).nodeValue = newText;
        }
        else if (newNode.asNative() != null)//oldNode is native too
          replace(newNode.asNative())
        else {
          updateElement(cast domNode, newNode.attributes, domNode.vdom.attributes);

          var newChildren = newNode.children;

				  var newLength = newChildren.length,
              oldLength = domNode.childNodes.length;

          var oldKeyed = {
            var ret = new haxe.DynamicAccess();
            var newKeys = new haxe.DynamicAccess();

            for (c in newChildren) 
              if (c.key != null && !newKeys[c.key]) 
                newKeys[c.key] = true;

            for (i in 0...oldLength) {
              var old = domNode.childNodes[i];
              var k = old.key;
              if (k != null && newKeys[k]) 
                ret[k] = old;
            }
            ret;
          }

          for (i in 0...newLength) {

            var newChild = newChildren[i];

            var target = 
              switch oldKeyed[newChild.key] {
                case null: 
                  var j = i,
                      max = domNode.childNodes.length;

                  while (j < max && oldKeyed.exists(domNode.childNodes[j].key)) j++;

                  domNode.childNodes[j];
                case v: v;
              }

            if (target == null) 
              domNode.appendChild(createNode(newChild));
            else {
              updateNode(target, newChild);
              var cur = domNode.childNodes[i];
              if (target != cur) 
                domNode.insertBefore(target, cur);
            }
          }
          for (i in newLength...oldLength)
            domNode.removeChild(domNode.childNodes[newLength]);    
        }
      case [false, true]:
        oldNode.asWidget().destroy();
        replace(createNode(newNode));
      case [true, false]:
        replace(newNode.asWidget().init());
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

	static function createNode(c:Child):Node {
    var ret:DomNode = doCreateNode(c);
    ret.vdom = c;
    return ret;
  }
	static function doCreateNode(c:Child):Node 
		return 
      if (c.isWidget) c.asWidget().init();
      else if (c.isText) document.createTextNode(c.asText());
      else switch c.asNative() {
        case null:
          
          console.log('create ${c.type} ${haxe.Json.stringify(c.attributes)}');
          
          var ret = document.createElement(c.type),
              attributes = c.attributes;

          updateElement(ret, attributes, null);
          
          for (c in c.children) if (c != null)
            ret.appendChild(createNode(c));

          ret;
        case v: v;
      }
}

@:forward(insertBefore, parentNode, appendChild, removeChild)
private abstract DomNode(Node) from Node to Node {

  public var childNodes(get, never):ChildList;
    
    inline function get_childNodes():ChildList
      return cast this.childNodes;

  public var key(get, never):String;

    inline function get_key():String
      return vdom.key;

  public var vdom(get, set):Child;
    
    inline function get_vdom():Child
      return untyped this.__vdom;

    inline function set_vdom(param:Child):Child
      return untyped this.__vdom = param;
}

extern class ChildList implements ArrayAccess<DomNode> {
  var length(default, null):Int;
}