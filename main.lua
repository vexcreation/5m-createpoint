arda = arda or {}
arda.Utils = arda.Utils or {}
arda.Points = arda.Points or {}

function arda.Utils.createBlip(blipData)
    local c = blipData.coords
    local blip = AddBlipForCoord(c.x, c.y, c.z)

    SetBlipSprite(blip, blipData.sprite or 1)
    SetBlipDisplay(blip, 4)
    SetBlipScale(blip, blipData.scale or 1.0)
    if blipData.color then SetBlipColour(blip, blipData.color) end
    SetBlipAsShortRange(blip, blipData.shortRange ~= false)

    if blipData.name then
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(blipData.name)
        EndTextCommandSetBlipName(blip)
    end

    return blip
end

function arda.createPoint(data)
    if not data or not data.coords then return end;

    local point = {
        coords = vector3(data.coords),
        nearbyDistance = data.nearbyDistance or 10.0,
        interactDistance = data.interactDistance or 2.0,
        key = data.key or 38,

        blip = data.blip,
        marker = data.marker,

        helpNotify = data.helpNotify,
        onNearby = data.onNearby,
        onInteract = data.onInteract,
        canInteract = data.canInteract,

        onEnter = data.onEnter,
        onExit = data.onExit,

        _inside = false,
        _removed = false
    }

    if point.blip then
        point.blip.coords = vector3(point.blip.coords or point.coords)
        point._blipId = arda.Utils.createBlip(point.blip)
    end

    if point.marker then
        point.marker.coords = vector3(point.marker.coords or point.coords)
        point.marker.drawDistance = point.marker.drawDistance or point.nearbyDistance
        point.marker.scale = vector3(point.marker.scale or vector3(1.0, 1.0, 1.0))
        point.marker.color = point.marker.color or { r = 255, g = 255, b = 255 }
        point.marker.alpha = point.marker.alpha or 155
        point.marker.type = point.marker.type or 1
    end

    CreateThread(function()
        while not point._removed do
            local sleep = 750

            local ped = PlayerPedId()
            local pCoords = GetEntityCoords(ped)
            local dist = #(pCoords - point.coords)

            if dist <= point.nearbyDistance then
                sleep = 0

                if not point._inside then
                    point._inside = true
                    if point.onEnter then point.onEnter(point) end
                end

                if point.onNearby then
                    point.onNearby(point, dist)
                end

                if point.marker and dist <= (point.marker.drawDistance or point.nearbyDistance) then
                    DrawMarker(
                        point.marker.type or 1,
                        point.marker.coords.x, point.marker.coords.y, point.marker.coords.z - 1.0,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        point.marker.scale.x, point.marker.scale.y, point.marker.scale.z,
                        point.marker.color.r, point.marker.color.g, point.marker.color.b,
                        point.marker.alpha or 155,
                        false, true, 2, false, false, false, false
                    )
                end

                local allowed = true
                if point.canInteract then
                    allowed = point.canInteract(point, dist) == true
                end

                if allowed and dist <= point.interactDistance then
                    if point.helpNotify then
                        point.helpNotify(point, dist)
                    end

                    if point.onInteract and IsControlJustReleased(0, point.key) then
                        point.onInteract(point, dist)
                    end
                end
            else
                if point._inside then
                    point._inside = false
                    if point.onExit then point.onExit(point) end
                end
            end

            Wait(sleep)
        end
    end)

    arda.Points[#arda.Points + 1] = point
    return point
end

function arda.removePoint(point)
    if not point or point._removed then return end
    point._removed = true

    if point._blipId then
        RemoveBlip(point._blipId)
        point._blipId = nil
    end
end