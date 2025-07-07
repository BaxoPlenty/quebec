--- An utility function to create lua-style classes by settings metatables.
return function<T, M, U...>(ctor: (U...) -> T, members: M): { new: (U...) -> T } & M
	local class = members

	class.__index = class

	function class.new(...)
		local instance = ctor(...)

		return setmetatable(instance, class)
	end

	return class
end
