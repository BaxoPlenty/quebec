return setmetatable({
	singleton = require(script.core.singleton),
	run = require(script.core.run),
	class = require(script.core.class),

	modules = script.modules,
}, {
	__call = function(self, ...)
		return self.run(...)
	end,
})
