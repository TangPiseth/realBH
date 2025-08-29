--[[
===============================================================================
                        PTHT AntiCheat Version v1.0
                          by @Mupnup
===============================================================================

DESCRIPTION:
This is an advanced PTHT (Plant, Tree, Harvest, Tree) script designed to avoid
anti-cheat detection by using slow movement patterns and Raw packet sending
instead of FindPath/teleportation.

KEY FEATURES:
✓ Vertical Snake Planting Pattern (bottom-top, then top-bottom alternating)
✓ Anti-cheat protection with movement rate limiting
✓ Automatic magplant switching when stock is empty
✓ Comprehensive configuration system via dialog
✓ Slow movement after reconnection to avoid detection
✓ UWS (Ultra World Spray) automation
✓ Real-time statistics and progress tracking
✓ Ghost mode automation
✓ Raw packet movement instead of FindPath

ANTI-CHEAT FEATURES:
- Uses Raw() packets instead of FindPath() to avoid teleportation detection
- Configurable movement delays between actions
- Rate limiting: maximum moves per second configurable
- Extra delays after reconnection
- Slow vertical movement pattern mimics human behavior

SETUP INSTRUCTIONS:
1. Place magplants with appropriate background ID in your world
2. Load the script in your Growtopia client
3. Type "/pthtconfig" to open configuration dialog
4. Configure your settings:
   - World name
   - Seed ID (default: 15757 for POG)
   - Platform ID (default: 3126)
   - Background ID for magplants (default: 14)
   - Anti-cheat settings (delays, movement speed)
   - UWS settings
5. Click "Start PTHT" or use "/pthtstart" command

COMMANDS:
/pthtconfig  - Open main configuration dialog
/pthtstart   - Start PTHT farming
/pthtstop    - Stop PTHT farming
/pthtstatus  - Show current status
/pthtcheck   - Run pre-flight validation check
/pthtquick   - Quick setup for POG farming (15757)

PLANTING PATTERN:
The script plants in a vertical snake pattern:
- Column 0, 10, 20, 30... : Bottom to Top (Y: 192 → 0)
- Column 10, 20, 30, 40... : Top to Bottom (Y: 0 → 192)
This creates an efficient vertical pattern while avoiding predictable movement.

REQUIREMENTS:
- Magplants with seeds placed in the world
- Platform blocks for farming area
- Ultra World Spray (if UWS feature is enabled)
- Sufficient world access permissions

SAFETY FEATURES:
- Prevents multiple instances running simultaneously
- Automatic reconnection with anti-cheat delays
- Magplant switching when empty
- Configurable timeout and retry limits
- Real-time status monitoring

For support or updates, contact @Mupnup
===============================================================================
]]--

-- PTHT AntiCheat Version by @Mupnup
-- Anti-cheat protection with slow movement and vertical planting pattern

-- MAIN CONFIGURATION SETTINGS
Settings = {
    -- [ Core Settings ] --
    World = "DOCS",                     -- World name to farm in
    SeedID = 15757,                     -- Seed item ID (POG by default)
    PlatformID = 3126,                  -- Platform block ID
    BackgroundID = 14,                  -- Background ID for magplant
    MaxPTHT = 30,                       -- Maximum PTHT cycles before stopping
    
    -- [ Position Settings ] --
    StartingPos = { 0, 192 },           -- Starting position (x, y)
    MaxX = 199,                         -- Maximum X coordinate
    MaxY = 192,                         -- Maximum Y coordinate
    
    -- [ Anti-Cheat Settings ] --
    AntiCheatMode = true,               -- Enable anti-cheat protection
    SlowMovement = true,                -- Use slow movement to avoid detection
    MovementDelay = 150,                -- Delay between tile movements (ms)
    PostReconnectDelay = 300,           -- Extra delay after reconnection (ms)
    MaxMovesPerSecond = 5,              -- Maximum tile moves per second
    
    -- [ Planting Settings ] --
    PlantMode = "VERTICAL_SNAKE",       -- Planting pattern: VERTICAL_SNAKE (bottom-top, top-bottom)
    PlantDelay = 60,                    -- Delay between planting actions (ms)
    HarvestDelay = 200,                 -- Delay between harvest actions (ms)
    
    -- [ UWS Settings ] --
    UseUWS = true,                      -- Enable Ultra World Spray usage
    UWSDelay = 3000,                    -- Delay after using UWS (ms)
    MaxTreesBeforeUWS = 17000,          -- Maximum trees before using UWS
    
    -- [ Magplant Settings ] --
    AutoSwitchMagplant = true,          -- Auto switch magplants when empty
    MagplantCheckDelay = 500,           -- Delay when checking magplant (ms)
    
    -- [ Connection Settings ] --
    ReconnectDelay = 5000,              -- Delay before reconnecting (ms)
    ReconnectAttempts = 3,              -- Maximum reconnect attempts
    
    -- [ Automation Settings ] --
    AutoPlant = true,                   -- Enable auto planting
    AutoHarvest = true,                 -- Enable auto harvesting
    AutoGhost = true,                   -- Enable auto ghost mode
    
    -- [ Debug Settings ] --
    DebugMode = false,                  -- Enable debug logging
    ShowStats = true,                   -- Show farming statistics
}

