package coconut.vdom.macros;

#if macro
import coconut.ui.macros.*;
import tink.domspec.Macro.tags;
import haxe.macro.Context;
import haxe.macro.Expr;

using tink.MacroApi;

class Setup {
  
  static var registered = false;

  static function addTags() {
    var ret = Context.getBuildFields();
    for (name in tags.keys()) {
      var tag = tags[name];
      ret.push({
        name: name,
        pos: tag.pos,
        access: [AStatic, APublic, AInline],
        kind: FFun({
          var et = tag.dom.toComplex();
          var args = [{
            name: 'attr',
            type: [
              tag.attr, 
              macro : tink.domspec.Events<$et>,
              macro : { 
                @:hxxCustomAttributes(~/^(data-|aria-)/)
                @:optional var attributes(default, never):Dynamic<xdom.html.Dataset.DatasetValue>; 
                @:optional var key(default, never):coconut.diffing.Key;
                @:optional var ref(default, never):$et->Void;
              },
            ].intersect().sure(),
            opt: false
          }];
          var callArgs = [macro $v{name}, macro attr];
          if (tag.kind != VOID) {
            args.push({
              name: 'children',
              type: macro : coconut.ui.Children,
              opt: true
            });
            callArgs.push(macro children);
          }
          {
            args: args,
            expr: macro return h($a{callArgs}),
            ret: macro : coconut.vdom.Child
          }
        })
      });
    }
    return ret;
  }

  static function all() 
    HXX.generator = new Generator(
      tink.hxx.Generator.extractTags(macro coconut.vdom.Html)
    );
  
}
#end