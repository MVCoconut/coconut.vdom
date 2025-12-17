package ;

import js.html.Element;
import js.Browser.*;
import coconut.Ui.*;
import coconut.ui.*;
import coconut.vdom.*;
import tink.unit.*;
import tink.testrunner.*;

@:asserts
class RunTests {

  static function main() {
    Runner.run(TestBatch.make([
      new RunTests(),
      new Issue32(),
      new Issue37(),
      new Issue44(),
    ])).handle(Runner.exit);
  }

  public function new() {}
  public function basic() {
    var div = document.createDivElement();
    div.id = 'app';
    document.body.appendChild(div);
    Renderer.mount(div, hxx('<Bar/>'));
    asserts.assert(document.getElementById('foo-42') != null);
    document.body.removeChild(div);
    return asserts.done();
  }

}

class Foo extends View {
  @:attribute var foo:Int;
  function render() '<div id="foo-$foo"/>';
}

class Bar extends View {
  function render() '<Foo foo={42} />';
}