-- Global Variables
local currentPTHT = 0
local totalTreesPlanted = 0
local totalTreesHarvested = 0
local currentMagplantIndex = 1
local allMagplants = {}
local isReconnecting = false
local lastMoveTime = 0
local movementCount = 0
local plantingDirection = 1  -- 1 = bottom to top, -1 = top to bottom
local currentColumn = 0
local changeRemote = false
local noStock = false
local isRunning = false -- Prevent multiple instances

-- Initialize player info
local function initializePlayer()
    if GetLocal() then
        Settings.PlayerName = GetLocal().name or "Unknown"
        Settings.PlayerID = GetLocal().userid or 0
    end
end

-- Safe initialization
pcall(initializePlayer)

-- Utility Functions
local function Log(message)
    if Settings.DebugMode then
        LogToConsole("`0[`cAntiCheat PTHT`0] " .. message)
    end
end

local function Console(message)
    SendVariantList({[0] = "OnConsoleMessage", [1] = "`0[`cAntiCheat PTHT`0] " .. message})
end

local function OverlayText(text)
    SendVariantList({[0] = "OnTextOverlay", [1] = text})
end

local function GetItemCount(itemID)
    local count = 0
    for _, item in pairs(GetInventory()) do
        if item.id == itemID then
            count = count + item.amount
        end
    end
    return count
end

-- Anti-Cheat Movement Functions
local function CanMove()
    if not Settings.AntiCheatMode then return true end
    
    local currentTime = os.clock() * 1000
    
    -- Reset movement counter every second
    if currentTime - lastMoveTime > 1000 then
        movementCount = 0
        lastMoveTime = currentTime
    end
    
    -- Check if we're moving too fast
    if movementCount >= Settings.MaxMovesPerSecond then
        Log("Movement rate limited - waiting")
        Sleep(200)
        return false
    end
    
    return true
end

local function SafeRaw(type, state, value, x, y)
    if not CanMove() then return false end
    
    local packet = {
        type = type,
        state = state,
        value = value,
        px = x,
        py = y,
        x = x * 32,
        y = y * 32
    }
    
    SendPacketRaw(false, packet)
    movementCount = movementCount + 1
    
    if Settings.SlowMovement then
        Sleep(Settings.MovementDelay)
    end
    
    return true
end

local function SafeMoveTo(x, y)
    if not GetWorld() then return false end
    
    -- Use Raw packets instead of FindPath for anti-cheat
    if Settings.AntiCheatMode then
        SafeRaw(0, 32, 0, x, y)
        Sleep(Settings.MovementDelay)
    else
        FindPath(x, y, 100)
        Sleep(100)
    end
    
    return true
end

-- Magplant Functions
local function FindAllMagplants()
    if not GetWorld() then return {} end
    
    local magplants = {}
    for _, tile in pairs(GetTiles()) do
        if tile.fg == 5638 and tile.bg == Settings.BackgroundID then
            table.insert(magplants, {x = tile.x, y = tile.y})
        end
    end
    
    Log("Found " .. #magplants .. " magplants")
    return magplants
end

local function GetCurrentMagplant()
    if #allMagplants == 0 then
        allMagplants = FindAllMagplants()
    end
    
    if #allMagplants == 0 then
        return nil, nil
    end
    
    if currentMagplantIndex > #allMagplants then
        currentMagplantIndex = 1
    end
    
    return allMagplants[currentMagplantIndex].x, allMagplants[currentMagplantIndex].y
end

local function SwitchToNextMagplant()
    if not Settings.AutoSwitchMagplant then return false end
    
    allMagplants = FindAllMagplants()
    if #allMagplants == 0 then
        Console("No magplants found!")
        return false
    end
    
    currentMagplantIndex = currentMagplantIndex + 1
    if currentMagplantIndex > #allMagplants then
        currentMagplantIndex = 1
    end
    
    local x, y = GetCurrentMagplant()
    if x and y then
        Console("Switching to magplant at (" .. x .. ", " .. y .. ")")
        return true
    end
    
    return false
end

local function GetRemoteFromMagplant()
    local x, y = GetCurrentMagplant()
    if not x or not y then
        Log("No current magplant available")
        return false
    end
    
    -- Move to magplant slowly
    if not SafeMoveTo(x, y - 1) then
        return false
    end
    
    Sleep(Settings.MagplantCheckDelay)
    
    -- Wrench the magplant
    SafeRaw(3, 0, 32, x, y)
    Sleep(200)
    
    -- Get remote
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. x .. "|\ny|" .. y .. "|\nbuttonClicked|getRemote")
    Sleep(Settings.MagplantCheckDelay)
    
    -- Check if we got remote
    local remoteCount = GetItemCount(5640)
    if remoteCount < 1 then
        Log("Magplant empty, switching to next")
        changeRemote = true
        noStock = true
        return false
    end
    
    changeRemote = false
    noStock = false
    return true
