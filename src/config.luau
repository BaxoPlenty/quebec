local configurationTypes = script.Parent.types["config.d"]

local defaultConfiguration: configurationTypes.FrameworkConfiguration = {
	--[[ - START OF CONFIG - ]]

	debug = "studio",
	logNonCritical = true,

	--[[ - END OF CONFIG - ]]
}

return defaultConfiguration
