# davidosomething's computercraft scripts

Lua scripts for [ComputerCraft](http://www.computercraft.info/) v1.7+.
Most of these are mirrored on
[my pastebin account](http://pastebin.com/u/davidosomething)
so you can grab them individually there.

## Installation

From a new ComputerCraft computer run

```
pastebin get uVtX8Yx6 startup
label set COMPUTER_LABEL
```

where `COMPUTER_LABEL` is one of `reactor` or `remote`. Then restart to have
CraftOS autorun the startup script.

## Files

### startup.lua

- Set environment, updates `bin/`, runs `bin/update.lua`, loads libs

### bin/

- Scripts for system

#### update.lua

- Updates scripts specific to the computer by label

### lib/

- APIs

#### meter.lua

- API to display a meter for battery, fuel, etc.

### remote/

- Scripts for advanced pocket computers

#### reactor.lua

- Sends toggle/status commands to a remote reactor

### reactor/

- Scripts for computers attached to reactors

#### main.lua

- Display reactor stats on nearby monitor and accept rednet commands `toggle`
  and `status`


