import coconut.ui.*;
import js.Browser.*;
import js.html.*;
import tink.state.State;

@:asserts
class SelectValue {
  public function new() {}

  static function selected(select:SelectElement)
    return [for (i in 0...select.options.length) {
      var option:OptionElement = cast select.options[i];
      if (option.selected) option.value;
    }].join(',');

  public function single() {
    var container = document.createDivElement(),
        value = new State('b'),
        options = new State(['a', 'b', 'c']),
        other = new State(0);

    document.body.appendChild(container);

    Renderer.mount(container, '
      <Isolated>
        <select value=${value.value} data-other=${other.value}>
          <for ${o in options.value}>
            <option value=${o}>${o.toUpperCase()}</option>
          </for>
        </select>
      </Isolated>
    ');

    var select:SelectElement = cast container.firstChild;
    asserts.assert(select.value == 'b');

    value.set('c');
    Renderer.updateAll();
    asserts.assert(select.value == 'c');

    value.set('d');
    options.set(['a', 'b', 'c', 'd']);
    Renderer.updateAll();
    asserts.assert(select.value == 'd');

    select.value = 'a';
    other.set(1);
    Renderer.updateAll();
    asserts.assert(select.value == 'd');

    value.set('x');
    Renderer.updateAll();
    asserts.assert(select.value == 'a');

    document.body.removeChild(container);
    return asserts.done();
  }

  public function multiple() {
    var container = document.createDivElement(),
        value = new State(['a', 'c']);

    document.body.appendChild(container);

    Renderer.mount(container, '
      <Isolated>
        <select multiple value=${value.value}>
          <option value="a" selected>A</option>
          <optgroup label="rest">
            <option value="b" selected>B</option>
            <Options values=${['c', 'd']} />
          </optgroup>
        </select>
      </Isolated>
    ');

    var select:SelectElement = cast container.firstChild;
    asserts.assert(selected(select) == 'a,c');

    value.set(['b', 'd']);
    Renderer.updateAll();
    asserts.assert(selected(select) == 'b,d');

    value.set([]);
    Renderer.updateAll();
    asserts.assert(selected(select) == '');

    document.body.removeChild(container);
    return asserts.done();
  }

  public function text() {
    var container = document.createDivElement();
    document.body.appendChild(container);

    Renderer.mount(container, '
      <select value="d">
        <option disabled>a</option>
        <Options values=${['b', 'c', 'd']} />
      </select>
    ');

    var select:SelectElement = cast container.firstChild;
    asserts.assert(select.value == 'd');

    document.body.removeChild(container);
    return asserts.done();
  }
}

class Options extends View {
  @:attribute var values:tink.pure.List<String>;
  function render() '
    <>
      <for ${v in values}>
        <option>${v}</option>
      </for>
    </>
  ';
}
