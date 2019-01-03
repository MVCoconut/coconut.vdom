package ;

import js.html.Element;
import js.Browser.*;
import coconut.Ui;
import coconut.ui.*;
import coconut.vdom.*;

class RunTests {

  static function main() {
    
    travix.Logger.exit(
      try {
        travix.Logger.println('... works');
        0;
      }
      catch (e:Dynamic) {
        travix.Logger.println(Std.string(e));
        500;
      }
    ); // make sure we exit properly, which is necessary on some targets, e.g. flash & (phantom)js
  }
  
}

class Foo extends View {
  @:attribute var foo:Int;
  function render() '<div />';
}

class Bar extends View {
  function render() '<Foo foo={42} />';
}