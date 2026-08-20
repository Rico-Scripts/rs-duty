# rs-duty

Plug-and-play duty systeem voor ESX Legacy.

## Dependencies
- es_extended
- ox_lib

## Server exports
```lua
exports['rs-duty']:IsOnDuty(source)
exports['rs-duty']:SetDuty(source, true)
exports['rs-duty']:SetDuty(source, false)
exports['rs-duty']:ToggleDuty(source)
exports['rs-duty']:GetDutyData(source)
```

## Client state
```lua
LocalPlayer.state.rsDuty
LocalPlayer.state.rsDutyJob
```

## Events
- `rs-duty:server:toggle`
- `rs-duty:server:set`
- `rs-duty:client:update`
