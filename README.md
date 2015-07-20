# davidosomething's computercraft scripts

MASTER IS UNSTABLE -- use the code at the [v1.0.0 release](https://github.com/davidosomething/computercraft/releases/tag/v1.0.0)

Lua scripts for [ComputerCraft](http://www.computercraft.info/) v1.7+.
Most of these are mirrored on
[my pastebin account](http://pastebin.com/u/davidosomething)
so you can grab them individually there.

## Screenshots

Reactor: right clicking left/right will toggle reactor or autotoggle state.

![Reactor](https://raw.githubusercontent.com/davidosomething/computercraft/master/docs/reactor-main.png)

Remote:

![Remote](https://raw.githubusercontent.com/davidosomething/computercraft/master/docs/remote-reactor.png)

## Installation

From a new ComputerCraft computer run

```
pastebin get uVtX8Yx6 startup
label set COMPUTER_LABEL
```

where `COMPUTER_LABEL` is one of `reactor` or `remote`. Then restart to have
CraftOS autorun the startup script.

After startup runs once and gets files via pastebin, future requests will be
made directly to GitHub via the HTTP API if you have that enabled.

## Docs

See [ldoc generated docs](http://davidosomething.github.io/computercraft/) for
more details.

