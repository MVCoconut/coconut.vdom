package coconut.vdom.macros;

#if macro
import coconut.ui.macros.Generator;
import haxe.macro.Context.*;
import haxe.macro.Expr;

using haxe.macro.Tools;
using tink.MacroApi;
using tink.CoreApi;

class Setup {
  static function all() 
    coconut.ui.macros.HXX.generator = new Generator(
      tink.hxx.Generator.extractTags(macro coconut.vdom.Html)
    );
  
}
#end