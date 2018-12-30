package coconut.ui;

import js.html.Node;
import coconut.vdom.Child;

class Renderer extends coconut.diffing.Widget<Node> {

  static public function mount(target:Node, vdom:Child)
    vdom.renderInto(target);

  // static public function getNative(view:View):Null<Node>
  //   return switch @:privateAccess view._coco_lastRender {
  //     case null:
  //     case r: r.each
  //   }
}