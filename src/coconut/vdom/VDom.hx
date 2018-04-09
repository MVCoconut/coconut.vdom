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

  static function updateNode(domNode:Node, newNode:Child, oldNode:Child) {
    if (newNode == oldNode) return domNode;
    var ret = domNode;
    
    function replace(with) {
      ret = with;
      if (domNode.parentNode != null)
        domNode.parentNode.replaceChild(ret, domNode);
    }

    switch [newNode.isWidget, oldNode.isWidget] {
      case [true, true]:

        replace(newNode.asWidget().__replaceWidget(oldNode.asWidget(), domNode));

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
          var elt:Element = cast domNode;
          updateElement(elt, newNode.attributes, oldNode.attributes);

          var newChildren = newNode.children,
              oldChildren = oldNode.children.toArray(),
              newDomChildren = [],
              oldDomChildren = domNode.childNodes;

          var newLength = newChildren.length,
              oldLength = oldChildren.length;

          var oldKeyed = {
            var ret = new haxe.DynamicAccess();
            var newKeys = new haxe.DynamicAccess();

            for (c in newChildren) 
              if (c.key != null && !newKeys[c.key]) 
                newKeys[c.key] = true;

            for (i in 0...oldLength) {
              var old = oldChildren[i];
              var k = old.key;
              if (k != null && newKeys[k] && !ret.exists(k)) 
                ret[k] = i;
            }
            ret;
          }

          var oldIndex = 0;
          var newDomChildren = [
            for (i in 0...newLength) {
              var newChild = newChildren[i];
              var oldChildIndex = 
                switch oldKeyed[newChild.key] {
                  case null: 

                    while (oldIndex < oldLength) {
                      var oldChild = oldChildren[oldIndex];
                      if (oldChild == null || oldKeyed.exists(oldChild.key))
                        oldIndex++; 
                      else break;
                    }
                      

                    if (oldIndex < oldLength)
                      oldIndex++;
                    else
                      oldIndex;
                  case v: 
                    oldKeyed.remove(newChild.key);
                    v;
                }

              switch oldDomChildren[oldChildIndex] {
                case null:
                  createNode(newChild);
                case target:
                  var oldChild = oldChildren[oldChildIndex];
                  oldChildren[oldChildIndex] = null;
                  updateNode(target, newChild, oldChild);
              }

            }
          ];
          
          for (i in 0...newDomChildren.length) {
            var newDom = newDomChildren[i];
            if (newDom != domNode.childNodes[i])
              domNode.insertBefore(newDom, domNode.childNodes[i]);
          }

          for (i in newLength...domNode.childNodes.length)
            domNode.removeChild(domNode.childNodes[newLength]);   

          for (o in oldChildren)
            if (o != null && o.isWidget)
              o.asWidget().__destroyWidget();
        }
      case [false, true]:
        oldNode.asWidget().__destroyWidget();
        replace(createNode(newNode));
      case [true, false]:
        replace(newNode.asWidget().__initWidget());
    }
    return ret;
  }

  static function setField(target:Dynamic, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    if (oldVal != newVal) 
      untyped target[name] = newVal;

  static function setStyle(target:js.html.CSSStyleDeclaration, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    if (oldVal != newVal) 
      if (newVal == null)
        target.removeProperty(name);
      else
        target.setProperty(name, newVal);


  static function setProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'key':
      case 'style':
        updateObject(element.style, newVal, oldVal, setStyle);
      case 'attributes':
        updateObject(element, newVal, oldVal, updateAttribute);
      default:
        if (newVal == null)
          untyped __js__('delete {0}[{1}]', element, name);
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

  static inline function updateObject<Target>(element:Target, newProps:Dict<Any>, oldProps:Dict<Any>, updateProp:Target->String->Any->Any->Void) {
    if (newProps == oldProps) return;
    var keys:Dynamic<Bool> = {};
    
    if (newProps == null) newProps = EMPTY;
    if (oldProps == null) oldProps = EMPTY;

    for(key in newProps.keys()) Reflect.setField(keys, key, true);
    for(key in oldProps.keys()) Reflect.setField(keys, key, true);
    
    for(key in Dict.getKeys(keys)) 
      updateProp(element, key, newProps[key], oldProps[key]);    
  }    

  static function createNode(c:Child):Node 
    return 
      if (c.isWidget) c.asWidget().__initWidget();
      else if (c.isText) document.createTextNode(c.asText());
      else switch c.asNative() {
        case null:
          
          var ret = document.createElement(c.type),
              attributes = c.attributes;

          updateElement(ret, attributes, null);
          
          for (c in c.children) if (c != null)
            ret.appendChild(createNode(c));

          ret;
        case v: v;
      }
}