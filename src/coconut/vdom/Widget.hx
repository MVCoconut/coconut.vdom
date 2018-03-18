package coconut.vdom;

import js.html.Node;

class Widget {
  @:noCompletion public var t(default, never):String;
  @:noCompletion public var k(default, never):String;
  @:noCompletion public var a(default, never):Dict<Any> = EMPTY_ATTR;
  @:noCompletion public var c(default, never):Children = EMPTY_CHILDREN;

  function new(?key:String, ?pos:haxe.PosInfos) {
    untyped this.k = key;
    untyped this.t = pos.className;
  }

  public function init():Node
    return throw new js.Error('$t does not overwrite init method');

  public function update(w:Widget, e:Node):Node
    return init();

  public function destroy(e:Node):Void {}

  @:native('a') static var EMPTY_ATTR:Dict<Any> = { isWidget: true };
  @:native('e') static var EMPTY_CHILDREN:Children = [];
}