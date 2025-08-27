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


function findItem(id)
    for _, itm in pairs(GetInventory()) do
        if itm.id == id then
            return itm.amount
        end    
    end
    return 0
end

function MembedahNigga()
AddHook("onvariant", "surgery", function(var)
if var[0]:find("OnDialogRequest") and var[1]:find("Status: `4Awake(.+)")then
    if findItem(1262) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_2
]])
        LogToConsole("`w[`cAwZka`w] `^Anesthetic")
    else
        LogToConsole("`4You don't have enough `^Anesthetic")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("end_dialog|surge_edit")then
SendPacket(2,[[
action|dialog_return
dialog_name|surge_edit
x|]]..var[1]:match("embed_data|x|(%d+)")..[[|
y|]]..var[1]:match("embed_data|y|(%d+)")..[[|
]])
LogToConsole("`w[`cAwZka`w] `wAuto `4Surgery `^Starting")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("end_dialog|popup")then
SendPacket(2,[[
action|dialog_return
dialog_name|popup
netID|]]..var[1]:match("embed_data|netID|(%d+)")..[[|
buttonClicked|surgery
]])
LogToConsole("`w[`cAwZka`w] `wAuto `4Surgery `^Starting")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("`4You can't see what you are doing!(.+)")then
if findItem(1258) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_0
]])
LogToConsole("`w[`cAwZka`w] `9Sponge")
    else
        LogToConsole("`4You don't have enough `9Sponge")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient's fever is `3slowly rising.")then
if findItem(1266) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_4
]])
LogToConsole("`w[`cAwZka`w] `#Antibiotics")
    else
        LogToConsole("`4You don't have enough `#Antibiotics")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient's fever is `6climbing.")then
if findItem(1266) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_4
]])
LogToConsole("`w[`cAwZka`w] `#Antibiotics")
    else
        LogToConsole("`4You don't have enough `#Antibiotics")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient's fever is `4climbing rapidly!.")then
if findItem(1266) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_4
]])
LogToConsole("`w[`cAwZka`w] `#Antibiotics")
    else
        LogToConsole("`4You don't have enough `#Antibiotics")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Operation site: `3Not sanitized")then
if findItem(1264) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_3
]])
LogToConsole("`w[`cAwZka`w] `rAntiseptic")
    else
        LogToConsole("`4You don't have enough `rAntiseptic")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Operation site: `6Unclean")then
if findItem(1264) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_3
]])
LogToConsole("`w[`cAwZka`w] `rAntiseptic")
    else
        LogToConsole("`4You don't have enough `rAntiseptic")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Operation site: `4Unsanitary")then
if findItem(1264) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_3
]])
LogToConsole("`w[`cAwZka`w] `rAntiseptic")
    else
        LogToConsole("`4You don't have enough `rAntiseptic")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("`6It is becoming hard to see your work.")then
if findItem(1258) > 1 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_0
]])
LogToConsole("`w[`cAwZka`w] `9Sponge")
    else
        LogToConsole("`4You don't have enough `9Sponge")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient is losing blood `4very quickly!")then
if findItem(1270) > 1 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_6
]])
LogToConsole("`w[`cAwZka`w] `8Stitches")
    else
        LogToConsole("`4You don't have enough `8Stitches")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient is `6losing blood!")then
if findItem(1270) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_6
]])
LogToConsole("`w[`cAwZka`w] `8Stitches")
    else
        LogToConsole("`4You don't have enough `8Stitches")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient is losing blood `3slowly")then
if findItem(1270) > 1 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_6
]])
LogToConsole("`w[`cAwZka`w] `8Stitches")
    else
        LogToConsole("`4You don't have enough `8Stitches")
    end
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("1296") and var[1]:find("Incisions: `30(.+)")  then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_7
]])
LogToConsole("`w[`cAwZka`w] `^Fix It!")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("1296") and var[1]:find("Incisions: `31(.+)")  then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_7
]])
LogToConsole("`w[`cAwZka`w] `^Fix It!")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("1296") and var[1]:find("Incisions: `32(.+)")  then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_7
]])
LogToConsole("`w[`cAwZka`w] `^Fix It!")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("1296") and var[1]:find("Incisions: `33(.+)")  then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_7
]])
LogToConsole("`w[`cAwZka`w] `^Fix It!")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("1296") and var[1]:find("Incisions: `44(.+)")  then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_7
]])
LogToConsole("`w[`cAwZka`w] `^Fix It!")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("1296") and var[1]:find("Incisions: `45(.+)")  then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_7
]])
LogToConsole("`w[`cAwZka`w] `^Fix It!")
return true
elseif var[0]:find("OnDialogRequest") and var[1]:find("1260") then
if findItem(1262) > 0 then
SendPacket(2,[[
action|dialog_return
dialog_name|surgery
buttonClicked|command_1
]])
LogToConsole("`w[`cAwZka`w] Scalpel")
    else
        LogToConsole("`4You don't have enough `wScalpel")
    end
return true
end
return false
end)
end

while true do
MembedahNigga()
Sleep(25)
end