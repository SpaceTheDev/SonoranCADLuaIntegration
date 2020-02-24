---------------------------------------------------------------------------
-- Config Options
---------------------------------------------------------------------------
local checkTime = "1000" -- Location check time in milliseconds

---------------------------------------------------------------------------
-- Client Event Handling **DO NOT EDIT UNLESS YOU KNOW WHAT YOU ARE DOING**
---------------------------------------------------------------------------
RegisterNetEvent('cadSendPanic')
AddEventHandler('cadSendPanic', function()
    TriggerServerEvent('cadSendPanicApi', identifier)
end)

        ---------------------------------
        -- Unit Panic Command
        ---------------------------------

RegisterCommand('panic', function(source, args, rawCommand)
    TriggerServerEvent('cadSendPanicApi', identifier)
end, false)

        ---------------------------------
        -- Unit Location Update
        ---------------------------------
Citizen.CreateThread(function()
    while true do
        local pos = GetEntityCoords(PlayerPedId())
        local var1, var2 = GetStreetNameAtCoord(pos.x, pos.y, pos.z, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        -- Determine location format
        if (GetStreetNameFromHashKey(var2) == '') then
            currentLocation = GetStreetNameFromHashKey(var1)
            if (identifier ~= nil) then
                if (currentLocation ~= lastLocation) then
                    -- Updated location - Save and send to server API call queue
                    lastLocation = currentLocation
                    TriggerServerEvent('cadSendLocation', identifier, currentLocation) 
                end
            end
        else 
            currentLocation = GetStreetNameFromHashKey(var1) .. ' / ' .. GetStreetNameFromHashKey(var2)
            if (identifier ~= nil) then
                if (currentLocation ~= lastLocation) then
                    -- Updated location - Save and send to server API call queue
                    lastLocation = currentLocation
                    TriggerServerEvent('cadSendLocation', identifier, currentLocation) 
                end
            end
        end
        -- Wait (1000ms) before checking for an updated unit location
        Citizen.Wait(checkTime)
    end
end)

        ---------------------------------
        -- Steam Hex Request
        ---------------------------------
Citizen.CreateThread(function()
    while (identifier == nil) do --Teminate Thread after recieving SteamHex from Server
        if (identifier == nil) then
            -- Identifier is not yet set -> Request Steam Hex from server
            TriggerServerEvent('GetSteamHex', GetPlayerServerId(PlayerId()))
        end
        Citizen.Wait(1000)
    end
end)

-- Reciever Event to get steamHex from server
RegisterNetEvent('ReturnSteamHex')
AddEventHandler('ReturnSteamHex', function(steamHex)
    identifier = steamHex
end)

---------------------------------------------------------------------------
-- Chat Suggestions
---------------------------------------------------------------------------
TriggerEvent('chat:addSuggestion', '/panic', 'Sends a panic signal to your SonoranCAD')
TriggerEvent('chat:addSuggestion', '/911', 'Sends a emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})TriggerEvent('chat:addSuggestion', '/311', 'Sends a non-emergency call to your SonoranCAD', {
    { name="Description of Call", help="State what the call is about" }
})