end

-- Tree Counting Functions
local function CountTrees()
    if not GetWorld() then return 0 end
    
    local count = 0
    for _, tile in pairs(GetTiles()) do
        if tile.fg == Settings.SeedID then
            count = count + 1
        end
    end
    return count
end

local function CountReadyTrees()
    if not GetWorld() then return 0 end
    
    local count = 0
    for _, tile in pairs(GetTiles()) do
        if tile.fg == Settings.SeedID and tile.extra and tile.extra.progress == 1.0 then
            count = count + 1
        end
    end
    return count
end

-- UWS Functions
local function UseUWS()
    if not Settings.UseUWS then return end
    
    Console("Using Ultra World Spray...")
    SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
    Sleep(Settings.UWSDelay)
end

-- Vertical Snake Planting Pattern
local function GetNextPlantingPosition()
    local x = currentColumn
    local y
    
    if plantingDirection == 1 then
        -- Bottom to top (192 to 0)
        y = Settings.StartingPos[2] - (currentColumn * 2) % (Settings.StartingPos[2] + 1)
        if y < 0 then
            -- Switch to top to bottom for next column
            plantingDirection = -1
            currentColumn = currentColumn + 1
            if currentColumn > Settings.MaxX then
                return nil, nil -- Finished
            end
            y = 0
        end
    else
        -- Top to bottom (0 to 192)
        y = (currentColumn * 2) % (Settings.StartingPos[2] + 1)
        if y > Settings.StartingPos[2] then
            -- Switch to bottom to top for next column
            plantingDirection = 1
            currentColumn = currentColumn + 1
            if currentColumn > Settings.MaxX then
                return nil, nil -- Finished
            end
            y = Settings.StartingPos[2]
        end
    end
    
    return x, y
end

local function PlantTrees()
    if not Settings.AutoPlant then return false end
    if GetItemCount(5640) < 1 then
        Log("No remote available for planting")
        return false
    end
    
    Console("Starting vertical snake planting pattern (bottom-top, top-bottom)...")
    
    local plantsThisCycle = 0
    
    -- Plant in vertical snake pattern: each column alternates direction
    for x = Settings.StartingPos[1], Settings.MaxX, 10 do
        if not GetWorld() or changeRemote then break end
        
        -- Determine direction for this column set
        local isEvenColumn = (math.floor(x / 10) % 2 == 0)
        
        if isEvenColumn then
            -- Plant from bottom to top (192 to 0)
            for y = Settings.StartingPos[2], 0, -2 do
                if not GetWorld() or changeRemote then break end
                
                local tile = GetTile(x, y)
                local belowTile = GetTile(x, y + 1)
                
                -- Check if we can plant here (empty spot with platform below)
                if tile and belowTile and 
                   tile.fg == 0 and 
                   (belowTile.fg == Settings.PlatformID or belowTile.fg ~= 0) then
                    
                    -- Move to position slowly to avoid anti-cheat
                    if SafeMoveTo(x, y) then
                        Sleep(Settings.PlantDelay)
                        
                        -- Plant the seed using Raw packet
                        SafeRaw(3, 0, 5640, x, y)
                        Sleep(Settings.PlantDelay)
                        
                        totalTreesPlanted = totalTreesPlanted + 1
                        plantsThisCycle = plantsThisCycle + 1
                        
                        -- Check remote count periodically
                        if GetItemCount(5640) < 1 then
                            Log("Remote depleted during planting")
                            changeRemote = true
                            break
                        end
                        
                        -- Show progress every 50 plants
                        if plantsThisCycle % 50 == 0 then
                            Console("Planted " .. plantsThisCycle .. " trees in this cycle")
                        end
                    end
                end
            end
        else
            -- Plant from top to bottom (0 to 192)
            for y = 0, Settings.StartingPos[2], 2 do
                if not GetWorld() or changeRemote then break end
                
                local tile = GetTile(x, y)
                local belowTile = GetTile(x, y + 1)
                
                -- Check if we can plant here (empty spot with platform below)
                if tile and belowTile and 
                   tile.fg == 0 and 
                   (belowTile.fg == Settings.PlatformID or belowTile.fg ~= 0) then
                    
                    -- Move to position slowly to avoid anti-cheat
                    if SafeMoveTo(x, y) then
                        Sleep(Settings.PlantDelay)
                        
                        -- Plant the seed using Raw packet
                        SafeRaw(3, 0, 5640, x, y)
                        Sleep(Settings.PlantDelay)
                        
                        totalTreesPlanted = totalTreesPlanted + 1
                        plantsThisCycle = plantsThisCycle + 1
                        
                        -- Check remote count periodically
                        if GetItemCount(5640) < 1 then
                            Log("Remote depleted during planting")
                            changeRemote = true
                            break
                        end
                        
                        -- Show progress every 50 plants
                        if plantsThisCycle % 50 == 0 then
                            Console("Planted " .. plantsThisCycle .. " trees in this cycle")
                        end
                    end
                end
            end
        end
        
        if changeRemote then break end
    end
    
    Console("Planting completed. Trees planted this cycle: " .. plantsThisCycle)
    Console("Total trees planted: " .. totalTreesPlanted)
    return plantsThisCycle > 0
