package coconut.diffing;

interface VNode<Native, Kind> {
  var kind(default, never):Kind;
  var key(default, never):Null<String>;
  function create():Native;
  function patch(target:Native, old:VNode<Native, Kind>):Native;
  function teardown(target:Native):Void;
}