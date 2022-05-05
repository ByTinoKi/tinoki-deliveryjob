ESX = nil

local isInMenu = false
local currentLocation, currentPoint = 0, 0
local currentVehicle = nil

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(100)
    end

    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(100)
    end

    ESX.PlayerData = ESX.GetPlayerData()

    if ESX.PlayerData.job.name == Config.JobName then
        CreateBlip()
    end
    Citizen.CreateThread(function() StartScript(); end)
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    ESX.PlayerData.job = job

    if job == Config.JobName then
        if not DoesBlipExist(Config.MainPosition.Blip.Blip) then
            CreateBlip()
        end
    else
        if DoesBlipExist(Config.MainPosition.Blip.Blip) then
            RemoveBlip(Config.MainPosition.Blip.Blip)
        end
    end
end)

function CreateBlip()
    local blip = AddBlipForCoord(Config.MainPosition.MenuLocation)
    SetBlipSprite(blip, Config.MainPosition.Blip.Sprite)
    SetBlipColour(blip, Config.MainPosition.Blip.Colour)
    SetBlipScale(blip, Config.MainPosition.Blip.Scale)
    SetBlipAsShortRange(blip, Config.MainPosition.Blip.IsShortRange)
    SetBlipDisplay(blip, 4)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(Config.MainPosition.Blip.Name)
    EndTextCommandSetBlipName(blip)

    Config.MainPosition.Blip.Blip = blip
end

function StartScript()
    while true do
        local wait = 1000

        if ESX.PlayerData.job.name == Config.JobName then
            local playerPed = PlayerPedId()
            local coords = GetEntityCoords(playerPed)
            local distance = GetDistanceBetweenCoords(coords, Config.MainPosition.MenuLocation, true)

            if distance < 10.0 and not DoesEntityExist(currentVehicle) then
                if Config.Markers.VehicleTakeout.Enabled then
                    wait = 5
                    DrawMarker(Config.Markers.VehicleTakeout.Type, Config.MainPosition.MenuLocation, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Markers.VehicleTakeout.Scale.x, Config.Markers.VehicleTakeout.Scale.y, Config.Markers.VehicleTakeout.Scale.z, Config.Markers.VehicleTakeout.Colour.r, Config.Markers.VehicleTakeout.Colour.g, Config.Markers.VehicleTakeout.Colour.b, Config.Markers.VehicleTakeout.Colour.a, false, false, 2, Config.Markers.VehicleTakeout.Rotate, nil, nil, false)
                end

                if distance < Config.Markers.VehicleTakeout.Scale.x and not isInMenu then
                    wait = 5
                    ESX.ShowHelpNotification('Druk ~INPUT_CONTEXT~ om het menu te openen')

                    if IsControlJustPressed(1, 51) then
                        Citizen.CreateThread(function() OpenJobMenu(); end)
                    end
                elseif distance > Config.Markers.VehicleTakeout.Scale.x and isInMenu then
                    wait = 5
                    isInMenu = false
                    ESX.UI.Menu.CloseAll()
                end
            end
        else
            wait = 2000
        end

        Citizen.Wait(wait)
    end
end