end

local function HarvestTrees()
    if not Settings.AutoHarvest then return false end
    
    local readyCount = CountReadyTrees()
    if readyCount == 0 then
        Log("No trees ready for harvest")
        return false
    end
    
    Console("Harvesting " .. readyCount .. " ready trees using vertical pattern...")
    
    local harvested = 0
    
    -- Harvest in same vertical pattern as planting for consistency
    for x = Settings.StartingPos[1], Settings.MaxX, 10 do
        if not GetWorld() then break end
        
        local isEvenColumn = (math.floor(x / 10) % 2 == 0)
        
        if isEvenColumn then
            -- Harvest from bottom to top (same as planting direction)
            for y = Settings.StartingPos[2], 0, -2 do
                if not GetWorld() then break end
                
                local tile = GetTile(x, y)
                if tile and tile.fg == Settings.SeedID and 
                   tile.extra and tile.extra.progress == 1.0 then
                    
                    -- Move to tree slowly to avoid anti-cheat
                    if SafeMoveTo(x, y) then
                        Sleep(Settings.HarvestDelay)
                        
                        -- Harvest the tree using Raw packet
                        SafeRaw(3, 0, 18, x, y)
                        Sleep(Settings.HarvestDelay)
                        
                        harvested = harvested + 1
                        totalTreesHarvested = totalTreesHarvested + 1
                        
                        -- Show progress every 50 harvests
                        if harvested % 50 == 0 then
                            Console("Harvested " .. harvested .. " trees...")
                        end
                    end
                end
            end
        else
            -- Harvest from top to bottom (same as planting direction)
            for y = 0, Settings.StartingPos[2], 2 do
                if not GetWorld() then break end
                
                local tile = GetTile(x, y)
                if tile and tile.fg == Settings.SeedID and 
                   tile.extra and tile.extra.progress == 1.0 then
                    
                    -- Move to tree slowly to avoid anti-cheat
                    if SafeMoveTo(x, y) then
                        Sleep(Settings.HarvestDelay)
                        
                        -- Harvest the tree using Raw packet
                        SafeRaw(3, 0, 18, x, y)
                        Sleep(Settings.HarvestDelay)
                        
                        harvested = harvested + 1
                        totalTreesHarvested = totalTreesHarvested + 1
                        
                        -- Show progress every 50 harvests
                        if harvested % 50 == 0 then
                            Console("Harvested " .. harvested .. " trees...")
                        end
                    end
                end
            end
        end
    end
    
    Console("Harvesting completed. Trees harvested this cycle: " .. harvested)
    Console("Total trees harvested: " .. totalTreesHarvested)
    return harvested > 0
end

