-- Re-exported types

local Types = require(script.types)

export type CustomLifecycle<Data> = Types.CustomLifecycle<Data>

-- Main

return {
	singleton = require(script.core.singleton),
	run = require(script.core.run),
	lifecycle = require(script.core.lifecycle),

	version = require(script.version),

	modules = script.modules,

	util = {
		class = require(script.core.class),
	},
}
