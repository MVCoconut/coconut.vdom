package coconut.vdom;

import js.html.*;
import coconut.vdom.VDom.h;
import coconut.vdom.Attr;

class Html {
  static public inline function iframe(attr: IframeAttr, ?children:Children):Child return h('iframe', attr, children);
  static public inline function object(attr: {> Attr, type:String, data:String }, ?children:Children):Child return h('object', attr, children);

  static public inline function param(attr: {> Attr, name:String, value:String }):Child return h('param', attr);
  static public inline function div(attr:EditableAttr, ?children:Children):Child return h('div', attr, children);
  static public inline function aside(attr:EditableAttr, ?children:Children):Child return h('aside', attr, children);
  static public inline function section(attr:EditableAttr, ?children:Children):Child return h('section', attr, children);

  static public inline function header(attr:EditableAttr, ?children:Children):Child return h('header', attr, children);
  static public inline function footer(attr:EditableAttr, ?children:Children):Child return h('footer', attr, children);
  static public inline function main(attr:EditableAttr, ?children:Children):Child return h('main', attr, children);
  static public inline function nav(attr:EditableAttr, ?children:Children):Child return h('nav', attr, children);

  static public inline function table(attr:EditableAttr, ?children:Children):Child return h('table', attr, children);
  static public inline function thead(attr:EditableAttr, ?children:Children):Child return h('thead', attr, children);
  static public inline function tbody(attr:EditableAttr, ?children:Children):Child return h('tbody', attr, children);
  static public inline function tfoot(attr:EditableAttr, ?children:Children):Child return h('tfoot', attr, children);
  static public inline function tr(attr:EditableAttr, ?children:Children):Child return h('tr', attr, children);
  static public inline function td(attr:TableCellAttr, ?children:Children):Child return h('td', attr, children);
  static public inline function th(attr:TableCellAttr, ?children:Children):Child return h('th', attr, children);

  static public inline function h1(attr:EditableAttr, ?children:Children):Child return h('h1', attr, children);
  static public inline function h2(attr:EditableAttr, ?children:Children):Child return h('h2', attr, children);
  static public inline function h3(attr:EditableAttr, ?children:Children):Child return h('h3', attr, children);
  static public inline function h4(attr:EditableAttr, ?children:Children):Child return h('h4', attr, children);
  static public inline function h5(attr:EditableAttr, ?children:Children):Child return h('h5', attr, children);

  static public inline function strong(attr:EditableAttr, ?children:Children):Child return h('strong', attr, children);
  static public inline function em(attr:EditableAttr, ?children:Children):Child return h('em', attr, children);
  static public inline function span(attr:EditableAttr, ?children:Children):Child return h('span', attr, children);
  static public inline function a(attr:AnchorAttr, ?children:Children):Child return h('a', attr, children);

  static public inline function p(attr:EditableAttr, ?children:Children):Child return h('p', attr, children);
  static public inline function i(attr:EditableAttr, ?children:Children):Child return h('i', attr, children);
  static public inline function b(attr:EditableAttr, ?children:Children):Child return h('b', attr, children);
  static public inline function small(attr:EditableAttr, ?children:Children):Child return h('small', attr, children);
  static public inline function menu(attr:EditableAttr, ?children:Children):Child return h('menu', attr, children);
  static public inline function ul(attr:EditableAttr, ?children:Children):Child return h('ul', attr, children);
  static public inline function ol(attr:EditableAttr, ?children:Children):Child return h('ol', attr, children);
  static public inline function li(attr:EditableAttr, ?children:Children):Child return h('li', attr, children);
  static public inline function label(attr:LabelAttr, ?children:Children):Child return h('label', attr, children);
  static public inline function button(attr:InputAttr, ?children:Children):Child return h('button', attr, children);
  static public inline function textarea(attr:TextAreaAttr, ?children:Children):Child return h('textarea', attr, children);
  
  static public inline function pre(attr:EditableAttr, ?children:Children):Child return h('pre', attr, children);

  static public inline function hr(attr: Attr):Child return h('hr', attr);
  static public inline function br(attr: Attr):Child return h('br', attr);
  static public inline function wbr(attr: Attr):Child return h('wbr', attr);

  static public inline function canvas(attr: CanvasAttr):Child return h('canvas', attr);
  static public inline function img(attr: ImgAttr):Child return h('img', attr);
  static public inline function audio(attr: AudioAttr, ?children:Children):Child return h('audio', attr, children);
  static public inline function video(attr: VideoAttr, ?children:Children):Child return h('video', attr, children);
  static public inline function source(attr: SourceAttr):Child return h('source', attr);
  static public inline function input(attr: InputAttr):Child return h('input', attr);
  static public inline function form(attr: FormAttr, ?children:Children):Child return h('form', attr, children);

  static public inline function select(attr: SelectAttr, ?children:Children):Child return h('select', attr, children);
  static public inline function option(attr: OptionAttr, ?children:Children):Child return h('option', attr, children);
  static public inline function script(attr: ScriptAttr, ?children:Children):Child return h('script', attr, children);
  
  static public inline function raw(attr: HtmlFragment.RawAttr):Child return HtmlFragment.create(attr);
}