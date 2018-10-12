package coconut.vdom;

import js.html.*;

@:build(coconut.vdom.macros.Setup.addTags())
class Html {
  static inline function h(tag:String, attr:Dynamic, ?children:coconut.ui.Children):Child 
    return @:privateAccess Child.element(tag, attr, children);
}