--[[ 
Custom PTHT Script with ImGui Configuration Menu
Bothax Supported - Made for realBH Repository
Features: Advanced Configuration, Webhook Support, Multiple Modes
]]--

-- Configuration Settings
Settings = {
    -- Main Settings
    World = "PTHT",
    SeedID = 15461, -- CTREE Seed ID
    MagBG = 284, -- Magplant Background ID
    MaxTree = 17000, -- Max trees before UWS
    AmountPTHT = 50, -- Total PTHT cycles
    
    -- Position Settings
    StartingPos = { 0, 192 }, -- Starting X, Y position
    
    -- Mode Settings
    Mode = "VERTICAL", -- VERTICAL or HORIZONTAL
    SecondAcc = false, -- true = right to left, false = left to right
    
    -- Boolean Settings
    UseUws = true, -- Use Ultra World Spray
    AntiLag = true, -- Anti-lag protection
    AntiSDB = true, -- Anti Super Broadcast
    AutoReconnect = true, -- Auto reconnect on disconnect
    
    -- Delay Settings
    DelayPT = 15, -- Plant delay (ms)
    DelayHT = 200, -- Harvest delay (ms)
    DelayAfterPT = 2500, -- Delay after planting
    DelayAfterUWS = 3000, -- Delay after UWS
    DelayEntering = 5000, -- World enter delay
    
    -- Webhook Settings
    WebhookEnabled = false,
    WebhookURL = "",
    WebhookDelay = 300,
    
    -- Advanced Settings
    UseMRAY = true, -- Use MRAY for faster planting
    AutoCollectGems = true, -- Auto collect gems
    EnableLogging = true, -- Enable console logging
}

-- Global Variables
local isRunning = false
local showGUI = true
local currentCycle = 0
local plant = true
local harvest = false
local chgremote = false
local getremote = true
local currentMag = 1
local totalGems = 0
local startTime = os.time()
local lastWebhookTime = 0

-- GUI State Variables
local showMainWindow = true
local showSettingsWindow = false
local showStatsWindow = false

-- Check required APIs
if not ImGui then
    LogToConsole("`4[PTHT] ImGui API is required! Enable it in Bothax API settings.")
    return
end

if not io then
    LogToConsole("`4[PTHT] IO API is required! Enable it in Bothax API settings.")
end

if not MakeRequest then
    LogToConsole("`4[PTHT] MakeRequest API is required for webhook! Enable it in Bothax API settings.")
end

-- Utility Functions
function Log(text)
    if Settings.EnableLogging then
        LogToConsole("`0[`cPTHT`0] " .. text)
    end
end

function GetPlayerName()
    return GetLocal() and GetLocal().name:gsub("`%w", ""):match("%S+") or "Unknown"
end

function GetWorldName()
    return GetWorld() and GetWorld().name or "Unknown"
end

function GetGems()
    totalGems = GetLocal() and GetLocal().gems or 0
    return totalGems
end

function FormatNumber(num)
    if num >= 1000000 then
        return string.format("%.1fM", num / 1000000)
    elseif num >= 1000 then
        return string.format("%.1fK", num / 1000)
    else
        return tostring(num)
    end
end

function FormatTime(seconds)
    local hours = math.floor(seconds / 3600)
    local minutes = math.floor((seconds % 3600) / 60)
    local secs = seconds % 60
    
    if hours > 0 then
        return string.format("%dh %dm %ds", hours, minutes, secs)
    elseif minutes > 0 then
        return string.format("%dm %ds", minutes, secs)
    else
        return string.format("%ds", secs)
    end
end

-- Inventory Functions
function inv(id)
    local count = 0
    for _, item in pairs(GetInventory()) do
        if item.id == id then
            count = count + item.amount
        end
    end
    return count
end

-- Packet Functions
function Raw(t, s, v, x, y)
    SendPacketRaw(false, {
        type = t,
        state = s,
        value = v,
        px = x,
        py = y,
        x = x * 32,
        y = y * 32
    })
end

function Join(worldName)
    SendPacket(3, "action|join_request\nname|" .. worldName .. "|\ninvitedWorld|0")
end

