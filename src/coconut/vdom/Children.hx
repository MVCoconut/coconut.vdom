package coconut.vdom;

abstract Children(Array<Child>) {
  
  public var length(get, never):Int;
    inline function get_length()
      return if (this == null) 0 else this.length;

  inline function new(a)
    this = a;

  @:arrayAccess inline function get(index:Int):Child
    return this[index];

  @:from static function ofArray(a:Array<Child>):Children
    return new Children([for (c in a) if (c != null) c]);

  @:from static inline function ofSingle(c:Child):Children
    return ofArray([c]);

  public inline function toArray()
    return if (this == null) [] else this.copy();
}