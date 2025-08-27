--[[
PTHT ImGui - Bothax Compatible Version
Simplified custom PTHT script with ImGui interface
Optimized for Bothax compatibility and ease of use
]]--

-- Check required APIs
local hasImGui = pcall(function() return ImGui end)
local hasIO = pcall(function() return io end)
local hasMakeRequest = pcall(function() return MakeRequest end)

if not hasImGui then
    error("ImGui API required! Enable it in Bothax API settings.")
end

-- Configuration
local config = {
    -- Main settings
    world = "PTHT",
    seedID = 15461,
    magBG = 284,
    maxTrees = 17000,
    targetCycles = 50,
    
    -- Position
    startX = 0,
    startY = 192,
    
    -- Mode
    mode = "VERTICAL", -- VERTICAL or HORIZONTAL
    secondAcc = false,
    
    -- Features
    useUWS = true,
    autoGems = true,
    antiLag = true,
    
    -- Delays
    plantDelay = 15,
    harvestDelay = 200,
    uwsDelay = 3000,
    enterDelay = 5000,
    
    -- Webhook
    webhookEnabled = false,
    webhookURL = "",
    webhookInterval = 300
}

-- State variables
local state = {
    running = false,
    showGUI = true,
    currentCycle = 0,
    isPlanting = true,
    needsRemote = true,
    currentMag = 1,
    startTime = os.time(),
    lastWebhook = 0
}

-- Utility functions
local function log(msg)
    if LogToConsole then
        LogToConsole("[PTHT] " .. msg)
    end
end

local function getPlayerName()
    if GetLocal and GetLocal() then
        return GetLocal().name:gsub("`%w", ""):match("%S+") or "Unknown"
    end
    return "Unknown"
end

local function getCurrentWorld()
    if GetWorld and GetWorld() then
        return GetWorld().name
    end
    return "Unknown"
end

local function getGems()
    if GetLocal and GetLocal() then
        return GetLocal().gems or 0
    end
    return 0
end

local function countItems(id)
    if not GetInventory then return 0 end
    local count = 0
    for _, item in pairs(GetInventory()) do
        if item.id == id then
            count = count + item.amount
        end
    end
    return count
end

local function formatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    end
    return tostring(num)
end

local function formatTime(seconds)
    local h = math.floor(seconds / 3600)
    local m = math.floor((seconds % 3600) / 60)
    local s = seconds % 60
    return string.format("%02d:%02d:%02d", h, m, s)
end

-- Raw packet function
local function sendRaw(type, state_val, value, x, y)
    if SendPacketRaw then
        SendPacketRaw(false, {
            type = type,
            state = state_val,
            value = value,
            px = x,
            py = y,
            x = x * 32,
            y = y * 32
        })
    end
end

-- World functions
local function joinWorld(worldName)
    if SendPacket then
        SendPacket(3, "action|join_request\nname|" .. worldName .. "|\ninvitedWorld|0")
    end
end

local function isInCorrectWorld()
    return getCurrentWorld() == config.world
end

-- Magplant functions
local function findMagplants()
    if not GetTile then return {} end
    local magplants = {}
    for x = 0, 199 do
        for y = 0, 199 do
            local tile = GetTile(x, y)
            if tile and tile.fg == 5638 and tile.bg == config.magBG then
                table.insert(magplants, {x = x, y = y})
            end
        end
    end
    return magplants
end

local function takeRemote()
    local magplants = findMagplants()
    if #magplants == 0 then
        log("No magplants found!")
        return false
    end
    
    if state.currentMag > #magplants then
        state.currentMag = 1
    end
    
    local mag = magplants[state.currentMag]
    sendRaw(0, 32, 0, mag.x, mag.y)
    Sleep(300)
    sendRaw(3, 0, 32, mag.x, mag.y)
    Sleep(300)
    
    if SendPacket then
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. mag.x .. "|\ny|" .. mag.y .. "|\nbuttonClicked|getRemote")
    end
    Sleep(500)
    
    log("Taking remote from magplant " .. state.currentMag)
    state.needsRemote = false
    return true
end

-- Tree counting
local function countTrees()
    if not GetTile then return 0 end
    local count = 0
    for y = config.startY, 0, -1 do
        for x = config.startX, 199 do
            local tile = GetTile(x, y)
            if tile and tile.fg == config.seedID then
                count = count + 1
            end
        end
    end
    return count
