package coconut.vdom;

abstract Dict<T>(Dynamic<T>) from Dynamic<T> to Dynamic<T> {
	
	public inline function new() this = {};

	@:arrayAccess inline function get(key:String):T
		return js.Syntax.field(this, key);

  public inline function keys()
    return js.Object.getOwnPropertyNames(cast this);
}  