local Logger = {}

function Logger:info(where, fmt, ...)
	print("[ info @ " .. where .. " ] " .. string.format(fmt, ...))
end

function Logger:warn(where, fmt, ...)
	warn("[ warn @ " .. where .. " ] " .. string.format(fmt, ...))
end

function Logger:error(...)
	pcall(function(where, fmt, ...)
		error("[ error @ " .. where .. " ] " .. string.format(fmt, ...))
	end, ...)
end

function Logger:criticalError(where, fmt, ...)
	error("[ crit. error @ " .. where .. " ] " .. string.format(fmt, ...))
end

return Logger
