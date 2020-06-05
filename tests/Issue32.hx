import js.Browser.*;
import coconut.vdom.*;
import coconut.vdom.Renderer.*;

@:asserts
class Issue32 {
	public static var count = 0;
	public function new() {}
	public function run() {
		count = 0;
		var div = document.createDivElement();
		document.body.appendChild(div);
		mount(div, hxx('<Overview/>'));
		
		asserts.assert(count == 0);
		document.querySelector('#issue32-button').click();
		updateAll();
		asserts.assert(count == 1);
		document.querySelector('#issue32-toggle').click();
		updateAll();
		document.querySelector('#issue32-button').click();
		updateAll();
		asserts.assert(count == 1);
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
		trace('compute ${state}');
		return state == 1 ? function() Issue32.count++ : null;
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