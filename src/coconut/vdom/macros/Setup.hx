package coconut.vdom.macros;

#if macro
import coconut.ui.macros.Generator;
import haxe.macro.Expr;

class Setup {
  
  static var registered = false;

  static function all() {

    coconut.ui.macros.HXX.generator = new Generator(
      tink.hxx.Generator.extractTags(macro coconut.vdom.Html)
    );

    coconut.ui.macros.ViewBuilder.afterBuild.whenever(function (ctx) {
      var attributes = TAnonymous(ctx.attributes.concat(
        (macro class {
          @:optional var key(default, never):coconut.vdom.Attr.Key;
        }).fields      
      ));

      ctx.target.addMembers(macro class {
        static public function fromHxx(attributes:$attributes) {
          return new coconut.vdom.Child.VWidget(
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