-- Magplant Functions
function GetMagplants()
    local magplants = {}
    for x = 0, 199 do
        for y = 0, 199 do
            if GetTile(x, y).fg == 5638 and GetTile(x, y).bg == Settings.MagBG then
                table.insert(magplants, {x = x, y = y})
            end
        end
    end
    return magplants
end

function TakeMagplant()
    local magplants = GetMagplants()
    if #magplants == 0 then
        Log("`4No magplants found!")
        return false
    end
    
    if currentMag > #magplants then
        currentMag = 1
    end
    
    local mag = magplants[currentMag]
    Raw(0, 32, 0, mag.x, mag.y)
    Sleep(300)
    Raw(3, 0, 32, mag.x, mag.y)
    Sleep(300)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. mag.x .. "|\ny|" .. mag.y .. "|\nbuttonClicked|getRemote")
    Sleep(500)
    
    Log("`2Taking remote from magplant " .. currentMag .. "/" .. #magplants)
    getremote = false
    return true
end

-- Tree/Land Counting Functions
function GetTreeCount()
    local treeCount = 0
    for y = Settings.StartingPos[2], 0, -1 do
        for x = Settings.StartingPos[1], 199 do
            if GetTile(x, y).fg == Settings.SeedID then
                treeCount = treeCount + 1
            end
        end
    end
    return treeCount
end

function GetReadyTrees()
    local readyCount = 0
    for y = Settings.StartingPos[2], 0, -1 do
        for x = Settings.StartingPos[1], 199 do
            local tile = GetTile(x, y)
            if tile.fg == Settings.SeedID and tile.extra and tile.extra.progress == 1.0 then
                readyCount = readyCount + 1
            end
        end
    end
    return readyCount
end

-- UWS Function
function UseUWS()
    if Settings.UseUws and inv(12600) > 0 then
        Log("`2Using Ultra World Spray...")
        Sleep(Settings.DelayAfterPT)
        SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
        Sleep(Settings.DelayAfterUWS)
        return true
    end
    return false
end

-- Mode Change Function
function ChangeMode()
    local treeCount = GetTreeCount()
    if treeCount > Settings.MaxTree then
        UseUWS()
        plant = false
        harvest = true
        Log("`9Switching to harvest mode - Trees: " .. treeCount)
    elseif GetReadyTrees() == 0 then
        plant = true
        harvest = false
        Log("`9Switching to plant mode - Trees: " .. treeCount)
    end
end

-- Main PTHT Function
function PTHT()
    if not GetWorld() or GetWorld().name ~= Settings.World then
        return
    end
    
    if Settings.Mode == "VERTICAL" then
        for x = (Settings.SecondAcc and 199 or Settings.StartingPos[1]), 
            (Settings.SecondAcc and Settings.StartingPos[1] or 199), 
            (Settings.SecondAcc and -10 or 10) do
            
            if not isRunning or chgremote then return end
            
            Log("`9" .. (plant and "Planting" or "Harvesting") .. " on X: " .. x)
            
            for i = 1, 2 do
                for y = Settings.StartingPos[2], 
                    (Settings.StartingPos[2] % 2 == 0 and 0 or 1), -2 do
                    
                    if not isRunning or chgremote then return end
                    
                    local tile = GetTile(x, y)
                    local shouldAct = false
                    
                    if plant and tile.fg == 0 and GetTile(x, y + 1).fg ~= 0 then
                        shouldAct = true
                    elseif harvest and tile.fg == Settings.SeedID and tile.extra and tile.extra.progress == 1.0 then
                        shouldAct = true
                    end
                    
                    if shouldAct then
                        Raw(0, (Settings.SecondAcc and 48 or 32), 0, x, y)
                        Sleep(30)
                        Raw(3, 0, (plant and 5640 or 18), x, y)
                        Sleep(plant and Settings.DelayPT or Settings.DelayHT)
                    end
                end
            end
        end
    else -- HORIZONTAL mode
        for y = Settings.StartingPos[2], (Settings.StartingPos[2] % 2 == 0 and 0 or 1), -2 do
            if not isRunning or chgremote then return end
            
            Log("`9" .. (plant and "Planting" or "Harvesting") .. " on Y: " .. y)
            
            for i = 1, 2 do
                for x = (Settings.SecondAcc and 199 or Settings.StartingPos[1]), 
                    (Settings.SecondAcc and Settings.StartingPos[1] or 199), 
                    (Settings.SecondAcc and -10 or 10) do
                    
                    if not isRunning or chgremote then return end
                    
                    local tile = GetTile(x, y)
                    local shouldAct = false
                    
                    if plant and tile.fg == 0 and GetTile(x, y + 1).fg ~= 0 then
                        shouldAct = true
                    elseif harvest and tile.fg == Settings.SeedID and tile.extra and tile.extra.progress == 1.0 then
                        shouldAct = true
                    end
                    
                    if shouldAct then
                        Raw(0, (Settings.SecondAcc and 48 or 32), 0, x, y)
                        Sleep(30)
                        Raw(3, 0, (plant and 5640 or 18), x, y)
                        Sleep(plant and Settings.DelayPT or Settings.DelayHT)
                    end
                end
            end
        end
    end
    
    ChangeMode()
    currentCycle = currentCycle + 1
end

-- Reconnection Function
function Reconnect()
    if not GetWorld() or GetWorld().name ~= Settings.World then
        Log("`4Reconnecting to world: " .. Settings.World)
        Join(Settings.World)
        Sleep(Settings.DelayEntering)
        getremote = true
    end
    
    if getremote then
        if TakeMagplant() then
            getremote = false
        end
    end
    
    if chgremote then
        if TakeMagplant() then
            currentMag = currentMag + 1
            chgremote = false
        end
    end
end

-- Webhook Function
function SendWebhook(message)
    if not Settings.WebhookEnabled or Settings.WebhookURL == "" then
        return
    end
    
    local currentTime = os.time()
    if currentTime - lastWebhookTime < Settings.WebhookDelay then
        return
    end
    
    local playerName = GetPlayerName()
    local worldName = GetWorldName()
    local uptime = FormatTime(currentTime - startTime)
    local gems = FormatNumber(GetGems())
    local trees = GetTreeCount()
    
    local webhookData = {
        embeds = {
            {
                title = "PTHT Custom Script Update",
                fields = {
                    { name = "Player", value = playerName, inline = true },
                    { name = "World", value = worldName, inline = true },
                    { name = "Cycle", value = currentCycle .. "/" .. Settings.AmountPTHT, inline = true },
                    { name = "Gems", value = gems, inline = true },
                    { name = "Trees", value = tostring(trees), inline = true },
                    { name = "Uptime", value = uptime, inline = true },
                    { name = "Status", value = message, inline = false }
                },
                color = math.random(0, 16777215),
                timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ")
            }
        }
    }
    
    local jsonData = table.concat({
        '{"embeds":[{"title":"PTHT Custom Script Update","fields":[',
        '{"name":"Player","value":"' .. playerName .. '","inline":true},',
        '{"name":"World","value":"' .. worldName .. '","inline":true},',
        '{"name":"Cycle","value":"' .. currentCycle .. '/' .. Settings.AmountPTHT .. '","inline":true},',
        '{"name":"Gems","value":"' .. gems .. '","inline":true},',
        '{"name":"Trees","value":"' .. trees .. '","inline":true},',
        '{"name":"Uptime","value":"' .. uptime .. '","inline":true},',
        '{"name":"Status","value":"' .. message .. '","inline":false}',
        '],"color":' .. math.random(0, 16777215) .. ',"timestamp":"' .. os.date("!%Y-%m-%dT%H:%M:%SZ") .. '"}]}'
    })
    
    if MakeRequest then
        MakeRequest(Settings.WebhookURL, "POST", {["Content-Type"] = "application/json"}, jsonData)
        lastWebhookTime = currentTime
        Log("`2Webhook sent: " .. message)
    end
end

-- Settings Save/Load Functions
function SaveSettings()
    if not io then
        Log("`4Cannot save settings - IO API not enabled!")
        return
    end
    
    local file = io.open("storage/emulated/0/android/media/com.rtsoft.growtopia/scripts/PTHT_CUSTOM_SETTINGS.txt", "w")
    if file then
        file:write("-- PTHT Custom Settings\n")
        for key, value in pairs(Settings) do
            if type(value) == "table" then
                file:write(key .. "={" .. value[1] .. "," .. value[2] .. "}\n")
            else
                file:write(key .. "=" .. tostring(value) .. "\n")
            end
        end
        file:close()
        Log("`2Settings saved successfully!")
    else
        Log("`4Failed to save settings!")
    end
end

function LoadSettings()
    if not io then
        Log("`4Cannot load settings - IO API not enabled!")
        return
    end
    
    local file = io.open("storage/emulated/0/android/media/com.rtsoft.growtopia/scripts/PTHT_CUSTOM_SETTINGS.txt", "r")
    if file then
        for line in file:lines() do
            if not line:match("^%-%-") and line:match("=") then
                local key, value = line:match("([^=]+)=(.+)")
                if key and value then
                    key = key:gsub("%s+", "")
                    
                    if value:match("^{") then
                        local x, y = value:match("{([^,]+),([^}]+)}")
                        if x and y then
                            Settings[key] = {tonumber(x), tonumber(y)}
                        end
                    elseif value == "true" then
                        Settings[key] = true
                    elseif value == "false" then
                        Settings[key] = false
                    elseif tonumber(value) then
                        Settings[key] = tonumber(value)
                    else
                        Settings[key] = value:gsub('"', '')
                    end
                end
            end
        end
        file:close()
        Log("`2Settings loaded successfully!")
    else
        Log("`3No saved settings found, using defaults.")
    end
end

-- Event Hooks
AddHook("OnVariant", "PTHT_Hook", function(var)
    if var[0] == "OnTalkBubble" then
        if var[2]:find("The MAGPLANT 5000 is empty") then
            chgremote = true
        end
    end
    
    if var[0] == "OnSDBroadcast" and Settings.AntiSDB then
        return true
    end
    
    if var[0] == "OnConsoleMessage" then
        local message = var[1]
        if message:find("Where would you like to go") or 
           message:find("Disconnected") or 
           message:find("** from") then
            return true
        end
    end
end)

-- Main GUI Function
AddHook("OnDraw", "PTHT_GUI", function()
    if not showGUI then return end
    
    -- Main Window
    if showMainWindow then
        local windowOpen, shouldClose = ImGui.Begin("PTHT Custom Script v1.0", true, ImGuiWindowFlags.AlwaysAutoResize)
        
        if windowOpen then
            -- Status Section
            ImGui.Text("Status: " .. (isRunning and "`2Running" or "`4Stopped"))
            ImGui.SameLine()
            if isRunning then
                if ImGui.Button("Stop", ImVec2(100, 30)) then
                    isRunning = false
                    Log("`4Script stopped by user")
                end
            else
                if ImGui.Button("Start", ImVec2(100, 30)) then
                    isRunning = true
                    startTime = os.time()
                    Log("`2Script started")
                    SendWebhook("Script started")
                end
            end
            
            ImGui.Separator()
            
            -- Quick Settings
            ImGui.Text("Quick Settings:")
            
            local changed, newWorld = ImGui.InputText("World", Settings.World, 32)
            if changed then Settings.World = newWorld end
            
            local changed, newAmount = ImGui.InputInt("PTHT Amount", Settings.AmountPTHT)
            if changed then Settings.AmountPTHT = newAmount end
            
            if ImGui.Checkbox("Use UWS", Settings.UseUws) then
                Settings.UseUws = not Settings.UseUws
            end
            ImGui.SameLine()
            if ImGui.Checkbox("Second Account", Settings.SecondAcc) then
                Settings.SecondAcc = not Settings.SecondAcc
            end
            
            -- Mode Selection
            ImGui.Text("Mode:")
            if ImGui.RadioButton("Vertical", Settings.Mode == "VERTICAL") then
                Settings.Mode = "VERTICAL"
            end
            ImGui.SameLine()
            if ImGui.RadioButton("Horizontal", Settings.Mode == "HORIZONTAL") then
                Settings.Mode = "HORIZONTAL"
            end
            
            ImGui.Separator()
            
            -- Action Buttons
            if ImGui.Button("Advanced Settings", ImVec2(150, 35)) then
                showSettingsWindow = true
            end
            ImGui.SameLine()
            if ImGui.Button("Statistics", ImVec2(150, 35)) then
                showStatsWindow = true
            end
            
            if ImGui.Button("Save Settings", ImVec2(150, 35)) then
                SaveSettings()
            end
            ImGui.SameLine()
            if ImGui.Button("Load Settings", ImVec2(150, 35)) then
                LoadSettings()
            end
            
            -- Current Stats Display
            ImGui.Separator()
            ImGui.Text("Current Cycle: " .. currentCycle .. "/" .. Settings.AmountPTHT)
            ImGui.Text("Gems: " .. FormatNumber(GetGems()))
            ImGui.Text("Trees: " .. GetTreeCount())
            ImGui.Text("Ready Trees: " .. GetReadyTrees())
            ImGui.Text("UWS: " .. inv(12600))
            ImGui.Text("Uptime: " .. FormatTime(os.time() - startTime))
            
        end
        
        if shouldClose then
            showMainWindow = false
        end
        
        ImGui.End()
    end
    
    -- Settings Window
    if showSettingsWindow then
        local windowOpen, shouldClose = ImGui.Begin("Advanced Settings", true)
        
        if windowOpen then
            if ImGui.BeginTabBar("SettingsTabs") then
                
                -- General Tab
                if ImGui.BeginTabItem("General") then
                    local changed, newSeedID = ImGui.InputInt("Seed ID", Settings.SeedID)
                    if changed then Settings.SeedID = newSeedID end
                    
                    local changed, newMagBG = ImGui.InputInt("Magplant BG", Settings.MagBG)
                    if changed then Settings.MagBG = newMagBG end
                    
                    local changed, newMaxTree = ImGui.InputInt("Max Trees", Settings.MaxTree)
                    if changed then Settings.MaxTree = newMaxTree end
                    
                    local changed, newStartX = ImGui.InputInt("Start X", Settings.StartingPos[1])
                    if changed then Settings.StartingPos[1] = newStartX end
                    
                    local changed, newStartY = ImGui.InputInt("Start Y", Settings.StartingPos[2])
                    if changed then Settings.StartingPos[2] = newStartY end
                    
                    ImGui.EndTabItem()
                end
                
                -- Delays Tab
                if ImGui.BeginTabItem("Delays") then
                    local changed, newDelayPT = ImGui.InputInt("Plant Delay (ms)", Settings.DelayPT)
                    if changed then Settings.DelayPT = newDelayPT end
                    
                    local changed, newDelayHT = ImGui.InputInt("Harvest Delay (ms)", Settings.DelayHT)
                    if changed then Settings.DelayHT = newDelayHT end
                    
                    local changed, newDelayAfterPT = ImGui.InputInt("Delay After Plant (ms)", Settings.DelayAfterPT)
                    if changed then Settings.DelayAfterPT = newDelayAfterPT end
                    
                    local changed, newDelayAfterUWS = ImGui.InputInt("Delay After UWS (ms)", Settings.DelayAfterUWS)
                    if changed then Settings.DelayAfterUWS = newDelayAfterUWS end
                    
                    local changed, newDelayEntering = ImGui.InputInt("Enter World Delay (ms)", Settings.DelayEntering)
                    if changed then Settings.DelayEntering = newDelayEntering end
                    
                    ImGui.EndTabItem()
                end
                
                -- Features Tab
                if ImGui.BeginTabItem("Features") then
                    if ImGui.Checkbox("Anti-Lag", Settings.AntiLag) then
                        Settings.AntiLag = not Settings.AntiLag
                    end
                    
                    if ImGui.Checkbox("Anti-SDB", Settings.AntiSDB) then
                        Settings.AntiSDB = not Settings.AntiSDB
                    end
                    
                    if ImGui.Checkbox("Auto Reconnect", Settings.AutoReconnect) then
                        Settings.AutoReconnect = not Settings.AutoReconnect
                    end
                    
                    if ImGui.Checkbox("Use MRAY", Settings.UseMRAY) then
                        Settings.UseMRAY = not Settings.UseMRAY
                    end
                    
                    if ImGui.Checkbox("Auto Collect Gems", Settings.AutoCollectGems) then
                        Settings.AutoCollectGems = not Settings.AutoCollectGems
                    end
                    
                    if ImGui.Checkbox("Enable Logging", Settings.EnableLogging) then
                        Settings.EnableLogging = not Settings.EnableLogging
                    end
                    
                    ImGui.EndTabItem()
                end
                
                -- Webhook Tab
                if ImGui.BeginTabItem("Webhook") then
                    if ImGui.Checkbox("Enable Webhook", Settings.WebhookEnabled) then
                        Settings.WebhookEnabled = not Settings.WebhookEnabled
                    end
                    
                    local changed, newURL = ImGui.InputText("Webhook URL", Settings.WebhookURL, 256)
                    if changed then Settings.WebhookURL = newURL end
                    
                    local changed, newDelay = ImGui.InputInt("Webhook Delay (s)", Settings.WebhookDelay)
                    if changed then Settings.WebhookDelay = newDelay end
                    
                    if ImGui.Button("Test Webhook", ImVec2(200, 35)) then
                        SendWebhook("Test message from PTHT Custom Script")
                    end
                    
                    ImGui.EndTabItem()
                end
                
                ImGui.EndTabBar()
            end
            
            ImGui.Separator()
            if ImGui.Button("Close", ImVec2(-1, 35)) then
                showSettingsWindow = false
            end
        end
        
        if shouldClose then
            showSettingsWindow = false
        end
        
        ImGui.End()
    end
    
    -- Statistics Window
    if showStatsWindow then
        local windowOpen, shouldClose = ImGui.Begin("Statistics", true)
        
        if windowOpen then
            ImGui.Text("=== PTHT Statistics ===")
            ImGui.Separator()
            
            ImGui.Text("Player: " .. GetPlayerName())
            ImGui.Text("World: " .. GetWorldName())
            ImGui.Text("Current Mode: " .. Settings.Mode)
            ImGui.Text("Direction: " .. (Settings.SecondAcc and "Right to Left" or "Left to Right"))
            
            ImGui.Separator()
            
            ImGui.Text("Progress: " .. currentCycle .. "/" .. Settings.AmountPTHT .. " cycles")
            ImGui.Text("Completion: " .. string.format("%.1f%%", (currentCycle / Settings.AmountPTHT) * 100))
            ImGui.Text("Current Action: " .. (plant and "Planting" or "Harvesting"))
            
            ImGui.Separator()
            
            ImGui.Text("Gems: " .. FormatNumber(GetGems()))
            ImGui.Text("Total Trees: " .. GetTreeCount())
            ImGui.Text("Ready Trees: " .. GetReadyTrees())
            ImGui.Text("UWS Available: " .. inv(12600))
            
            ImGui.Separator()
            
            local uptime = os.time() - startTime
            ImGui.Text("Uptime: " .. FormatTime(uptime))
            if uptime > 0 then
                ImGui.Text("Cycles/Hour: " .. string.format("%.1f", (currentCycle / uptime) * 3600))
            end
            
            if ImGui.Button("Reset Statistics", ImVec2(-1, 35)) then
                currentCycle = 0
                startTime = os.time()
                Log("`2Statistics reset")
            end
        end
        
        if shouldClose then
            showStatsWindow = false
        end
        
        ImGui.End()
    end
end)

-- Main Loop
function MainLoop()
    while true do
        Sleep(100)
        
        if isRunning then
            if Settings.AutoCollectGems then
                SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1")
            end
            
            Reconnect()
            
            if GetWorld() and GetWorld().name == Settings.World and not chgremote and not getremote then
                PTHT()
                
                -- Check if completed
                if currentCycle >= Settings.AmountPTHT then
                    isRunning = false
                    Log("`2PTHT completed! Total cycles: " .. currentCycle)
                    SendWebhook("PTHT completed! Total cycles: " .. currentCycle)
                end
                
                -- Periodic webhook updates
                if Settings.WebhookEnabled and currentCycle > 0 and currentCycle % 5 == 0 then
                    SendWebhook("Progress update - Cycle " .. currentCycle)
                end
            end
        end
    end
end

-- Initialize
Log("`2PTHT Custom Script loaded successfully!")
Log("`9Use the GUI to configure and start the script.")
LoadSettings()

-- Start main loop
MainLoop()