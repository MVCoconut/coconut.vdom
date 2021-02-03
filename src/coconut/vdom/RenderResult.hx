package coconut.vdom;

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
    return VNode.embed(n);

  static public function fragment(attr:{}, children:Children):RenderResult
    return VNode.many(children);

  // @:from static function ofView(v:coconut.vdom.View):RenderResult
  //   return VWidgetInst(v);
}