function OpenJobMenu()
    isInMenu = true
    local elements = {
        { value = 'small', label = 'Small Job' },--
        { value = 'medium', label = 'Medium Job' },
        { value = 'big', label = 'Hard Job' }--
    }

    ESX.UI.Menu.Open('default', GetCurrentResourceName(), 'main-menu', {
        title = 'delivery Job',
        align = 'right',
        elements = elements
    }, function(data, menu)
        if data.current.value ~= 'small' and Config.CheckLicense then
            ESX.TriggerServerCallback('esx_license:checkLicense', function(doesHaveLicense) 
                if doesHaveLicense then
                    menu.close()
                    isInMenu = false
                    local didAttatchTrailer = false

                    ESX.Game.SpawnVehicle(GetHashKey(Config.Vehicles[data.current.value]), vector3(Config.MainPosition.VehicleLocation.x, Config.MainPosition.VehicleLocation.y, Config.MainPosition.VehicleLocation.z), Config.MainPosition.VehicleLocation.h, function(callback_vehicle) 
                        currentVehicle = callback_vehicle

                        if data.current.value == 'big' then
                            ESX.Game.SpawnVehicle(GetHashKey('trailers2'), vector3(Config.MainPosition.TrailerLocation.x, Config.MainPosition.TrailerLocation.y, Config.MainPosition.TrailerLocation.z), Config.MainPosition.TrailerLocation.h, function(callback_vehicle2) 
                                local blip = AddBlipForCoord(vector3(Config.MainPosition.TrailerLocation.x, Config.MainPosition.TrailerLocation.y, Config.MainPosition.TrailerLocation.z))
                                SetBlipRoute(blip, true)
                                exports.pNotify:SendNotification({
                                    text = "Take the trailer for the truck.", 
                                    type = "success", 
                                    timeout = math.random(2500, 3000), 
                                    layout = "centerLeft", 
                                    queue = "left"
                                })
                                while callback_vehicle2 and not IsEntityAttachedToEntity(callback_vehicle2, callback_vehicle) do
                                    Citizen.Wait(100)
                                end

                                didAttatchTrailer = true
                                RemoveBlip(blip)
                            end)
                        end
                    end)

                    while not didAttatchTrailer and data.current.value == 'big' do
                        Citizen.Wait(100)
                    end

                    StartMission(data.current.value, false)
                else
                    exports.pNotify:SendNotification({
                        text = "You need truck driver license.", 
                        type = "error", 
                        timeout = math.random(2500, 3000), 
                        layout = "centerLeft", 
                        queue = "left"
                    })
              
                end
            end, GetPlayerServerId(PlayerId()), Config.TruckingLicense)
        else
            menu.close()
            isInMenu = false
            local didAttatchTrailer = false

            ESX.Game.SpawnVehicle(GetHashKey(Config.Vehicles[data.current.value]), vector3(Config.MainPosition.VehicleLocation.x, Config.MainPosition.VehicleLocation.y, Config.MainPosition.VehicleLocation.z), Config.MainPosition.VehicleLocation.h, function(callback_vehicle) 
                currentVehicle = callback_vehicle

                if data.current.value == 'big' then
                    ESX.Game.SpawnVehicle(GetHashKey('trailers2'), vector3(Config.MainPosition.TrailerLocation.x, Config.MainPosition.TrailerLocation.y, Config.MainPosition.TrailerLocation.z), Config.MainPosition.TrailerLocation.h, function(callback_vehicle2) 
                        local blip = AddBlipForCoord(vector3(Config.MainPosition.TrailerLocation.x, Config.MainPosition.TrailerLocation.y, Config.MainPosition.TrailerLocation.z))
                        SetBlipRoute(blip, true)                    
                        exports.pNotify:SendNotification({
                            text = "You need a trailer for the truck!", 
                            type = "error", 
                            timeout = math.random(2500, 3000), 
                            layout = "centerLeft", 
                            queue = "left"
                        })
                        while callback_vehicle2 and not IsEntityAttachedToEntity(callback_vehicle2, callback_vehicle) do
                            Citizen.Wait(100)
                        end

                        didAttatchTrailer = true
                        RemoveBlip(blip)
                    end)
                end
            end)

            while not didAttatchTrailer and data.current.value == 'big' do
                Citizen.Wait(100)
            end

            StartMission(data.current.value, false)
        end
    end, function(data, menu)
        isInMenu = false
        menu.close()
    end)
end

local currentBlip = nil

