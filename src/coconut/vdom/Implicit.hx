package coconut.vdom;

class Implicit extends coconut.diffing.Implicit<js.html.Node, RenderResult> {

  static final TYPE = coconut.diffing.Implicit.type();

  static public function fromHxx(attr):RenderResult
    return coconut.diffing.VNode.VNodeData.VWidget(TYPE, null, null, attr);

}