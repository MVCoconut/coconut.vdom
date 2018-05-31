package coconut.vdom.macros;

#if macro
import coconut.ui.macros.Generator;

class Setup {
  static function all() 
    coconut.ui.macros.HXX.generator = new Generator(
      tink.hxx.Generator.extractTags(macro coconut.vdom.Html)
    );
  
}
#end