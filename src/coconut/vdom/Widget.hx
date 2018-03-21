package coconut.vdom;

import js.html.Node;

class Widget {
  
  @:noCompletion public var t(default, never):String = ':widget';
  @:noCompletion public var k(default, never):String;
  @:noCompletion public var a(default, never):Dict<Any>;
  @:noCompletion public var c(default, never):Children;

  function new(?key:String) {
    untyped this.k = key;
  }

  @:noCompletion public function __initWidget():Node
    return throw new js.Error('$t does not overwrite init method');

  @:noCompletion public function __replaceWidget(w:Widget, e:Node):Node
    return __initWidget();

  @:noCompletion public function __destroyWidget():Void {}

}