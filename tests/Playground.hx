import coconut.ui.*;
import coconut.Ui.hxx;
import js.Browser.*;

class Playground {

  static function main() {
    Renderer.mount(
      cast document.body.appendChild(document.createDivElement()),
      hxx('<HelloView />')
    );
  }
}

class HelloSubView extends View {
  function render() '<div />';
}

class HelloView extends View
{
  @:ref var sub:HelloSubView;

  function render() '<HelloSubView ref=${sub} />';

  override function viewDidMount()
    console.log("HelloView afterMounting", sub.current); //it's always null

  override function viewDidUpdate()
    console.log("HelloView afterPatching", sub.current); //it's always null
}
