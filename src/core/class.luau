type Constructor<T, A...> = (self: T, A...) -> ()
type Class<T, P, A...> = P & { new: (A...) -> T & P }

--- An utility function to create lua-style classes by settings metatables.
return function<T, P, A...>(constructor: Constructor<T, A...>, prototype: P?): Class<T, P, A...>
	local proto = prototype or {}
	local mt = { __index = proto }

	local function new(...: A...)
		local self = (setmetatable({}, mt) :: any) :: T

		constructor(self, ...)

		return self
	end

	(proto :: any).new = new

	return proto :: any
end
