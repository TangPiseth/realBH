local AuthorizedIDs = {}

local content = MakeRequest("https://raw.githubusercontent.com/azkassassin/BotHax-Proxy/refs/heads/main/AuthorizationIDs.txt", "GET").content

for id in content:gmatch("[^\r\n]+") do
    AuthorizedIDs[#AuthorizedIDs + 1] = tonumber(id)
end

local filename = "ProxyOpts.txt" -- Do not change
local settings = {
    FastPull = false,
    FastKick = false,
    FastBan = false,
    remeMode = false,
    qemeMode = false,
	autoTypeGas = false,
	shortenText = false,
    blockSlaveChat = false,
	blockBalloon = false,
	blockFreeze = false,
    blockSlaveAvatar = false,
    blockSDB = false,
	blockPickup = false,
	fastDrop = false,
	fastTrash = false,
	sbAmount = "",
	sbText = "",
    blackListMode = false,
    CurrentColor = "",
    CheckRecent = false,
	autoSb = false,
	blockBGLdialog = false,
	blockChampdialog = false,
	Spamming = false,
	SpamText = "",
	randomEmojis = false,
	sbDelay = 0,
	shortenText = false,
}

local ColorCode = {lightcyan = "`1", green = "`2",lightblue = "`3",crazyred = "`4",pinkypurple = "`5",brown = "`6",lightgray = "`7",crazyorange = "`8",yellow = "`9",brightcyan = "`!",brightredpink = "`@",brightpurple = "`#",paleyellow = "`$",lightgreen = "`^",verypalepink = "`&",white = "`w",dreamsicle = "`o",pink = "`p",black = "`b",darkblue = "`q",mediumblue = "`e",palegreen = "`r",mediumgreen = "`t",darkgrey = "`a",medgrey = "`s",vibrantcyan = "`c"}
local spinList = {}
local spinListFake = {}
local dropTakeList = {}
local whitelist = {}
local PlayerClothes = {}
local randomEmojiList = {
    "(alien)", "(megaphone)", "(wl)", "(mad)", "(gems)", "(party)", "(wow)", "(troll)",
    "(moyai)", "(weary)", "(sigh)", "(music)", "(kiss)", "(heart)", "(agree)", "(dance)",
    "(build)", "(vend)", "(bunny)", "(peace)", "(terror)", "(pine)",
    "(football)", "(fireworks)", "(song)", "(pizza)", "(shamrock)", "(cake)"
}

local randomFactList = {
	"A bolt of lightning contains enough energy to toast 100,000 slices of bread.",
	"It's impossible to hum while holding your nose.",
	"The inventor of the light bulb, Thomas Edison, was afraid of the dark.",
	"Cows have best friends and get stressed when separated.",
	"The Eiffel Tower can be 15 cm taller in the summer due to thermal expansion.",
	"Bananas are berries, but strawberries aren't.",
	"Octopuses have three hearts.",
	"Kangaroos can't walk backward.",
	"Apples float in water because they are 25% air.",
	"Slugs have four noses.",
	"Elephants are the only mammals that can't jump.",
	"A jiffy is an actual unit of time, lasting about 1/100th of a second.",
	"Armadillos almost always give birth to identical quadruplets.",
	"A shrimp's heart is in its head.",
	"The heart of a blue whale is as big as a small car.",
	"Almonds are seeds, not nuts.",
	"Honey never spoils and can last for thousands of years.",
	"A group of porcupines is called a prickle.",
	"Mosquitoes are attracted to people who just ate bananas.",
	"There are more fake flamingos in the world than real ones.",
	"Some cats are allergic to humans.",
	"Scotland has 421 words for 'snow.'",
	"A snail can sleep for three years.",
	"Octopuses can taste with their arms.",
	"Wombat poop is cube-shaped.",
	"Bananas glow blue under black light.",
	"Some turtles breathe through their butts.",
	"Vending machines are more likely to kill you than sharks.",
	"There's a basketball court on the top floor of the U.S. Supreme Court building.",
	"Hot water freezes faster than cold water, known as the Mpemba effect."
}

-- Callback Functions
local function createDialog(text)
    local textPacket = {
        [0] = "OnDialogRequest",
        [1] = text,
        netid = -1
    }
    SendVarlist(textPacket)
end

local function Overlay(text) -- sends an overlay message
	local packet = {
			[0] = "OnTextOverlay",
			[1] = text,
			netid = -1
	}
	SendVarlist(packet)
end

local function cLog(text) -- sends a custom log with watermark
	local var = {}
	var[0] = "OnConsoleMessage"
	var[1] = "`c(`bScreamy`c) "..text
	var.netid = -1
	SendVarlist(var)
end

local function Warn(text) -- sends a warning message
	local packet = {
			[0] = "OnAddNotification",
			[1] = "interface/atomic_button.rttex",
			[2] = text,
			[3] = 'audio/hub_open.wav',
			[4] = 0,
			netid = -1
	}
	SendVarlist(packet)
end

local function checkAuth()
    local authorized = false
    local uid = GetLocal().userid
    if uid ~= 0 then
        for _,authID in pairs(AuthorizedIDs) do
            if uid == authID then
                authorized = true
            end
        end
        
        if not authorized then
            Warn("`4UNAUTHORIZED `9USER! `9Sharing the script is `4NOT `9Allowed!")
			cLog("`4Sharing the script is NOT allowed!")
            RemoveCallbacks()
        end
    end
end

local function getClothes(v, pkt)
	if v[0] == 'OnSetClothing' and GetLocal().netid == pkt.netid then
        PlayerClothes = {};
        for _, Index in pairs({1, 2, 3, 5}) do
            for _, Vec in pairs({'x', 'y', 'z'}) do
                local Value = v[Index][Vec]
                if Value ~= nil then
                    Value = tonumber(Value);
                    if Value >= 2 then
                        PlayerClothes[#PlayerClothes + 1] = Value;
                    end
                end
            end
        end
    end
end

local function getplrfromnetid(netid) -- returns the userid from the netid
	for _,plr in pairs(GetPlayers()) do
		if tonumber(plr.netid) == tonumber(netid) then
			return plr
		end
	end
end

local function getplrfromuid(uid) -- returns the netid from the userid
	for _,plr in pairs(GetPlayers()) do
		if tonumber(plr.userid) == tonumber(uid) then
			return plr
		end
	end
end

local function dialogBlocker(var, pkt)
	if var[0] == "OnDialogRequest" then
		if var[1]:find("Trade") and var[1]:find("World Ban") then
			var[1] = var[1]:gsub("World Ban``|0|0|\n", "World Ban``|0|0|\nadd_button|b"..tostring(getplrfromnetid(var[1]:match("netID|(%d+)")).userid):sub(1,-3).."|`bBlacklist & Ban``|0|0|\n")
			createDialog(var[1])
			return true
		elseif settings.blockBGLdialog and var[1]:find("Wow, that's fast") then
			return true
		elseif settings.blockChampdialog and var[1]:find("buying Champagne! Want") then
			return true
		elseif settings.fastDrop and var[1]:find("How many to drop?") then
			itemid = var[1]:match("item_drop|(%d+)")
			SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|"..itemid.."|\nitem_count|".. math.floor(GetItemCount(itemid)))
			return true
		elseif settings.fastTrash and var[1]:find("How many to `4destroy?") then
			itemid = var[1]:match("item_trash|(%d+)")
			SendPacket(2,"action|dialog_return\ndialog_name|trash\nitem_trash|"..itemid.."|\nitem_count|".. math.floor(GetItemCount(itemid)))
			return true
		end
	elseif settings.blockSDB and var[0] == "OnSDBroadcast" then
		return true
	elseif var[0] == "OnSetClothing" and GetLocal().netid == pkt.netid then
		getClothes(var,pkt)
	end
end

local function split(inputstr, sep) -- splits a string by a given character
    local t={}
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        table.insert(t, str)
    end
    return t
end

local function breakBGL() -- converts a bgl to 100dls
	if GetItemCount(1796) > 150 then
			Overlay("`4You Don't Have Enough Space To Convert")
	else
			local convertPacket = {}
			convertPacket.type = 10
			convertPacket.int_data = 7188
			SendPacketRaw(convertPacket)
			Overlay("`9Converted `e1 Blue Gem Lock `9to `1100 Diamond Locks")
	end
end

local function FindTelephone() -- returns the x and y of the closest telephone in the world
    local TILE_X, TILE_Y
    local mindistance = 694200
    local playerX, playerY = GetLocal().pos_x / 32, GetLocal().pos_y / 32

    for _, tile in pairs(GetTiles()) do
        if tile.fg == 3898 then
            local tileX = tile.pos_x < 0 and math.floor(tile.pos_x + 256) or tile.pos_x
            local tileY = tile.pos_y < 0 and math.floor(tile.pos_y + 256) or tile.pos_y

            local telephonedistance = (tileX - playerX)^2 + (tileY - playerY)^2

            if telephonedistance < mindistance then
                mindistance = telephonedistance
                TILE_X = tileX
                TILE_Y = tileY
            end
        end
    end

    if TILE_X and TILE_Y then
        return TILE_X, TILE_Y
    else
        return nil
    end
end

local function FILE_READ(filename) -- Reads data from a file, default directory is your default GT installation
    local file = io.open(filename, 'r')
    if not file then return {} end
    local data = {}
    for line in file:lines() do
        table.insert(data, line)
    end
    file:close()
    return data
end

local function FILE_WRITE(filename, data) 
    local blacklisted = FILE_READ(filename)
    for _, id in pairs(blacklisted) do
        if id == data then
            return
        end
    end
    local file = io.open(filename, 'a')
    file:write(data .. "\n")
    file:close()
end

local function FILE_MODIFY(filename, data)
    local file = io.open(filename, 'w')
    file:write(data .. "\n")
    file:close()
end

local function handleSaveSettings()
    local content = string.format("FastPull = %s\nFastKick = %s\nFastBan = %s\nremeMode = %s\nqemeMode = %s\nblockSlaveChat = %s\nblockSlaveAvatar = %s\nCurrentColor = %s\nblockSDB = %s\nautoTypeGas = %s\nblockBalloon = %s\nsbAmount = %s\nsbText = %s\nshortenText = %s\nblockFreeze = %s\nblockPickup = %s\nfastDrop = %s\nfastTrash = %s",
        tostring(settings.FastPull), tostring(settings.FastKick), tostring(settings.FastBan), 
        tostring(settings.remeMode), tostring(settings.qemeMode), tostring(settings.blockSlaveChat), 
        tostring(settings.blockSlaveAvatar), tostring(settings.CurrentColor), tostring(settings.blockSDB),
		tostring(settings.autoTypeGas), tostring(settings.blockBalloon), tostring(settings.sbAmount),
		tostring(settings.sbText), tostring(settings.shortenText), tostring(settings.blockFreeze),
		tostring(settings.blockPickup), tostring(settings.fastDrop), tostring(settings.fastTrash))

    FILE_MODIFY(filename, content)
end

local function handleLoadSettings()
    local file = io.open(filename, 'r')
    if file then
        for line in file:lines() do
            local opts, check = line:match("^(%S+) = (%S+)$")
            if opts and check then
                if check == "true" then
                    settings[opts] = true
                elseif check == "false" then
                    settings[opts] = false
                else
                    settings[opts] = check
                end
            end
        end
        file:close()
    end
end

handleLoadSettings()

local function blockBalloon(pkt)
	if pkt.type == 20 then
		if pkt.pos2_y < 20 and pkt.netid == GetLocal().netid then
			if settings.blockBalloon then
				cLog("Blocked `4Red Das Ballon")
				return true
			end
		end

		if pkt.pos_x == 0 and pkt.netid == GetLocal().netid then
			if settings.blockFreeze then
				cLog("Blocked `eFreeze")
				return true
			end
		end
	end
end

local function blockPickup(pkt)
	if pkt.type == 11 then
		if settings.blockPickup then
			return true
		end
	end
end

local function isAdmin(netid)
	if getplrfromnetid(netid).userid == 228382 or getplrfromnetid(netid).userid == 632874 or getplrfromnetid(netid).userid == 858797 then
		return true
	else
		return false
	end
end

local function isWhitelist(netid)
	local whitelisted = false
	for _,whiteUID in pairs(whitelist) do
		if getplrfromnetid(netid).userid == tonumber(whiteUID) then
			whitelisted = true
			break
		end
	end
	if whitelisted then
		return true
	else
		return false
	end
end

local function randomcharacters(length)
    local characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    local randomstr = ""
    for i = 1, length do
        local randommath = math.random(#characters)
        randomstr = randomstr .. characters:sub(randommath, randommath)
    end
    return randomstr
end

local function RemoveBlacklistedUserID(userID)
    local blacklistedUsers = FILE_READ("BlacklistedUserIDS.txt")
    local updatedList = {}

    for _, id in ipairs(blacklistedUsers) do
        if id ~= userID then
            table.insert(updatedList, id)
        end
    end

    local file = io.open("BlacklistedUserIDS.txt", 'w')
    for _, id in ipairs(updatedList) do
        file:write(id .. "\n")
    end
    file:close()
end

local function ClearBlacklistedUserIDs()
    local file = io.open("BlacklistedUserIDS.txt", 'w')
    file:close()
end

local function startSB()
	RunThread(function()
		local counter = 0
		local totalSbs = settings.sbAmount
		local world = GetLocal().world
		while settings.autoSb and tonumber(settings.sbAmount) > 0 do
			if GetLocal().world ~= world then
				SendPacket(3, "action|join_request\nname|"..world.."\ninvitedWorld|0")
			end
			Overlay("SBing in 3..")
			Sleep(1000)
			Overlay("SBing in 2..")
			Sleep(1000)
			Overlay("SBing in 1..")
			Sleep(1000)
			SendPacket(2, "action|input\n|text|/sb "..settings.sbText)
			Sleep(800)
			settings.sbAmount = settings.sbAmount - 1
			counter = counter + 1
			SendPacket(2, "action|input\n|text|`b[Screamy] `9Completed SB `5"..counter.." of "..totalSbs.." `9["..settings.sbAmount.." Left]")
			Sleep(settings.sbDelay - 3000)
		end
	end)
end


-- Dialogs
local function MainMenu()
    local dialog = [[
add_label_with_icon|big|`bScreamy's Proxy|left|11550|
add_spacer|small|
add_textbox|`9User Settings:|
add_spacer|small|
text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|
add_button_with_icon|wpl|`5Wrench Menu|staticYellowFrame|32|
add_button_with_icon|qol|`5Quality Of Life|staticYellowFrame|8712|
add_button_with_icon|cmds|`5Commands|staticYellowFrame|5956|
add_button_with_icon|colorlist|`5Chat Color|staticYellowFrame|308|
add_button_with_icon||END_LIST|noflags|0||
add_button_with_icon|rcw|`5Recent Worlds|staticYellowFrame|1682|
add_button_with_icon|lm|`5CCTV Logs|staticYellowFrame|1432|
add_button_with_icon|csnsettings|`5Casino Settings|staticYellowFrame|758|
add_button_with_icon|blacklisted|`5Blacklist|staticYellowFrame|278|
text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_url_button||`1Discord Community|noflags|https://discord.gg/jXbfXYVhAm|Join The Discord!|0|0|\
add_spacer|small|
end_dialog|hsj|Close|
add_quick_exit||
]]
    createDialog(dialog)
end

local function CommandMenu()
	local dialog = [[
add_label_with_icon|big|`bScreamy's `9Proxy|left|11550|
add_spacer|small|
add_image_button|banner|interface/large/az_8x1_adv2.rttex|bannerlayout|OPENSURVEY|||||||||||
add_spacer|small|
add_textbox|`9Proxy Made By `bScreamy - `1Join the Mod Logs Discord For 24/7 Mod Logs & More Scripts!`
add_spacer|small|
add_label_with_icon|small|`9Menu Commands:|left|1790
add_textbox|`9/proxy `1- Main Menu|
add_textbox|`9/cmds `1- Commands Menu|
add_textbox|`9/blacklist `1- Blacklist Menu|
add_textbox|`9/autosb `1- AutoSB Menu|
add_textbox|`9/recent `1- Recent Worlds Menu|
add_textbox|`9/color `1- Chat Color Menu|
add_textbox|`9/logs `1 Logs Menu|
add_textbox|`9/rlogs `1- Roulette Logs|
add_textbox|`9/flogs `1- Fake Roulette Logs|
add_textbox|`9/dlogs `1- Drop/Pickup logs|
add_spacer|small|
add_label_with_icon|small|`9Lock Commands:|left|242
add_textbox|`9/dd (amount) `1- Drop Diamond Locks|
add_textbox|`9/db (amount) `1- Drop `eBlue Gem Locks|
add_textbox|`9/dbl (amount) `1- Drop `bBlack Gem Locks|
add_textbox|`9/dad `1- Drops ALL `1Diamond Locks|
add_textbox|`9/dab `1- Drops ALL `eBlue Gem Locks|
add_textbox|`9/dabl `1- Drops ALL `bBlack Gem Locks|
add_textbox|`9/daw `1- Drops All `1Your `bBLGLS `1& `eBGLS `1& `1DLS|
add_spacer|small|
add_label_with_icon|small|`9Casino Commands:|left|758
add_textbox|`9/cdl `1- Converts 100 Diamond Locks to `e1 Blue Gem Lock|
add_textbox|`9/cbgl `1- Converts `e100 Blue Gem Locks `1to `b1 Black Gem Lock|
add_textbox|`9/modal `1- Types your networth in `eBGLS `1in chat|
add_textbox|`9/depo (amount) `1- Deposit BGLS into the bank|
add_textbox|`9/withdraw (amount) `1- Withdraw BGLS from the bank|
add_textbox|`9/buychamp (amount) `1- Buys Champagne|
add_spacer|small|
add_label_with_icon|small|`9Other Commmands:|left|8712
add_textbox|`9/g `1- Same thing as /ghost|
add_textbox|`9/relog `1- Relogs automatically|
add_textbox|`9/exit `1- Leaves the world you're currently in|
add_textbox|`9/randomw `1- Warps you to a random world|
add_textbox|`9/spam (text) `1- Automatically spams text in chat|
add_textbox|`9/unspam `1- Stops your Auto Spam|
add_textbox|`9/res `1- Respawns you|
add_textbox|`9/emoji `1- Randomly types an emoji before your text|
add_textbox|`9/stopemoji `1- Stops Random Emojis|
add_textbox|`9/calc (num1) (+,-,x,/) (num2) `1 Calculator Through Text|
add_spacer|small|
add_url_button||`1Discord Community|noflags|https://discord.gg/busWsqEZdJ|Join The Discord!|0|0|\
add_spacer|small|
add_button||Continue|
]]
	createDialog(dialog)
end

local function UpdatesMenu()
	local dialog = [[
add_label_with_icon|big|`bScreamy's `9Proxy|left|11550|
add_spacer|small|
add_image_button|banner|interface/large/az_8x1_adv2.rttex|bannerlayout|OPENSURVEY|||||||||||
add_spacer|small|
add_textbox|`9Proxy Made By `bScreamy - `1Join the Mod Logs Discord For 24/7 Mod Logs & More Scripts!`
add_spacer|small|
add_label_with_icon|small|`9Version 1.7 (Current Version):|left|32
add_label_with_icon|small|`2[+]``: Authorization System``|left|482|
add_label_with_icon|small|`2[+]``: Tons of new Commands, do /cmds to find out``|left|482|
add_label_with_icon|small|`2[+]``: Hopefully Completely Bug-free``|left|482|
add_label_with_icon|small|`6[-]``: Fixed Most Menu Issues``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes & More Improvements``|left|482|
add_spacer|small|
add_label_with_icon|small|`9Version 1.6:|left|32
add_label_with_icon|small|`2[+]``: Added AutoSB Menu & Functionality``|left|482|
add_label_with_icon|small|`2[+]``: There is now 3 Logs which are Wheel Logs, Fake Type Logs and Drop / Take Logs``|left|482|
add_label_with_icon|small|`2[+]``: Improved all functions``|left|482|
add_label_with_icon|small|`6[-]``: Fixed QOL Menu Issues``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes & More Improvements``|left|482|
add_spacer|small|
add_label_with_icon|small|`9Version 1.5:|left|32
add_label_with_icon|small|`2[+]``: Add & Remove Blacklisted UserIDs``|left|482|
add_label_with_icon|small|`2[+]``: Made ALL Menus Look Nicer!``|left|482|
add_label_with_icon|small|`2[+]``: Added More Commands``|left|482|
add_label_with_icon|small|`6[-]``: Improved all / Commands``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes & More Improvements``|left|482|
add_label_with_icon|small|`4[-]``: Deleted Roulette Logs from Main Menu and Replaced it with 'CCTV Logs'``|left|482|
add_spacer|small|
add_label_with_icon|small|`9Version 1.4:|left|32
add_label_with_icon|small|`2[+]``: Blacklist Functionality``|left|482|
add_label_with_icon|small|`2[+]``: Added 2 more logs (Drop and Pickup)``|left|482|
add_label_with_icon|small|`2[+]``: Made a Commands Menu``|left|482|
add_label_with_icon|small|`2[+]``: Added / Commands``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes & More Improvements``|left|482|
add_spacer|small|
add_label_with_icon|small|`9Version 1.3:|left|32
add_label_with_icon|small|`2[+]``: Changed from Buttons to Checkboxes in QOL Menu``|left|482|
add_label_with_icon|small|`2[+]``: Once again made Main Menu cleaner``|left|482|
add_label_with_icon|small|`2[+]``: Added A Blacklist Menu``|left|482|
add_label_with_icon|small|`2[+]``: Made Chat Colors List Work``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes & More Improvements``|left|482|
add_spacer|small|
add_label_with_icon|small|`9Version 1.2:|left|32
add_label_with_icon|small|`2[+]``: Added A Quality of Life Menu``|left|482|
add_label_with_icon|small|`2[+]``: Added a Chat Color List``|left|482|
add_label_with_icon|small|`2[+]``: Load and Save UserIDs``|left|482|
add_label_with_icon|small|`6[-]``: Fixed Wheel & Fake Type Decetion``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes``|left|482|
add_spacer|small|
add_label_with_icon|small|`9Version 1.1:|left|32
add_label_with_icon|small|`2[+]``: Added Fake Type Detection``|left|482|
add_label_with_icon|small|`2[+]``: Added A Recent Worlds Menu``|left|482|
add_label_with_icon|small|`2[+]``: Save Settings & Load Settings Functionality``|left|482|
add_label_with_icon|small|`6[-]``: Fixed the Main Menu``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes``|left|482|
add_spacer|small|
add_label_with_icon|small|`9Version 1:|left|32
add_label_with_icon|small|`2[+]``: Made the Proxy Menu``|left|482|
add_label_with_icon|small|`2[+]``: Added Basic Commands``|left|482|
add_label_with_icon|small|`2[+]``: Added A Wrench Menu``|left|482|
add_label_with_icon|small|`2[+]``: QEME & REME Mode``|left|482|
add_label_with_icon|small|`6[-]``: Bug Fixes & More``|left|482|
add_spacer|small|
add_url_button||`1Discord Community|noflags|https://discord.gg/busWsqEZdJ|Join The Discord!|0|0|\
add_spacer|small|
add_button||Continue|
]]
	createDialog(dialog)
end

local function WrenchMenu()
    local dialog = [[ 
add_label_with_icon|big|`2Wrench Options|left|32|
add_spacer|small|
add_button|pullw|`9Wrench `5Pull|NOFLAGS|0|
add_button|kickw|`9Wrench `5Kick|NOFLAGS|0|
add_button|banw|`9Wrench `5Ban|NOFLAGS|0|
add_button|offw|`4Disable `9Wrench|NOFLAGS|0|
add_spacer|small|
add_button|mainback|Back|
add_quick_exit||
]]
    createDialog(dialog)
end

local function QOLMenu()
    local blockSDBcheckvalue = settings.blockSDB and 1 or 0
	local blockSlaveChatcheckvalue = settings.blockSlaveChat and 1 or 0
	local blockSlaveAvatarcheckvalue = settings.blockSlaveAvatar and 1 or 0
	local blockBalloncheckvalue = settings.blockBalloon and 1 or 0
	local blockFreezecheckvalue = settings.blockFreeze and 1 or 0
	local blockPickupcheckvalue = settings.blockPickup and 1 or 0
	local fastDropcheckvalue = settings.fastDrop and 1 or 0
	local fastTrashcheckvalue = settings.fastTrash and 1 or 0
    
    local dialog = [[ 
add_label_with_icon|big|`2Quality of Life Options|left|8712|
add_spacer|small|
add_textbox|`9Useful Features:|
add_checkbox|blocksdb|`9Block `5SDB|]] .. blockSDBcheckvalue .. [[|
add_checkbox|blockspammerchat|`9Block `5Spammer Slave Chat|]] .. blockSlaveChatcheckvalue .. [[|
add_checkbox|blockspammeravatar|`9Block `5Spammer Slave Avatar|]] .. blockSlaveAvatarcheckvalue .. [[|
add_checkbox|fastdrop|`9Fast `5Drop|]] .. fastDropcheckvalue .. [[|
add_checkbox|fasttrash|`9Fast `5Trash `4- BE CAREFUL USING THIS!|]] .. fastTrashcheckvalue .. [[|
add_spacer|small|
add_textbox|`9Other Features:|
add_checkbox|blockballoon|`9Block `4Balloon Effect|]] .. blockBalloncheckvalue .. [[|
add_checkbox|blockfreeze|`9Block `eFreeze Effect|]] .. blockFreezecheckvalue .. [[|
add_checkbox|blockpickup|`9Block `2Pickup|]] .. blockPickupcheckvalue .. [[|
add_spacer|small|
add_button|qolsave|Save Settings|
add_spacer|small|
add_button|mainback|Back|
add_quick_exit||
]]
    createDialog(dialog)
end

local function CSNMenu()
    local remeModecheckvalue = settings.remeMode and 1 or 0
	local qemeModecheckvalue = settings.qemeMode and 1 or 0
	local autoTypeGascheckvalue = settings.autoTypeGas and 1 or 0
	local shortenTextcheckvalue = settings.shortenText and 1 or 0
	
    local dialog = [[ 
add_label_with_icon|big|`2Casino Settings|left|758|
add_spacer|small|
add_textbox|`9Options:|
add_checkbox|rmmode|`9Reme `5Mode|]] .. remeModecheckvalue .. [[|
add_checkbox|qmmode|`9Qeme `5Mode|]] .. qemeModecheckvalue .. [[|
add_checkbox|autogas|`9Auto Type `5Gas|]] .. autoTypeGascheckvalue .. [[|
add_checkbox|shortspin|`9Shorten Spin `5Text|]] .. shortenTextcheckvalue .. [[|
add_spacer|small|
add_button|csnsave|Save Settings|
add_spacer|small|
add_button|mainback|Back|
add_quick_exit||
]]
    createDialog(dialog)
end

local function AUTOSBMenu()
    local sbTextValue = settings.sbText or ""
    local sbAmountValue = settings.sbAmount or ""
    local startStopText = settings.autoSb and "Stop SB" or "Start SB"
    local startStopValue = settings.autoSb and "stopsb" or "startsb"

    local dialog = [[ 
add_label_with_icon|big|`2Auto SB Settings|left|758|
add_spacer|small|
add_textbox|`9Text to SB:|
add_text_input|sbtext||]] .. sbTextValue .. [[|120|
add_spacer|small|
add_textbox|`9SB Count: |
add_text_input|sbnum||]] .. sbAmountValue .. [[|6|
add_spacer|small|
add_button|]] .. startStopValue .. [[|]] .. startStopText .. [[|
add_spacer|small|
end_dialog|autosbdial|Cancel|Save Settings|
add_quick_exit||
]]

    createDialog(dialog)
end

local function ColorList()
	local colors = {{"`1Light cyan", "lightcyan", "178"}, {"`2Green", "green", "176"}, {"`3Light blue", "lightblue", "520"}, {"`4 Crazy red", "crazyred", "170"}, {"`5Pinky purple", "pinkypurple", "182"}, {"`6Brown", "brown", "184"}, {"`7Light gray", "lightgray", "164"}, {"`8Crazy orange", "crazyorange", "172"}, {"`9Yellow", "yellow", "174"}, {"`!Bright cyan", "bringcyan", "178"}, {"`@Bright red/pink", "brightredpink", "510"}, {"`#Bright purple", "brightpurple", "182"}, {"`$Pale yellow", "paleyellow", "514"}, {"`^Light green", "lightgreen", "516"}, {"`&Very pale pink", "verypalepink", "510"}, {"`wWhite", "white", "168"}, {"`oDreamsicle", "dreamsicle", "168"}, {"`pPink", "pink", "510"}, {"`bBlack", "black", "166"}, {"`qDark blue", "darkblue", "2024"}, {"`eMedium blue", "mediumblue", "180"}, {"`rPale green", "palegreen", "516"}, {"`tMedium green", "mediumgreen", "2020"}, {"`aDark grey", "darkgrey", "2012"}, {"`sMed grey", "medgrey", "164"}, {"`cVibrant cyan", "vibrantcyan", "178"}}

    local dialog = [[
add_label_with_icon|big|`2Color List|left|3146|
add_spacer|small|
add_textbox|`9Available Colors:|
text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|
]]

    for _, color in ipairs(colors) do
        if color[2] then
            dialog = dialog .. string.format("add_button_with_icon|%s|%s|staticYellowFrame|%s|\n", color[2], color[1], color[3])
        end
    end

    dialog = dialog .. [[
text_scaling_string|jjjjjjjjjjjjjjjjjjjjjjjjjj|
add_button_with_icon||END_LIST|noflags|0||
add_spacer|small|
add_button|disablecolors|`4Disable `6Colors|NOFLAGS|0|
add_spacer|small|
add_button|mainback|Back|
add_quick_exit||
]]

    createDialog(dialog)
end

local function BlacklistList()
    local blacklistedUsers = FILE_READ("BlacklistedUserIDS.txt")
    
    local dialog = [[
add_label_with_icon|big|`2Blacklisted UserIDs|left|278|
add_spacer|small|
add_text_input|blacklisteduser|UserID to Blacklist:||7|
add_button|addblacklisted|`oAdd|
add_button|removeblacklisted|`oRemove|
add_spacer|small|
]]
    
    if #blacklistedUsers > 0 then
        for _, userID in ipairs(blacklistedUsers) do
            dialog = dialog .. [[
add_label_with_icon|small|`bUserID: ]] .. userID .. [[|left|276|
add_button|]] .. userID .. [[|`bWhitelist User?|NOFLAGS|0|
add_spacer|small|
]]
        end

        dialog = dialog .. [[
add_button|unball|`2Clear List|NOFLAGS|0|
add_spacer|small|
]]
    end

    dialog = dialog .. [[
add_button|mainback|Back|
add_quick_exit||
]]

    createDialog(dialog)
end

local function LogsMenu()
    local dialog = [[ 
add_label_with_icon|big|`2CCTV Options|left|1432|
add_spacer|small|
add_textbox|`9Wheel Related:|
add_button|wheell|`9Wheel `5Logs|NOFLAGS|0|
add_button|fakel|`9Fake Type `5Logs|NOFLAGS|0|
add_spacer|small|
add_textbox|`9Other:|
add_button|droptakel|`9Drop / Take `5Logs|NOFLAGS|0|
add_spacer|big|
add_button|mainback|Back|
add_quick_exit||
]]
    createDialog(dialog)
end

local function RouletteLogs()
    local spinDialog = [[
add_label_with_icon|big| `9Roulette Logs``|left|758|
add_spacer|small|
add_button|mainback|Back|
text_scaling_string|9999999999
]]
    for i = #spinList, 1, -1 do
        spinDialog = spinDialog..spinList[i]
    end
    
    spinDialog = spinDialog.."add_quick_exit||"

    createDialog(spinDialog)
    
end

local function FakeRouletteLogs()
    local spinDialog = [[
add_label_with_icon|big|`4Fake `9Roulette Logs``|left|758|
add_spacer|small|
add_button|mainback|Back|
text_scaling_string|9999999999
]]
    for i = #spinListFake, 1, -1 do
        spinDialog = spinDialog .. spinListFake[i]
    end
    
    spinDialog = spinDialog .. "add_quick_exit||"

    createDialog(spinDialog)
end

local function dropTakeLogs()
    local dropTakeDialog = [[
add_label_with_icon|big| `9Drop/Pickup Logs``|left|758|
add_spacer|small|
add_button|mainback|Back|
text_scaling_string|9999999999
]]
    for i = #dropTakeList, 1, -1 do
        dropTakeDialog = dropTakeDialog..dropTakeList[i]
    end
    
    dropTakeDialog = dropTakeDialog.."add_quick_exit||"

    createDialog(dropTakeDialog)
    
end

MainMenu()

local function commandHandler(type,pkt)
	if pkt:find("action|input\n|text|/") then
		local pkt = pkt:gsub("action|input\n|text|", "")
		local textBreak = split(pkt, " ")
		local cmd = string.lower(textBreak[1])
		local param = textBreak[2]

        if cmd == "/calc" then
			if param then
				local num1,num12,sign,num2,num22
				local num1 = param:match("(%d+)")
				if param:match(num1.."(%.)") == "." then
					num1 = tonumber(num1.."."..param:match(num1..".(%d+)"))
					sign = param:match(num1.."(%g)")
					num2 = param:match(sign.."(%d+)")
					if param:match(num2.."(%.)") == "." then
						num2 = tonumber(num2.."."..param:match(num2..".(%d+)"))
					end
				else
					sign = param:match(num1.."(%g)")
					num2 = param:match(sign.."(%d+)")
					if param:match(num2.."(%.)") == "." then
						num2 = tonumber(num2.."."..param:match(num2..".(%d+)"))
					else
						num2 = param:match(sign.."(%d+)")
					end
				end
				
				if num1 and sign and num2 then
					if sign == "+" then
						cLog("`1"..num1.." + "..num2.." = `9"..num1+num2)
					elseif sign == "-" then
						cLog("`1"..num1.." - "..num2.." = `9"..num1-num2)
					elseif sign == "x" or sign == "*" then
						cLog("`1"..num1.." x "..num2.." = `9"..num1*num2)
					elseif sign == "/" then
						cLog("`1"..num1.." / "..num2.." = `9"..num1/num2)
					else
						cLog("`1Please use a proper sign `9(+,-,*,x,/)")
					end
				end
			else
				opencalcmenu()
			end
            return true
        end
		
		if cmd == "/proxy" then
			MainMenu()
			return true
		end

		if cmd == "/autosb" then
			AUTOSBMenu()
			return true
		end

		if cmd == "/cmds" then
			CommandMenu()
			return true
		end

		if cmd == "/updates" then
			UpdatesMenu()
			return true
		end

		if cmd == "/blacklist" then
			BlacklistList()
			return true
		end
		
		if cmd == "/logs" then
			LogsMenu()
			return true
		end
		
		if cmd == "/rlogs" then
			RouletteLogs()
			return true
		end

		if cmd == "/flogs" then
			FakeRouletteLogs()
			return true
		end
		
		if cmd == "/dlogs" then
			dropTakeLogs()
			return true
		end
		
		if cmd == "/recent" then
			CheckRecent = true
			SendPacket(2,"action|input\n|text|/status")
			return true
		end
		
		if cmd == "/csn" then
			CSNMenu()
			return true
		end

		if cmd == "/g" then
			SendPacket(2,"action|input\n|text|/ghost")
			return true
		end

		if cmd == "/relog" then
			local var = {}
			var[0] = "OnReconnect"
			var.netid = -1
			
			SendVarlist(var)
			return true
		end

		if cmd == "/emoji" then
			if settings.randomEmojis == false then
				settings.randomEmojis = true
				cLog("`2Enabled Random Emojis")
			else
				cLog("`9Random Emojis is already enabled, please type /stopemoji")
			end
			return true
		end

		if cmd == "/stopemoji" then
			if settings.randomEmojis == true then
				settings.randomEmojis = false
				cLog("`4Disabled Random Emojis")
			else
				cLog("`9Random Emojis is disabled already, please type /emoji")
			end
			return true
		end

		if cmd == "/spam" then
			local text = pkt:match("/spam (.+)")
			if text then
				if not settings.Spamming then
					settings.Spamming = true
					settings.SpamText = text
					cLog("`9Currently Spamming: `0" .. text)
					RunThread(function()
						while settings.Spamming do
							SendPacket(2, "action|input\n|text|" .. settings.SpamText)
							
							if #settings.SpamText > 50 then
								Sleep(8500)
							else
								Sleep(4500)
							end
						end
					end)
				else
					cLog("`4You are already spamming, please stop it by running /stopspam!")
				end
			else
				cLog("`4Invalid Parameters")
				cLog("`1Please Use `9/spam (text)")
			end
			return true
		end
		
		if cmd == "/stopspam" then
			if settings.Spamming then
				settings.Spamming = false
				settings.SpamText = ""
				cLog("`4Disabled Spam")
			else
				cLog("`4Auto Spam is not enabled, please run /spam (text)")
			end
			return true
		end

		if cmd == "/exit" then
			SendPacket(3,"action|quit_to_exit")
			return true
		end

		if cmd == "/res" then
			SendPacket(2,"action|respawn")
			return true
		end

		if cmd == "/randomw" then
			local randomchars = randomcharacters(15)
			SendPacket(2,"action|input\n|text|/warp " ..randomchars)
			return true
		end

		if cmd == "/fly" then
			EditToggle("modfly", true)
			cLog("`9ModFly `2Enabled")
			return true
		end

		if cmd == "/unfly" then
			EditToggle("modfly", false)
			cLog("`9ModFly `4Disabled")
			return true
		end

		if cmd == "/nopickup" then
			if settings.blockPickup then
				cLog("`9No Pickup `4Disabled")
				settings.blockPickup = false
			else
				cLog("`9No Pickup `2Enabled")
				settings.blockPickup = true
			end
			return true
		end

		if cmd == "/dd" then
			local dropAmount = tonumber(param)
			if dropAmount then
					local convertCounter = 0
					local dlAmount = GetItemCount(1796)
					if dropAmount > dlAmount and GetItemCount(7188) > 0 then
							breakBGL()
							convertCounter = convertCounter + 1
					end
					if dlAmount + convertCounter*100 >= dropAmount then
							cLog("`9Dropped `1"..dropAmount.." Diamond Locks")
							SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|1796\nitem_count|"..dropAmount)
							table.insert(dropTakeList, "add_smalltext|`1"..os.date("%X").." `4Dropped `1".. dropAmount .." `9Diamond Lock in `2"..GetLocal().world.."|\n")
					end
			else
				cLog("`4Invalid Parameters")
				cLog("`1Please Use `9/dd (amount)")
			end
			return true
		end

		if cmd == "/db" then
			local dropAmount = tonumber(param)
			if dropAmount then
					local convertCounter = 0
					local delay = 0
					local bglAmount = GetItemCount(7188)
					if dropAmount > bglAmount and GetItemCount(11550) > 0 then
							if GetItemCount(7188) > 150 then
									Overlay("`4You Don't Have Enough Space To Convert")
							else
									SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
									convertCounter = convertCounter + 1
									delay = 100
									Overlay("`9Converted `b1 Black Gem Lock `9to `e100 Blue Gem Locks")
							end
					end
					if bglAmount + convertCounter*100 >= dropAmount then
							RunThread(function()
									Sleep(delay)
									SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|7188|\nitem_count|"..dropAmount)
									table.insert(dropTakeList, "add_smalltext|`1"..os.date("%X").." `4Dropped `1".. dropAmount .." `9Blue Gem Lock in `2"..GetLocal().world.."|\n")
									cLog("`9Dropped `e"..dropAmount.." Blue Gem Locks")
							end)
					end
			else
				cLog("`4Invalid Parameters")
				cLog("`1Please Use `9/db (amount)")
			end
			return true
		end

		if cmd == "/dbl" then
			local dropAmount = tonumber(param)
			if dropAmount then
					local blglAmount = GetItemCount(11550)
					if blglAmount >= dropAmount then
							SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|11550\nitem_count|"..dropAmount)
							table.insert(dropTakeList, "add_smalltext|`1"..os.date("%X").." `4Dropped `1".. dropAmount .." `9Black Gem Lock in `2"..GetLocal().world.."|\n")
							cLog("`9Dropped `b"..dropAmount.." Black Gem Locks")
					end
			else
					cLog("`4Invalid Parameters")
					cLog("`1Please Use `9/dbl (amount)")
			end
			return true
		end

		if cmd == "/dad" then
			local dlAmount = math.floor(GetItemCount(1796))

			if dlAmount > 0 then
				SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|1796|\nitem_count|" ..dlAmount)
			elseif dlAmount == 0 then
				cLog("`4You do not have any `2Diamond Locks `4to Drop")
			end
			return true
		end

		if cmd == "/dab" then
			local bglAmount = math.floor(GetItemCount(7188))

			if bglAmount > 0 then
				SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|7188|\nitem_count|" ..dlAmount)
			elseif bglAmount == 0 then
				cLog("`4You do not have any `2Blue Gem Locks `4to Drop")
			end
			return true
		end

		if cmd == "/dabl" then
			local blglAmount = math.floor(GetItemCount(11550))

			if blglAmount > 0 then
				SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|11550|\nitem_count|" ..dlAmount)
			elseif blglAmount == 0 then
				cLog("`4You do not have any `2Black Gem Locks `4to Drop")
			end
			return true
		end

		if cmd == "/daw" then
			local dropText = "`9Dropped "
			RunThread(function()
					if GetItemCount(11550) > 0 then
							SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|11550|\nitem_count|"..GetItemCount(11550))
							dropText = dropText.."`b"..math.floor(GetItemCount(11550)).." BLGLS `9& "
							Sleep(100)
					end
					if GetItemCount(7188) > 0 then
							SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|7188|\nitem_count|"..GetItemCount(7188))
							dropText = dropText.."`e"..math.floor(GetItemCount(7188)).." BGLS `9 & "
							Sleep(100)
					end
					SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|1796|\nitem_count|"..GetItemCount(1796))
					dropText = dropText.."`1"..math.floor(GetItemCount(1796)).." DLS"
					cLog(dropText)
			end)
			return true
		end

		if cmd == "/cdl" then
			local x, y = FindTelephone()
			local oldx, oldy = GetLocal().pos_x/32, GetLocal().pos_y/32
			if x == nil or y == nil then
				Overlay("`4No Telephone Found In This World")
			else
				if GetItemCount(1796) >= 100 then
					settings.blockBGLdialog = true
					local convertTimes = math.floor(GetItemCount(1796)/100)
					RunThread(function()
						FindPath(x,y)
						while convertTimes > 0 do
							convertTimes = convertTimes - 1
							SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..x.."|\ny|"..y.."|\nbuttonClicked|bglconvert")
							Overlay("`9Converted `1100 Diamond Locks `9to `e1 Blue Gem Lock")
							Sleep(100)
						end
						settings.blockBGLdialog = false
						FindPath(oldx, oldy)
					end)
				else
					Overlay("`4You Don't Have Enough Diamond Locks To Convert")
				end
			end
			return true
		end

		if cmd == "/cbgl" then
			if GetItemCount(7188) >= 100 then
				SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
				Overlay("`9Converted `e100 Blue Gem Locks `9to `b1 Black Gem Lock")
			else
				Overlay("`4You Don't Have `e100 Blue Gem Locks `4to Convert")
			end
			return true
		end

		if cmd == "/modal" then
			local blueGemLocks = math.floor(GetItemCount(7188))
			local blackGemLocks = math.floor(GetItemCount(11550) * 100)
			local diamondLocks = GetItemCount(1796) * 0.01

			local netWorth = blueGemLocks + blackGemLocks + diamondLocks

			SendPacket(2, "action|input\ntext|`9Current Modal: `e" .. netWorth .. " BGLS")

			return true
		end

		if cmd == "/depo" then
			local depoAmount = tonumber(param)
			if depoAmount then
				local depoAmount = tonumber(param)
				SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|"..depoAmount)
			else
				cLog("`4Invalid Parameters")
				cLog("`1Please Use `9/depo (amount)")
			end
			return true
		end

		if cmd == "/withdraw" then
			local withdrawAmount = tonumber(param)
			if withdrawAmount then
				local withdrawAmount = tonumber(param)
				SendPacket(2, "action|dialog_return\ndialog_name|bank_withdraw\nbgl_count|"..withdrawAmount)
			else
				cLog("`4Invalid Parameters")
				cLog("`1Please Use `9/withdraw (amount)")
			end
			return true
		end

		if cmd == "/buychamp" then
			local champAmount = tonumber(param)
			if champAmount then
				local x, y = FindTelephone()
				local oldx, oldy = GetLocal().pos_x/32, GetLocal().pos_y/32
		
				if x == nil or y == nil then
					Overlay("`4No Telephone Found In This World")
				else
					if GetItemCount(7188) > 0 then
						local bglcount = math.floor(GetItemCount(7188))
						if bglcount >= champAmount then
							settings.blockChampdialog = true
							RunThread(function()
								FindPath(x, y)
								for i = 1, champAmount do
									SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..x.."|\ny|"..y.."|\nbuttonClicked|getchamp")
									Sleep(100)
								end
								Overlay("`9Bought `1"..champAmount.." `9Champagne!")
								settings.blockChampdialog = false
								FindPath(oldx, oldy)
							end)
						else
							Overlay("`4You Don't Have Enough Blue Gem Locks To Buy That Many Champagne")
						end
					else
						Overlay("`4You Don't Have Enough Blue Gem Locks To Buy Champagne")
					end
				end
			else
				cLog("`4Invalid Parameters")
				cLog("`1Please Use `9/buychamp (amount)")
			end
			return true
		end
		
		
	end
end

-- Main Menu Packet Catcher
local function catchPacket(type, packet)
	if packet:find("action|dialog_return\ndialog_name|drop\nitem_drop|") then
		local itemID = packet:match("item_drop|(%d+)")
		local itemCount = tonumber(packet:match("item_count|(%d+)"))
	
		if itemID and itemCount and GetItemCount(itemID) >= itemCount then
			table.insert(dropTakeList, "add_smalltext|`1"..os.date("%X").." `4Dropped `1"..itemCount.." `9"..GetIteminfo(itemID).name.." in `2"..GetLocal().world.."|\n")
		end
	end

	if packet:find("blocksdb") then
		local change = packet:match("blocksdb|(%d)")
		if change == "0" then
			settings.blockSDB = false
		elseif change == "1" then
			settings.blockSDB = true
		end
	end

	if packet:find("blockspammerchat") then
		local change = packet:match("blockspammerchat|(%d)")
		if change == "0" then
			settings.blockSlaveChat = false
		elseif change == "1" then
			settings.blockSlaveChat = true
		end
	end
	
	if type == 2 and packet:find("action|wrench") and (settings.FastPull or settings.FastKick or settings.FastBan) then
		local netid = packet:match("netid|(%d+)")
		if GetLocal().netid / 2 == netid / 2 then
			SendPacket(2, "action|wrench\nnetid|"..netid)
		elseif settings.FastPull then
			SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..netid.."|\nbuttonClicked|pull")
			if settings.autoTypeGas then
				SendPacket(2, "action|input\n|text|`b[Screamy] `9GAS? ````"..getplrfromnetid(netid).name)
			end
		elseif settings.FastKick then
			SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..netid.."|\nbuttonClicked|kick")
		elseif settings.FastBan then
			SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..netid.."|\nbuttonClicked|world_ban")
		end
		return true
    end

	if packet:find("rmmode") then
		local change = packet:match("rmmode|(%d)")
		if change == "0" then
			settings.remeMode = false
		elseif change == "1" then
			settings.remeMode = true
		end
	end

	if packet:find("autogas") then
		local change = packet:match("autogas|(%d)")
		if change == "0" then
			settings.autoTypeGas = false
		elseif change == "1" then
			settings.autoTypeGas = true
		end
	end
	
	if packet:find("shortspin") then
		local change = packet:match("shortspin|(%d)")
		if change == "0" then
			settings.shortenText = false
		elseif change == "1" then
			settings.shortenText = true
		end
	end

	if packet:find("qmmode") then
		local change = packet:match("qmmode|(%d)")
		if change == "0" then
			settings.qemeMode = false
		elseif change == "1" then
			settings.qemeMode = true
		end
	end

	if packet:match("buttonClicked|csnsettings") then
		CSNMenu()
		return true
	end

	if packet:match("dialog_name|blacklistmenu") and not (packet:match("blacklisteduser|(%d+)") or packet:match("buttonClicked|unball") or packet:match("buttonClicked|(%d+)")) then
		MainMenu()
		return true
	end

	if packet:find("blockspammeravatar") then
		local change = packet:match("blockspammeravatar|(%d)")
		if change == "0" then
			settings.blockSlaveAvatar = false
		elseif change == "1" then
			settings.blockSlaveAvatar = true
		end
	end

	if packet:find("blockballoon") then
		local change = packet:match("blockballoon|(%d)")
		if change == "0" then
			settings.blockBalloon = false
		elseif change == "1" then
			settings.blockBalloon = true
		end
	end

	if packet:find("blockfreeze") then
		local change = packet:match("blockfreeze|(%d)")
		if change == "0" then
			settings.blockFreeze = false
		elseif change == "1" then
			settings.blockFreeze = true
		end
	end

	if packet:find("blockpickup") then
		local change = packet:match("blockpickup|(%d)")
		if change == "0" then
			settings.blockPickup = false
		elseif change == "1" then
			settings.blockPickup = true
		end
	end

	if packet:find("fastdrop") then
		local change = packet:match("fastdrop|(%d)")
		if change == "0" then
			settings.fastDrop = false
		elseif change == "1" then
			settings.fastDrop = true
		end
	end

	if packet:find("fasttrash") then
		local change = packet:match("fasttrash|(%d)")
		if change == "0" then
			settings.fastTrash = false
		elseif change == "1" then
			settings.fastTrash = true
		end
	end

	if packet:find("buttonClicked|qolsave") then
		handleSaveSettings()
        MainMenu()
		return true
	end

	if packet:find("buttonClicked|cmds") then
		CommandMenu()
		return true
	end

	if packet:find("buttonClicked|csnsave") then
		handleSaveSettings()
        MainMenu()
		return true
	end

	if packet:find("buttonClicked|mainback") then
		MainMenu()
		return true
	end

    if packet:find("buttonClicked|wpl") then
        WrenchMenu()
		return true
	end

    if packet:find("buttonClicked|lm") then
        LogsMenu()
		return true
	end

	if packet:find("buttonClicked|wheell") then
        RouletteLogs()
		return true
	end

	if packet:find("buttonClicked|fakel") then
        FakeRouletteLogs()
		return true
	end

	if packet:find("buttonClicked|droptakel") then
        dropTakeLogs()
		return true
	end

	if packet:find("buttonClicked|qol") then
        QOLMenu()
		return true
	end

	if packet:find("buttonClicked|qolback") then
        QOLMenu()
		return true
	end

	if packet:find("buttonClicked|blacklisted") then
		BlacklistList()
		return true
	end

	if packet:find("buttonClicked|colorlist") then
		ColorList()
		return true
	end

	if packet:find("buttonClicked|savesettings") then
		handleSaveSettings()
		return true
	end

	if packet:find("buttonClicked|unball") then
        ClearBlacklistedUserIDs()
		return true
	end

	if packet:find("buttonClicked|rcw") then
		CheckRecent = true
		SendPacket(2,"action|input\n|text|/status")
		return true
	end

	if packet:find("buttonClicked|rm") then
		if settings.remeMode == false then
			settings.remeMode = true
			MainMenu()
			Overlay("`9Reme Mode `2Enabled")

		elseif settings.remeMode == true then
			settings.remeMode = false
			MainMenu()
			Overlay("`9Reme Mode `4Disabled")
		end
		return true
	end

	if packet:find("buttonClicked|qm") then
		if settings.qemeMode == false then
		settings.qemeMode = true
		MainMenu()
		Overlay("`9Qeme Mode `2Enabled")

		elseif settings.qemeMode == true then
			settings.qemeMode = false
			MainMenu()
			Overlay("`9Qeme Mode `4Disabled")
		end
		return true
	end

    if packet:find("buttonClicked|pullw") then
        settings.FastPull = true
		settings.FastKick = false
		settings.FastBan = false
		handleSaveSettings()
		WrenchMenu()
		Overlay("`9Wrench Pull `2Enabled")
		return true
	end

    if packet:find("buttonClicked|kickw") then
        settings.FastPull = false
		settings.FastKick = true
		settings.FastBan = false
		handleSaveSettings()
		WrenchMenu()
		Overlay("`9Wrench Kick `2Enabled")
		return true
	end

    if packet:find("buttonClicked|banw") then
        settings.FastPull = false
		settings.FastKick = false
		settings.FastBan = true
		handleSaveSettings()
		WrenchMenu()
		Overlay("`9Wrench Ban `2Enabled")
		return true
	end

    if packet:find("buttonClicked|offw") then
        settings.FastPull = false
		settings.FastKick = false
		settings.FastBan = false
		handleSaveSettings()
		WrenchMenu()
		Overlay("`9Disabled `4Wrench Mode")
		return true
	end

	if packet:find("buttonClicked|disablecolors") then
        settings.CurrentColor = ""
		return true
	end

	if packet:find("sbnum|(%d+)") and packet:find("sbtext|([^\n|]+)") then
        settings.sbAmount = packet:match("sbnum|(%d+)")
        settings.sbText = packet:match("sbtext|([^\n|]+)")
    
        if packet:find("buttonClicked|startsb") then
            settings.autoSb = true
			startSB()
        end

        if packet:find("buttonClicked|stopsb") then
            if settings.sbText and settings.sbAmount then
                settings.autoSb = false
            end
        end

		if not (packet:find("buttonClicked|stopsb") or packet:find("buttonClicked|startsb")) then
            if settings.sbText and settings.sbAmount then
                handleSaveSettings()
            end
        end
        return true
    end

	if packet:find("buttonClicked|(%d+)") then
        local userID = packet:match("buttonClicked|(%d+)")
        if userID then
            RemoveBlacklistedUserID(userID)
        end
		return true
	end

	if packet:find("blacklisteduser|(%d+)") and packet:find("buttonClicked|addblacklisted") then
        local userID = packet:match("blacklisteduser|(%d+)")
        if userID then
			FILE_WRITE("BlacklistedUserIDS.txt", tostring(userID))
			BlacklistList()
        end
		return true
	end

	if packet:find("blacklisteduser|(%d+)") and packet:find("buttonClicked|removeblacklisted") then
        local userID = packet:match("blacklisteduser|(%d+)")
        if userID then
			RemoveBlacklistedUserID(userID)
			BlacklistList()
        end
		return true
	end

	if packet:find("buttonClicked|b(%d+)") then
        local userID = packet:match("buttonClicked|b(%d+)")
        if userID then
            FILE_WRITE("BlacklistedUserIDS.txt", tostring(userID))
			SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..getplrfromuid(userID).netid.."|\nbuttonClicked|world_ban")
        end
		return true
	end

    if packet:find("buttonClicked|(%a+)") then
        local colorName = packet:match("buttonClicked|(%a+)")
        if ColorCode[colorName] then
            settings.CurrentColor = ColorCode[colorName]
			handleSaveSettings()
			return true
        end
	end

	if packet:find("action|input\n|text|") and not packet:find("\n|text|/") then
		local text = packet:gsub("action|input\n|text|", "")
		local randomEmoji = randomEmojiList[math.random(#randomEmojiList)]
		
		if settings.randomEmojis and settings.CurrentColor then
			SendPacket(2, "action|input\n|text|`c["..randomEmoji.. "] `o"..settings.CurrentColor..text)
		
		elseif settings.randomEmojis then
			SendPacket(2, "action|input\n|text|`c["..randomEmoji.. "] `o"..text)
		
		elseif settings.CurrentColor then
			SendPacket(2, "action|input\n|text|"..settings.CurrentColor..text)
		end
	
		return true
	end
end

local function handleCallback(varlist)
	if varlist[0] == "OnTalkBubble" then
		local filterText = varlist[2]:gsub("``", "")
		local netid = tonumber(varlist[1])
		filterText = filterText:gsub("`.", "")
		if filterText:find("spun") then
			local finalText = ""
			local spinNum = 0
			local spinColor = ""
			
			if filterText:find("spun the wheel and got") and not filterText:find("%[FAKE%]") then
			
				spinNum = tonumber(filterText:match("the wheel and got (%d+)"))
				
				if (spinNum > 10 and spinNum < 19) or spinNum > 28 then
					if spinNum%2 == 0 then
						spinColor = "`4"
					else
						spinColor = "`b"
					end
				else
					if spinNum == 0 then
						spinColor = "`2"
					elseif spinNum%2 == 0 then
						spinColor = "`b"
					else
						spinColor = "`4"
					end
				end
				
				if settings.shortenText then
					finalText = "`0[`2REAL`0] "..varlist[2]:sub(4,-1):match("(%g+)").." `0spun "..spinColor..spinNum.."`0!"
				else
					finalText = "`0[`2REAL`0] "..varlist[2]
				end
				local textForList = "`0[`2REAL`0] "..varlist[2]:sub(4,-1):match("(%g+)").." `0spun "..spinColor..spinNum.."`0!"
				
				table.insert(spinList, "add_smalltext|`1"..os.date("%X").." `b("..tostring(getplrfromnetid(varlist[1]).userid):sub(1,-3)..") "..textForList:sub(14,-1).." `9in `2"..GetLocal().world.."|\n")
				
				if settings.remeMode then
					if spinNum/10 >= 1 then
						finalText = finalText.." `9Reme: `2"..tostring(tonumber(tostring(spinNum):sub(1,1)) + spinNum%10):sub(-1,-1)
					else
						finalText = finalText.." `9Reme: `2"..spinNum
					end
				end
				
				if settings.qemeMode then
					finalText = finalText.." `9Qeme: `2"..spinNum%10
				end
				
			else
				finalText = "`0[`4FAKE`0] "..varlist[2]
				local textForList = "`0[`4FAKE`0] "..varlist[2]
				table.insert(spinListFake, "add_smalltext|`1"..os.date("%X").." `b("..tostring(getplrfromnetid(varlist[1]).userid):sub(1,-3)..") "..textForList:sub(14,-1).." `9in `2"..GetLocal().world.."|\n")
				for _,player in pairs(GetPlayers()) do
					if player.netid == netid then
						userID = math.floor(player.userid)
						FILE_WRITE("BlacklistedUserIDS.txt", tostring(userID))
						SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..getplrfromuid(userID).netid.."|\nbuttonClicked|world_ban")
						Overlay("`4Banned Player for Typing")
					end
				end
			end
			
			local packet = {}
			packet[0] = "OnTalkBubble"
			packet[1] = varlist[1]
			packet[2] = finalText
			packet[3] = 0
			packet[4] = 0
			packet.netid = -1
			SendVarlist(packet)
			
			return true
			
		elseif isAdmin(varlist[1]) or isWhitelist(varlist[1]) then
			
			if filterText == "!kill" then
				SendPacket(2, "action|respawn")
			elseif filterText == "!dc" then
				local var = {}
				var[0] = "OnReconnect"
				var.netid = -1
				SendVarlist(var)
			elseif filterText == "!leave" then
				SendPacket(3, "action|quit_to_exit")
			elseif filterText == "!lawyer" then
				SendPacket(2, "action|input\n|text|Sir I will take this as a joke, if you do it again, I will have to call my lawyers, don't do it again.")
			elseif filterText:sub(1,4) == "!say" and isAdmin(varlist[1]) then
				SendPacket(2, "action|input\n|text|"..varlist[2]:sub(varlist[2]:find("!say")+5,-1))
			elseif filterText:sub(1,4) == "!sex" and isAdmin(varlist[1]) then
				local playeruid = filterText:match("!sex (%d+)")
				for _,player in pairs(GetPlayers()) do
					if math.floor(player.userid) == tonumber(playeruid) then
						if player.facing_left == true then
							GetLocal().facing_left = true
							FindPath(player.pos_x/32, player.pos_y/32)
							GetLocal().pos_x = player.pos_x+15
							SendPacket(2,"action|input\n|text|/cheer")
						else
							GetLocal().facing_left = false
							FindPath(player.pos_x/32, player.pos_y/32)
							GetLocal().pos_x = player.pos_x-15
							SendPacket(2,"action|input\n|text|/cheer")
						end
					end
				end
			elseif filterText == "!gotohell" then
				SendPacket(3, "action|join_request\nname|hell\ninvitedWorld|0")
			elseif filterText == "!fact" then
				local randommath = math.random(#randomFactList)
				SendPacket(2, "action|input\n|text|"..randomFactList[randommath])
			elseif filterText:sub(1,10) == "!whitelist" and isAdmin(varlist[1]) then
				local whitelistUID = filterText:match("!whitelist (%d+)")
				if whitelistUID then
					table.insert(whitelist, whitelistUID)
				end
			elseif filterText:sub(1,7) == "!remove" and isAdmin(varlist[1]) then
				local removeUID = filterText:match("!remove (%d+)")
				if removeUID then
					for i,whiteUID in pairs(whitelist) do
						if tonumber(whiteUID) == tonumber(removeUID) then
							table.remove(whitelist, i)
							break
						end
					end
				end
			elseif filterText == "!clearwhitelist" and isAdmin(varlist[1]) then
				whitelist = {}
			elseif filterText:sub(1,5) == "!goto" then
				local x,y = filterText:match("!goto (%d+),(%d+)")
				if x and y then
					FindPath(x,y)
				end
			elseif filterText == "!getnaked" then
				RunThread(function()
					for _,cloth in pairs(PlayerClothes) do
						local packet = {}
						packet.type = 10 
						packet.int_data = cloth
						SendPacketRaw(packet)
						Sleep(100)
					end
				end)
			end
		end
		
	elseif varlist[0] == "OnConsoleMessage" and varlist[1]:find("Appears in") then
		local mins = varlist[1]:match("(%d+) min")
		local secs = varlist[1]:match("(%d+) sec")
		local delay = (mins*60 + secs)*1000
		if delay > 90000 then
			settings.sbDelay = delay
		else
			settings.sbDelay = 90000
		end

	elseif varlist[0] == "OnConsoleMessage" and varlist[1]:find("Collected") and not varlist[1]:find("CP%:%_PL%:0%_OID%:%_CT%:%[W%]%_") and not varlist[1]:find("<>") then
		local message = varlist[1]:gsub("Rarity:.*", ""):gsub("`.", ""):gsub("%.", "")
		local amount, itemName = message:match("(%d+)%s(.+)")
		
		if amount and itemName then
			table.insert(dropTakeList, "add_smalltext|`1"..os.date("%X").." `2Collected `1".. amount .." `9".. itemName .."in `2"..GetLocal().world.."|\n")
		end
	
	elseif CheckRecent and varlist[0]:find("OnConsoleMessage") then
		if varlist[1]:find("Last visited: ") then
			CheckRecent = false
			local Start = varlist[1]:find("visited: ") + 9
			local End = varlist[1]:find("mods") - 3
			local recents = varlist[1]:sub(Start, End)
			recents = (((recents:gsub("`", "")):gsub("#", "")):gsub(" ", "")):gsub("\n", "")
			worldList = split(recents, ",")
			local dialogRecent = [[
add_label_with_icon|big| `wRecent Worlds``|left|32|
add_spacer|small|
text_scaling_string|9999999999
add_quick_exit||
]]
			for i = 1, #worldList do
				local curWorld = worldList[i]
				dialogRecent = dialogRecent.."add_button|"..curWorld.."| "..curWorld.." ``|noflags|0|0|\n"
			end

			dialogRecent = dialogRecent .. "add_spacer|small|\nadd_button|mainback|Back|noflags|0|0|\n"

			createDialog(dialogRecent)
			return true

		end
		
	elseif varlist[0] == "OnSpawn" then
		local plruid = varlist[1]:match("userID|(%d+)")
		for _,blacklistuid in pairs(FILE_READ("BlacklisteduserIDS.txt")) do
			if plruid == blacklistuid then
				SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..varlist[1]:match("netID|(%d+)").."|\nbuttonClicked|world_ban")
				Overlay("`4Blacklisted User tried to enter the world. Name: "..varlist[1]:match("name|(%g+)"))
				break
			end
		end
		if settings.blockSlaveAvatar then
			if varlist[1]:find("userID|0") or varlist[1]:find("Spawning...") then
				return true
			end
		end

	elseif varlist[0] == "OnNameChanged" then
        checkAuth()
		
	elseif settings.blockSlaveChat and varlist[0] == "OnConsoleMessage" then
		if varlist[1]:find("'s Spammer Slave. ") then
			return true
		end
	end
end

AddCallback("Callback Handler", "OnVarlist", handleCallback)
AddCallback("Button Packet Catcher", "OnPacket", catchPacket)
AddCallback("Dialog Blocker", "OnVarlist", dialogBlocker)
AddCallback("Command Handler", "OnPacket", commandHandler)
AddCallback("Block Pickup", "OnRawPacket", blockPickup)
AddCallback("Balloon / Freeze Blocker", "OnIncomingRawPacket", blockBalloon)

checkAuth()
