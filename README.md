# Coconut VDOM Renderer

![Gitter](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/MVCoconut/Lobby)

A pure Haxe virtual dom renderer for [coconut.ui](https://github.com/MVCoconut/coconut.diffing) based on [coconut.diffing](https://github.com/MVCoconut/coconut.diffing).

Differences from coconut.react:

- no JS dependency (moderate size saving)
- allows putting DOM straight into VDOM (use with care)
- slightly better performance (YMMV)

All in all coconut.vdom supports everything coconut.react does, except for the rendering of "pure" react components. You may find coconut.react + preact (+ preact-compat) a good middleground.