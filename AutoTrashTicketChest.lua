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

SpeedTrash = 200

local IDs = {
    {1898, 1898}, {15362, -176}, {15360, -174}, {15806, -620}, {15358, -172}
}

local function Count(id)
    for _, item in pairs(GetInventory()) do
        if item.id == id then
            return item.amount
        end
    end
    return 0
end

while true do
    for _, item in ipairs(IDs) do
        if Count(item[1]) >= 100 then
            SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. item[2] .. "|\nitem_count|" .. Count(item[1]))
            Sleep(SpeedTrash)
        else
            Sleep(SpeedTrash)
        end
    end
end