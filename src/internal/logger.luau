local Levels = {
	Information = "inf",
	Debug = "dbg",
	Warning = "wrn",
	Error = "err",
	CriticalError = "cri",
}

local Platform = if game:GetService("RunService"):IsClient() then "client" else "server"

local Logger = {}

function Logger.log(level: string, func, fmt: string, ...)
	func(`[ quebec {level} - {Platform} ] {string.format(fmt, ...)}`)
end

function Logger.info(fmt: string, ...)
	return Logger.log(Levels.Information, print, fmt, ...)
end

function Logger.debug(fmt: string, ...)
	return Logger.log(Levels.Debug, print, fmt, ...)
end

function Logger.warn(fmt: string, ...)
	return Logger.log(Levels.Warning, warn, fmt, ...)
end

function Logger.error(fmt: string, ...)
	return pcall(function(...)
		Logger.log(Levels.Error, error, fmt, ...)
	end, ...)
end

function Logger.critical(fmt: string, ...)
    return Logger.log(Levels.CriticalError, error, fmt, ...)
end

return Logger
