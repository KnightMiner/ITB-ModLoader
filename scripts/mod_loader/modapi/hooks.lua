--[[
	Executes the function on the game's next update step. Only works during missions.
	
	Calling this while during game loop (either in a function called from missionUpdate,
	or as a result of previous runLater) will correctly schedule the function to be
	invoked during the next update step (not the current one).
--]]
function modApi:runLater(fn)
	assert(type(fn) == "function")

	if not self.runLaterQueue then
		self.runLaterQueue = {}
	end

	table.insert(self.runLaterQueue, fn)
end

function modApi:processRunLaterQueue(mission)
	if self.runLaterQueue then
		local err = nil
		local q = self.runLaterQueue
		local n = #q
		for i = 1, n do
			local ok, result = pcall(function()
				q[i](mission)
			end)
			q[i] = nil

			if not ok then
				err = result
				break
			end
		end

		-- compact the table, if processed hooks also scheduled
		-- their own runLater functions (but we will process those
		-- on the next update step)
		local i = n + 1
		local j = 0
		while q[i] do
			j = j + 1
			q[j] = q[i]
			q[i] = nil
			i = i + 1
		end

		if err then
			error(err)
		end
	end
end

--[[
	Registers a conditional hook which will be
	executed once the condition function associated
	with it returns true.
--]]
function modApi:conditionalHook(conditionFn, fn, removeFn)
	assert(type(conditionFn) == "function")
	assert(type(fn) == "function")

	-- Compatibility with earlier versions of this function
	if removeFn == nil then
		removeFn = function()
			return true
		end
	elseif type(removeFn) == "boolean" then
		local removeArg = removeFn
		removeFn = function()
			return removeArg
		end
	end
	assert(type(removeFn) == "function")

	table.insert(self.conditionalHooks, {
		condition = conditionFn,
		hook = fn,
		remove = removeFn
	})
end

function modApi:evaluateConditionalHooks()
	for i, tbl in ipairs(self.conditionalHooks) do
		if tbl.condition() then
			if tbl.remove() then
				table.remove(self.conditionalHooks, i)
			end
			tbl.hook()
		end
	end
end

--[[
	Schedules an argumentless function to be executed
	in msTime milliseconds.
--]]
function modApi:scheduleHook(msTime, fn)
	assert(type(msTime) == "number")
	assert(type(fn) == "function")

	table.insert(self.scheduledHooks, {
		triggerTime = self:elapsedTime() + msTime,
		hook = fn
	})

	-- sort the table according to triggerTime field, so hooks
	-- that are scheduled sooner are executed first, even if
	-- both hooks are processed during the same update step.
	table.sort(self.scheduledHooks, self.compareScheduledHooks)
end

function modApi:updateScheduledHooks()
	local t = self:elapsedTime()

	for i, tbl in ipairs(self.scheduledHooks) do
		if tbl.triggerTime <= t then
			table.remove(self.scheduledHooks, i)
			tbl.hook()
		end
	end
end

modApi.events.onGameExited:subscribe(function()
	modApi.runLaterQueue = {}
end)
