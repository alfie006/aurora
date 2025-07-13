# Aurora Framework — API Guide
## What is Aurora?
Aurora is a Roblox framework designed to make your life easier by handling common tasks like server-client communication, player data saving/loading, and logging. It’s modular, meaning you can add or remove parts easily, and it automatically handles loading modules depending on whether the code is running on the server, client, or both.

## Modules Overview
#### 1. Aurora (Main Loader)
What it does:
This is the heart of the system. It loads your shared, server-only, and client-only modules and initializes them with any settings you want.

### How to use it:

```lua
local Aurora = require(ReplicatedStorage.Aurora)

local settings = {
    Logger = { debug = true },      -- Turn on debug logs
    DataService = { defaultData = { coins = 0 } },  -- Set default player data
}

Aurora:Init(settings)  -- Start everything up
```
#### 2. DataService (Player Data Management)
What it does:
Loads and saves player data automatically, keeps it cached in memory, and saves it regularly so players don’t lose progress.

Key functions:

``` Init(Aurora, defaultData) — Set up the data service with default player data. ```

```Load(player) — Load the player’s saved data. ```

```Get(player) — Get the cached data for a player.```

```Save(player) — Save a player’s data, with built-in cooldowns so you don’t overload Roblox DataStores.```

```AutoSaveAll() — Saves all player data (usually runs automatically every 5 minutes).```

Example usage:

```lua
local DataService = Aurora.Modules.DataService
local Players = game:GetService("Players")

Players.PlayerAdded:Connect(function(player)
    DataService:Load(player)  -- Load data when player joins
end)

-- Update player data example
local data = DataService:Get(player)
data.coins = (data.coins or 0) + 100  -- Give player 100 coins
DataService:Save(player)  -- Save updated data
```
#### 3. Logger (Easy Logging)
What it does:
Helps you print messages to the console with different levels like debug, info, warning, and error. You can toggle debug messages on or off.

Key functions:

```SetMinLevel(level) — Set the minimum level of logs you want to see.```

```EnableDebug(true/false) — Turn debug logging on or off.```

```Debug(message), Info(message), Warn(message), Error(message) — Different ways to log your messages.```

Example usage:

```lua
local Logger = Aurora.Modules.Logger
Logger:EnableDebug(true)  -- Turn on debug messages

Logger:Info("Game started")
Logger:Debug("Loading player stats...")
Logger:Warn("Low health warning!")
Logger:Error("Something went wrong!")
```
#### 4. Messaging (Server-Client Communication Made Simple)
What it does:
Handles all RemoteEvents and RemoteFunctions for you. Lets you easily register functions that clients or servers can call, bind event listeners, and fire events across the network.

How to use it:

```Init(Aurora) — Prepare the messaging system.```

```RegisterFunction(name, fn) — Register a function on the server that clients can call.```

```CallFunction(name, ...) — Call a registered function (on the same machine or over the network).```

```BindEvent(eventName, callback) — Listen for an event.```

```FireEvent(eventName, ...) — Send an event to everyone or the server.```

Example — Server script:

```lua
local Messaging = Aurora.Modules.Messaging

-- Register a function clients can call
Messaging:RegisterFunction("AddNumbers", function(player, a, b)
    print(player.Name, "called AddNumbers with", a, b)
    return a + b
end)

-- Listen for a shout event from clients
Messaging:BindEvent("PlayerShout", function(player, message)
    print(player.Name, "shouted:", message)
    Messaging:FireEvent("BroadcastShout", player.Name, message)
end)
```
Example — Client script:

```lua
local Messaging = Aurora.Modules.Messaging

-- Call the server function
local sum = Messaging:CallFunction("AddNumbers", 5, 10)
print("Sum from server:", sum)

-- Listen for broadcast shouts from server
Messaging:BindEvent("BroadcastShout", function(playerName, message)
    print(playerName .. " says:", message)
end)

-- Send a shout to the server
Messaging:FireEvent("PlayerShout", "Hello everyone!")
```

## Summary

This API offers:

-   Modular initialization (Aurora)
    
-   Player data management with autosave (DataService)
    
-   Flexible logging (Logger)
    
-   Server-client remote communication (Messaging)
    

Feel free to extend modules or add new ones in the `Modules` folder, Aurora has built in automatic initialization features which will run the ```Init()``` function on any module as soon as ```Aurora:Init()``` is called.
