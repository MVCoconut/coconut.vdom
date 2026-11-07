import coconut.ui.*;
import js.Browser.*;
import js.html.*;
import tink.state.State;

// Page translators (Safari, Edge, Firefox) swap each text node for a new one holding the translation; Google wraps the
// translation in <font> elements instead. The renderer still holds the original text nodes.
@:asserts
class TranslatedText {
  public function new() {}

  static function translate(root:Node, google = false) {
    var texts = [];
    var walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
    while (walker.nextNode() != null)
      texts.push(walker.currentNode);
    for (t in texts)
      if (t.nodeValue != '' && t.nodeValue.indexOf('EN:') != 0) {
        var translated = document.createTextNode('EN:' + t.nodeValue);
        t.parentNode.replaceChild(
          if (google) {
            var outer = document.createElement('font'), inner = document.createElement('font');
            inner.appendChild(translated);
            outer.appendChild(inner);
            outer;
          }
          else translated,
          t
        );
      }
  }

  static function container() {
    var c = document.createDivElement();
    document.body.appendChild(c);
    return c;
  }

  public function changedTextReplacesTheTranslation() {
    var c = container(), text = new State('eins');
    Renderer.mount(c, '<Isolated><div>${text.value}</div></Isolated>');
    var div = c.firstChild;

    for (next in ['zwei', 'drei', 'vier']) {
      translate(div);
      text.set(next);
      Renderer.updateAll();
      asserts.assert(div.childNodes.length == 1);
      asserts.assert(div.textContent == next);
    }

    document.body.removeChild(c);
    return asserts.done();
  }

  public function unchangedTextKeepsTheTranslation() {
    var c = container(), text = new State('eins'), cls = new State('a');
    Renderer.mount(c, '<Isolated><div class=${cls.value}>${text.value}</div></Isolated>');
    var div:Element = cast c.firstChild;

    translate(div);
    cls.set('b');
    Renderer.updateAll();

    asserts.assert(div.className == 'b');
    asserts.assert(div.childNodes.length == 1);
    asserts.assert(div.textContent == 'EN:eins');

    document.body.removeChild(c);
    return asserts.done();
  }

  public function unchangedTextKeepsItsPlace() {
    var c = container(), text = new State('eins'), other = new State('alt');
    Renderer.mount(c, '<Isolated><div>${text.value}<span>${other.value}</span></div></Isolated>');
    var div = c.firstChild;

    translate(div);
    other.set('neu');
    Renderer.updateAll();

    asserts.assert(div.childNodes.length == 2);
    asserts.assert(div.firstChild.textContent == 'EN:eins');
    asserts.assert(div.lastChild.textContent == 'neu');

    document.body.removeChild(c);
    return asserts.done();
  }

  public function textNextToAnElement() {
    var c = container(), text = new State('eins');
    Renderer.mount(c, '<Isolated><div>${text.value}<span>fest</span></div></Isolated>');
    var div = c.firstChild;

    translate(div);
    text.set('zwei');
    Renderer.updateAll();

    asserts.assert(div.childNodes.length == 2);
    asserts.assert(div.firstChild.nodeValue == 'zwei');
    asserts.assert(div.lastChild.textContent == 'EN:fest');

    document.body.removeChild(c);
    return asserts.done();
  }

  public function newNodeBeforeATranslationDoesNotReplaceIt() {
    var c = container(), text = new State('eins'), show = new State(false);
    Renderer.mount(c, '<Isolated><div><if ${show.value}><b>neu</b></if>${text.value}</div></Isolated>');
    var div = c.firstChild;

    translate(div);
    show.set(true);
    Renderer.updateAll();

    asserts.assert(div.childNodes.length == 2);
    asserts.assert(div.firstChild.textContent == 'neu');
    asserts.assert(div.lastChild.textContent == 'EN:eins');

    document.body.removeChild(c);
    return asserts.done();
  }

  public function togglingNextToATranslation() {
    var c = container(), text = new State('eins'), show = new State(true);
    Renderer.mount(c, '<Isolated><div><if ${show.value}><b>neu</b></if>${text.value}</div></Isolated>');
    var div = c.firstChild;

    for (i in 0...4) {
      translate(div);
      show.set(!show.value);
      if (i == 2) text.set('zwei');
      Renderer.updateAll();
    }
    // after an even number of toggles the <b> is back next to one copy of the text, translated after its last change
    asserts.assert(div.childNodes.length == 2);
    asserts.assert(div.firstChild.nodeName == 'B');
    asserts.assert(div.lastChild.textContent == 'EN:zwei');

    document.body.removeChild(c);
    return asserts.done();
  }

  public function elementsInsertedByOthersStay() {
    var c = container(), text = new State('eins');
    Renderer.mount(c, '<Isolated><div>${text.value}</div></Isolated>');
    var div = c.firstChild;

    translate(div);
    var injected = document.createElement('i');// an extension's button, say
    div.insertBefore(injected, div.firstChild);
    text.set('zwei');
    Renderer.updateAll();

    asserts.assert(injected.parentNode == div);

    document.body.removeChild(c);
    return asserts.done();
  }

  public function googleFontWrappers() {
    var c = container(), text = new State('eins');
    Renderer.mount(c, '<Isolated><div>${text.value}</div></Isolated>');
    var div = c.firstChild;

    for (next in ['zwei', 'drei']) {
      translate(div, true);
      text.set(next);
      Renderer.updateAll();
      asserts.assert(div.childNodes.length == 1);
      asserts.assert(div.textContent == next);
    }

    document.body.removeChild(c);
    return asserts.done();
  }

  public function removingTranslatedText() {
    var c = container(), text = new State('eins'), show = new State(true);
    Renderer.mount(c, '<Isolated><div><if ${show.value}>${text.value}<span>fest</span></if></div></Isolated>');
    var div = c.firstChild;

    translate(div);
    text.set('zwei');
    Renderer.updateAll();
    translate(div);
    show.set(false);
    var error = try {
      Renderer.updateAll();
      null;
    } catch (e:Dynamic) Std.string(e);

    asserts.assert(error == null);
    asserts.assert(div.textContent == '');

    document.body.removeChild(c);
    return asserts.done();
  }
}
