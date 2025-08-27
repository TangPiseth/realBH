--[Copy world]
--[Turn on /ghost]
--[Type /copy to copy world]
--[Type /paste to paste world]
--[Type /pastex to stop paste world]
--[Type /stop to stop script]
--{Type /paste again if items not enough]
worldType = "normal" --[normal/nether/island/small]

--[Main Script]
SendVariantList({[0] = "OnDialogRequest", [1] = [[
set_default_color|`w
add_label_with_icon|small|`8BooLua Community|left|2918|
add_spacer|small|
add_label_with_icon|small|`5VIP `b- `5Free Scripts CPS|left|1368|
add_label_with_icon|small|`eGL `b- `2BotHax `b- `8GPai|left|1368|
add_label_with_icon|small|`6Report Bug Script|left|1368|
add_label_with_icon|small|`3Request Script|left|1368|
add_label_with_icon|small|`8Learn Script|left|1368|
add_spacer|small|
add_url_button||`qDiscord``|NOFLAGS|https://discord.gg/Any9dcWNwE|`$BooLua Community.|0|0|
add_smalltext|`9Need more scripts?!Join now!|
add_quick_exit|]]})
if string.lower(worldType) == "normal" then
	sizeX, sizeY = 199, 59
elseif string.lower(worldType) == "nether" then
	sizeX, sizeY = 149, 149
elseif string.lower(worldType) == "island" then
	sizeX, sizeY = 199, 199
else
	sizeX, sizeY = 29, 29
end
function cmdhook(type, str)
	if str:find("/copy") then
		copy = true
		return true
	end
	if str:find("/paste") then
		pastex = false
		paste = true
		return true
	end
	if str:find("/pastex") then
		stop = true
		return true
	end
	if str:find("/stop") then
		stop = true
		return true
	end
	return false
end
AddHook("onsendpacket", "hook", cmdhook)
function findPath(x, y)
	SendPacketRaw(false, {state = 32, x = x * 32 - 32, y = y * 32})
	Sleep(100)
end
function put(x, y, id)
	SendPacketRaw(false, {type = 3, value = id, px = x, py = y, x = x * 32, y = y * 32})
	Sleep(200)
end
tiles = {}
copy = false
paste = false
pastex = false
stop = false
while true do
	Sleep(500)
	if copy then
		for tileY = sizeY, 0, -1 do
			for tileX = 0, sizeX, 1 do
				tile = GetTile(tileX, tileY)
				if tile then
					if tile.bg > 0 and tile.fg > 0 then
						table.insert(tiles, {x = tileX, y = tileY, bg = tile.bg, fg = tile.fg})
					elseif tile.bg > 0 and tile.fg == 0 then
						table.insert(tiles, {x = tileX, y = tileY, bg = tile.bg, fg = 0})
					elseif tile.bg == 0 and tile.fg > 0 then
						table.insert(tiles, {x = tileX, y = tileY, bg = 0, fg = tile.fg})
					end
				end
			end
		end
		copy = false
		LogToConsole("copied")
	end
	Sleep(1000)
	if paste then
		for _, tile in pairs(tiles) do
			if pastex then
				break
			end
			if GetTile(tile.x, tile.y).bg ~= tile.bg or GetTile(tile.x, tile.y).fg ~= tile.fg then
				findPath(tile.x, tile.y + 1)
				if tile.bg > 0 then
					put(tile.x, tile.y, tile.bg)
				end
				if tile.fg > 0 then
					put(tile.x, tile.y, tile.fg)
				end
			end
		end
		paste = false
		LogToConsole("pasted")
	end
	Sleep(1000)
	if stop then
		break
	end
	Sleep(500)
end
RemoveHooks()
LogToConsole("DONE")
