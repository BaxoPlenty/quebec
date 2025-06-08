local root = script.Parent.Parent

local logger = require(root.internal.logger)

local finderTypes = root.types["finder.d"]
local quebecInstanceTypes = root.core.QuebecInstance

type DependencyFinder = finderTypes.Finder & {
	instance: quebecInstanceTypes.QuebecInstance,
}

local DependencyFinder: DependencyFinder = {}

DependencyFinder.__index = DependencyFinder

function DependencyFinder.new(instance: quebecInstanceTypes.QuebecInstance)
	local self = setmetatable({}, DependencyFinder) :: DependencyFinder

	self.instance = instance

	return self
end

function DependencyFinder:find(searchString: string): finderTypes.FinderResult?
	local segments = string.split(string.gsub(searchString, "@", "", 1), "/")

	if #segments < 2 then
		return logger:criticalError("DependencyFinder:find", "less than 2 segments detected in string %q", searchString)
	end

	if segments[1] == self.instance.singletonFolder.Name then
		return {
			pathSegments = segments,
			kind = "singleton",
		}
	elseif segments[1] == "quebec" then
		return {
			pathSegments = segments,
			kind = "module",
		}
	else
        local instanceName = segments[1]
		local instance = self.instance:waitForSharedInstance(instanceName)

		if instance then
			table.remove(segments, 1)

			if #segments > 2 then
				logger:criticalError(
					"DependencyFinder:find",
					"invalid segments. did you try to access multiple instances at once? path=%q",
					searchString
				)
			end

			local result = instance.finder:find(`@{table.concat(segments, "/")}`)

            if result then
                result.instanceName = instanceName

                return result
            end
		end
	end
end

return DependencyFinder
