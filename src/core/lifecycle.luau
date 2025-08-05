local Types = require(script.Parent.Parent.types)

local function getSingletons(self: Types.InternalLifecycle)
    return self.__singletons
end

return function<T>(data: T & Types.CustomLifecycleData): T
    data.__type = "Quebec.Lifecycle"
    data.__singletons = {}

    data.getSingletons = getSingletons

    return data
end
