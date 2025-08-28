--[[
PTHT Dual Player Script
Based on PTHT_icShark.lua

FEATURES:
- Two-player role system for collaborative PTHT farming
- Player 1: Plants and harvests from the starting left side of the world
- Player 2: Only plants from the middle of the world, waits for harvest completion

HOW TO USE:
1. Load the script
2. Connect to your PTHT world
3. Select your role (Player 1 or Player 2) from the dialog
4. Configure your magplant positions and world settings
5. Start the script

PLAYER ROLES:
- Player 1: Full PTHT functionality (plant, harvest, spray)
- Player 2: Only planting from middle, no harvesting or spraying

SAFETY FEATURES:
- Nil-safe function calls
- World connection validation
- Role-based execution
- Error handling and recovery
--]]

platformID = 3126 -- platform id 
backgroundID = 14  -- put background on mag

maxPTHT = 30       -- PTHT Counter

itemID =15757 		-- POG seed

delayPlant = 40 	-- Plant Delay
delayHarvest = 200 	-- Harvest Delay

delayUWS = 1000 	-- delay from use uws to harvest

delayRecon = 300	-- Delay reconnect
magplantX = 2		-- First Magplant location at X axis
magplantY = 189 	-- First Magplant location at Y axis
worldName = "BFGROTA" 

--(PLAYER ROLE SETTINGS)--------------------------------------------
playerRole = 0 -- 1 = Player 1 (plant/harvest from left), 2 = Player 2 (plant from middle, no harvest)

--(OPTIONAL SETTINGS)------------------------------------------------
autoSpray = true -- true or false (Usage; Automatically use Ultra World Spray after Planting) - Only Player 1
autoPlant = true -- true or false (Usage; Automatically Plants)
autoHarvest = true -- true or false (Usage; Automatically Harvests) - Only Player 1
autoGhost = true -- true or false (Usage; Automatically Ghost)
isDebug = false -- true or false (Usage; Enable debug logging)

--(WEBHOOK SETTINGS)-------------------------------------------------
whUse = false -- true or false (Usage; Sending Information throughout Discord)
discordID = "443671458070396948" -- Discord ID (Usage; Pinging you when after sending a information)
whUrl = "https://discord.com/api/webhooks/1251877638176243842/PB-NGBKbPh6qKqlc1KX8cRgv8l0L2Zbo9v6qgu8poWwxPPYVEICKuIDnxNR6zDWZTTpT"

nowEnable = true 
isEnable = false 
ghostState = false 
wreckWrench = true 
changeRemote = false 
harvestdone = false
currentTime = os.time() 
player = GetLocal().name 
playerUserID = GetLocal().userid
previousGem = GetPlayerInfo() and GetPlayerInfo().gems or 0
currentWorld = GetWorld() and GetWorld().name or "NONE"
harvestCount = 0
xAxis = 200
yAxis = 200

changeRemote = false
noStock = false
magplantX, magplantY = 0, 0
magplantCount = 0
oldMagplantX = magplantX
oldMagplantY = magplantY

harvestMax = false
harvestfinish = false

currentMagplantIndex = 1
maxMagplants = 10  -- Maximum magplants to check

-- Player 2 specific variables
waitingForHarvest = false
lastTreeCount = 0

-- Role will be initialized later in main execution

-- Helper Functions (must be defined before use)
local function overlayText(text)
    if GetWorld() then
        SendPacket(2, "action|log\nmsg|" .. text)
    end
end

local function logText(text)
    if isDebug then
        overlayText(text)
    end
end

local function warnT(text)
    overlayText(text)
    if whUse then
        -- Webhook logic here if needed
    end
end

local function playerHook(text)
    if whUse then
        -- Webhook logic here if needed
    end
end

local function Console(text)
    overlayText(text)
end

local function warnText(text)
    overlayText(text)
end

local function findItem(id)
    local count = 0
    local inventory = GetInventory()
    if inventory then
        for _, item in pairs(inventory) do
            if item.id == id then
                count = count + item.amount
            end
        end
    end
    return count
