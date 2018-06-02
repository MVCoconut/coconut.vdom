package coconut.vdom;

import js.html.*;

using tink.CoreApi;
using StringTools;

abstract Ext(String) from String to String {
  
  @:from static inline function ofInt(i:Int):Ext
    return cast i;
  
  @:from static inline function ofFloat(f:Float):Ext
    return cast f;
  
  @:from static inline function ofBool(b:Bool):Ext
    return 
      if (b) '';
      else js.Lib.undefined;
}

abstract Key(Dynamic) from String from Int from Float from Bool {
  static var keygen = 0;

  @:from static function ofObj<T:{}>(v:T):Key {
    if (v == null) return null;
    var o: { __vdomKey__:Key } = cast v;
    if (o.__vdomKey__ == null) o.__vdomKey__ = keygen++;
    return o.__vdomKey__;
  }

  @:from static function ofAny<T>(v:T):Key 
    return switch Type.typeof(v) {
      case TInt, TFloat, TBool, TClass(String): cast v;
      case TClass(Array): (cast v : Array<Dynamic>).join(':');
      default: ofObj(cast v);
    }
}

typedef Attr = AttrOf<Element>;

@:forward
abstract EventFrom<E:Event, T:Element>(E) from E to E {
  
  public var target(get, never):Element;
    inline function get_target():T
      return cast this.target;

  public var currentTarget(get, never):T;
    inline function get_currentTarget():T
      return cast this.target;
  
  public var dom(get, never):T;
    inline function get_dom()
      return currentTarget;

}

