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

delay = 250

while true do
SendPacketRaw(false,{type = 3,value = 32,px = GetLocal().pos.x//32,py = GetLocal().pos.y//32,x = GetLocal().pos.x,y = GetLocal().pos.y})
Sleep(delay)
SendPacket(2,"action|dialog_return\ndialog_name|vend_buyconfirm\nx|"..( GetLocal().pos.x//32 ).."|\ny|"..( GetLocal().pos.y//32 ).."|\nbuyamount|250")
Sleep(delay)
SendPacket(2, "action|dialog_return\ndialog_name|givexgems\nitem_id|-484|\nitem_count|250")
Sleep(delay)
end