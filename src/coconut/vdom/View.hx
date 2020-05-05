package coconut.vdom;

@:build(coconut.ui.macros.ViewBuilder.build((_:coconut.vdom.RenderResult)))
@:autoBuild(coconut.vdom.View.autoBuild())
class View extends coconut.diffing.Widget<js.html.Node> {
  macro function hxx(e);
}