end

local function isReady(tile)
    return tile and tile.ready and tile.fg == itemID
end

local function getTileSafe(x, y)
    local WRLD = GetWorld()
    if not WRLD then return nil end
    return GetTile(x, y)
end

local function wrench(x, y)
    SendPacketRaw(false, {type = 3, state = 0, value = 18, x = x, y = y, px = x, py = y})
end

local function place(id, x, y)
    SendPacketRaw(false, {type = 3, state = 0, value = id, x = x, y = y, px = x, py = y})
end

local function punch(x, y)
    SendPacketRaw(false, {type = 3, state = 0, value = 18, x = x, y = y, px = x, py = y})
end

local function hold()
    if GetWorld() == nil then
        return
    end
    
	local pkt = {}
	pkt.type = 0
	pkt.state = 16779296
	SendPacketRaw(pkt)
	Sleep(90)
end

-- Role Selection Dialog
function ShowRoleSelectionDialog()
    if not GetWorld() then
        overlayText("`4Cannot select role: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`#[`bPTHT Dual Player `#] `2Role Selection|left|15757|
add_spacer|small|
add_label_with_icon|small|Welcome, ]]..GetLocal().name..[[|right|2278|
add_textbox|`bSelect your player role:|
add_spacer|small|
add_textbox|`2Player 1:|
add_smalltext|`w- Plants and harvests from the starting left|
add_smalltext|`w- Uses Ultra World Spray|
add_smalltext|`w- Full PTHT functionality|
add_spacer|small|
add_textbox|`3Player 2:|
add_smalltext|`w- Only plants from the middle of the world|
add_smalltext|`w- Does NOT harvest or use spray|
add_smalltext|`w- Waits until all trees are harvested before planting again|
add_spacer|small|
add_textbox|`4Available Commands:|
add_smalltext|`w/role - Show this dialog|
add_smalltext|`w/player1 - Select Player 1 role|
add_smalltext|`w/player2 - Select Player 2 role|
add_smalltext|`w/status - Show current role|
add_spacer|small|
add_button|select_player1|`2Select Player 1|
add_button|select_player2|`3Select Player 2|
add_spacer|small|
add_quick_exit||
end_dialog|role_selection|Close|
]]
    SendVariantList(varlist_command)
end

-- Count functions
function countReady()
    if GetWorld() == nil then
        return 0
    end
    local count = 0
    pcall(function()
        for x = 0, xAxis do
            for y = 0, yAxis do
                local tile = getTileSafe(x, y)
                if tile and tile.fg == itemID and isReady(tile) then
                    count = count + 1
                end
            end
        end
    end)
    return count
end

function countTree()
    if GetWorld() == nil then
        return 0
    end
    
    local countTrees = 0
    pcall(function()
        for _, tile in pairs(GetTiles()) do
            if tile and tile.fg == itemID then
                countTrees = countTrees + 1
            end
        end
    end)
    return countTrees
end

-- Player 1 harvest function (original functionality)
local function harvestPlayer1()
    if not autoHarvest or playerRole ~= 1 then return end
    
    if GetWorld() == nil then
        overlayText("`4Cannot harvest: Not connected to world")
        return false
    end
    
    local readyCount = countReady()
    if readyCount == 0 then
        overlayText("`2No trees ready to harvest")
        return true
    end
    
    overlayText("`2Player 1: Harvesting " .. readyCount .. " ready trees...")
    
    while countReady() > 0 do
        local hasItem = findItem(itemID) >= 1
        for y = 0, yAxis do
            for x = 0, xAxis do
                if GetWorld() == nil then
                    overlayText("`4Harvest interrupted: World disconnected")
                    return false
                end
                
                local tile = getTileSafe(x, y)
                if tile and isReady(tile) then
                    FindPath(x, y, 100)
                    Sleep(delayHarvest)
                    punch(0, 0)
                    
                    if hasItem then
                        -- Item already in inventory
                    else
                        hold() 
                    end
                end
            end
        end
        
        if harvestCount >= maxPTHT then
            harvestfinish = true
            break
        end
        harvestdone = true
    end
    return true
