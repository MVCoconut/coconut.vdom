package coconut.diffing;

interface Driver<Native> {
  function total(target:Native):Int;
  function get(target:Native, index:Int):Native;
  function all(target:Native):Array<Native>;
  function insertAt(target:Native, child:Native, index:Int):Void;
  function removeAt(target:Native, index:Int):Void;
}