-- Validation Functions
local function ValidateFarmingSetup()
    if not GetWorld() then
        Console("ERROR: Not connected to any world!")
        return false
    end
    
    if GetWorld().name ~= Settings.World then
        Console("ERROR: Connected to wrong world! Expected: " .. Settings.World .. ", Current: " .. GetWorld().name)
        return false
    end
    
    -- Check for magplants
    allMagplants = FindAllMagplants()
    if #allMagplants == 0 then
        Console("ERROR: No magplants found with background ID " .. Settings.BackgroundID)
        return false
    end
    
    Console("Found " .. #allMagplants .. " magplants")
    
    -- Check if we have any remote seeds
    local remoteCount = GetItemCount(5640)
    if remoteCount == 0 then
        Console("WARNING: No remote seeds in inventory, will try to get from magplant")
    else
        Console("Remote seeds available: " .. remoteCount)
    end
    
    -- Check for platforms in farming area
    local platformCount = 0
    for x = Settings.StartingPos[1], math.min(Settings.StartingPos[1] + 50, Settings.MaxX) do
        for y = Settings.StartingPos[2], math.max(Settings.StartingPos[2] - 20, 0), -1 do
            local tile = GetTile(x, y)
            if tile and tile.fg == Settings.PlatformID then
                platformCount = platformCount + 1
            end
        end
    end
    
    if platformCount == 0 then
        Console("ERROR: No platform blocks found in farming area! Platform ID: " .. Settings.PlatformID)
        return false
    end
    
    Console("Validation successful - Found " .. platformCount .. " platform blocks")
    return true
end

-- Pre-flight check function
local function PreFlightCheck()
    Console("Running pre-flight checks...")
    
    if not ValidateFarmingSetup() then
        Console("Pre-flight check FAILED! Please fix the issues above.")
        OverlayText("`4Pre-flight check FAILED!")
        return false
    end
    
    Console("Pre-flight check PASSED! Ready to start PTHT.")
    OverlayText("`2Pre-flight check PASSED!")
    return true
end
local function Reconnect()
    if isReconnecting then return end
    isReconnecting = true
    
    Console("Reconnecting to world...")
    
    for attempt = 1, Settings.ReconnectAttempts do
        Sleep(Settings.ReconnectDelay)
        SendPacket(3, "action|join_request\nname|" .. Settings.World .. "|\ninvitedWorld|0")
        Sleep(3000)
        
        if GetWorld() and GetWorld().name == Settings.World then
            Console("Reconnected successfully")
            
            -- Add extra delay after reconnection for anti-cheat
            if Settings.AntiCheatMode then
                Console("Anti-cheat mode: Adding post-reconnect delay")
                Sleep(Settings.PostReconnectDelay)
            end
            
            break
        else
            Console("Reconnect attempt " .. attempt .. " failed")
        end
    end
    
    isReconnecting = false
end

-- Hook for magplant empty detection and other events
AddHook("OnVariant", "MagplantCheck", function(var)
    if var[0] == "OnTalkBubble" and var[2]:find("The MAGPLANT 5000 is empty") then
        changeRemote = true
        noStock = true
        Log("Magplant empty detected via talk bubble")
        return false
    end
    
    if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT 5000") then
        if var[1]:find("The machine is currently empty!") then
            changeRemote = true
            noStock = true
            Log("Magplant dialog shows empty")
        end
        return true
    end
    
    -- Block SDB for anti-lag
    if var[0] == "OnSDBroadcast" then
        return true
    end
    
    -- Handle disconnection
    if var[0] == "OnConsoleMessage" and var[1]:find("Disconnected") then
        Log("Disconnection detected")
        isReconnecting = true
        return false
    end
    
    return false
end)

-- Additional packet hook for anti-cheat protection
AddHook("OnSendPacket", "AntiCheatProtection", function(type, packet)
    -- Block rapid movement packets if anti-cheat is enabled
    if Settings.AntiCheatMode and type == 0 then
        if not CanMove() then
            Log("Blocked rapid movement packet")
            return true
        end
    end
    return false
end)

-- Main PTHT Loop
local function MainPTHTLoop()
    if isRunning then
        Console("PTHT is already running! Use /pthtstop to stop first.")
        return
    end
    
    -- Run pre-flight checks
    if not PreFlightCheck() then
        return
    end
    
    isRunning = true
    Console("Starting Anti-Cheat PTHT v1.0")
    Console("World: " .. Settings.World)
    Console("Max PTHT: " .. Settings.MaxPTHT)
    Console("Anti-cheat mode: " .. (Settings.AntiCheatMode and "ENABLED" or "DISABLED"))
    
    -- Enable modfly for better movement
    ChangeValue("[C] Modfly", true)
    
    -- Initialize magplants
    allMagplants = FindAllMagplants()
    currentMagplantIndex = 1
    
    while currentPTHT < Settings.MaxPTHT and isRunning do
        -- Check world connection
        if not GetWorld() or GetWorld().name ~= Settings.World then
            Reconnect()
            goto continue
        end
        
        -- Handle magplant switching
        if changeRemote or noStock or GetItemCount(5640) < 1 then
            Console("Need to switch magplant or get remote")
            
            if not GetRemoteFromMagplant() then
                if SwitchToNextMagplant() then
                    if not GetRemoteFromMagplant() then
                        Console("All magplants empty! Stopping.")
                        break
                    end
                else
                    Console("No available magplants! Stopping.")
                    break
                end
            end
        end
        
        -- Enable ghost mode
        if Settings.AutoGhost then
            SendPacket(2, "action|input\ntext|/ghost")
            Sleep(1000)
        end
        
        -- Main farming cycle
        Console("PTHT Cycle " .. (currentPTHT + 1) .. "/" .. Settings.MaxPTHT)
        
        -- Plant trees
        if PlantTrees() then
            -- Use UWS if enabled
            if Settings.UseUWS and CountTrees() > Settings.MaxTreesBeforeUWS then
                UseUWS()
            end
            
            -- Wait for trees to grow
            Console("Waiting for trees to grow...")
            local waitCycles = 0
            while CountReadyTrees() < (CountTrees() * 0.8) and GetWorld() and isRunning and waitCycles < 60 do
                Sleep(5000)
                waitCycles = waitCycles + 1
                if CountReadyTrees() > 0 then
                    Console("Ready trees: " .. CountReadyTrees() .. "/" .. CountTrees())
                end
            end
            
            -- Harvest trees
            if isRunning then
                HarvestTrees()
                currentPTHT = currentPTHT + 1
                
                if Settings.ShowStats then
                    Console("Stats - PTHT: " .. currentPTHT .. "/" .. Settings.MaxPTHT .. 
                           " | Planted: " .. totalTreesPlanted .. 
                           " | Harvested: " .. totalTreesHarvested)
                end
            end
        end
        
        ::continue::
        Sleep(1000)
    end
    
    isRunning = false
    Console("PTHT completed! Final stats:")
    Console("Total PTHT cycles: " .. currentPTHT)
    Console("Total trees planted: " .. totalTreesPlanted)
    Console("Total trees harvested: " .. totalTreesHarvested)
end

-- Configuration Dialog System
local function CHECKBOX(value)
    return value and "1" or "0"
end

local function GetPTHTStatusText()
    local status = {}
    if GetWorld() then
        table.insert(status, "`6World: `2" .. (GetWorld().name or "UNKNOWN"))
        table.insert(status, "`6Trees: `2" .. CountTrees())
        table.insert(status, "`6Ready: `2" .. CountReadyTrees())
        table.insert(status, "`6Remote: `2" .. GetItemCount(5640))
        table.insert(status, "`6PTHT: `2" .. currentPTHT .. "/" .. Settings.MaxPTHT)
        table.insert(status, "`6Magplants: `2" .. #allMagplants)
    else
        table.insert(status, "`4World: DISCONNECTED")
    end
    return table.concat(status, " | ")
end

local function ShowMainConfigDialog()
    if not GetWorld() then
        OverlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local dialog = {
        [0] = "OnDialogRequest",
        [1] = [[
set_default_color|`o
text_scaling_string|pthtConfig
add_label_with_icon|big|`#[`bAntiCheat PTHT`#] `2Configuration|left|15757|
add_spacer|small|
add_label_with_icon|small|Welcome, ]]..Settings.PlayerName..[[|right|2278|
add_textbox|`bAnti-Cheat PTHT Settings by `#@Mupnup|
add_spacer|small|
add_smalltext|]]..GetPTHTStatusText()..[[|
add_spacer|small|

add_textbox|`2Core Settings:|
add_text_input|world|World Name:|]]..Settings.World..[[|20|
add_text_input|seedID|Seed ID:|]]..Settings.SeedID..[[|8|
add_text_input|platformID|Platform ID:|]]..Settings.PlatformID..[[|8|
add_text_input|backgroundID|Background ID:|]]..Settings.BackgroundID..[[|8|
add_text_input|maxPTHT|Max PTHT Cycles:|]]..Settings.MaxPTHT..[[|5|
add_spacer|small|

add_textbox|`3Anti-Cheat Settings:|
add_checkbox|antiCheatMode|`3Enable Anti-Cheat Protection|]]..CHECKBOX(Settings.AntiCheatMode)..[[|
add_checkbox|slowMovement|`3Use Slow Movement|]]..CHECKBOX(Settings.SlowMovement)..[[|
add_text_input|movementDelay|Movement Delay (ms):|]]..Settings.MovementDelay..[[|5|
add_text_input|maxMovesPerSecond|Max Moves/Second:|]]..Settings.MaxMovesPerSecond..[[|3|
add_text_input|postReconnectDelay|Post-Reconnect Delay (ms):|]]..Settings.PostReconnectDelay..[[|5|
add_spacer|small|

add_textbox|`4Automation Settings:|
add_checkbox|autoPlant|`4Auto Plant|]]..CHECKBOX(Settings.AutoPlant)..[[|
add_checkbox|autoHarvest|`4Auto Harvest|]]..CHECKBOX(Settings.AutoHarvest)..[[|
add_checkbox|autoGhost|`4Auto Ghost|]]..CHECKBOX(Settings.AutoGhost)..[[|
add_checkbox|autoSwitchMagplant|`4Auto Switch Magplant|]]..CHECKBOX(Settings.AutoSwitchMagplant)..[[|
add_spacer|small|

add_textbox|`5UWS & Timing Settings:|
add_checkbox|useUWS|`5Enable UWS Usage|]]..CHECKBOX(Settings.UseUWS)..[[|
add_text_input|maxTreesBeforeUWS|Max Trees Before UWS:|]]..Settings.MaxTreesBeforeUWS..[[|8|
add_text_input|plantDelay|Plant Delay (ms):|]]..Settings.PlantDelay..[[|5|
add_text_input|harvestDelay|Harvest Delay (ms):|]]..Settings.HarvestDelay..[[|5|
add_text_input|uwsDelay|UWS Delay (ms):|]]..Settings.UWSDelay..[[|5|
add_spacer|small|

add_textbox|`6Debug & Display:|
add_checkbox|debugMode|`6Debug Mode|]]..CHECKBOX(Settings.DebugMode)..[[|
add_checkbox|showStats|`6Show Statistics|]]..CHECKBOX(Settings.ShowStats)..[[|
add_spacer|small|

add_button|start_ptht|`2Start PTHT|
add_button|stop_ptht|`4Stop PTHT|
add_button|preflight_check|`6Run Pre-flight Check|
add_button|refresh_magplants|`6Refresh Magplants|
add_spacer|small|
add_textbox|`9Quick Setup for POG Farming:|
add_button|quick_setup_pog|`9Quick Setup POG (ID: 15757)|
add_quick_exit||
end_dialog|anticheat_ptht_main|Save & Close|
]]
    }
    SendVariantList(dialog)
end

-- Dialog Handler
AddHook("OnSendPacket", "PTHTConfigHandler", function(type, packet)
    if type == 2 and packet:find("action|dialog_return") then
        if packet:find("dialog_name|anticheat_ptht_main") then
            -- Extract and update settings
            local function extractValue(field)
                return packet:match("text_input|" .. field .. "|([^|]+)")
            end
            
            local function extractCheckbox(field)
                return packet:find("checkbox|" .. field .. "|1") and true or false
            end
            
            -- Update core settings
            local newWorld = extractValue("world")
            if newWorld and newWorld ~= "" then
                Settings.World = newWorld:upper()
            end
            
            local newSeedID = extractValue("seedID")
            if newSeedID and tonumber(newSeedID) then
                Settings.SeedID = tonumber(newSeedID)
            end
            
            local newPlatformID = extractValue("platformID")
            if newPlatformID and tonumber(newPlatformID) then
                Settings.PlatformID = tonumber(newPlatformID)
            end
            
            local newBackgroundID = extractValue("backgroundID")
            if newBackgroundID and tonumber(newBackgroundID) then
                Settings.BackgroundID = tonumber(newBackgroundID)
                allMagplants = FindAllMagplants() -- Refresh magplants
            end
            
            local newMaxPTHT = extractValue("maxPTHT")
            if newMaxPTHT and tonumber(newMaxPTHT) then
                Settings.MaxPTHT = tonumber(newMaxPTHT)
            end
            
            -- Update anti-cheat settings
            Settings.AntiCheatMode = extractCheckbox("antiCheatMode")
            Settings.SlowMovement = extractCheckbox("slowMovement")
            
            local newMovementDelay = extractValue("movementDelay")
            if newMovementDelay and tonumber(newMovementDelay) then
                Settings.MovementDelay = tonumber(newMovementDelay)
            end
            
            local newMaxMoves = extractValue("maxMovesPerSecond")
            if newMaxMoves and tonumber(newMaxMoves) then
                Settings.MaxMovesPerSecond = tonumber(newMaxMoves)
            end
            
            local newPostReconnect = extractValue("postReconnectDelay")
            if newPostReconnect and tonumber(newPostReconnect) then
                Settings.PostReconnectDelay = tonumber(newPostReconnect)
            end
            
            -- Update automation settings
            Settings.AutoPlant = extractCheckbox("autoPlant")
            Settings.AutoHarvest = extractCheckbox("autoHarvest")
            Settings.AutoGhost = extractCheckbox("autoGhost")
            Settings.AutoSwitchMagplant = extractCheckbox("autoSwitchMagplant")
            
            -- Update UWS settings
            Settings.UseUWS = extractCheckbox("useUWS")
            
            local newMaxTrees = extractValue("maxTreesBeforeUWS")
            if newMaxTrees and tonumber(newMaxTrees) then
                Settings.MaxTreesBeforeUWS = tonumber(newMaxTrees)
            end
            
            local newPlantDelay = extractValue("plantDelay")
            if newPlantDelay and tonumber(newPlantDelay) then
                Settings.PlantDelay = tonumber(newPlantDelay)
            end
            
            local newHarvestDelay = extractValue("harvestDelay")
            if newHarvestDelay and tonumber(newHarvestDelay) then
                Settings.HarvestDelay = tonumber(newHarvestDelay)
            end
            
            local newUWSDelay = extractValue("uwsDelay")
            if newUWSDelay and tonumber(newUWSDelay) then
                Settings.UWSDelay = tonumber(newUWSDelay)
            end
            
            -- Update debug settings
            Settings.DebugMode = extractCheckbox("debugMode")
            Settings.ShowStats = extractCheckbox("showStats")
            
            -- Handle buttons
            if packet:find("buttonClicked|start_ptht") then
                Console("Starting PTHT from configuration...")
                -- Reset counters
                currentPTHT = 0
                totalTreesPlanted = 0
                totalTreesHarvested = 0
                -- Start PTHT
                MainPTHTLoop()
            elseif packet:find("buttonClicked|stop_ptht") then
                Console("PTHT stop requested")
                isRunning = false
                OverlayText("`4PTHT Stopped by user")
            elseif packet:find("buttonClicked|refresh_magplants") then
                allMagplants = FindAllMagplants()
                OverlayText("`6Found " .. #allMagplants .. " magplants!")
                ShowMainConfigDialog()
            elseif packet:find("buttonClicked|preflight_check") then
                PreFlightCheck()
                ShowMainConfigDialog()
            elseif packet:find("buttonClicked|quick_setup_pog") then
                -- Quick setup for POG farming
                Settings.SeedID = 15757
                Settings.PlatformID = 3126
                Settings.BackgroundID = 14
                Settings.MaxPTHT = 30
                Settings.UseUWS = true
                Settings.AntiCheatMode = true
                Settings.SlowMovement = true
                OverlayText("`9Quick setup applied for POG farming!")
                ShowMainConfigDialog()
            end
            
            OverlayText("`2Settings saved successfully!")
            return true
        end
    end
    return false
end)

-- Command Handler
AddHook("OnSendPacket", "PTHTCommandHandler", function(type, packet)
    if type == 2 and packet:find("action|input") then
        local text = packet:match("|text|(.+)")
        if text then
            if text == "/pthtconfig" or text == "/ptht" then
                ShowMainConfigDialog()
                return true
            elseif text == "/pthtstatus" then
                OverlayText(GetPTHTStatusText())
                return true
            elseif text == "/pthtstart" then
                Console("Starting PTHT...")
                currentPTHT = 0
                totalTreesPlanted = 0
                totalTreesHarvested = 0
                MainPTHTLoop()
                return true
            elseif text == "/pthtstop" then
                Console("PTHT stop requested")
                isRunning = false
                OverlayText("`4PTHT Stopped")
                return true
            elseif text == "/pthtcheck" then
                PreFlightCheck()
                return true
            elseif text == "/pthtquick" then
                -- Quick setup for POG farming
                Settings.SeedID = 15757
                Settings.PlatformID = 3126
                Settings.BackgroundID = 14
                Settings.MaxPTHT = 30
                Settings.UseUWS = true
                Settings.AntiCheatMode = true
                Settings.SlowMovement = true
                Console("Quick setup applied for POG farming!")
                OverlayText("`9Quick POG setup complete!")
                return true
            end
        end
    end
    return false
end)

-- Start the script
Console("Anti-Cheat PTHT v1.0 initialized")
Console("Commands: /pthtconfig, /pthtstart, /pthtstop, /pthtcheck, /pthtquick")
OverlayText("`2Anti-Cheat PTHT loaded! Use /pthtconfig to setup")