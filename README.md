# Quebec - a modular Roblox game framework

> **⚠️ Note:** Quebec hasn’t been battle-tested in production games yet - it’s still fresh.
> We'd love your feedback! If you run into any issues or have suggestions, please open an issue.
> The goal is to build something truly great, together.

**Quebec** is a modular framework used in Roblox games. It's goal is to reduce boilerplate code and provide the developer with useful yet simple features. A simple service looks like this:

```lua
local TestService = {
    lifecycles = { "start" }
}

function TestService:start()
    print("Hello, World!")
end

return TestService
```

Or even shorter:

```lua
return {
    lifecycles = { "start" },
    start = function (_)
        print("Hello, World!")
    end
}
```

## 📚 Documentation

The documentation can be found here: https://baxoplenty.gitbook.io/quebec-docs

## 🧪 Example Setup

You can find an example setup using Rojo here: https://github.com/BaxoPlenty/quebec-rojo-setup

It contains 2 branches:

-   `multiplace` - for games having multiple places and shared code
-   `singleplace` - for games that only have one place

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

In the `init.*.lua` file, you simply load the Quebec module, and it will handle the rest:

```lua
-- init.*.lua

require("path_to_quebec")(script --[[ , table of options ]])
```

You can load the same Quebec module on both client and server. It will automatically determine the environment which it's running in.

## 📦 Modules

Modules are essentially libraries which you can use inside your singletons as a dependency. There's guides for:

-   [Adding modules to a singleton](https://baxoplenty.gitbook.io/quebec-docs/modules/requiring-modules)
-   [A list of built-in modules](https://baxoplenty.gitbook.io/quebec-docs/built-in-modules)

## ⛰️ Roadmap

Quebec is still being actively developed. You can track the development status here: https://github.com/BaxoPlenty/quebec/issues

## 🤝 Contributing

Thank you for your interest in contributing! There are many ways to contribute to this project. Get started here: [Contributing Guide](/CONTRIBUTING.md)
