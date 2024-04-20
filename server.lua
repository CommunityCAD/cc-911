RegisterNetEvent('cc-911:Handle911Call', function(narrative, callLocation, cityName)
    local source = source
    local data = {
        narrative = narrative,
        location = callLocation, 
        city = cityName,  
    }


    PerformHttpRequest(Config.cadURL .. "/api/v1/emergency/create_call", function(err, text, headers)
        if err == 200 then
            print("911 Call processed successfully.")  
            TriggerClientEvent('cc-911:CallResponse', source, true, "Your 911 call has been received! The authorities are on their way!")
        else
            print("Error processing 911 call. Error code:", err)
            TriggerClientEvent('cc-911:CallResponse', source, false, "There was a problem with your 911 call. Please try again.")
        end
    end, 'POST', json.encode(data), {
        ["Content-Type"] = "application/json",
        ['token'] = Config.api_key
    })
end)
