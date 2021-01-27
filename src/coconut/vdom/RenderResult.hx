package coconut.vdom;

import coconut.diffing.VNode;
import coconut.diffing.*;
import js.html.*;

@:pure
abstract RenderResult(VNode<Node>) to VNode<Node> from VNode<Node> {

  inline function new(n) this = n;

  @:from static inline function ofText(s:String):RenderResult
    return
      if (s == null) null;
      else coconut.vdom.Html.text(s);

  @:from static function ofInt(i:Int):RenderResult
    return ofText('$i');

  @:from static function ofNode(n:Node):RenderResult
    return new VNativeInst(n);

  // @:from static function ofView(v:coconut.vdom.View):RenderResult
  //   return VWidgetInst(v);
}