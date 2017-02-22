package coconut.vdom;

import tink.state.Observable;

class ViewBase<Original, Presented> extends Renderable {

  @:noCompletion var __lastPresented:Presented;

  public function new(data:Original, extract:Original->Presented, renderer:Presented->vdom.VNode, key) {
    super(Observable.auto(function () {
      var nu = extract(data);
      return 
        if (__lastPresented != null && compare(nu, __lastPresented)) last;
        else renderer(__lastPresented = nu);
    }), key);
  }

  @:noCompletion private function compare(nu:Presented, old:Presented) {
    if (nu == old) return true;

    for (f in Reflect.fields(nu)) {
      var nu = Reflect.field(nu, f),
          old = Reflect.field(old, f);

      if (old != nu) 
        switch [Std.instance(old, ConstObservable), Std.instance(nu, ConstObservable)] {
          case [null, _] | [_, null]: 
            return false;
          case [a, b]: 
            return a.m.value == b.m.value;
        }
    }
    return true;
  }
    
}