end

local function countReadyTrees()
    if not GetTile then return 0 end
    local count = 0
    for y = config.startY, 0, -1 do
        for x = config.startX, 199 do
            local tile = GetTile(x, y)
            if tile and tile.fg == config.seedID and tile.extra and tile.extra.progress == 1.0 then
                count = count + 1
            end
        end
    end
    return count
end

-- UWS function
local function useUWS()
    if config.useUWS and countItems(12600) > 0 then
        log("Using Ultra World Spray...")
        if SendPacket then
            SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
        end
        Sleep(config.uwsDelay)
        return true
    end
    return false
end

-- Main farming logic
local function farmingLoop()
    if not isInCorrectWorld() then
        return
    end
    
    -- Switch modes based on tree count
    local treeCount = countTrees()
    if treeCount > config.maxTrees then
        if state.isPlanting then
            useUWS()
            state.isPlanting = false
            log("Switching to harvest mode")
        end
    elseif countReadyTrees() == 0 then
        if not state.isPlanting then
            state.isPlanting = true
            log("Switching to plant mode")
        end
    end
    
    -- Farm based on mode
    if config.mode == "VERTICAL" then
        for x = (config.secondAcc and 199 or config.startX), 
            (config.secondAcc and config.startX or 199), 
            (config.secondAcc and -10 or 10) do
            
            if not state.running then return end
            
            for y = config.startY, 0, -2 do
                if not state.running then return end
                
                local tile = GetTile and GetTile(x, y)
                if tile then
                    local shouldAct = false
                    
                    if state.isPlanting and tile.fg == 0 then
                        local belowTile = GetTile and GetTile(x, y + 1)
                        if belowTile and belowTile.fg ~= 0 then
                            shouldAct = true
                        end
                    elseif not state.isPlanting and tile.fg == config.seedID and tile.extra and tile.extra.progress == 1.0 then
                        shouldAct = true
                    end
                    
                    if shouldAct then
                        sendRaw(0, (config.secondAcc and 48 or 32), 0, x, y)
                        Sleep(30)
                        sendRaw(3, 0, (state.isPlanting and 5640 or 18), x, y)
                        Sleep(state.isPlanting and config.plantDelay or config.harvestDelay)
                    end
                end
            end
        end
    end
    
    state.currentCycle = state.currentCycle + 1
end

-- Webhook function
local function sendWebhook(message)
    if not config.webhookEnabled or config.webhookURL == "" or not hasMakeRequest then
        return
    end
    
    local now = os.time()
    if now - state.lastWebhook < config.webhookInterval then
        return
    end
    
    local data = string.format([[{
        "embeds": [{
            "title": "PTHT Script Update",
            "fields": [
                {"name": "Player", "value": "%s", "inline": true},
                {"name": "World", "value": "%s", "inline": true},
                {"name": "Cycle", "value": "%d/%d", "inline": true},
                {"name": "Status", "value": "%s", "inline": false}
            ],
            "color": %d
        }]
    }]], getPlayerName(), getCurrentWorld(), state.currentCycle, config.targetCycles, message, math.random(0, 16777215))
    
    MakeRequest(config.webhookURL, "POST", {["Content-Type"] = "application/json"}, data)
    state.lastWebhook = now
    log("Webhook sent: " .. message)
end

-- Settings save/load
local function saveSettings()
    if not hasIO then
        log("Cannot save - IO API not enabled!")
        return
    end
    
    local file = io.open("storage/emulated/0/android/media/com.rtsoft.growtopia/scripts/PTHT_SIMPLE_CONFIG.txt", "w")
    if file then
        for key, value in pairs(config) do
            file:write(key .. "=" .. tostring(value) .. "\n")
        end
        file:close()
        log("Settings saved!")
    end
end

local function loadSettings()
    if not hasIO then
        log("Cannot load - IO API not enabled!")
        return
    end
    
    local file = io.open("storage/emulated/0/android/media/com.rtsoft.growtopia/scripts/PTHT_SIMPLE_CONFIG.txt", "r")
    if file then
        for line in file:lines() do
            local key, value = line:match("([^=]+)=(.+)")
            if key and value then
                if value == "true" then
                    config[key] = true
                elseif value == "false" then
                    config[key] = false
                elseif tonumber(value) then
                    config[key] = tonumber(value)
                else
                    config[key] = value
                end
            end
        end
        file:close()
        log("Settings loaded!")
    end
