package coconut.vdom;

@:forward
abstract Child(VNode) from VNode {
 
  public var isText(get, never):Bool;
    inline function get_isText()
      return this.t == null;

  public var isWidget(get, never):Bool;
    inline function get_isWidget():Bool
      return this.a['isWidget'] == true;

  public var key(get, never):String;
    inline function get_key()
      return this.k;

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