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
                @:optional var attributes(default, never):coconut.diffing.Dict<xdom.html.Dataset.DatasetValue>; 
                @:optional var key(default, never):coconut.diffing.Key;
              },
            ].intersect().sure(),
            opt: false
          }];
          var callArgs = [macro $v{name}, macro attr];
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
            expr: macro return h($a{callArgs}),
            ret: macro : coconut.vdom.Child
          }
        })
      });
    }
    return ret;
  }

  static function all() {

    HXX.generator = new Generator(
      tink.hxx.Generator.extractTags(macro coconut.vdom.Html)
    );

    coconut.ui.macros.ViewBuilder.afterBuild.whenever(function (ctx) {
      var attributes = TAnonymous(ctx.attributes.concat(
        (macro class {
          @:optional var key(default, never):coconut.diffing.Key;
        }).fields      
      ));

      ctx.target.addMembers(macro class {
        static public function fromHxx(attributes:$attributes) {
          return new coconut.vdom.Child.VWidget(
            attributes.key,
            attributes,
            $i{ctx.target.target.name},
            $i{ctx.target.target.name}.new,
            function (data, v) v.__initAttributes(data) //TODO: unhardcode method name ... should probably come from ctx
          );
        }
      });
    });
  }
  
}
#end