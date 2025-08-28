-- STATIONARY PTHT SCRIPT
-- This script plants and harvests without teleporting around the world
-- It works in a small radius around the player's current position

Settings = {
	-- [ Tile Settings ] --
	StartingPos = { 0, 192 }, -- ( x, y ) - Not used in stationary mode --
	MagBG = 284, -- ( Background ID for magplants ) --
	WorkRadius = 8, -- ( Radius in tiles around player to work in ) --
	
	-- [ Main Settings ] --
	World = "DOCS", -- ( Change this to your world name ) --
	SeedID = 15461, -- ( Seed ID to plant - 15461 is typically used ) --
	MaxTree = 100, -- ( Max trees in work area before harvesting ) --
	AmountPTHT = 50, -- ( Number of PTHT cycles to run ) --
	
	-- [ Boolean Settings ] --
	UseUws = true, -- ( true = using Ultra World Spray / false = not using ) --
	AntiLag = true,
	AntiSDB = true,
	
	-- [ Delay Settings ] --
	DelayPT = 40, -- ( Plant delay in milliseconds ) --
	DelayHT = 200, -- ( Harvest delay in milliseconds ) --
	DelayAfterPT = 2500, -- ( Delay after planting before using UWS ) --
	DelayAfterUWS = 2500, -- ( Delay after using UWS ) --
}

AddHook("OnVariant", "StationaryPTHT", function(var)
	if var[0] == "OnTalkBubble" then
		if var[2]:find("The MAGPLANT 5000 is empty") then
			chgremote = true
		end
	end
	if var[0] == "OnSDBroadcast" then
		if Settings.AntiSDB then
			return true
		end
	end
	if var[0] == "OnConsoleMessage" and var[1]:find("Where would you like to go") then
		return true
	end
	if var[0] == "OnConsoleMessage" and var[1]:find("Disconnected?! Will attempt to reconnect...") then
		return true
	end
	if var[0] == "OnConsoleMessage" and var[1]:find("** from") then
		return true
	end
	if var[0] == "OnConsoleMessage" and var[1]:find("Xenonite") then
		return true
	end
end)

World = Settings.World
function Log(x)
	LogToConsole("`0[`cStationary PTHT`0] "..x)
end

function Join(w)
	SendPacket(3, "action|join_request\nname|".. w .."|\ninvitedWorld|0")
end

function Raw(t, s, v, x, y)
	pkt = {
		type = t,
		state = s,
		value = v,
		px = x, 
		py = y,
		x = x * 32,
		y = y * 32
	}
	SendPacketRaw(false, pkt)
end

function punch(x, y)
	pkt = {}
	pkt.type = 3
	pkt.value = 18
	pkt.x = GetLocal().pos.x
	pkt.y = GetLocal().pos.y 
	pkt.px = math.floor(GetLocal().pos.x / 32 + x)
	pkt.py = math.floor(GetLocal().pos.y / 32 + y)
	SendPacketRaw(false, pkt)
	Sleep(40)
end

function place(id, x, y)
	pkt = {}
	pkt.type = 3
	pkt.value = id
	pkt.px = math.floor(GetLocal().pos.x / 32 + x)
	pkt.py = math.floor(GetLocal().pos.y / 32 + y)
	pkt.x = GetLocal().pos.x
	pkt.y = GetLocal().pos.y
	SendPacketRaw(false, pkt)
	Sleep(40)
end

function inv(id)
	local count = 0
	for _, item in pairs(GetInventory()) do
		if item.id == id then
			count = count + item.amount
		end
	end
	return count
end

function GetMagplant()
	local Found = {}
	for x = 0, 199, 1 do
		for y = 0, 199, 1 do
			if GetTile(x, y).fg == 5638 and GetTile(x, y).bg == Settings.MagBG then
				table.insert(Found, {x, y})
			end
		end
	end
	return Found
end

C = 1

function TakeMagplant()
	Mag = GetMagplant()
	if C >= #Mag then
		C = 1
	end
	Sleep(500)
	Raw(0, 32, 0, Mag[C][1], Mag[C][2])
	Sleep(500)
	Raw(3, 0, 32, Mag[C][1], Mag[C][2])
	Sleep(500)
	SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. Mag[C][1] .. "|\ny|".. Mag[C][2] .. "|\nbuttonClicked|getRemote")
	Sleep(500)
	getremote = false
	return
end

function GetTree()
	local Tree = 0
	-- Count trees in work radius around player (stationary)
	local playerX = math.floor(GetLocal().pos.x / 32)
	local playerY = math.floor(GetLocal().pos.y / 32)
	
	for relX = -Settings.WorkRadius, Settings.WorkRadius do
		for relY = -Settings.WorkRadius, Settings.WorkRadius do
			local x = playerX + relX
			local y = playerY + relY
			
			-- Make sure coordinates are within world bounds
			if x >= 0 and x <= 199 and y >= 0 and y <= 199 then
				if GetTile(x, y).fg == Settings.SeedID then
					Tree = Tree + 1
				end
			end
		end
	end
	return Tree
end

