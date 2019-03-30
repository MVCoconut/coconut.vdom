package coconut.vdom;

import coconut.diffing.VNode;
import coconut.diffing.*;
import js.html.*;

@:pure
abstract Child(VNode<Node>) to VNode<Node> from VNode<Node> {
  
  inline function new(n) this = n;
  
  @:from static inline function ofText(s:String):Child
    return Html.text(s);

  @:from static function ofInt(i:Int):Child
    return ofText(Std.string(i));

  @:from static function ofNode(n:Node):Child
    return VNativeInst(n);

  @:from static function ofView(v:coconut.ui.View):Child
    return VWidgetInst(v);

  static function widget<A>(type:WidgetType<A, Node>, key, ref:Dynamic, attr:A)
    return new Child(VWidget(type, ref, key, attr));

}