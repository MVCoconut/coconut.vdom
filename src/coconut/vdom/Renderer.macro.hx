package coconut.vdom;

class Renderer {
  static public macro function hxx(e)
    return coconut.vdom.macros.HXX.parse(e);
}