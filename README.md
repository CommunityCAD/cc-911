# Community CAD 911 Script

911 Script for Community CAD

## Install

- Download the Latest Version
- Rename the folder to `cc-911`
- Drag Into your `resources` Folder
- Start `cc-911`

## Configuration

The resource includes one config file to get you up and running!

### `config.lua`

- `nearestPostalResourceName`: Name of your Nearest Postal Folder Name (Example: `nearest-postal`)
- `cadURL`: The URL of your CAD (Example: `https://community.communitycad.app`)
- `api_key`: Your CAD API Key 
- `enableDispatcherCheck`: Enable or disable dispatcher checking (`true` or `false`)
- `enableAttachDetach`: Enable or disable attach and detach commands (`true` or `false`)
- `messages`: Custom messages for different scenarios
  - `callerReceived`: Message sent to the caller when the call is received
  - `callerError`: Message sent to the caller if there is an error
  - `dispatcherMessage`: Message format for dispatch notifications
- `colors`: Custom colors for messages
  - `callerReceived`: Color for the caller received message (RGB format)
  - `callerError`: Color for the caller error message (RGB format)
  - `dispatcherMessage`: Color for the dispatcher message (RGB format)

## Dependencies

- [`nearest-postal`](https://github.com/DevBlocky/nearest-postal): This resource is required to obtain the nearest postal code. Ensure it is installed and running on your server for the postal code feature to function properly.

## Usage

### Reporting an Incident

To report an incident, use the `/911` command followed by a description of the incident. For example:

```
/911 There is a fire at my location
````

### Attaching to a Call

If you are an active unit, you can attach to a call using the `/attach` command followed by the call ID. For example:

```
/attach 2400025
````


### Detaching from a Call

If you are an active unit, you can detach from a call using the `/detach` command followed by the call ID. For example:

```
/detach 2400025
````

## Dispatch Checking

When `enableDispatcherCheck` is set to `true`, the script will check if a dispatcher is active before processing a 911 call. If a dispatcher is active, the call will only be sent to the CAD system. If no dispatcher is active, the call will be sent to the CAD system and also notify active units in the game.

### How it Works

1. When a 911 call is made, the script checks if dispatcher checking is enabled.
2. If enabled, it makes an API request to check for active dispatchers.
3. If a dispatcher is active, the call is sent to the CAD system.
4. If no dispatcher is active, the call is sent to the CAD system and active units are notified in the game.
5. The caller is always notified that their call has been received, regardless of the dispatcher status.

By using this feature, you can ensure that 911 calls are handled appropriately based on the availability of dispatchers.