package coconut.vdom;

abstract Child(VNode) from VNode from Widget {
 
  public var isText(get, never):Bool;
    inline function get_isText()
      return this.t == null;

  public var isWidget(get, never):Bool;
    inline function get_isWidget():Bool
      return this.t == 'widget';

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
    return ({ t: null, k: s, a: @:privateAccess VDom.EMPTY } : VNode);

  @:from static inline function ofInt(i:Int):Child
    return ofString(Std.string(i));
    
}

typedef VNode = {
  var t(default, never):String;
  @:optional var k(default, never):String;
  var a(default, never):Dict<Any>;
  @:optional var c(default, never):Children;
}