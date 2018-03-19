package coconut.vdom;

import js.html.*;
import js.Browser.*;

class HtmlFragment extends Widget {
  var content:String;
  var tag:String;
  var element:Element;
  var className:ClassName;
  public function new(content, ?tag:String = 'span', ?key, ?className) {
    super(key);
    this.content = content;
    this.tag = tag;
    this.className = className;
  }

  override public function init() {
    if (this.element == null) {
      this.element = document.createElement(tag);
      this.element.innerHTML = this.content;
      if (this.className != null) this.element.className = this.className;
    }
    return this.element;
  }
    
  override function update(old:Widget, e:js.html.Node) 
    return switch Std.instance(old, HtmlFragment) {
      case null: this.init();
      case v if (v.tag == this.tag): 
        
        this.element = cast e;

        if (this.className != v.className)
          this.element.className = this.className;

        if (this.content != v.content)
          this.element.innerHTML = this.content;

        e;
      default: this.init();
    }
    
  static public function create(attr:RawAttr)
    return 
      if (attr.content == "" && attr.force != true) null;
      else new HtmlFragment(attr.content, attr.tag, attr.key, attr.className);  

}

typedef RawAttr = {
  var content:String;
  @:optional var key:String;
  @:optional var force:Bool;
  @:optional var tag:String;
  @:optional var className:ClassName;
}