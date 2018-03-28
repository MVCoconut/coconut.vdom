package coconut.vdom;

@:observable
abstract Child(VNode) from VNode from Widget {
  
  static public inline var WIDGET = ':widget';
  static public inline var TEXT = ':text';
  static public inline var NATIVE = ':native';

  public var isText(get, never):Bool;
    inline function get_isText()
      return this.t == TEXT;

  public var isWidget(get, never):Bool;
    inline function get_isWidget():Bool
      return this.t == WIDGET;

  public var isNative(get, never):Bool;
    inline function get_isNative():Bool
      return this.t == NATIVE;

  public var key(get, never):String;
    inline function get_key()
      return this.k;

  public var type(get, never):String;
    inline function get_type()
      return this.t;

  public var attributes(get, never):Dict<Any>;
    inline function get_attributes()
      return this.a;

  public var children(get, never):Children;
    inline function get_children()
      return this.c;

  @:from static inline function ofString(s:String):Child
    return ({ t: ':text', k: s, a: @:privateAccess VDom.EMPTY } : VNode);

  @:from static inline function ofInt(i:Int):Child
    return ofString(Std.string(i));

  @:from static inline function ofElement(e:js.html.Node):Child
    return ({ t: ':native', a: { NATIVE: e } } : VNode);

  public inline function asText():Null<String>
    return if (isText) key else null;

  public inline function asNative():Null<js.html.Node>
    return if (isNative) attributes[NATIVE] else null;

  public inline function asWidget():Null<Widget>
    return if (isWidget) cast this else null;

  @:to public inline function toDom():js.html.Node
    return @:privateAccess VDom.createNode(this);
}

typedef VNode = {
  var t(default, never):String;
  @:optional var k(default, never):String;
  var a(default, never):Dict<Any>;
  @:optional var c(default, never):Children;
}