end

-- Event hooks
if AddHook then
    AddHook("OnVariant", "PTHT_Events", function(var)
        if var[0] == "OnTalkBubble" and var[2]:find("The MAGPLANT 5000 is empty") then
            state.needsRemote = true
            state.currentMag = state.currentMag + 1
        end
        
        if var[0] == "OnSDBroadcast" and config.antiLag then
            return true
        end
    end)
end

-- GUI
if AddHook and hasImGui then
    AddHook("OnDraw", "PTHT_GUI", function()
        if not state.showGUI then return end
        
        local windowOpen, shouldClose = ImGui.Begin("PTHT Simple v1.0", true)
        
        if windowOpen then
            -- Status
            ImGui.Text("Status: " .. (state.running and "Running" or "Stopped"))
            ImGui.SameLine()
            
            if state.running then
                if ImGui.Button("Stop") then
                    state.running = false
                    log("Script stopped")
                end
            else
                if ImGui.Button("Start") then
                    state.running = true
                    state.startTime = os.time()
                    log("Script started")
                    sendWebhook("Script started")
                end
            end
            
            ImGui.Separator()
            
            -- Settings
            local changed, newWorld = ImGui.InputText("World", config.world, 32)
            if changed then config.world = newWorld end
            
            local changed, newCycles = ImGui.InputInt("Target Cycles", config.targetCycles)
            if changed then config.targetCycles = newCycles end
            
            if ImGui.Checkbox("Use UWS", config.useUWS) then
                config.useUWS = not config.useUWS
            end
            
            if ImGui.Checkbox("Second Account", config.secondAcc) then
                config.secondAcc = not config.secondAcc
            end
            
            if ImGui.Checkbox("Auto Gems", config.autoGems) then
                config.autoGems = not config.autoGems
            end
            
            ImGui.Separator()
            
            -- Webhook
            ImGui.Text("Webhook:")
            if ImGui.Checkbox("Enable", config.webhookEnabled) then
                config.webhookEnabled = not config.webhookEnabled
            end
            
            if config.webhookEnabled then
                local changed, newURL = ImGui.InputText("URL", config.webhookURL, 256)
                if changed then config.webhookURL = newURL end
            end
            
            ImGui.Separator()
            
            -- Stats
            ImGui.Text("Cycle: " .. state.currentCycle .. "/" .. config.targetCycles)
            ImGui.Text("Gems: " .. formatNumber(getGems()))
            ImGui.Text("Trees: " .. countTrees())
            ImGui.Text("UWS: " .. countItems(12600))
            ImGui.Text("Uptime: " .. formatTime(os.time() - state.startTime))
            
            ImGui.Separator()
            
            if ImGui.Button("Save Settings") then
                saveSettings()
            end
            ImGui.SameLine()
            if ImGui.Button("Load Settings") then
                loadSettings()
            end
        end
        
        if shouldClose then
            state.showGUI = false
        end
        
        ImGui.End()
    end)
end

-- Main loop
local function mainLoop()
    while true do
        Sleep(100)
        
        if state.running then
            -- Auto collect gems
            if config.autoGems and SendPacket then
                SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1")
            end
            
            -- Handle reconnection
            if not isInCorrectWorld() then
                log("Joining world: " .. config.world)
                joinWorld(config.world)
                Sleep(config.enterDelay)
                state.needsRemote = true
            end
            
            -- Take remote if needed
            if state.needsRemote and isInCorrectWorld() then
                takeRemote()
            end
            
            -- Main farming
            if isInCorrectWorld() and not state.needsRemote then
                farmingLoop()
                
                -- Check completion
                if state.currentCycle >= config.targetCycles then
                    state.running = false
                    log("PTHT completed!")
                    sendWebhook("PTHT completed! Cycles: " .. state.currentCycle)
                end
                
                -- Periodic webhook
                if state.currentCycle > 0 and state.currentCycle % 5 == 0 then
                    sendWebhook("Progress update")
                end
            end
        end
    end
end

-- Initialize
log("PTHT Simple Script loaded!")
loadSettings()

-- Start main loop
mainLoop()