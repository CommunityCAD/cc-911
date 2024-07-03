RegisterCommand('911', function(_, args)
    local narrative = table.concat(args, " ") or 'None'

    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId(), true))
    local streetHash = GetStreetNameAtCoord(x, y, z)
    local streetName = GetStreetNameFromHashKey(streetHash)
    local zoneName = GetNameOfZone(x, y, z)
    local cityName = GetLabelText(zoneName)

    local postal = ""
    if exports['nearest-postal'] and type(exports['nearest-postal'].getPostal) == "function" then
        postal = exports['nearest-postal']:getPostal() or ""
    end

    local callLocation = "Unknown Location"
    if postal ~= "" and streetName ~= "" then
        callLocation = postal .. "- " .. streetName
    elseif streetName ~= "" then
        callLocation = streetName
    end

    TriggerServerEvent('cc-911:Handle911Call', narrative, callLocation, cityName)
end, false)

TriggerEvent('chat:addSuggestion', '/911', 'Report an incident to emergency services.', {
    { name="description", help="Describe the incident." }
})

RegisterNetEvent('cc-911:CallResponse', function(success, message)
    TriggerEvent('chat:addMessage', {
        args = {"911 Dispatch", message}
    })
end)

RegisterCommand('attach', function(source, args, rawCommand)
    local callId = args[1]

    if callId == nil then
        TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Please provide a call ID.' } })
        print("Attach command received, but no call ID provided.")
        return
    end

    print("Attach command received with call ID:", callId)

    TriggerServerEvent('cc-911:attachToCall', callId)
end, false)

RegisterCommand('detach', function(source, args, rawCommand)
    local callId = args[1]

    if callId == nil then
        TriggerEvent('chat:addMessage', { args = { '^1SYSTEM', 'Please provide a call ID.' } })
        print("Detach command received, but no call ID provided.")
        return
    end

    print("Detach command received with call ID:", callId)

    TriggerServerEvent('cc-911:detachFromCall', callId)
end, false)
