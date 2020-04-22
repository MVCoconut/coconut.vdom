package coconut.vdom;

class Renderer {
  static public function hxx(e)
    return coconut.vdom.macros.HXX.parse(e);

  static function mount(target, markup)
    return coconut.ui.macros.Helpers.mount(macro coconut.vdom.Renderer.mountInto, target, markup, hxx);
}