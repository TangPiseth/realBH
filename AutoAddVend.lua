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

AddHook("onvariant", "ADD VEND", function(var)
if var[0] == "OnDialogRequest" and var[1]:find("DigiVend Machine") then
XX = var[1]:match("embed_data|x|(%d+)")
YY = var[1]:match("embed_data|y|(%d+)")
SendPacket(2, "action|dialog_return\ndialog_name|vend_edit\nx|".. XX .."|\ny|".. YY .."|\nbuttonClicked|addstock\n")
SendVariantList({[0] = "OnTextOverlay", [1] = "`0[ `c@AwZka `0] `9Added Items to Vending `2SUCCESS `9!!"})
return true
end
return false
end)

