Config = {}

Config.nearestPostalResourceName = "nearest-postal" -- Your Nearest Postal Name https://github.com/DevBlocky/nearest-postal

Config.cadURL = "https://community.communitycad.app" -- Your CAD URL (No trailing / at the end!)

Config.api_key = 'API_KEY' -- Your Community CAD API Key

Config.enableDispatcherCheck = true -- Enable or disable dispatcher checking

Config.enableAttachDetach = true -- Enable or disable attach and detach commands

-- Customization options
Config.messages = {
    callerReceived = "Your 911 call has been received and forwarded to the authorities.",
    callerError = "There was a problem with your 911 call. Please try again.",
    dispatcherMessage = "New 911 call received: %s at %s. Call ID: %d"
}

Config.colors = {
    callerReceived = {255, 255, 255}, -- White
    callerError = {255, 0, 0}, -- Red
    dispatcherMessage = {255, 255, 0} -- Yellow
}
