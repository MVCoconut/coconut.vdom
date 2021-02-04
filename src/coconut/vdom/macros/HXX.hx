package coconut.vdom.macros;

#if macro
import coconut.ui.macros.Helpers;
import tink.hxx.*;

class HXX {
  static final generator = new Generator(Tag.extractAllFrom(macro coconut.vdom.Html));

  static public function parse(e)
    return Helpers.parse(e, generator, 'coconut.vdom.RenderResult.fragment');
}
#end