import js.Browser.*;
import coconut.vdom.*;
import coconut.vdom.Renderer.*;

@:asserts
class Issue32 {
	public static var clicks = 0;
	public static var computations = 0;
	public function new() {}
	public function run() {
		computations = clicks = 0;
		var div = document.createDivElement();
		document.body.appendChild(div);
		mount(div, hxx('<Overview/>'));
		
		asserts.assert(clicks == 0);
		asserts.assert(computations == 1);
		
		document.querySelector('#issue32-button').click();
		asserts.assert(clicks == 1);
		
		document.querySelector('#issue32-toggle').click();
		updateAll();
		asserts.assert(clicks == 1);
		asserts.assert(computations == 2);
		
		document.querySelector('#issue32-button').click();
		asserts.assert(clicks == 1);
		
		document.body.removeChild(div);
		return asserts.done();
	}
}

class Overview extends View {
	@:state var mystate:Int = 1;

	function render() '
		<div>
			<p>State: ${mystate}</p>
			<Menu onClick=${getClick(mystate)}/>
			<button id="issue32-toggle" onclick=${toggle}>Toggle</button>
		</div>
	';
	
	function toggle() {
		mystate++;
	}

	inline function getClick(state:Int):Void->Void {
		Issue32.computations++;
		return state == 1 ? function() Issue32.clicks++ : null;
	}
}

class Menu extends View {
	@:attr var onClick:Void->Void = null;
	function render() '
		<div>
			<Button onClick=${onClick}/>
		</div>
	';
}

class Button extends View {
	@:attr var onClick:Void->Void = null;
	function render() '
		<button id="issue32-button" onclick=${onClick}>Button</button>
	';
}