typedef AttrOf<Target:Element> = {
  @:optional var key(default, never):Key;
  @:optional var className(default, never):ClassName;
  @:optional var id(default, never):String;
  @:optional var title(default, never):String;
  @:optional var lang(default, never):String;
  @:optional var dir(default, never):String;
  
  @:optional var attributes(default, never):Dict<Ext>;
  
  @:optional var hidden(default, never):Bool;
  @:optional var tabIndex(default, never):Int;
  @:optional var accessKey(default, never):String;
  @:optional var accessKeyLabel(default, never):String;
  @:optional var draggable(default, never):Bool;
  @:optional var spellcheck(default, never):Bool;
  @:optional var style(default, never):Style;
  
  @:optional var onwheel(default, never):Callback<EventFrom<WheelEvent, Target>>;
  
  @:optional var oncopy(default, never):Callback<EventFrom<ClipboardEvent, Target>>;
  @:optional var oncut(default, never):Callback<EventFrom<ClipboardEvent, Target>>;
  @:optional var onpaste(default, never):Callback<EventFrom<ClipboardEvent, Target>>;
  
  @:optional var onabort(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onblur(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onfocus(default, never):Callback<EventFrom<Event, Target>>;
  
  @:optional var oncanplay(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var oncanplaythrough(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onchange(default, never):Callback<EventFrom<Event, Target>>;
  
  @:optional var onclick(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var oncontextmenu(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var ondblclick(default, never):Callback<EventFrom<MouseEvent, Target>>;
  
  @:optional var ondrag(default, never):Callback<EventFrom<DragEvent, Target>>;
  @:optional var ondragend(default, never):Callback<EventFrom<DragEvent, Target>>;
  @:optional var ondragenter(default, never):Callback<EventFrom<DragEvent, Target>>;
  @:optional var ondragleave(default, never):Callback<EventFrom<DragEvent, Target>>;
  @:optional var ondragover(default, never):Callback<EventFrom<DragEvent, Target>>;
  @:optional var ondragstart(default, never):Callback<EventFrom<DragEvent, Target>>;
  @:optional var ondrop(default, never):Callback<EventFrom<DragEvent, Target>>;
  
  @:optional var ondurationchange(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onemptied(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onended(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var oninput(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var oninvalid(default, never):Callback<EventFrom<Event, Target>>;
  
  @:optional var onkeydown(default, never):Callback<EventFrom<KeyboardEvent, Target>>;
  @:optional var onkeypress(default, never):Callback<EventFrom<KeyboardEvent, Target>>;
  @:optional var onkeyup(default, never):Callback<EventFrom<KeyboardEvent, Target>>;
  
  @:optional var onload(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onloadeddata(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onloadedmetadata(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onloadstart(default, never):Callback<EventFrom<Event, Target>>;
  
  @:optional var onmousedown(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var onmouseenter(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var onmouseleave(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var onmousemove(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var onmouseout(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var onmouseover(default, never):Callback<EventFrom<MouseEvent, Target>>;
  @:optional var onmouseup(default, never):Callback<EventFrom<MouseEvent, Target>>;
  
  @:optional var onpause(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onplay(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onplaying(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onprogress(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onratechange(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onreset(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onresize(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onscroll(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onseeked(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onseeking(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onselect(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onshow(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onstalled(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onsubmit(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onsuspend(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var ontimeupdate(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onvolumechange(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onwaiting(default, never):Callback<EventFrom<Event, Target>>;
  
  @:optional var onpointercancel(default, never):Callback<EventFrom<PointerEvent, Target>>;
  @:optional var onpointerdown(default, never):Callback<EventFrom<PointerEvent, Target>>;
  @:optional var onpointerup(default, never):Callback<EventFrom<PointerEvent, Target>>;
  @:optional var onpointermove(default, never):Callback<EventFrom<PointerEvent, Target>>;
  @:optional var onpointerout(default, never):Callback<EventFrom<PointerEvent, Target>>;
  @:optional var onpointerover(default, never):Callback<EventFrom<PointerEvent, Target>>;
  @:optional var onpointerenter(default, never):Callback<EventFrom<PointerEvent, Target>>;
  @:optional var onpointerleave(default, never):Callback<EventFrom<PointerEvent, Target>>;
  
  @:optional var ongotpointercapture(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onlostpointercapture(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onfullscreenchange(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onfullscreenerror(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onpointerlockchange(default, never):Callback<EventFrom<Event, Target>>;
  @:optional var onpointerlockerror(default, never):Callback<EventFrom<Event, Target>>;
  
  @:optional var onerror(default, never):Callback<EventFrom<ErrorEvent, Target>>;
  
  @:optional var ontouchstart(default, never):Callback<EventFrom<TouchEvent, Target>>;
  @:optional var ontouchend(default, never):Callback<EventFrom<TouchEvent, Target>>;
  @:optional var ontouchmove(default, never):Callback<EventFrom<TouchEvent, Target>>;
  @:optional var ontouchcancel(default, never):Callback<EventFrom<TouchEvent, Target>>;
}

typedef EditableAttr = {>Attr,
  @:optional var contentEditable(default, never):Bool;
}

typedef FormAttr = {>AttrOf<FormElement>,
  @:optional var method(default, never):String;
  @:optional var action(default, never):String;
}

typedef AnchorAttr = {> AttrOf<AnchorElement>,
  @:optional var href(default, never):String;
  @:optional var target(default, never):String;
  @:optional var type(default, never):String;
}


typedef TableCellAttr = {> Attr,
  @:optional var abbr(default, never):String;
  @:optional var colSpan(default, never):Int;
  @:optional var headers(default, never):String;
  @:optional var rowSpan(default, never):Int;
  @:optional var scope(default, never):String;
  @:optional var sorted(default, never):String;
}


typedef InputAttr = {> AttrOf<InputElement>,
  @:optional var checked(default, never):Bool;
  @:optional var disabled(default, never):Bool;
  @:optional var required(default, never):Bool;
  @:optional var autofocus(default, never):Bool;
  @:optional var value(default, never):String;
  @:optional var type(default, never):String;
  @:optional var name(default, never):String;
  @:optional var placeholder(default, never):String;
  @:optional var max(default, never):String;
  @:optional var min(default, never):String;
  @:optional var step(default, never):String;
  @:optional var maxlength(default, never):Int;
  @:optional var pattern(default, never):String;
  @:optional var accept(default, never):String;
}

typedef TextAreaAttr = {> AttrOf<TextAreaElement>,
  @:optional var autofocus(default, never):Bool;
  @:optional var cols(default, never):Int;
  @:optional var dirname(default, never):String;
  @:optional var disabled(default, never):Bool;
  @:optional var form(default, never):String;
  @:optional var maxlength(default, never):Int;
  @:optional var name(default, never):String;
  @:optional var placeholder(default, never):String;
  @:optional var readonly(default, never):Bool;
  @:optional var required(default, never):Bool;
  @:optional var rows(default, never):Int;
  @:optional var wrap(default, never):String;
}

typedef IframeAttr = {> AttrOf<IFrameElement>,
  @:optional var sandbox(default, never):String; 
  @:optional var width(default, never):Int; 
  @:optional var height(default, never):Int; 
  @:optional var src(default, never):String; 
  @:optional var srcdoc(default, never):String; 
  @:optional var allowFullscreen(default, never):Bool;
  @:deprecated @:optional var scrolling(default, never):IframeScrolling;
}

@:enum abstract IframeScrolling(String) {
  var Yes = "yes";
  var No = "no";
  var Auto = "auto";
}

typedef ImgAttr = {> AttrOf<ImageElement>,
  @:optional var src(default, never):String;
  @:optional var width(default, never):Int;
  @:optional var height(default, never):Int;
}

typedef AudioAttr = {> AttrOf<AudioElement>,
  @:optional var src(default, never):String;
  @:optional var autoplay(default, never):Bool;
  @:optional var controls(default, never):Bool;
  @:optional var loop(default, never):Bool;
  @:optional var muted(default, never):Bool;
  @:optional var preload(default, never):String;
}

typedef VideoAttr = {> AttrOf<VideoElement>,
  @:optional var src(default, never):String;
  @:optional var autoplay(default, never):Bool;
  @:optional var controls(default, never):Bool;
}

typedef SourceAttr = {> AttrOf<SourceElement>,
  @:optional var src(default, never):String;
  @:optional var srcset(default, never):String;
  @:optional var media(default, never):String;
  @:optional var sizes(default, never):String;
  @:optional var type(default, never):String;
}

typedef LabelAttr = {> AttrOf<LabelElement>,
  @:optional var htmlFor(default, never):String;
}

typedef SelectAttr = {> AttrOf<SelectElement>,
  @:optional var autofocus(default, never):Bool;
  @:optional var disabled(default, never):Bool;
  @:optional var form(default, never):FormElement;
  @:optional var multiple(default, never):Bool;
  @:optional var name(default, never):String;
  @:optional var required(default, never):Bool;
  @:optional var size(default, never):Int;
}

typedef OptionAttr = {> AttrOf<OptionElement>,
  @:optional var disabled:Bool;
  @:optional var form(default, never):FormElement;
  @:optional var label(default, never):String;
  @:optional var defaultSelected(default, never):Bool;
  @:optional var selected(default, never):Bool;
  @:optional var value(default, never):String;
  @:optional var text(default, never):String;
  @:optional var index(default, never):Int;
}

typedef ScriptAttr = {> AttrOf<ScriptElement>,
  @:optional var async(default, never):Bool;
  @:optional var charset(default, never):String;
  @:optional var defer(default, never):Bool;
  @:optional var src(default, never):String;
  @:optional var type(default, never):String;
}

typedef CanvasAttr = {>Attr,
  @:optional var width(default, never):String;
  @:optional var height(default, never):String;
}