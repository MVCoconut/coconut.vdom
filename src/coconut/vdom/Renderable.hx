package coconut.vdom;

#if !macro
import js.html.Element;
import tink.CoreApi;
import tink.state.Observable;
import vdom.Attr.Key;
import vdom.VDom.*;
import vdom.*;

@:build(coconut.vdom.macros.Setup.forwardCalls())
class Renderable extends Widget {
  
  @:noCompletion var rendered:Observable<VNode>;
  @:noCompletion var element:Element;
  @:noCompletion var binding:CallbackLink;
  @:noCompletion var last:VNode;
  
  static var keygen = 0;
  @:noCompletion @:keep var key:Key;
  
  public function new(rendered, ?key:Key) {
    this.rendered = rendered;
    if (key == null)
      key = rendered;
      
    this.key = key;
  }
        
  @:noCompletion override public function init():Element {
    last = rendered.value;
    this.element = create(last);
    
    setupBinding();
    
    return this.element;
  }
  
  @:noCompletion function setupBinding()
    this.binding = this.rendered.bind(function (next) {
      if (next != last) apply(next);
    });
  
  @:noCompletion function apply(next) {
    var changes = diff(last, next);
    beforeUpdate();
    this.element = patch(element, changes);
    last = next;
    afterUpdate();
  }
    
  public function toElement() 
    return switch element {
      case null: init();
      case v: v;
    } 
   
  @:noCompletion function beforeUpdate() {}
  @:noCompletion function afterUpdate() {}
  
  @:noCompletion override public function update(x:{}, y):Element {
    switch Std.instance(x, Renderable) {
      case null:
      case v: reuseRender(v);
    }
    return toElement();
  }

  @:noCompletion private function reuseRender(that:Renderable) {
    this.element = that.element;
    this.last = that.last;
    apply(rendered);
    setupBinding();
    that.destroy();
  }
  
  macro function get(_, e);
  macro function hxx(e);

  override public function destroy():Void {
    this.binding.dissolve();
    super.destroy();
  }  
}
#else
class Renderable {
 
  macro function get(_, e) 
    return coconut.vdom.macros.Select.typed(e);
  macro function hxx(_, e)
    return vdom.VDom.hxx(e);
}
#end
