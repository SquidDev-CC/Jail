local commands = commands

local function wrap(name, wrap, verbose)
	if not commands then error("No commands") verbose = true end
	if wrap or verbose then
		local func
		if not commands then
			func = print
		else
		 	func = commands[name]
		end
		return function(...)
			local success, res = func(...)
			if not success or verbose then
				print(textutils.serialize({...}))
				print(textutils.serialize(res))
			end

			return success, res
		end
	else
		return commands.async[name]
	end
end

local function many(commands)
	local ids, count = {}, 0
	for cmd, func in pairs(commands) do
		local id = commands.native.execAsync(cmd)
		ids[id] = func
		count = count + 1
	end

	while count > 0 do
		local _, id, errored, success, result = os.pullEvent("task_complete")
		local func = ids[id]
		if func then
			count = count - 1
			ids[id] = nil
			if errored then
				func(errored, success)
			else
				func(success, result)
			end
		end
	end
end

return {
	wrap = wrap,
	many = many,
}