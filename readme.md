# Insomnia Plugins

Plugins for [insomnia] implemented with JavaScript and PureScript.

[insomnia]: https://insomnia.rest


**Attention:** After changing a plugin, Insomnia must be reloaded!


## Activation

1. Make sure the cli tool `bower` is installed:
  `npm install --global bower`
1. Make sure PureScript is installed (i.e. the cli tool `pulp`):
  `brew install purescript` or `npm install --global purescript`
1. Build plugins with `make`
1. Open Insomnia
1. Go to Preferences > General > Plugins (scroll to the bottom)
1. Add path `~/Projects/feram/insomnia-plugins`
1. Go to Preferences > Plugins and verify that the plugins are listed
