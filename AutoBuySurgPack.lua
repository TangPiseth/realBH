SendPacket(2,"action|input\ntext|`bSCRIPT `0BY `c@AwZka `2ACTIVATED !! `0(tongue)")

SendVariantList({[0] = "OnDialogRequest", [1] = [[
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
add_quick_exit|]]})

itemPack = "buy_surgkit"
itemList = {
    1258,
    1260,
    1262,
    1264,
    1266,
    1268,
    1270
}

moveTrue = false
AddHook("onvariant", "mommy", function(var)
    if var[0] == "OnTextOverlay" and var[1]:find("You can't drop that here, face somewhere with open space.") then
        moveTrue = true
        return true
    end
    return false
end)

local function findItem(id)
    count = 0
    for _, inv in pairs(GetInventory()) do
        if inv.id == id then
            count = count + inv.amount
        end
    end
    return count
end

local function scanObject(id)
    count = 0
    for _, object in pairs(GetObjectList()) do
        if object.id == id then
            count = count + object.amount
        end
    end
    return count
end

local function dropPacks()
    GetX, GetY = math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32)
    for _, packList in pairs(itemList) do
        if findItem(packList) >= 1 then
            SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|".. packList .."|\nitem_count|".. findItem(packList))
            Sleep(250)
            LogToConsole(GetItemInfo(packList).name ..": `2".. scanObject(packList))
            SendVariantList({[0] = "OnTextOverlay", [1] = "`9Auto Drop When Max `2SUCCESS `0!!"})
        end
    end
    
    if moveTrue then
        FindPath(GetX + 1, GetY, 60)
        moveTrue = false
    end
end

while true do
    Sleep(250)
    SendPacket(2, "action|buy\nitem|".. itemPack)
    for _, packList in pairs(itemList) do
        if findItem(packList) >= 250 then
            Sleep(100)
            dropPacks()
        end
    end
end