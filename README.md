# FiveM CreatePoint Function

## 🚀 - Lua Usage

```lua
arda.createPoint({
    coords = vector3(215.12, -810.22, 30.73),
    blip = {
        sprite = 280,
        color = 2,
        scale = 0.9,
        name = "Beispiel Point"
    },
    marker = {
        type = 1,
        drawDistance = 25.0,
        scale = vector3(1.0, 1.0, 1.0),
        color = { r = 0, g = 180, b = 255 },
        alpha = 155
    },
    onNearby = function(point, distance)
        print("action >> onNearby")
    end,
    helpNotify = function(point, distance)
        print("action >> helpNotify")
    end,
    onInteract = function(point, distance)
        print("action >> onInteract")
    end
})
```
