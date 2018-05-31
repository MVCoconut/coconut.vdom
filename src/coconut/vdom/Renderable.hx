package coconut.vdom;

#if !macro
import js.html.Element;
import js.html.Node;
import js.Browser.*;
import tink.CoreApi;
import tink.state.Observable;

class Renderable extends Widget {
  static var dummy(get, null):Element;
    static function get_dummy() {
      if (dummy == null) {
        dummy = document.createDivElement();
        dummy.style.display = 'none !important';
        document.head.appendChild(dummy);
      }
      return dummy;
    }

  @:noCompletion var __rendered:Observable<coconut.ui.RenderResult>;
  @:noCompletion var __dom:Element;
  @:noCompletion var __binding:CallbackLink;
  @:noCompletion var __lastRender:coconut.ui.RenderResult;
  
  static var keygen:Int = 0;
  
  public function new(rendered) {
    this.__rendered = rendered;
    super('coconut-widget:' + (keygen++));
  }
        
  @:noCompletion override public function __initWidget() {
    __lastRender = __rendered.value;
    this.__dom = @:privateAccess cast VDom.createNode(__lastRender);
    __setupBinding();
    
    return this.__dom;
  }

  public function mount(into:Element) {
    if (this.__dom != null) throw 'assert';//TODO: should probably just move it around in the DOM

    @:privateAccess VDom.mount(this, into);
  }
  
  @:noCompletion function __setupBinding()
    this.__binding = this.__rendered.bind(function (next) {
      if (next != __lastRender) __apply(next);
    });
  
  @:noCompletion function __apply(next) {
    beforePatching(this.__dom);
    this.__dom = cast @:privateAccess VDom.updateNode(__dom, next, __lastRender);
    __lastRender = next;
    afterPatching(this.__dom);
  }
    
  @:deprecated('use mount instead')
  public function toElement()
    return switch __dom {
      case null: __initWidget();
      case v: v;
    } 

  @:noCompletion function beforePatching(element:Element) {}
  @:noCompletion function afterPatching(element:Element) {}
  @:noCompletion function beforeDestroy(element:Element) {}
  @:noCompletion function afterDestroy(element:Element) {}
  
  macro function get(_, e);
  macro function hxx(e);

  @:noCompletion override public function __destroyWidget():Void {
    beforeDestroy(this.__dom);
    this.__binding.dissolve();
    super.__destroyWidget();
    
    function _destroy(v:Child) 
      for (c in v.children) {
        if (c.isWidget) c.asWidget().__destroyWidget();
        else _destroy(c);
      }

    _destroy(__lastRender);
    afterDestroy(this.__dom);
    this.__dom = null;
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
