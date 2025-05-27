local root = script.Parent.Parent

local networkingTypes = root.modules.networking

export type WithNetworking = {
	networking: networkingTypes.NetworkingDependency,
}
