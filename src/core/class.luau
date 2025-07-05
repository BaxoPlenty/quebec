--- An utility function to create lua-style classes by settings metatables.
return function<T, U...>(ctor: (U...) -> T): { new: (U...) -> T }
	local class = {}

	class.__index = class

	function class.new(...)
		local instance = ctor(...)

		return setmetatable(instance, class)
	end

	return class
end
