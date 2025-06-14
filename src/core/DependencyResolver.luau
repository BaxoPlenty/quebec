local root = script.Parent.Parent

local logger = require(root.internal.logger)

local resolverTypes = root.types["resolver.d"]
local quebecInstanceTypes = root.core.QuebecInstance

type DependencyResolver = resolverTypes.Resolver & {
	instance: quebecInstanceTypes.QuebecInstance,
}

local DependencyResolver: DependencyResolver = {}
DependencyResolver.__index = DependencyResolver

function DependencyResolver.new(instance: quebecInstanceTypes.QuebecInstance)
	local self = setmetatable({}, DependencyResolver) :: DependencyResolver

	self.instance = instance

	return self
end

function DependencyResolver:resolve(searchString: string): resolverTypes.ResolverResult?
	local segments = string.split(string.gsub(searchString, "@", "", 1), "/")

	if #segments < 2 then
		return logger:criticalError("DependencyResolver:resolve", "less than 2 segments detected in string %q", searchString)
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
					"DependencyResolver:resolve",
					"invalid segments. did you try to access multiple instances at once? path=%q",
					searchString
				)
			end

			local result = instance.resolver:resolve(`@{table.concat(segments, "/")}`)

			if result then
				result.instanceName = instanceName

				return result
			end
		end
	end
end

return DependencyResolver
