package coconut.vdom;

import js.html.*;

@:build(coconut.vdom.macros.Setup.addTags())
class Html {
  static inline function h(tag:String, attr:Dynamic, ?children:coconut.ui.Children):Child 
    return @:privateAccess Child.element(tag, attr, cast children);

  static public inline function raw(attr):Child
    return HtmlFragment.fromHxx(attr);
}

private class HtmlFragment extends coconut.ui.View {
  @:attribute var content:String;
  @:attribute var tag:String = 'span'; 
  @:attribute var className:tink.domspec.ClassName = null;
  
  var root:Element;
  var lastTag:String;
  var lastContent:String;

  function render()
    return @:privateAccess Html.h(tag, { className: className, ref: function (e) this.root = e });

  function viewDidMount() {
    lastContent = tag;
    root.innerHTML = lastContent = content;
  }

  function viewDidUpdate() 
    if (lastContent != content || lastTag != tag) {
      root.innerHTML = content;
      lastContent = content;
      lastTag = tag;
    }
    
}