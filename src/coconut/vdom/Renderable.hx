package coconut.vdom;

#if !macro
import js.html.Element;
import tink.CoreApi;
import tink.state.Observable;

class Renderable extends Widget {
  
  @:noCompletion var __rendered:Observable<coconut.ui.RenderResult>;
  @:noCompletion var __dom:Element;
  @:noCompletion var __binding:CallbackLink;
  @:noCompletion var __lastRender:coconut.ui.RenderResult;
  
  static var keygen:Int = 0;
  
  public function new(rendered) {
    this.__rendered = rendered;
    super('coconut-widget:' + (keygen++));
  }
        
  @:noCompletion override public function init() {
    __lastRender = __rendered.value;
    this.beforeInit();
    this.__dom = @:privateAccess cast VDom.createNode(__lastRender);
    this.afterInit(__dom);
    __setupBinding();
    
    return this.__dom;
  }
  
  @:noCompletion function __setupBinding()
    this.__binding = this.__rendered.bind(function (next) {
      if (next != __lastRender) __apply(next);
    });
  
  @:noCompletion function __apply(next) {
    beforePatching(this.__dom);
    this.__dom = cast @:privateAccess VDom.updateNode(__dom, next);
    __lastRender = next;
    afterPatching(this.__dom);
  }
    
  public function toElement()
    return switch __dom {
      case null: init();
      case v: v;
    } 

  @:noCompletion function beforeInit() {}
  @:noCompletion function afterInit(element:Element) {}
  @:noCompletion function beforePatching(element:Element) {}
  @:noCompletion function afterPatching(element:Element) {}
  @:noCompletion function beforeDestroy(element:Element) {}
  @:noCompletion function afterDestroy(element:Element) {}
  
  macro function get(_, e);
  macro function hxx(e);

  @:noCompletion override public function destroy():Void {
    beforeDestroy(this.__dom);
    this.__binding.dissolve();
    super.destroy();
    
    function _destroy(v:Child) 
      for (c in v.children) {
        if (c.isWidget) (cast c:Widget).destroy();
        else _destroy(c);
      }

    _destroy(__lastRender);
    afterDestroy(this.__dom);
  }  
}
#else
class Renderable {
 
  macro function get(_, e) 
    return coconut.vdom.macros.Select.typed(e);
  macro function hxx(_, e) 
    return 
      #if coconut_ui
        coconut.ui.macros.HXX.parse(e);
      #else
        vdom.VDom.hxx(e);
      #end
}
#end
