import coconut.ui.*;
import js.Browser.*;
import tink.state.State;

@:asserts
class LostNode {
  public function new() {}

  public function movedAway() {
    var container = document.createDivElement(),
        items = new State(['a', 'b']);

    document.body.appendChild(container);

    Renderer.mount(container, '
      <Isolated>
        <ul id="list" class="items main">
          <for ${i in items.value}>
            <li class="item">${i}</li>
          </for>
        </ul>
      </Isolated>
    ');

    // Something other than the renderer moves away the last node it rendered.
    var list = container.firstChild;
    container.appendChild(list.lastChild);

    items.set(['a']);
    var message = try {
      Renderer.updateAll();
      null;
    } catch (e:Dynamic) Std.string(e);

    asserts.assert(message != null);
    asserts.assert(message.indexOf('assert:') == 0);
    asserts.assert(message.indexOf('ul#list.items.main') > -1);
    asserts.assert(message.indexOf('(in div < body < html) is missing') > -1);

    document.body.removeChild(container);
    return asserts.done();
  }

  // A parent with fewer element ancestors than ancestors() lists, as in a subtree that was taken out of the page.
  public function underDetachedParent() {
    var container = document.createDivElement(),
        items = new State(['a', 'b']);

    Renderer.mount(container, '
      <Isolated>
        <ul class="items">
          <for ${i in items.value}>
            <li class="item">${i}</li>
          </for>
        </ul>
      </Isolated>
    ');

    var list = container.firstChild;
    container.appendChild(list.lastChild);

    items.set(['a']);
    var message = try {
      Renderer.updateAll();
      null;
    } catch (e:Dynamic) Std.string(e);

    asserts.assert(message != null);
    asserts.assert(message.indexOf('assert:') == 0);
    asserts.assert(message.indexOf('ul.items (in div) is missing') > -1);

    return asserts.done();
  }
}