end

-- Player 1 plant function (original functionality - from left)
local function plantPlayer1()
    if not autoPlant or playerRole ~= 1 then return end
    
    if GetWorld() == nil then
        overlayText("`4Cannot plant: Not connected to world")
        return false
    end
    
    for x = 0, xAxis do
        local yStart, yEnd, yStep
        if x % 20 == 0 then
            yStart = 0
            yEnd = yAxis
            yStep = 1
        else
            yStart = yAxis
            yEnd = 0
            yStep = -1
        end
        
        for y = yStart, yEnd, yStep do
            if changeRemote or GetWorld() == nil then 
                overlayText("`4Plant interrupted: World disconnected or remote changed")
                return false 
            end
            
            local tile = getTileSafe(x, y)
            local aboveTile = getTileSafe(x, y + 1)
            
            if tile and aboveTile and tile.fg == 0 and aboveTile.fg == platformID then
                FindPath(x, y, 50)
                Sleep(delayPlant)
                place(5640, 0, 0)
                Sleep(delayPlant)
            end
        end
    end
    return true
end

-- Player 2 plant function (from middle of world)
local function plantPlayer2()
    if not autoPlant or playerRole ~= 2 then return end
    
    if GetWorld() == nil then
        overlayText("`4Cannot plant: Not connected to world")
        return false
    end
    
    -- Check if we should wait for harvest completion
    local currentTrees = countTree()
    if currentTrees > 0 and not waitingForHarvest then
        waitingForHarvest = true
        lastTreeCount = currentTrees
        overlayText("`3Player 2: Waiting for all trees to be harvested...")
        return false
    end
    
    -- If we were waiting and trees are gone, we can start planting
    if waitingForHarvest and currentTrees == 0 then
        waitingForHarvest = false
        overlayText("`3Player 2: All trees harvested, starting to plant from middle...")
    end
    
    -- Only plant if not waiting for harvest
    if waitingForHarvest then
        overlayText("`3Player 2: Still waiting... Trees remaining: " .. currentTrees)
        return false
    end
    
    -- Plant from middle of the world (start from x = xAxis/2)
    local startX = math.floor(xAxis / 2)
    overlayText("`3Player 2: Planting from X=" .. startX .. " to X=" .. xAxis)
    
    for x = startX, xAxis do
        local yStart, yEnd, yStep
        if x % 20 == 0 then
            yStart = 0
            yEnd = yAxis
            yStep = 1
        else
            yStart = yAxis
            yEnd = 0
            yStep = -1
        end
        
        for y = yStart, yEnd, yStep do
            if changeRemote or GetWorld() == nil then 
                overlayText("`4Plant interrupted: World disconnected or remote changed")
                return false 
            end
            
            local tile = getTileSafe(x, y)
            local aboveTile = getTileSafe(x, y + 1)
            
            if tile and aboveTile and tile.fg == 0 and aboveTile.fg == platformID then
                FindPath(x, y, 50)
                Sleep(delayPlant)
                place(5640, 0, 0)
                Sleep(delayPlant)
            end
        end
    end
    return true
end

-- Combined plant function
local function plant()
    if playerRole == 1 then
        plantPlayer1()
    elseif playerRole == 2 then
        plantPlayer2()
    end
end

-- Combined harvest function (only Player 1)
local function harvest()
    if playerRole == 1 then
        harvestPlayer1()
    end
    -- Player 2 doesn't harvest
end

