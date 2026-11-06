import coconut.ui.*;
import js.Browser.*;
import coconut.vdom.Renderer.*;
import tink.state.State;

@:asserts
class Translate {
  public function new() {}

  public function attributeNotProperty() {
    var root = document.createElement("div"),
        translate = new State<Null<tink.domspec.Attributes.Translate>>(No),
        el:js.html.Element = null;

    mount(root, hxx('<Isolated><span ref={v -> el = v} translate=${translate.value}>Name</span></Isolated>'));

    asserts.assert(el.getAttribute('translate') == 'no');
    asserts.assert((untyped el.translate) == false); // what translators read

    translate.set(Yes);
    updateAll();
    asserts.assert(el.getAttribute('translate') == 'yes');
    asserts.assert((untyped el.translate) == true);

    translate.set(null);
    updateAll();
    asserts.assert(!el.hasAttribute('translate'));

    return asserts.done();
  }
}
