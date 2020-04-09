package coconut.vdom;

#if !macro
@:build(coconut.ui.macros.ViewBase.build())
class View extends coconut.diffing.Widget<js.html.Node> {
  macro function hxx(e);
}
#else
class View {
  static function hxx(_, e)
    return coconut.ui.macros.HXX.parse(e, 'coconut.diffing.VNode.fragment');
}
#end