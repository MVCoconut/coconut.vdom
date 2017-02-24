package coconut.vdom;

import tink.state.Observable;

class ViewBase<Original, Presented> extends Renderable {
  @:noCompletion var __lastPresented:Presented;
  
  public function new(data:Original, extract:Original->Presented, compare:Presented->Presented->Bool, renderer:Presented->vdom.VNode, key:vdom.Attr.Key) {
    super(Observable.auto(function () {
      __beforeExtract();
      var nu = extract(data);
      return 
        if (__lastPresented != null && compare(nu, __lastPresented)) __lastRender;
        else renderer(__lastPresented = nu);
    }), key);
  }

  @:noCompletion private function __beforeExtract() {}
  @:noCompletion private function __resetCache<A>(?v:A) 
    this.__lastPresented = null;

  @:noCompletion private function __copyCache(old:ViewBase<Original, Presented>) 
    this.__lastPresented = old.__lastPresented;
    
}