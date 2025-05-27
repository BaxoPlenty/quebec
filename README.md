# Quebec - a modular Roblox game framework

**Quebec** is a modular framework used in Roblox games. Its goal is to boilerplate code and provide the developer with useful yet simple features. A simple service looks like this:

```lua
local TestService = {}

function TestService:OnStart()
    print("Hello, World!")
end

return TestService
```

Or even shorter:

```lua
return {
    OnStart = function (_)
        print("Hello, World!")
    end
}
```

## 📁 Project Structure

A default project would look like this:

-   server/
    -   services/
        -   service_one.lua
        -   service_two.lua
    -   init.server.lua
-   client/
    -   controllers/
        -   controller_one.lua
        -   controller_two.lua
    -   init.client.lua

In the `init.lua` file, you simply load the Quebec module, and it will handle the rest:

```lua
-- init.lua

require("path_to_quebec")(script --[[ , optional_path_to_config ]])
```

You can load the same Quebec module on both client and server. It will automatically determine the environment which it's running in.

## 📦 Dependencies

**TODO**

### ✅ Available Modules

**TODO**

### ➕ Adding Dependencies

**TODO**
