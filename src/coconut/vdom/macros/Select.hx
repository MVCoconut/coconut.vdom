package coconut.vdom.macros;

import haxe.macro.Expr;
using tink.MacroApi;

class Select {
  static var tags = [
    'a' => macro : js.html.AnchorElement,
    'input' => macro : js.html.InputElement,
    'iframe' => macro : js.html.IFrameElement,    
    'img' => macro : js.html.ImageElement,    
    'button' => macro : js.html.ButtonElement,    
  ];    
  static public function typed(e:Expr) {
    var type = 
      switch tink.csss.Parser.parse(e.getString().sure(), e.pos).sure() {
        case [tags[Std.string(_[_.length - 1].tag)] => v] if (v != null): v;
        default: macro : js.html.Element;
      }
    return macro (cast this.element.querySelector($e) : $type);      
  }
}