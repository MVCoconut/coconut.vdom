import js.Browser.*;
import coconut.vdom.Renderer.*;

@:asserts
class Issue44 {
  public static var clicks = 0;
  public static var computations = 0;
  public function new() {}
  public function run() {
    var root = document.createElement("div");
    document.body.appendChild(root);
    
    var child = root;

    try mount(root, hxx('<div ref={v -> child = v} style=${{ "--foo": 123 }}/>'))
    catch (_) {};
      
    asserts.assert(child.style.getPropertyValue('--foo') == "123");
    return asserts.done();
  }
}