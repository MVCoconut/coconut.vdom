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
    coconut.ui.macros.HXX.generator = new Generator(function ()
      return switch getType('coconut.vdom.Html') {
        case TInst(_.get().statics.get() => statics, _):
          [for (f in statics) if (f.isPublic) switch f.kind {
            case FMethod(MethInline): 
              new Named(
                f.name, 
                tink.hxx.Generator.tagDeclaration('coconut.vdom.Html.${f.name}', f.pos, f.type)
              );
            default: continue;
          }];
        default: throw 'assert';
      }     
    );
  
}
#end