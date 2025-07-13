# Aurora Framework API Documentation

---

## Overview

Aurora is a modular Roblox framework designed for scalable server-client communication, data management, and logging. It supports server-only, client-only, and shared modules, and includes a Messaging system for RemoteEvents and RemoteFunctions.

---

## Modules

### Aurora

#### `Aurora:Init(settings)`

Initializes the Aurora framework by loading and initializing all modules in the appropriate folders based on whether the environment is server or client.

- **Parameters:**
  - `settings` *(table, optional)* — Configuration for individual modules.

---

### DataService

Handles player data loading, caching, saving, and autosaving using Roblox DataStores.

#### Methods

- **`DataService:Init(Aurora, defaultData)`**

  Initializes the DataService module.

  - `Aurora` — Reference to the Aurora framework instance.
  - `defaultData` *(table, optional)* — Default data template for new players.

- **`DataService:Load(player)`**

  Loads player data from the DataStore or returns default data if none exists.

  - `player` — The player instance whose data to load.

- **`DataService:Get(player)`**

  Returns cached data for the given player.

- **`DataService:Save(player)`**

  Saves the cached player data to the DataStore with a cooldown to prevent spamming saves.

- **`DataService:AutoSaveAll()`**

  Saves data for all cached players.

---

### Logger

Provides structured logging with log levels: DEBUG, INFO, WARN, ERROR.

#### Methods

- **`Logger:SetMinLevel(level)`**

  Sets the minimum log level to display.

- **`Logger:EnableDebug(enable)`**

  Enables or disables debug-level logging.

- **`Logger:Debug(message)`**

  Logs a debug message (shown only if debug is enabled).

- **`Logger:Info(message)`**

  Logs an informational message.

- **`Logger:Warn(message)`**

  Logs a warning message.

- **`Logger:Error(message)`**

  Logs an error message.

---

### Messaging

A robust messaging system that wraps Roblox RemoteEvents and RemoteFunctions for server-client communication.

#### Methods

- **`Messaging:Init()`**

  Initializes the messaging system.

- **`Messaging:RegisterFunction(name, fn)`**

  Registers a server function callable by clients.

  - `name` *(string)* — Function identifier.
  - `fn` *(function)* — The function to execute.

- **`Messaging:CallFunction(name, ...)`**

  Calls a registered function. If called on client, invokes the server function via RemoteFunction.

- **`Messaging:BindEvent(eventName, callback)`**

  Binds a callback to a named RemoteEvent.

- **`Messaging:FireEvent(eventName, ...)`**

  Fires a RemoteEvent to the other side (server to clients or client to server).

---

## Examples

### Initialize Aurora

```lua
local Aurora = require(game.ReplicatedStorage.Aurora)
Aurora:Init()