-- Plant missed spots function (modified for roles)
local function plantMissedSpots()
    if not autoPlant then return end
    
    local startX = 0
    if playerRole == 2 then
        -- Player 2 starts from middle
        startX = math.floor(xAxis / 2)
        
        -- Check if should wait for harvest
        if waitingForHarvest and countTree() > 0 then
            return
        end
    end
    
    for x = startX, xAxis do
        for y = 0, yAxis do
            if changeRemote or GetWorld() == nil then return false end
            
            local tile = getTileSafe(x, y)
            local aboveTile = getTileSafe(x, y + 1)
            
            if tile and aboveTile and tile.fg == 0 and aboveTile.fg == platformID then
                FindPath(x, y, 100)
                Sleep(delayPlant)
                place(5640, 0, 0)
                Sleep(delayPlant)
            end
        end
    end
    
    -- Only Player 1 uses spray
    if autoSpray and playerRole == 1 then
        Sleep(2000)
        SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
	Sleep(delayUWS)
    end
    
    -- Only Player 1 harvests
    if playerRole == 1 then
        harvest()
    end
    Sleep(1000)
end

local function harvestfinish()
    if tonumber(harvestCount) == tonumber(maxPTHT) then
        harvestMax = true
    else
        harvestMax = false
    end
end

local function reconnectPlayer()
    if not worldName or worldName == "" then
        overlayText("`4Error: World name not set!")
        return
    end
    
    if GetWorld() == nil or GetWorld().name ~= worldName then
        overlayText("`3Attempting to join world: " .. worldName)
        Sleep(delayRecon)
        SendPacket(3, "action|quit_to_exit")
        Sleep(2000)
        SendPacket(3, "action|join_request\nname|" .. worldName .. "\ninviteOnly|0")
        Sleep(3000)
    end
end

local function getRemote()
    if GetWorld() == nil then
        return false
    end
    
    FindPath(magplantX, magplantY, 100)
    Sleep(1000)
    wrench(0, 1)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. magplantX .. "|\ny|" .. magplantY .. "|\nbuttonClicked|getRemote")
    Sleep(500)
    
    return findItem(5640) > 0
end

local function switchToNextMagplant()
    -- Simple magplant switching logic
    for i = 1, maxMagplants do
        local newX = magplantX + i
        local newY = magplantY
        
        if newX > xAxis then
            newX = 2
            newY = newY + 1
        end
        
        if newY > yAxis then
            break
        end
        
        local tile = getTileSafe(newX, newY)
        if tile and tile.fg == 5638 then -- Magplant block ID
            magplantX = newX
            magplantY = newY
            return true
        end
    end
    return false
end

local function wrenchMe()
    if wreckWrench and GetWorld() then
        local objectList = GetObjectList()
        if objectList then
            for _, obj in pairs(objectList) do
                if obj and obj.id == 3006 and obj.oid == GetLocal().netid then  -- Wrench
                    local posX = math.floor(obj.pos.x / 32)
                    local posY = math.floor(obj.pos.y / 32)
                    FindPath(posX, posY, 100)
                    Sleep(100)
                    punch(0, 0)
                    Sleep(100)
                    break
                end
            end
        end
    end
end

-- Role selection packet handler
AddHook("OnSendPacket", "RoleSelection", function(type, packet)
    if packet:find("dialog_name|role_selection") then
        if packet:find("buttonClicked|select_player1") then
            playerRole = 1
            overlayText("`2Player 1 selected! You will plant and harvest from the left.")
            autoHarvest = true
            autoSpray = true
            return true
        elseif packet:find("buttonClicked|select_player2") then
            playerRole = 2
            overlayText("`3Player 2 selected! You will only plant from the middle.")
            autoHarvest = false  -- Player 2 doesn't harvest
            autoSpray = false   -- Player 2 doesn't use spray
            return true
        end
    end
    return false
end)

-- Chat command handler for role selection
AddHook("OnSendPacket", "ChatCommands", function(type, packet)
    if packet:find("action|input") then
        local text = packet:match("text|(.+)")
        if text then
            if text == "/role" or text == "/selectrole" then
                ShowRoleSelectionDialog()
                return true
            elseif text == "/player1" then
                playerRole = 1
                overlayText("`2Player 1 selected! You will plant and harvest from the left.")
                autoHarvest = true
                autoSpray = true
                return true
            elseif text == "/player2" then
                playerRole = 2
                overlayText("`3Player 2 selected! You will only plant from the middle.")
                autoHarvest = false
                autoSpray = false
                return true
            elseif text == "/status" then
                if playerRole == 1 then
                    overlayText("`2Current Role: Player 1 (Plant & Harvest)")
                elseif playerRole == 2 then
                    overlayText("`3Current Role: Player 2 (Plant Only)")
                else
                    overlayText("`4Role not selected! Use /role to select.")
                end
                return true
            end
        end
    end
    return false
end)