function GetReadyTrees()
	local readyTrees = 0
	local playerX = math.floor(GetLocal().pos.x / 32)
	local playerY = math.floor(GetLocal().pos.y / 32)
	
	for relX = -Settings.WorkRadius, Settings.WorkRadius do
		for relY = -Settings.WorkRadius, Settings.WorkRadius do
			local x = playerX + relX
			local y = playerY + relY
			
			-- Make sure coordinates are within world bounds
			if x >= 0 and x <= 199 and y >= 0 and y <= 199 then
				local tile = GetTile(x, y)
				if tile.fg == Settings.SeedID and isReady(tile) then
					readyTrees = readyTrees + 1
				end
			end
		end
	end
	return readyTrees
end

function UseUws()
	Sleep(Settings.DelayAfterPT)
	if Settings.UseUws then
		SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
		Log("Using Ultra World Spray...")
		Sleep(Settings.DelayAfterUWS)
	end
end

function isReady(tile)
	if tile and tile.extra and tile.extra.progress and tile.extra.progress == 1.0 then
		return true
	end
	return false
end

plant = true
harvest = false

function chgmode()
	if GetTree() > Settings.MaxTree then
		UseUws()
		plant = false
		harvest = true
		Log("Switching to `9Harvest `0mode")
		return
	else
		plant = true
		harvest = false
		Log("Switching to `9Plant `0mode")
		return
	end
	Tree = 0
end

function StationaryHarvest()
	local playerX = math.floor(GetLocal().pos.x / 32)
	local playerY = math.floor(GetLocal().pos.y / 32)
	local harvested = false
	
	-- Harvest in immediate area around player without moving
	-- Work in a small radius around current position
	for relX = -Settings.WorkRadius, Settings.WorkRadius do
		for relY = -Settings.WorkRadius, Settings.WorkRadius do
			if GetWorld() == nil or GetWorld().name ~= World or chgremote then
				return harvested
			end
			
			local x = playerX + relX
			local y = playerY + relY
			
			-- Make sure coordinates are within world bounds
			if x >= 0 and x <= 199 and y >= 0 and y <= 199 then
				local tile = GetTile(x, y)
				if tile.fg == Settings.SeedID and isReady(tile) then
					-- Harvest using relative coordinates (stay in place)
					punch(relX, relY)
					Sleep(Settings.DelayHT)
					harvested = true
				end
			end
		end
	end
	
	return harvested
end

function StationaryPlant()
	local playerX = math.floor(GetLocal().pos.x / 32)
	local playerY = math.floor(GetLocal().pos.y / 32)
	local planted = false
	
	-- Check if we have seeds before planting
	if inv(5640) <= 0 then
		Log("No seeds available, getting from magplant...")
		chgremote = true
		return planted
	end
	
	-- Plant in immediate area around player without moving
	-- Work in a small radius around current position
	for relX = -Settings.WorkRadius, Settings.WorkRadius do
		for relY = -Settings.WorkRadius, Settings.WorkRadius do
			if GetWorld() == nil or GetWorld().name ~= World or chgremote then
				return planted
			end
			
			local x = playerX + relX
			local y = playerY + relY
			
			-- Make sure coordinates are within world bounds
			if x >= 0 and x <= 199 and y >= 0 and y <= 199 then
				local tile = GetTile(x, y)
				local tileAbove = GetTile(x, y + 1)
				
				-- Check if we can plant here (empty tile with platform above)
				if tile.fg == 0 and tileAbove.fg ~= 0 then
					-- Plant using relative coordinates (stay in place)
					place(5640, relX, relY)
					Sleep(Settings.DelayPT)
					planted = true
					
					-- Check if we're running low on seeds
					if inv(5640) <= 5 then
						Log("Running low on seeds, will get more from magplant...")
						chgremote = true
						break
					end
				end
			end
		end
		if chgremote then break end
	end
	
	return planted
end

m = 0
function PTHT()
	local treeCount = GetTree()
	local readyCount = GetReadyTrees()
	local seedCount = inv(5640)
	
	if plant then
		Log("Currently [`9Planting`0] - Trees: " .. treeCount .. " | Seeds: " .. seedCount)
		local planted = StationaryPlant()
		if planted then
			Log("Planted seeds in stationary area")
		end
	elseif harvest then
		Log("Currently [`9Harvesting`0] - Ready trees: " .. readyCount)
		local harvested = StationaryHarvest()
		if harvested then
			Log("Harvested trees in stationary area")
		end
	end
	
	if GetWorld() == nil or GetWorld().name ~= World or chgremote then
		return
	else
		chgmode()
		m = m + 1
		
		-- Add small delay between cycles
		Sleep(1000)
	end
end

chgremote = false
getremote = true

function reConnect()
	if GetWorld() == nil or GetWorld().name ~= World then
		Join(World)
		Sleep(5000)
		getremote = true
	end
	if getremote then
		TakeMagplant()
	end
	if chgremote then
		TakeMagplant()
		C = C + 1
		chgremote = false
	end
	PTHT()
end

Log("Starting Stationary PTHT script...")
Log("Work radius: " .. Settings.WorkRadius .. " tiles around player")
Log("World: " .. Settings.World)
Log("Seed ID: " .. Settings.SeedID)
Log("Max trees before harvest: " .. Settings.MaxTree)
Log("This script stays in one place and doesn't teleport around!")

repeat
	reConnect()
	Sleep(100) -- Small delay between cycles
until m // 2 == Settings.AmountPTHT

Log("PTHT cycles completed: " .. (m // 2) .. "/" .. Settings.AmountPTHT)
Log("Script finished!")