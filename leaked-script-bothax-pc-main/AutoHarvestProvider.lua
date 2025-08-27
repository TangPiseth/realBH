tabel_uid = {
    "101311",
    "930145",
    "929020"
}

local platY = GetLocal().pos.y / 32
local WORLD = GetWorld().name

local function say(txt)
    SendPacket(2,"action|input\ntext|`9"..txt)
end

local function awloggs(text)
    LogToConsole("`w[`cAwZka`w] `9"..text)
end

--[Main Script]
function main()
    local sizeX, sizeY

    local worldType = WORLD_TYPE

    if worldType == "NORMAL" then
        sizeX, sizeY = 100, 60
    elseif worldType == "NETHER" then
        sizeX, sizeY = 150, 150
    elseif worldType == "ISLAND" then
        sizeX, sizeY = 200, 200
    else
        awloggs("WARNING: Unrecognized world type '" .. tostring(WORLD_TYPE) .. "'. Using default NORMAL world settings.")
        sizeX, sizeY = 100, 60
    end

    awloggs("World Type: " .. tostring(WORLD_TYPE) .. ", Size: " .. sizeX .. "x" .. sizeY)
	Sleep(1000)

    harvestTiles = {}
    for harvestX = 0, sizeX - 1, 1 do
        for harvestY = sizeY - 2, 0, -1 do
            if GetTile(harvestX, harvestY).fg == PROVIDER_ID and harvestY <= platY then
                table.insert(harvestTiles, {x = harvestX, y = harvestY})
            end
        end
    end

    awloggs("Total harvest tiles found: " .. #harvestTiles)
	Sleep(1000)

    local totalHarvestedProviders = 0
    local allProvidersHarvested = false

    for i = 1, 3 do
        if allProvidersHarvested then
            break
        end

        awloggs("Harvest iteration " .. i)
        local harvestedThisIteration = 0

        for _, tile in pairs(harvestTiles) do
            local currentTile = GetTile(tile.x, tile.y)
            if currentTile.fg == PROVIDER_ID then
                local progress = currentTile.extra and currentTile.extra.progress or 0
                
                if progress == 1 then
                    SendPacketRaw(false, {state = 32, x = tile.x * 32, y = tile.y * 32})
                    SendPacketRaw(false, {type = 3, value = 18, px = tile.x, py = tile.y, x = tile.x * 32, y = tile.y * 32})
                    SendPacketRaw(false, {state = 4196896, px = tile.x, py = tile.y, x = tile.x * 32, y = tile.y * 32})
                    SendPacketRaw(false, {state = 16779296, px = tile.x, py = tile.y, x = tile.x * 32, y = tile.y * 32})
                    
                    awloggs(string.format("Harvested tile at (%d, %d)", tile.x, tile.y))
                    
                    totalHarvestedProviders = totalHarvestedProviders + 1
                    harvestedThisIteration = harvestedThisIteration + 1
                    
                    Sleep(DELAY_HT)
                end
            end
        end

        if harvestedThisIteration == 0 then
            allProvidersHarvested = true
        end
    end

    awloggs("TOTAL PROVIDERS HARVESTED: " .. totalHarvestedProviders)
	Sleep(1000)

    if allProvidersHarvested then
        say("All providers have been harvested. `4Stopping script.")
        return
    end
end

local function hook_1(varlist)
    if varlist[0]:find("OnConsoleMessage") then
        if varlist[1]:find("Spam detected!") then
            return true
        end
    end
    if varlist[0] == "OnSDBroadcast" then
        return true
    end
    return false
end
AddHook("onvariant", "hook one", hook_1)

local user = GetLocal().userid
local match_found = false

for _, id in pairs(tabel_uid) do
    if user == tonumber(id) then
        match_found = true
        break
    end
end

DetachConsole()
if match_found then
    awloggs("`2Verifying `bUID...")
    Sleep(1000)
    awloggs("`bUID `9SUCCESSFULLY `2DETECTED `0! `e"..GetLocal().userid)
    Sleep(1000)
    awloggs("`6You’ve been `2VERIFIED `0!")
    Sleep(1000)
    say("`8Auto Make `5Glue `0by `cAwZka")

    main()
else
    awloggs("`2Verifying `bUID...")
    Sleep(1000)
    say("`bUID `4NOT VERIFIED")
    Sleep(1000)
    awloggs("`9Heads up `0! You need to enter your `bUID `9for `2ACCESS.")
end