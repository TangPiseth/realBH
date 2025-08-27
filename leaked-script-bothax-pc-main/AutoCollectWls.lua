-- Please Put TELEPHONE in Your World !--

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

local Vends = {}

local worldX, worldY = GetTile(199, 199) and 199 or 99, GetTile(199, 199) and 199 or 59
for y = worldY, 0, -1 do
    for x = 0, worldX do
        local tile = GetTile(x, y)
        if tile.fg == 9268 then
            table.insert(Vends, { x = x, y = y })
        end
    end
end

local function wrench(x, y)
    local pkt = {
        type = 3,
        value = 32,
        px = x,
        py = y,
        x = GetLocal().pos.x,
        y = GetLocal().pos.y
    }
    SendPacketRaw(false, pkt)
end

function ConvertDLtoBGL()
    if Inventory(1796) >= 100 then
        local posX, posY = math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32)
        local tiles = {}

        for y = worldY, 0, -1 do
            for x = 0, worldX do
                local tile = GetTile(x, y)
                if tile.fg == 3898 then
                    table.insert(tiles, { x = x, y = y })
                end
            end
        end

        local minDist, coor = math.huge, nil
        for _, xy in ipairs(tiles) do
            local dist = math.sqrt((posX - xy.x)^2 + (posY - xy.y)^2)
            if dist < minDist then
                minDist = dist
                coor = xy
            end
        end

        if coor then
            local telX, telY = coor.x, coor.y
            local lastPosX, lastPosY = posX, posY
            
            if FindPath(telX, telY) then
                while math.floor(GetLocal().pos.x / 32) ~= telX or math.floor(GetLocal().pos.y / 32) ~= telY do
                    Sleep(100)
                end

                SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|" .. telX .. "|\ny|" .. telY .. "|\nbuttonClicked|bglconvert")
                Sleep(500)
            end

            if FindPath(lastPosX, lastPosY) then
                while math.floor(GetLocal().pos.x / 32) ~= lastPosX or math.floor(GetLocal().pos.y / 32) ~= lastPosY do
                    Sleep(100)
                end
            end
        else
            LogToConsole("`0[`4ERROR`0] `9No `5Telephone `w(`2IDs: `b3898`w) `9found in the world!`")
        end
    end
end

AddHook("onvariant", "hook", function(var)
    if var[0] == "OnDialogRequest" and var[1]:match("Withdraw") then
        local nx, ny = math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32)
        SendPacket(2, "action|dialog_return\ndialog_name|vend_edit\nx|" .. nx .. "|\ny|" .. ny .. "|\nbuttonClicked|pullwls|1")
        return true
    end
end)

local function MoveAndWrench(vend)
    if FindPath(vend.x, vend.y) then
        while math.floor(GetLocal().pos.x / 32) ~= vend.x or math.floor(GetLocal().pos.y / 32) ~= vend.y do
            Sleep(100)
        end

        wrench(vend.x, vend.y)
        Sleep(250)
    end
end

function Inventory(ItemID)
    for _, Inv in pairs(GetInventory()) do
        if Inv.id == ItemID then
            return Inv.amount
        end
    end
    return 0
end

function DoubleClick(ITEM_ID)
    local packet = {
        type = 10,
        value = ITEM_ID
    }
    SendPacketRaw(false, packet)
    Sleep(300)
end

local lastVendIndex = 1 

while true do
    if Inventory(242) >= 100 then

        while Inventory(242) >= 100 do
            DoubleClick(242)
            Sleep(300)
        end

        local vend = Vends[lastVendIndex]
        if vend then
            FindPath(vend.x, vend.y)
            while math.floor(GetLocal().pos.x / 32) ~= vend.x or math.floor(GetLocal().pos.y / 32) ~= vend.y do
                Sleep(100)
            end
        end
    end

    if Inventory(1796) >= 100 then
        ConvertDLtoBGL()
        Sleep(500)

        local vend = Vends[lastVendIndex]
        if vend then
            FindPath(vend.x, vend.y)
            while math.floor(GetLocal().pos.x / 32) ~= vend.x or math.floor(GetLocal().pos.y / 32) ~= vend.y do
                Sleep(100)
            end
        end
    end

    for i = lastVendIndex, #Vends do
        local vend = Vends[i]
        if Inventory(242) < 100 then
            lastVendIndex = i 
            MoveAndWrench(vend)
            Sleep(250)
        else
            break
        end
    end

    if lastVendIndex >= #Vends then
        lastVendIndex = 1
    end
end
