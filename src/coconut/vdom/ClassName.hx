package coconut.vdom;

using StringTools;

abstract ClassName(String) to String {
  
  inline function new(s:String) this = s;
  
  public function add(that:ClassName) 
    return new ClassName(switch [this, (that:String)] {
      case [null, v] | [v, null]: v;
      case [a, b]: '$a $b';
    });

  @:from static function ofMap(parts:Map<String, Bool>)
    return new ClassName(ofArray([for (c in parts.keys()) if (parts[c]) ofString(c)]));
  
  @:from static function ofArray(parts:Array<String>) 
    return new ClassName(parts.map(ofString).join(' '));

  @:from static function ofString(s:String):ClassName
    return new ClassName(s.trim());
}