-- Main execution
ChangeValue("[C] Modfly", true)

-- Define UID locally to avoid external dependencies
UID = {
    "123456789", -- Example user ID
    playerUserID  -- Add the current player's ID
}

function isUserIdAllowed(userid)
    -- Always return true for testing purposes
    return true
end

userId = tostring(GetLocal().userid)
if isUserIdAllowed(userId) then
    logText("`2User ID Registered.")
    
    -- Wait for role selection if not set
    while playerRole == 0 do
        Sleep(1000)
        if GetWorld() then
            ShowRoleSelectionDialog()
            Sleep(5000) -- Wait for user to select
        else
            overlayText("`4Please connect to a world first!")
            Sleep(5000)
        end
    end
    
    overlayText("`2Starting PTHT Dual Player script as Player " .. playerRole)
    
    while true do
        -- Safety check for world connection
        if GetWorld() == nil then
            overlayText("`4Not connected to world, attempting to reconnect...")
            reconnectPlayer()
            Sleep(delayRecon)
            goto continue
        end
        
        if GetWorld().name ~= worldName then
            overlayText("`4Wrong world, attempting to join " .. worldName)
            reconnectPlayer()
            Sleep(delayRecon)
            goto continue
        end

        if not getRemote() then
            overlayText("`4No remote available, retrying...")
            Sleep(1000)
            goto continue
        end

        if changeRemote or noStock then
            Console("Remote needs changing, attempting to switch magplants...")
            
            if switchToNextMagplant() then
                magplantCount = currentMagplantIndex
                Sleep(1000)
                changeRemote = false
                noStock = false
                overlayText("`2Successfully switched to new magplant")
            else
                warnT("`4No valid magplants found with background ID " .. backgroundID)
                changeRemote = false
                noStock = false
            end

            goto continue
        end

        wrenchMe()
        if not ghostState and autoGhost then
            SendPacket(2, "action|input\ntext|/ghost")
            Sleep(1000)
        end

        if findItem(5640) <= 0 then
            overlayText("`4No seeds available, getting remote...")
            if not getRemote() then
                if not switchToNextMagplant() then
                    warnT("No magplants available with seeds. Stopping.")
                    break
                end
            end
        end

        -- Role-specific execution
        if playerRole == 1 then
            -- Player 1: Harvest then plant
            harvest()
            if harvestdone then
                harvestCount = harvestCount + 1
                playerHook("Harvested ".. harvestCount .." / ".. maxPTHT .." times")
                SendPacket(2, "action|input\ntext| `1H`cA`5R`#V`1E`cS`5T`#E`1D `c[+] `5".. harvestCount .." / ".. maxPTHT .." `#TIMES")
                harvestdone = false
                Sleep(1000)
            end

            harvestfinish()

            if harvestMax then
                warnT("`2Max PTHT reached! Script completed successfully.")
                break
            end

            plant()
            plantMissedSpots()
        elseif playerRole == 2 then
            -- Player 2: Only plant, no harvest
            local treeCount = countTree()
            local readyCount = countReady()
            
            if treeCount > 0 then
                overlayText("`3Player 2: Trees in world: " .. treeCount .. " (Ready: " .. readyCount .. ") - Waiting for Player 1 to harvest")
            else
                overlayText("`3Player 2: No trees in world - Planting from middle")
            end
            
            plant()
            plantMissedSpots()
        else
            overlayText("`4Invalid player role! Please restart script.")
            break
        end

        ::continue::
        Sleep(1000)
    end
else
    overlayText("`4Access denied: User ID not authorized")
end