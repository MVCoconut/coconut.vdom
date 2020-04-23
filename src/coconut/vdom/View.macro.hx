package coconut.vdom;

class View {
  static function hxx(_, e)
    return coconut.vdom.macros.HXX.parse(e);

  static function init()
    return
      coconut.diffing.macros.ViewBuilder.init(macro : coconut.vdom.RenderResult);
}