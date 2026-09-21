local function notify(message)
    TriggerEvent('chat:addMessage', {
        color = { 0, 170, 255 },
        args = { 'KruigerDV', message }
    })
end

local function requestControl(entity)
    if not DoesEntityExist(entity) then return false end

    NetworkRequestControlOfEntity(entity)

    local timeout = GetGameTimer() + 2000
    while not NetworkHasControlOfEntity(entity) and GetGameTimer() < timeout do
        Wait(0)
        NetworkRequestControlOfEntity(entity)
    end

    return NetworkHasControlOfEntity(entity)
end

local function deleteVehicle(vehicle)
    if not DoesEntityExist(vehicle) then
        return false
    end

    requestControl(vehicle)
    SetEntityAsMissionEntity(vehicle, true, true)
    DeleteVehicle(vehicle)

    if DoesEntityExist(vehicle) then
        DeleteEntity(vehicle)
    end

    return not DoesEntityExist(vehicle)
end

RegisterCommand(Config.Command, function()
    local ped = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(ped, false)

    if vehicle == 0 and Config.AllowNearestVehicle then
        local coords = GetEntityCoords(ped)
        vehicle = GetClosestVehicle(
            coords.x,
            coords.y,
            coords.z,
            Config.MaxDistance,
            0,
            70
        )
    end

    if vehicle == 0 or not DoesEntityExist(vehicle) then
        notify(('No vehicle found within %.1f meters.'):format(Config.MaxDistance))
        return
    end

    if deleteVehicle(vehicle) then
        notify('Vehicle deleted.')
    else
        notify('Unable to delete that vehicle.')
    end
end, false)
