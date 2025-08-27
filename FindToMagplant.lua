--[ Please stand on the Magplant ] --

-- DO NOT TOUCH ANY PART BELOW --
IDs = 1255
SpeedAdd = 500

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

local magplantX, magplantY = 0, 0
local magplantFill = true 
AddHook("onvariant", "SiGmA", function(var)
    if var[0] == "OnDialogRequest" and var[1]:find("Item Finder") then
        return true
    elseif var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT 5000") then
        magplantX = tonumber(var[1]:match("embed_data|x|(%d+)"))
        magplantY = tonumber(var[1]:match("embed_data|y|(%d+)"))
        return true
    elseif var[0] == "OnConsoleMessage" and var[1]:find("This doesn't fit") then
        magplantFill = false
        return true
    end
end)

local function wrench(x, y)
    local pkt = {
        type = 3,
        value = 32,
        px = math.floor(GetLocal().pos.x / 32 + x),
        py = math.floor(GetLocal().pos.y / 32 + y),
        x = GetLocal().pos.x,
        y = GetLocal().pos.y
    }
    SendPacketRaw(false, pkt)
end

while true do
    if magplantX ~= 0 and magplantY ~= 0 then
        Sleep(250)
        
        wrench(0, 1)
        
        if magplantFill then
            SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. IDs .. "|1")
            Sleep(250)
            SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. magplantX .. "|\ny|" .. magplantY .. "|\nbuttonClicked|additems")
            Sleep(SpeedAdd)
        else
            magplantX = magplantX + 1
            FindPath(magplantX, magplantY - 1, 60)
            magplantFill = true
        end
    end
end