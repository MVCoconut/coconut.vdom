package coconut.vdom;

import coconut.diffing.VNode;
import coconut.diffing.*;
import js.html.*;

@:pure
abstract Child(VNode<Node>) to VNode<Node> from VNode<Node> {
  
  inline function new(n) this = n;

  static function element(tag, attr:Dynamic, ?children) 
    return VNative(tag, attr.ref, attr.key, attr, children);
  
  @:from static function ofText(s:String):Child
    return element('', { text: s });

  @:from static function ofInt(i:Int):Child
    return Std.string(i);

  @:from static function ofNode(n:Node):Child
    return VNativeInst(n);

  @:from static function ofView(v:coconut.ui.View):Child
    return VWidgetInst(v);

  static function widget<A>(name, key, ref:Dynamic, attr:A, type:WidgetType<A, Node>)
    return new Child(VWidget(name, ref, key, attr, type));

  @:deprecated('Use coconut.ui.Renderer.mount instead')
  public function renderInto(target:Element) 
    coconut.ui.Renderer.mount(target, this);

}