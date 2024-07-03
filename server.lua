RegisterNetEvent('cc-911:Handle911Call', function(narrative, callLocation, cityName)
    local source = source
    local data = {
        narrative = narrative,
        location = callLocation,
        city = cityName,
        type = 1,
        source = "911 CALL",
        status = "RCVD",
        priority = 3
    }

    if Config.enableDispatcherCheck then
        PerformHttpRequest(Config.cadURL .. "/api/v1/emergency/get_active_dispatcher", function(err, response, headers)
            local dispatcherActive = false
            if err == 200 then
                local jsonResponse = json.decode(response)
                if jsonResponse.success and #jsonResponse.data > 0 then
                    dispatcherActive = true
                end
            end

            if dispatcherActive then
                sendToCAD(source, data)
            else
                sendToCADAndNotifyUnits(source, data)
            end
        end, 'POST', json.encode({}), {
            ["Content-Type"] = "application/json",
            ['token'] = Config.api_key
        })
    else
        sendToCADAndNotifyUnits(source, data)
    end

    local callerMessage = Config.messages.callerReceived
    if Config.enableAttachDetach then
        callerMessage = callerMessage
    end
    TriggerClientEvent('cc-911:CallResponse', source, true, callerMessage, Config.colors.callerReceived)
end)

function sendToCAD(source, data)
    PerformHttpRequest(Config.cadURL .. "/api/v1/emergency/create_call", function(err, response, headers)
        if err == 200 then
            local jsonResponse = json.decode(response)
            if jsonResponse.success and jsonResponse.data and #jsonResponse.data > 0 then
                local callID = jsonResponse.data[1].id
                data.id = callID
                print("911 Call processed successfully. Call ID: " .. callID)
            else
                print("Error processing 911 call. Response:", response)
                TriggerClientEvent('cc-911:CallResponse', source, false, Config.messages.callerError, Config.colors.callerError)
            end
        else
            print("Error processing 911 call. Error code:", err)
            TriggerClientEvent('cc-911:CallResponse', source, false, Config.messages.callerError, Config.colors.callerError)
        end
    end, 'POST', json.encode(data), {
        ["Content-Type"] = "application/json",
        ['token'] = Config.api_key
    })
end

function sendToCADAndNotifyUnits(source, data)
    PerformHttpRequest(Config.cadURL .. "/api/v1/emergency/create_call", function(err, response, headers)
        if err == 200 then
            local jsonResponse = json.decode(response)
            if jsonResponse.success and jsonResponse.data and #jsonResponse.data > 0 then
                local callID = jsonResponse.data[1].id
                data.id = callID
                print("911 Call processed successfully. Call ID: " .. callID)

                PerformHttpRequest(Config.cadURL .. "/api/v1/emergency/get_active_units", function(err, response, headers)
                    if err == 200 then
                        local jsonResponse = json.decode(response)
                        if jsonResponse.success and #jsonResponse.data > 0 then
                            local activeUnits = jsonResponse.data[1]
                            for _, unit in ipairs(activeUnits) do
                                local user_id = unit.user_id
                                local fivem_id = getPlayerByDiscordID(user_id)
                                if fivem_id then
                                    TriggerClientEvent('chat:addMessage', fivem_id, {
                                        color = Config.colors.dispatcherMessage,
                                        args = {"911 Dispatch", string.format(Config.messages.dispatcherMessage, data.narrative, data.location, data.id)}
                                    })
                                end
                            end
                        end
                    end
                end, 'POST', json.encode({}), {
                    ["Content-Type"] = "application/json",
                    ['token'] = Config.api_key
                })
            else
                print("Error processing 911 call. Response:", response)
                TriggerClientEvent('cc-911:CallResponse', source, false, Config.messages.callerError, Config.colors.callerError)
            end
        else
            print("Error processing 911 call. Error code:", err)
            TriggerClientEvent('cc-911:CallResponse', source, false, Config.messages.callerError, Config.colors.callerError)
        end
    end, 'POST', json.encode(data), {
        ["Content-Type"] = "application/json",
        ['token'] = Config.api_key
    })
end

