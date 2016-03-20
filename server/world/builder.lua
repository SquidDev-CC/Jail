local config = require "shared.config"
local blocks = require "server.world.blocks"
local command = require "server.command".wrap

local kill = command "kill"
local fill = command "fill"
local tp = command "tp"
local gamemode = command "gamemode"
local title = command "title"

local width, height = config.map.width, config.map.height

local function build(map)
	local data = map.data
	for x = 1, width do
		local previous, previousRun = nil, 0
		local row = data[x]
		for z = 1, height do
			local value = row[z]

			if previous and previous ~= value then
				local block = blocks[previous]

				local startY = block.offset + config.map.bottom
				local finishY = startY + block.height - 1
				fill(x, startY, z - previousRun + 1, x, finishY, z - 1, block.block)

				previousRun = 0
				previous = nil
			end

			local block = blocks[value]
			if block.build then
				block.build(x, z)
			elseif block.block then
				previous = value
				previousRun = previousRun + 1
			end
		end

		if previous then
			local block = blocks[previous]

			local startY = block.offset + config.map.bottom
			local finishY = startY + block.height - 1
			fill(x, startY, width - previousRun + 1, x, finishY, width, block.block)

			previousRun = 0
			previous = nil
		end
	end
end

local function clear()
	kill("@e[type=!Player]")
	fill(1, config.map.bottom - 1, 1, width, config.map.bottom, height, "minecraft:quartz_block")
	fill(1, config.map.bottom + 1, 1, width, config.map.top, height, "minecraft:air")
end

local function setup(map)
	local entrance = map.entrance

	gamemode("adventure", "@a[name=!ThatVeggie]")
	tp("@a", entrance[1], config.map.bottom + 1, entrance[2])
	title("@a", "title", {text=map.title})
	title("@a", "subtitle", {text=map.subtitle})
end

return {
	build = build,
	clear = clear,
	setup = setup,
}
