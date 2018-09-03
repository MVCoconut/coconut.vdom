package coconut.vdom;

#if !macro
import js.html.Node;
import js.Browser.*;
import tink.CoreApi;
import tink.state.Observable;

class Widget {

  @:noCompletion var __rendered:Observable<coconut.ui.RenderResult>;
  @:noCompletion var __dom:Node;
  @:noCompletion var __binding:CallbackLink;
  @:noCompletion var __lastRender:coconut.ui.RenderResult;
  
  static var keygen:Int = 0;
  
  public function new(rendered) 
    this.__rendered = rendered;
        
  @:noCompletion public function __initWidget() {
    __lastRender = __rendered.value;
    
    this.__dom = __lastRender.create();
    __setupBinding();
    
    return __dom;
  }
  
  @:noCompletion function __setupBinding()
    this.__binding = this.__rendered.bind(function (next) {
      if (next != __lastRender) __apply(next);
    });
  
  @:noCompletion function __apply(next:Child) {
    this.__dom = next.patch(__dom, __lastRender);
    __lastRender = next;
    __afterPatching();
  }
  
  @:noCompletion function __afterPatching() {}
  @:noCompletion function __beforeDestroy() {}

  macro function hxx(e);

  @:noCompletion public function __destroyWidget(target:Node):Void {
    __lastRender.teardown(target);
    this.__binding.dissolve();
  }  
}
#else
class Widget {
 
  macro function hxx(_, e) 
    return 
      #if coconut_ui
        coconut.ui.macros.HXX.parse(e);
      #else
        vdom.VDom.hxx(e);
      #end
}
#end