function getPlayerByDiscordID(discordID)
    for _, playerId in ipairs(GetPlayers()) do
        for _, identifier in ipairs(GetPlayerIdentifiers(playerId)) do
            if string.find(identifier, "discord:") then
                local id = identifier:gsub("discord:", "")
                if id == tostring(discordID) then
                    return playerId
                end
            end
        end
    end
    return nil
end

function isActiveUnit(discordId, callback)
    PerformHttpRequest(Config.cadURL .. "/api/v1/emergency/get_active_units", function(err, response, headers)
        if err == 200 then
            local jsonResponse = json.decode(response)
            if jsonResponse.success and #jsonResponse.data > 0 then
                local activeUnits = jsonResponse.data[1]
                for _, unit in ipairs(activeUnits) do
                    if tostring(unit.user_id) == discordId then
                        callback(true)
                        return
                    end
                end
            end
        end
        callback(false)
    end, 'POST', json.encode({}), {
        ["Content-Type"] = "application/json",
        ['token'] = Config.api_key
    })
end

RegisterServerEvent('cc-911:attachToCall')
AddEventHandler('cc-911:attachToCall', function(callId)
    local _source = source
    print("Server event received with call ID:", callId, "and source:", _source)

    local discordId = GetDiscordId(_source)
    
    if discordId == nil then
        TriggerClientEvent('chat:addMessage', _source, { args = { '^1SYSTEM', 'Could not find your Discord ID.' } })
        print("Could not find Discord ID for player with source:", _source)
        return
    end

    isActiveUnit(discordId, function(active)
        if active then
            print("Discord ID found and active:", discordId)
            AttachToCall(callId, discordId, _source)
        else
            TriggerClientEvent('chat:addMessage', _source, { args = { '^1SYSTEM', 'You are not an active unit and cannot attach to calls.' } })
            print("Player with Discord ID", discordId, "is not an active unit.")
        end
    end)
end)

function AttachToCall(callId, discordId, playerId)
    local url = Config.cadURL .. "/api/v1/emergency/attach_unit"
    local data = {
        call_id = callId,
        user_id = discordId
    }

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            TriggerClientEvent('chat:addMessage', playerId, { args = { '^2SYSTEM', 'You have been successfully attached to the call.' } })
        else
            TriggerClientEvent('chat:addMessage', playerId, { args = { '^1SYSTEM', 'Failed to attach to the call. Please try again.' } })
        end
    end, 'POST', json.encode(data), { ["Content-Type"] = 'application/json', ["Authorization"] = "Bearer " .. Config.api_key, ['token'] = Config.api_key })
end

RegisterServerEvent('cc-911:detachFromCall')
AddEventHandler('cc-911:detachFromCall', function(callId)
    local _source = source
    print("Server event received with call ID:", callId, "and source:", _source)

    local discordId = GetDiscordId(_source)
    
    if discordId == nil then
        TriggerClientEvent('chat:addMessage', _source, { args = { '^1SYSTEM', 'Could not find your Discord ID.' } })
        print("Could not find Discord ID for player with source:", _source)
        return
    end

    isActiveUnit(discordId, function(active)
        if active then
            print("Discord ID found and active:", discordId)
            DetachFromCall(callId, discordId, _source)
        else
            TriggerClientEvent('chat:addMessage', _source, { args = { '^1SYSTEM', 'You are not an active unit and cannot detach from calls.' } })
            print("Player with Discord ID", discordId, "is not an active unit.")
        end
    end)
end)

function DetachFromCall(callId, discordId, playerId)
    local url = Config.cadURL .. "/api/v1/emergency/detach_unit"
    local data = {
        call_id = callId,
        user_id = discordId
    }

    PerformHttpRequest(url, function(statusCode, response, headers)
        if statusCode == 200 then
            TriggerClientEvent('chat:addMessage', playerId, { args = { '^2SYSTEM', 'You have been successfully detached from the call.' } })
        else
            TriggerClientEvent('chat:addMessage', playerId, { args = { '^1SYSTEM', 'Failed to detach from the call. Please try again.' } })
        end
    end, 'POST', json.encode(data), { ["Content-Type"] = 'application/json', ["Authorization"] = "Bearer " .. Config.api_key, ['token'] = Config.api_key })
end

function GetDiscordId(playerId)
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, identifier in ipairs(identifiers) do
        if string.match(identifier, "discord:") then
            return string.sub(identifier, 9)
        end
    end
    return nil
end
