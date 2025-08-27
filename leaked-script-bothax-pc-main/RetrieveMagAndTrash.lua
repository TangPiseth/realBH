--[ Please stand on the Magplant ] --

-- DO NOT TOUCH ANY PART BELOW --
IDs = 15343
SpeedTrash = 500

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

magX = math.floor(GetLocal().pos.x / 32)
magY = math.floor(GetLocal().pos.y / 32 + 1)
AddHook("onvariant", "hook", function(var)
	if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT") then
		return true
	end
	if var[0] == "OnTextOverlay" and var[1]:find("`4You don't have enough of those!") then
		trash = false
	end
	return false
end)
SendPacketRaw(false, {type = 3, value = 32, px = magX, py = magY, x = magX * 32, y = magY * 32})
Sleep(1000)
trash = true
while trash do
	SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. magX .. "|\ny|" .. magY .. "|\nbuttonClicked|withdraw")
	Sleep(SpeedTrash)
	SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. IDs .. "|\nitem_count|50")
	Sleep(SpeedTrash)
end
RemoveHooks()
