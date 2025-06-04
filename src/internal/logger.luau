local Logger = {
	enableDebug = game:GetService("RunService"):IsStudio(),
}

---Logs debug information to the console.
---
---Note: this only works if `self.enableDebug` is true
function Logger:debug(where, fmt, ...)
	if self.enableDebug then
		print(`[ DBG @ {where} ] {string.format(fmt, ...)}`)
	end
end

---Logs info to the console.
function Logger:info(where, fmt, ...)
	print(`[ INF @ {where} ] {string.format(fmt, ...)}`)
end

---Logs a warning to the console.
function Logger:warn(where, fmt, ...)
	warn(`[ WRN @ {where} ] {string.format(fmt, ...)}`)
end

---Logs an error without halting the execution of the current thread.
function Logger:error(where: string, fmt: string, ...)
	pcall(function(...)
		error(`[ ERR @ {where} ] {string.format(fmt, ...)}`)
	end, ...)
end

---Logs a critical error and halts the execution of the current thread.
function Logger:criticalError(where: string, fmt: string, ...)
	error(`[ CRI @ {where} ] {string.format(fmt, ...)}`)
end

return Logger
