package coconut.vdom;

import js.html.*;

@:build(coconut.vdom.macros.Setup.addTags())
class Html {
  static inline function h(tag:String, attr:Dynamic, ?children:Children):Child return new Child.VElement(tag, attr, children);
  // static public inline function raw(attr: HtmlFragment.RawAttr):Child return HtmlFragment.create(attr);
}