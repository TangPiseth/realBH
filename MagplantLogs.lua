IDs = 3004 -- Background ID
SpeedCheck = 100 -- Delay [ if magplant more than 10 Recommended set delay to 250-300]

-- DO NOT TOUCH ANY PART BELOW --

SendPacket(2,"action|input\ntext|`bSCRIPT `0BY `c@AwZka `2ACTIVATED !! `0(tongue)")
ps =
[[set_default_color||
add_label_with_icon|small|`8Script by `c@AwZka                   |left|3524|
add_spacer|small|
add_label_with_icon|small|`9Username: `c]]..GetLocal().name..[[|right|1794|
add_spacer|small|
add_label_with_icon|small|`9Current World: `#]]..GetWorld().name..[[|left|3802|
add_spacer|small|
add_label_with_icon|small|`4!! `bDon't Sell My `9SCRIPT `4!!|left|6278|
add_spacer|small|
add_url_button|comment|`eDiscord Server|noflags|https://discord.gg/gT47nWgm|Would you like to join my `eDiscord Server?|
end_dialog|c|Close|
add_quick_exit||]]
SendVariantList{[0] = "OnDialogRequest",[1] = ps}

local CurrentStock, Mags = {}, {}
local worldX, worldY = GetTile(199, 199) and 199 or 99, GetTile(199, 199) and 199 or 59

local function intToString(i)
    return tostring(i):reverse():gsub("%d%d%d", "%1,"):reverse():gsub("^,", "")
end

AddHook("onvariant", "calculate", function(var)
    if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT 5000") then
        var[1] = var[1]:gsub("`.", "")
        local Names, theIDs = var[1]:match("add_label_with_icon|small|([^|]+)|left|(%d+)|")
        local CheckStock = var[1]:match("Stock: (%d+) items.")
        
        if Names and theIDs and CheckStock then
            CurrentStock[theIDs] = CurrentStock[theIDs] or { name = Names, stock = 0 }
            CurrentStock[theIDs].stock = CurrentStock[theIDs].stock + tonumber(CheckStock)
        end
        return true
    end
    return false
end)

local SearchMag = false

for y = worldY, 0, -1 do
    for x = 0, worldX do
        local tile = GetTile(x, y)
        if tile.fg == 5638 and tile.bg == IDs then
            table.insert(Mags, { x = x, y = y })
            SearchMag = true
        end
    end
end

if not SearchMag then
    LogToConsole("`w[ `4ERROR `w] `9Unable to find `cMagplant")
    LogToConsole("`8Make Sure You've set the `5Background ID `2Correctly")
    return
end

-- if scanning more than 10 magplants Auto Adjust Enable --
if #Mags > 10 then
    SpeedCheck = 300
    LogToConsole("[ `4WARNING `$] `wAuto-adjusting delay to `c300 `wfor stability")
end

LogToConsole("`wScanning `2" .. #Mags .. " `cMagplant")
LogToConsole("[`wApproximate Duration: `2" .. math.ceil((#Mags * (SpeedCheck * 2)) / 1000) .. " Seconds`$]")

for index, coord in ipairs(Mags) do
    local x, y = coord.x, coord.y
    SendPacketRaw(false, { px = x, py = y, x = x * 32, y = y * 32, state = 32 })
    Sleep(SpeedCheck)
    SendPacketRaw(false, { type = 3, value = 32, px = x, py = y, x = x * 32, y = y * 32 })
    Sleep(SpeedCheck)
    LogToConsole("`wProgress [`2" .. index .. "`w/`2" .. #Mags .. "`w] `wMagplants scanned.") -- Track Scanning Progress --
end

-- Sort items by stock amount in descending order --
local sortedStock = {}
for id, data in pairs(CurrentStock) do
    table.insert(sortedStock, { id = id, name = data.name, stock = data.stock })
end

table.sort(sortedStock, function(a, b) return a.stock > b.stock end)

local dialog = {
    "add_label_with_icon|big|`wMags Scanned: `2" .. #Mags .. " `wMagplant|left|5638|",
    "add_label_with_icon|big|`wElapsed Time: `2" .. math.ceil(((#Mags * (SpeedCheck * 2)) / 1000) + 1) .. " `wSeconds|left|7864|",
    "add_spacer|small|",
}

for _, data in ipairs(sortedStock) do
    table.insert(dialog, "add_label_with_icon|small|`w[ `c" .. intToString(data.stock) .. " `w] `7" .. data.name .. "|left|" .. data.id .. "|")
end

table.insert(dialog, "end_dialog|magplant_stock|Exit|")
SendVariantList({ [0] = "OnDialogRequest", [1] = table.concat(dialog, "\n") })