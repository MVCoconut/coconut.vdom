package coconut.vdom;

import coconut.diffing.*;
import js.html.*;

@:enum abstract NodeKind(String) {
  var Text = 'text';
  var Element = 'element';
  var Widget = 'widget';
}

typedef ChildNode = VNode<Node, NodeKind>;

@:forward
abstract Child(ChildNode) from ChildNode to ChildNode {
  
  @:from static inline function ofString(s:String):Child
    return new VText(s);

}

class VText implements ChildNode {

  public var kind(default, never):NodeKind = Text;
  public var key(default, never):Null<String> = null;//Perhaps the text could serve as key?
  
  var text:String;

  public function new(text)
    this.text = text;

  public function create()
    return js.Browser.document.createTextNode(text);

  public function patch(target:Node, old:Child) 
    return create();//TODO: if target is a text node, just replace the text (assuming a benchmark confirms it's worth it)

  public function teardown(target:Node):Void {}
}

class DomDriver implements Driver<Node> {
  static public var inst(default, never):DomDriver = new DomDriver();

  function new() {}
  public function total(target:Node):Int
    return target.childNodes.length;

  public function get(target:Node, index:Int):Node
    return target.childNodes[index];

  public function insertAt(target:Node, child:Node, index:Int):Void
    target.insertBefore(child, target.childNodes[index]);

  public function removeAt(target:Node, index:Int):Void
    target.removeChild(target.childNodes[index]);

  public function all(target:Node):Array<Node>
    return untyped Array.prototype.slice.call(target.childNodes);

}

class VElement implements ChildNode {
  public var kind(default, never):NodeKind = Element;
  public var key(default, never):Null<String>;

  var tag:String;
  var attributes:Dict<Any>;
  var children:Children;

  public function new(tag, attributes, ?children) {
    this.tag = tag;
    this.attributes = attributes;
    this.children = children;
  }

  public function create() {
    var ret = js.Browser.document.createElement(tag);
    for (a in attributes.keys())
      setProp(ret, a, attributes[a]);
    for (c in children)
      ret.appendChild(c.create());
    return ret;
  }

  public function patch(target:Node, old:Child) 
    return 
      switch old.kind {
        case Element:
          
          var old:VElement = cast old;
          
          if (old.tag != tag) create();
          else {
            var e:Element = cast target;
            Differ.updateObject(e, attributes, old.attributes, updateProp);
            Differ.updateChildren(DomDriver.inst, e, children.toArray(), old.children.toArray());//TODO: avoid the copying
            e;
          }

        default:
          create();
      }

  public function teardown(target:Node):Void 
    for (i in 0...children.length)
      children[i].teardown(target.childNodes[i]);

  static function setProp(element:Element, name:String, newVal:Dynamic, ?oldVal:Dynamic)
    switch name {
      case 'key':
      case 'style':
        Differ.updateObject(element.style, newVal, oldVal, Differ.setField);
      case 'attributes':
        Differ.updateObject(element, newVal, oldVal, updateAttribute);
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
}

class VWidget<W:Widget, Data> implements ChildNode {
  public var kind(default, never):NodeKind = Widget;
  public var key(default, never):Null<String>;

  var data:Data;
  var cls:Class<W>;
  var construct:Data->W;
  var update:Data->W->Void;

  var instances:Map<Node, W> = new Map();//TODO: actually the instances should be saved into the DOM so something similar to `ReactDOM.findNode` is possible

  public function new(data, cls, construct, update) {
    this.data = data;
    this.cls = cls;
    this.construct = construct;
    this.update = update;
  }

  public function create() {
    var widget = instantiate();
    var dom = widget.__initWidget();
    instances[dom] = widget;
    return dom;
  }

  public function instantiate()
    return construct(data);

  public function patch(target:Node, old:Child) 
    return switch old.kind {
      case Widget:
        var old:VWidget<Dynamic, Dynamic> = cast old;
        if (old.cls == cls) {
          update(data, old.instances[target]);
          target;
        }
        else 
          create();
      default: create();  
    }

  public function teardown(target:Node):Void {
    instances[target].__destroyWidget(target);
    instances.remove(target);
  }
}