function StartMission(mission, cancel)
    if currentPoint < Config.MissionCount and not cancel then
        if currentPoint == 0 then
            exports.pNotify:SendNotification({
                text = "Go to the marker and deliver package!", 
                type = "success", 
                timeout = math.random(2500, 3000), 
                layout = "centerLeft", 
                queue = "left"
            })
        else
            exports.pNotify:SendNotification({
                text = "Deliver next package!", 
                type = "success", 
                timeout = math.random(2500, 3000), 
                layout = "centerLeft", 
                queue = "left"
            })
        end

        local location = Config.Missions[mission][math.random(1, #Config.Missions[mission])]
        while location == currentLocation do
            location = Config.Missions[mission][math.random(1, #Config.Missions[mission])]
            Citizen.Wait(10)
        end
        currentLocation = location
        currentBlip = AddBlipForCoord(location.vehicle)
        SetBlipRoute(currentBlip, true)

        local playerPed = PlayerPedId()
        while currentBlip ~= nil do
            local wait = 1000

            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                if vehicle == currentVehicle then
                    local coords = GetEntityCoords(playerPed)
                    local distance = GetDistanceBetweenCoords(coords, location.vehicle, true)

                    if distance < 20.0 then
                        if Config.Markers.Missions.Enabled then
                            wait = 5
                            DrawMarker(Config.Markers.Missions.Type, location.vehicle - vector3(0.0, 0.0, 0.95), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Markers.Missions.Scale.x, Config.Markers.Missions.Scale.y, Config.Markers.Missions.Scale.z, Config.Markers.Missions.Colour.r, Config.Markers.Missions.Colour.g, Config.Markers.Missions.Colour.b, Config.Markers.Missions.Colour.a, false, false, 2, Config.Markers.Missions.Rotate, nil, nil, false)
                        end

                        if distance < Config.Markers.Missions.Scale.x then
                            StartWalking(location.walk, mission)
                            break
                        end
                    end
                else
                    exports.pNotify:SendNotification({
                        text = "Go back to your vehicle!", 
                        type = "error", 
                        timeout = math.random(2500, 3000), 
                        layout = "centerLeft", 
                        queue = "left"
                    })
                    wait = 10000
                end
            else
                exports.pNotify:SendNotification({
                    text = "Go back to your vehicle!", 
                    type = "success", 
                    timeout = math.random(2500, 3000), 
                    layout = "centerLeft", 
                    queue = "left"
                })
                wait = 10000
            end

            Citizen.Wait(wait)
        end
        RemoveBlip(currentBlip)
        currentPoint = currentPoint + 1
        StartMission(mission, currentVehicle == nil)
    elseif not cancel then
        exports.pNotify:SendNotification({
            text = "go back to warehouse to get payed!", 
            type = "success", 
            timeout = math.random(2500, 3000), 
            layout = "centerLeft", 
            queue = "left"
        })
        local playerPed = PlayerPedId()
        currentBlip = AddBlipForCoord(Config.MainPosition.DeleteLocation)
        SetBlipRoute(currentBlip, true)

        while true do
            local wait = 1000
            
            if IsPedInAnyVehicle(playerPed, false) then
                local vehicle = GetVehiclePedIsIn(playerPed, false)

                if vehicle == currentVehicle then
                    local coords = GetEntityCoords(playerPed)
                    local distance = GetDistanceBetweenCoords(coords, Config.MainPosition.DeleteLocation, true)
                    
                    if distance < 10.0 then
                        if Config.Markers.DeleteLocation.Enabled then
                            wait = 5
                            DrawMarker(Config.Markers.DeleteLocation.Type, Config.MainPosition.DeleteLocation - vector3(0.0, 0.0, 0.95), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Markers.DeleteLocation.Scale.x, Config.Markers.DeleteLocation.Scale.y, Config.Markers.DeleteLocation.Scale.z, Config.Markers.DeleteLocation.Colour.r, Config.Markers.DeleteLocation.Colour.g, Config.Markers.DeleteLocation.Colour.b, Config.Markers.DeleteLocation.Colour.a, false, false, 2, Config.Markers.DeleteLocation.Rotate, nil, nil, false)
                        end 

                        if distance < Config.Markers.DeleteLocation.Scale.x then
                            break
                        end
                    end
                end
            end

            Citizen.Wait(wait)
        end

        ESX.Game.DeleteVehicle(currentVehicle)
        RemoveBlip(currentBlip)
        currentLocation = 0
        currentPoint = 0
        currentVehicle = nil
        TriggerServerEvent('tinoki-deliveryjob:payoutPlayer', mission)
    else
        exports.pNotify:SendNotification({
            text = "Delivery canceled!", 
            type = "error", 
            timeout = math.random(2500, 3000), 
            layout = "centerLeft", 
            queue = "left"
        })
        ESX.Game.DeleteVehicle(currentVehicle)
        RemoveBlip(currentBlip)
        currentBlip = nil
        currentLocation = 0
        currentPoint = 0
        currentVehicle = nil
    end
end

RegisterCommand('delv', function()
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)

    local trunkPos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, "boot"))
    print(trunkPos)
end, false)

function StartWalking(location, mission)
    local playerPed = PlayerPedId()
    local vehicle = GetVehiclePedIsIn(playerPed, false)
    exports.pNotify:SendNotification({
        text = "Get out of your vehicle!", 
        type = "success", 
        timeout = math.random(2500, 3000), 
        layout = "centerLeft", 
        queue = "left"
    })
    
    RemoveBlip(currentBlip)

    currentBlip = AddBlipForCoord(location)
    SetBlipColour(blip, 3)
    SetBlipRoute(currentBlip, true)
    SetBlipRouteColour(currentBlip, 3)

    while IsPedInAnyVehicle(playerPed, false) do
        Citizen.Wait(10)
    end

    if Config.VehicleBootOffset[mission] then
        exports.pNotify:SendNotification({
            text = "Go to the trunk and take package!", 
            type = "success", 
            timeout = math.random(2500, 3000), 
            layout = "centerLeft", 
            queue = "left"
        })

        while true do
            Citizen.Wait(0)

            local coords = GetEntityCoords(playerPed)
            local trunkPos = GetWorldPositionOfEntityBone(vehicle, GetEntityBoneIndexByName(vehicle, Config.VehicleBootOffset[mission]))
            --local trunkPos = GetEntityCoords(vehicle) - Config.VehicleBootOffset[mission] + vector3(0.0, 0.0, 0.0)
            local distance = GetDistanceBetweenCoords(coords, trunkPos, true)

            if distance <= 2.0 then
                ESX.Game.Utils.DrawText3D(trunkPos, '~g~[E]~s~ take package', 0.8, 8)

                if IsControlJustPressed(1, 51) then
                    break
                end
            end
        end
    end

    exports.pNotify:SendNotification({
        text = "Go to the door and deliver the package!", 
        type = "success", 
        timeout = math.random(2500, 3000), 
        layout = "centerLeft", 
        queue = "left"
    })
    RequestAnimDict('anim@heists@box_carry@')
    while not HasAnimDictLoaded('anim@heists@box_carry@') do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, 'anim@heists@box_carry@', 'idle', 4.0, 1.0, -1, 49, 0, 0, 0, 0)
    RemoveAnimDict('anim@heists@box_carry@')

    local propHash = GetHashKey('hei_prop_heist_box')
    RequestModel(propHash)
    while not HasModelLoaded(propHash) do
        Citizen.Wait(10)
    end

    local x, y, z = table.unpack(GetEntityCoords(playerPed))
    local prop = CreateObject(propHash, x, y, z + 0.2, true, true, true)
    AttachEntityToEntity(prop, playerPed, GetPedBoneIndex(playerPed, 60309), 0.025, 0.08, 0.255, -145.0, 290.0, 0.0, true, true, false, true, 1, true)
    SetModelAsNoLongerNeeded(propHash)

    while true do
        local coords = GetEntityCoords(playerPed)

        if GetDistanceBetweenCoords(coords, location, true) <= 2.0 then
            --ESX.ShowHelpNotification('Press ~INPUT_CONTEXT~ To Drop Off ~b~The Package')
            ESX.Game.Utils.DrawText3D(location, '~g~[E]~s~ To drop off ~s~The package', 0.8, 8)

            if IsControlJustPressed(1, 51) then
                break
            end
        end

        Citizen.Wait(0)
    end

    RequestAnimDict('anim@heists@box_carry@')
    while not HasAnimDictLoaded('anim@heists@box_carry@') do
        Citizen.Wait(10)
    end
    TaskPlayAnim(playerPed, 'anim@heists@box_carry@', "exit", 8.0, 1.0, -1, 49, 0, 0, 0, 0 )
    Citizen.Wait(750)
    ClearPedSecondaryTask(playerPed)
    RemoveAnimDict('anim@heists@box_carry@')
    DeleteEntity(prop)

    exports.pNotify:SendNotification({
        text = "Go back to your vehicle!", 
        type = "success", 
        timeout = math.random(2500, 3000), 
        layout = "centerLeft", 
        queue = "left"
    })
    RemoveBlip(currentBlip)

    currentBlip = AddBlipForCoord(GetEntityCoords(vehicle))
    SetBlipColour(currentBlip, 1)
    SetBlipRoute(currentBlip, true)
    SetBlipRouteColour(currentBlip, 1)

    while not IsPedInAnyVehicle(playerPed, false) do
        Citizen.Wait(10)
    end
end

RegisterCommand('canceldelivery', function()
    StartMission(nil, true)
end, false)