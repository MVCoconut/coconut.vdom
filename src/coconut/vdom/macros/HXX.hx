package coconut.vdom.macros;

#if macro
import coconut.ui.macros.Helpers;
import tink.hxx.*;

class HXX {
  static final generator = new Generator();

  static public function parse(e)
    return Helpers.parse(e, generator, 'coconut.vdom.RenderResult.fragment');
}
#end