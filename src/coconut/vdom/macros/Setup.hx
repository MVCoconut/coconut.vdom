package coconut.vdom.macros;

#if macro
import haxe.macro.Context.*;
import haxe.macro.Expr;

using haxe.macro.Tools;
using tink.MacroApi;

class Setup {
  static function forwardCalls() {
    var ret = getBuildFields();
    for (f in getType('vdom.VDom').getClass().statics.get())
      switch f {
        case { isPublic: true, kind: FMethod(MethInline) }:
          switch f.type.follow() {
            case TFun(args, _):
              var name = f.name;
              ret.push({
                name: name,
                pos: f.pos,
                access: [AInline, APrivate],
                kind: FFun({
                  args: [for (a in args) { name: a.name, opt: a.opt, type: null }],
                  ret: null,
                  expr: macro return vdom.VDom.$name($a{args.map(function (a) return macro $i{a.name})})
                })
              });
            default: throw 'assert';
          }
        default:
      }
    return ret;
  }
  static var defined = false;
  static function all() {
    #if coconut_ui
    if (!defined) {
      
      defined = true;
      coconut.ui.macros.HXX.options = vdom.VDom.options;      

      if ('coconut.ui.Renderable'.definedType() == None)
        defineType({
          pack: ['coconut', 'ui'],
          name: 'Renderable',
          pos: (macro null).pos,
          fields: [],
          kind: TDAlias(macro : coconut.vdom.Renderable),
        });

      if ('coconut.ui.RenderResult'.definedType() == None)
        defineType({
          pack: ['coconut', 'ui'],
          name: 'RenderResult',
          pos: (macro null).pos,
          fields: [],
          kind: TDAlias(macro : vdom.VNode),
        });
    }
    #end
  }
}
#end