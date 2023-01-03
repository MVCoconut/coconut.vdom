import coconut.ui.*;
import js.Browser.*;

@:asserts
class Issue37 {
  public function new() {}
  public function test() {
    var container = document.createDivElement(),
        state = new tink.state.State(0);

    document.body.appendChild(container);

    Renderer.mount(container, '
      <Isolated>
        <if ${state.value == 0}>
          <button id="issue37" onclick=${() -> state.set(state.value + 1)}/>
        <else>
          <button id="issue37" />
        </if>
      </Isolated>
    ');

    document.getElementById('issue37').click();
    asserts.assert(state.value == 1);
    Renderer.updateAll();
    document.getElementById('issue37').click();
    asserts.assert(state.value == 1);

    return asserts.done();
  }
}