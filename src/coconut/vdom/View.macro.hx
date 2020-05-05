package coconut.vdom;

class View {
  static function hxx(_, e)
    return coconut.vdom.macros.HXX.parse(e);

  static function autoBuild()
    return
      coconut.diffing.macros.ViewBuilder.autoBuild(macro : coconut.vdom.RenderResult);
}