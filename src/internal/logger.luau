local RunService = game:GetService("RunService")

local Levels = {
	Information = "inf",
	Debug = "dbg",
	Warning = "wrn",
	Error = "err",
	CriticalError = "cri",
}

local Platform = if RunService:IsClient() then "client" else "server"

local Logger = {
	enableDebug = RunService:IsStudio(),
	enableInfo = true,
}

function Logger.log(level: string, func, fmt: string, ...)
	func(`[ quebec {level} - {Platform} ] {string.format(fmt, ...)}`)
end

function Logger.info(fmt: string, ...)
	if not Logger.enableInfo then
		return
	end

	Logger.log(Levels.Information, print, fmt, ...)
end

function Logger.debug(fmt: string, ...)
	if not Logger.enableDebug then
		return
	end

	Logger.log(Levels.Debug, print, fmt, ...)
end

function Logger.warn(fmt: string, ...)
	Logger.log(Levels.Warning, warn, fmt, ...)
end

function Logger.error(fmt: string, ...)
	pcall(function(...)
		Logger.log(Levels.Error, error, fmt, ...)
	end, ...)
end

function Logger.critical(fmt: string, ...)
	Logger.log(Levels.CriticalError, error, fmt, ...)
end

return Logger
