package coconut.vdom.macros;

#if macro
import coconut.ui.macros.Helpers;
import tink.hxx.*;
import haxe.macro.Expr;

using tink.MacroApi;

class HXX {
  static final generator = new Generator(Tag.extractAllFrom(macro coconut.vdom.Html));

  static public function parse(e:Expr)
    return Helpers.parse(e, generator, 'coconut.diffing.VNode.fragment');
}
#end