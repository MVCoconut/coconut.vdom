package coconut.vdom.macros;

#if macro
import coconut.ui.macros.*;
import tink.domspec.Macro.tags;
import haxe.macro.Context;
import haxe.macro.Expr;
import tink.hxx.*;

using tink.MacroApi;

class Setup {

  static function addTags() {
    var ret = Context.getBuildFields();
    for (name in tags.keys()) {
      var tag = tags[name];
      var fqn = switch tag.domCt {
        case macro : js.html.svg.$_: 'svg:$name';
        default: name;
      }

      ret.push({
        name: name.toUpperCase(),
        pos: tag.pos,
        access: [AStatic],
        kind: FProp('default', 'never', null, macro nodeType($v{fqn})),
      });
      ret.push({
        name: name,
        pos: tag.pos,
        access: [AStatic, APublic, AInline],
        kind: FFun({
          var et = tag.domCt;
          var args = [
            {
              name: 'hxxMeta',
              type: macro : HxxMeta<$et>,
              opt: false
            },
            {
              name: 'attr',
              type: [
                tag.attr,
                macro : tink.domspec.Events<$et>,
                macro : {
                  @:hxxCustomAttributes(~/^(data-|aria-)/)
                  @:optional var attributes(default, never):Dynamic<xdom.html.Dataset.DatasetValue>;
                },
              ].intersect().sure(),
              opt: false
            }
          ];
          var callArgs = [macro $i{name.toUpperCase()}, macro cast hxxMeta.ref, macro hxxMeta.key, macro attr];
          if (tag.kind != VOID) {
            args.push({
              name: 'children',
              type: macro : coconut.vdom.Children,
              opt: true
            });
            callArgs.push(macro children);
          }
          {
            args: args,
            expr: macro return VNode.native($a{callArgs}),
            ret: macro : coconut.vdom.RenderResult
          }
        })
      });

    }
    return ret;
  }
}
#end