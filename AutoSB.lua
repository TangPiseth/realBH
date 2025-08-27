--->>> SuperBroadcast Script by AwZka <<<---

--->>> EDIT AREA <<<---
local WEBHOOK_SB = "https://discord.com/api/webhooks/1360477988986028082/S2oRmKiZG_0BlOm0jiTe9n1bbochizWh1_xl-IKbZDoQEiDhC_fS6_4K0z8ekYZE4Z-3"
local USER_TO_PING = "1094219942309666860"

--------------------------------------

--->>> DON'T TOUCH ANYTHING HERE <<<---
local XSB,YSB = GetLocal().pos.x //32 , GetLocal().pos.y //32
local WORLD_SB = GetWorld().name
local NAME = GetLocal().name
local GEMSB = GetPlayerInfo().gems
local delay = 1.5
local MULAI_SB = os.time()
local USED_GEMS = 0
local USED_BGEMS = 0
local SISABGEMS = 0
local COUNT = 0
local COUNTS = 0
local JUMLAH_SB = 0
local STARTSB = false
local SCOPY = false
local LONELY = false
local WDON = false
local logfake = "spun"
local safesb = false
local PTIME = os.time() - MULAI_SB
local PERKIRAANBERESSB = COUNT, MULAI_SB, JUMLAH_SB, delay
local BERESSB = PERKIRAANBERESSB
local SISA_SB = JUMLAH_SB - COUNT
local ALLSB = JUMLAH_SB * 1.5
local MENITS = ALLSB - COUNTS
local NAME_USERS = GetLocal().name

function AWZKAS(awzka)
SendVariantList({[0] = "OnTextOverlay", [1] = awzka })
end
function wrn(text)
text = text
awzka = {}
awzka[0] = "OnAddNotification"
awzka[1] = "interface/atomic_button.rttex"
awzka[2] = text
awzka[3] = "audio/hub_open.wav"
awzka[4] = 0
SendVariantList(awzka)
end

local success = false
AddHook("onvariant","var",function(var)
if var[0]:find("OnConsoleMessage") and var[1]:find("`4Unknown command.") then
return true
end
if var[0]:find("OnDialogRequest") and var[1]:find("add_text_input") then
for _, awzka in ipairs(var) do
local left, right = awzka:find("display_text||")
if left then
local textsign = awzka:find("|", right  + 1)
if textsign then
local text = awzka:sub(right + 1, textsign - 1)
LogToConsole("`2Success `0Set TEXT SB : ".. text)
AWZKAS("`2Success `0Set TEXT SB : ".. text)
TEXT_SB = text
return true
end
end
end
end
if var[0]:find("OnConsoleMessage") and var[1]:find(">> `5Super") then
    local used_gems = tonumber(var[1]:match("Used `$(%d+) Gems")) or 0
    local used_bgems = tonumber(var[1]:match("Used `$(%d+) Black Gems")) or 0
    local sisa_bgems = var[1]:match("`$(%d+)`` left") or "0"
    USED_GEMS = (USED_GEMS or 0) + used_gems
    USED_BGEMS = (USED_BGEMS or 0) + used_bgems
    SISABGEMS = tonumber(sisa_bgems) or 0
    return true
end

if var[0] == "OnSDBroadcast" then
LogToConsole("`4//BLOCKED SDB//")
return true
end
if var[0] == "OnConsoleMessage" and var[1]:find("Where would you like to go?") then
SendPacket(3,"action|join_request\nname|"..WORLD_SB.."\ninvitedWorld|0")
return true
end
if var[0] == "OnConsoleMessage" and var[1]:find("```w(.+)`` `%$World Locked``") then
local dcdc = var[1]:match("```w(.+)`` `%$World Locked``")
if safesb then
if dcdc ~= WORLD_SB then
SendPacket(3,"action|join_request\nname|"..WORLD_SB.."\ninvitedWorld|0")
return true
end
end
end
if var[0] == "OnConsoleMessage" and var[1]:find("World Locked") then
FindPath(XSB,YSB)
return true
end
if var[0]:find("OnDialogRequest") and var[1]:find("add_player_info") then
return true
end
if var[0] == "OnConsoleMessage" and var[1]:find("has been queued") then
success = true
end
return false
end)

SendVariantList({ [0] = "OnDialogRequest", [1] = [[
add_label_with_icon|big|`4Super Broadcast `cAwZka|left|2480|
add_textbox|																														|
add_label_with_icon|small|`0Command List|left|14824|
add_spacer|small|
add_smalltext|`9/menu `w[ Show Menu ]|
add_smalltext|`9/info `w[ Show Info ]|
add_spacer|small|
add_smalltext|`9/copy `w[ Copy Text SB ]|
add_smalltext|`9/count `2{amount} `w[ Set How Many Count SB ]|
add_smalltext|`9/1h `w[ +1 Hours ]|
add_smalltext|`9/2h `w[ +2 Hours ]|
add_smalltext|`9/3h `w[ +3 Hours ]|
add_smalltext|`9/csb `2{amount} `w[ +{amount} Sb ]|
add_smalltext|`9/wdone `2{name} `w[ Set World Done SB ]|
add_spacer|small|
add_smalltext|`9/start `w[ Start SB ]|
add_smalltext|`9/stop `w[ Stop Sb ]|
add_spacer|small|
add_smalltext|`9/ads `w[ Set Your Name + World SB ]|
add_smalltext|`wExample : `cAwZka`1[`2BTK`1]|
add_smalltext|`9/solo `w[ Lonely Mode ]|
add_smalltext|`9/safe `w[ Safe Features ]|
add_smalltext|`9/fake `w[ Fake Logs ]|
add_spacer|small|
add_quick_exit||
end_dialog|cmdend|Close|
]]})
AddHook("onsendpacket", "AWZKASB", function(type,str)
if str:find("/fake") then
SendVariantList({ [0] = "OnDialogRequest", [1] = [[
add_label_with_icon|big|`4Fake `wWheel Logs|left|1436|
add_spacer|small|
add_button|resetf|`4Reset|noflags|0|
]]..logfake..[[
add_quick_exit||
add_button|link|Back|
]] })
return true
end
if str:find("/info") then
SendVariantList({ [0] = "OnDialogRequest", [1] = [[
add_label_with_icon|big|`4Super Broadcast `cAwZka|left|2480|
add_textbox|																														|
add_label_with_icon|small|Welcome back, ]]..NAME_USERS..[[|right|2278|
add_spacer|small|
add_label_with_icon|small|`wCurrent World `0: `1]] ..WORLD_SB.. [[|left|3802|
add_label_with_icon|small|`wPath: ]]..math.floor(GetLocal().pos.x / 32)..[[ [ `9x `w] ]]..math.floor(GetLocal().pos.y / 32)..[[ `w[ `6y `w]|left|1684|
add_spacer|small|
add_label_with_icon|small|`wInformation|left|3524|
add_spacer|small|

add_smalltext|`9SB `2Amount `b: `b]] ..JUMLAH_SB.. [[ `wx SB|
add_smalltext|`9SB `4Remains `b: `b]] ..SISA_SB.. [[ `wx Left|
add_smalltext|`9SB `cSend `b: `b]] ..COUNT.. [[ `wx Done|
add_spacer|small|

add_label_with_icon|small|`wGems|left|15670|
add_spacer|small|
add_smalltext|`cCurrent Gems `0: `w]]..KOMA(GetPlayerInfo().gems)..[[ |
add_smalltext|`cGems Used `0: `w]] ..KOMA(USED_GEMS).. [[ |
add_spacer|small|

add_label_with_icon|small|`wTime|left|7864|
add_spacer|small|
add_smalltext|`9Start SB `0: `b]] .. os.date(" %I:%M %p ", MULAI_SB) .. [[|
add_smalltext|`9SB Duration `0: `b]] .. math.floor(JUMLAH_SB*1.5).. [[ `wMinutes|
add_smalltext|`9End SB `0: `b]] .. os.date(" %I:%M %p ", BERESSB) .. [[|
add_smalltext|`9Remains `0: `b]] .. MENITS .. [[ `wMinutes Left!|
add_spacer|small|
add_smalltext|`b]] .. math.floor(PTIME%86400/3600) ..[[ `0Hours `b]].. math.floor(PTIME%86400%3600/60) ..[[ `0Minutes `b]].. math.floor(PTIME%3600%60) .. [[ `0Seconds|
add_spacer|small|

add_label_with_icon|small|`wCredits|left|394|
add_spacer|small|
add_smalltext|`0Thanks For Buying My `4SuperBroadcast `bScript|
add_smalltext|`9Script By `cAwZka Community|
add_smalltext|`0Have `4Bug `0or Any `4Issue`0?|
add_smalltext|`0DM `eDiscord `w[ `c@azkassasin `w]|
add_spacer|small|

add_label_with_icon|big|`wVersion `21.0|left|11816|
add_spacer|small|

add_quick_exit||
end_dialog|cmdend|Close|
]]})
return true
end
if str:find("/menu") then
SendVariantList({ [0] = "OnDialogRequest", [1] = [[
add_label_with_icon|big|`4Super Broadcast `cAwZka|left|2480|
add_textbox|																														|
add_label_with_icon|small|`0Command List|left|14824|
add_spacer|small|
add_smalltext|`9/menu `w[ Show Menu ]|
add_smalltext|`9/info `w[ Show Info ]|
add_spacer|small|
add_smalltext|`9/copy `w[ Copy Text SB ]|
add_smalltext|`9/count `2{amount} `w[ Set How Many Count SB ]|
add_smalltext|`9/1h `w[ +1 Hours ]|
add_smalltext|`9/2h `w[ +2 Hours ]|
add_smalltext|`9/3h `w[ +3 Hours ]|
add_smalltext|`9/csb `2{amount} `w[ +{amount} Sb ]|
add_smalltext|`9/wdone `2{name} `w[ Set World Done SB ]|
add_spacer|small|
add_smalltext|`9/start `w[ Start SB ]|
add_smalltext|`9/stop `w[ Stop Sb ]|
add_spacer|small|
add_smalltext|`9/ads `w[ Set Your Name + World SB ]|
add_smalltext|`wExample : `cAwZka`1[`2BTK`1]|
add_smalltext|`9/solo `w[ Lonely Mode ]|
add_smalltext|`9/safe `w[ Safe Features ]|
add_smalltext|`9/fake `w[ Fake Logs ]|
add_spacer|small|
add_quick_exit||
end_dialog|cmdend|Close|
]]})
return true
end
if str:find("/copy") then
SCOPY = true
LogToConsole("`c`9Wrench Sign to `2Copy Text")
AWZKAS("`c`9Wrench Sign to `2Copy Text")
return true
end
if str:find("/safe") then
safesb = true
LogToConsole("`cSafe Features `0[ `2ACTIVATED `0]")
AWZKAS("`cSafe Features `0[ `2ACTIVATED `0]")
return true
end
if str:find("/1h") then
JUMLAH_SB = JUMLAH_SB + 40
ALLSB = JUMLAH_SB * 1.5
BERESSB = PERKIRAANBERESSB(COUNT, MULAI_SB, JUMLAH_SB, delay)
LogToConsole("`c+1 Hours SB Time")
AWZKAS("`c+1 Hours SB Time")
return true
end
if str:find("/2h") then
JUMLAH_SB = JUMLAH_SB + 80
ALLSB = JUMLAH_SB * 1.5
BERESSB = PERKIRAANBERESSB(COUNT, MULAI_SB, JUMLAH_SB, delay)
LogToConsole("`c+2 Hours SB Time")
AWZKAS("`c+2 Hours SB Time")
return true
end
if str:find("/3h") then
JUMLAH_SB = JUMLAH_SB + 120
ALLSB = JUMLAH_SB * 1.5
BERESSB = PERKIRAANBERESSB(COUNT, MULAI_SB, JUMLAH_SB, delay)
LogToConsole("`c+3 Hours SB Time")
AWZKAS("`c+3 Hours SB Time")
return true
end
if str:find("/count (%d+)") then
SBT = str:match("/count (%d+)")
JUMLAH_SB = tonumber(SBT)
ALLSB = JUMLAH_SB * 1.5
BERESSB = PERKIRAANBERESSB(COUNT, MULAI_SB, JUMLAH_SB, delay)
LogToConsole("`cSet `9"..SBT.." Count SB `0[ `2ACTIVATED `0]")
AWZKAS("`cSet `9"..SBT.." Count SB `0[ `2ACTIVATED `0]")
return true
end
if str:find("/count (%d+)") then
SBC = str:match("/count (%d+)")
JUMLAH_SB = JUMLAH_SB + SBC
ALLSB = JUMLAH_SB * 1.5
BERESSB = PERKIRAANBERESSB(COUNT, MULAI_SB, JUMLAH_SB, delay)
LogToConsole("`cSet `9"..SBC.." Count SB `0[ `2ACTIVATED `0]")
AWZKAS("`cSet `9"..SBC.." Count SB `0[ `2ACTIVATED `0]")
return true
end
if str:find("/ads") then
AA = math.random(1,9)
BB = math.random(1,9)
SendPacket(2, "action|input\ntext|/nick "..NAMESB.."`"..AA.."[`"..BB..""..WORLD_SB.."`"..AA.."]")
LogToConsole("`2Success `0Set Nick "..NAMESB.."`"..AA.."[`"..BB..""..WORLD_SB.."`"..AA.."]")
AWZKAS("`2Success `0Set Nick "..NAMESB.."`"..AA.."[`"..BB..""..WORLD_SB.."`"..AA.."]")
return true
end
if str:find("/solo") then
if LONELY == false then
LONELY = true
SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_lonely|1\ncheck_Antibounce|1")
LogToConsole("`cLonely Mode `0[ `2ON `0]")
AWZKAS("`cLonely Mode `0[ `2ON `0]")
else
LONELY = false
SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_lonely|0\ncheck_Antibounce|1")
LogToConsole("`cLonely Mode `0[ `4OFF `0]")
AWZKAS("`cLonely Mode `0[ `4OFF `0]")
return true
end
end
if str:find("/wdone (.+)") then
DONE_WORLD = str:match("/wdone (.+)")
WDON = true
LogToConsole("`cWorld SB Set to `w: "..DONE_WORLD)
AWZKAS("`cWorld SB Set to `w: "..DONE_WORLD)
return true
end
if str:find("/start") then
STARTSB = true
LogToConsole("`2Starting `cSuperBroadcast..")
AWZKAS("`2Starting `cSuperBroadcast..")
return true
end
if str:find("/stop") then
STARTSB = false
LogToConsole("`4Stopping `cSuperBroadcast..")
AWZKAS("`4Stopping `cSuperBroadcast..")
return true
end
return false
end)
function getname()
inputName = GetLocal().name
namePos = string.find(inputName, "% ")
if namePos then
extractedString = string.sub(inputName, 1, namePos - 1)
return extractedString
else
return inputName
end
end
NAMESB = getname()
function KOMA(num)
num = math.floor(num + 0.5)
local formatted = tostring(num)
local k = 3
while k < #formatted do
formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
k = k + 4
end
return formatted
end

function PERKIRAANBERESSB(COUNT, MULAI_SB, JUMLAH_SB, delay)
if COUNT == 0 then
return MULAI_SB + (JUMLAH_SB * delay * 60)
else
return MULAI_SB + ((JUMLAH_SB - COUNT) * delay * 60)
end
end

function namebersih(str)
local cleanedStr = string.gsub(str, "`(%S)", '')
cleanedStr = string.gsub(cleanedStr, "`{2}|(~{2})", '')
return cleanedStr
end

function LOGS(AWZKA)
LogToConsole(""..AWZKA)
end



while true do
if STARTSB then
SendPacket(2, "action|input\ntext|/me `0[ `cThanks `0] `9For Buying `5SuperBroadcast ")
Sleep(1000)
SendPacket(2, "action|input\ntext|/me `0[ `cWorld `0] `2= "..WORLD_SB.."")
Sleep(1000)
SendPacket(2, "action|input\ntext|/me `0[ `cDuration `0] `b= "..math.floor(JUMLAH_SB*1.5).." `9Minutes")
Sleep(1000)
for awzka = 1, JUMLAH_SB do
PTIME = os.time() - MULAI_SB
SendPacket(2, "action|input\ntext|/sb "..TEXT_SB.." `b~ `0#`cAwZka")
Sleep(1000)
SendPacket(2, "action|input\ntext|/sb "..TEXT_SB.." `b~ `0#`cAwZka")
local GEMSC = GetPlayerInfo().gems - GEMSB
GEMSB = GetPlayerInfo().gems
COUNT = COUNT + 1
COUNTS = COUNTS + 1.5
SISA_SB = JUMLAH_SB - COUNT
Sleep(5000)
if success then
SendPacket(2, "action|input\ntext|`0(megaphone) [ `cGems `9Used `0] = `6".. KOMA(USED_GEMS) .." (gems) ")
LOGS("`0(megaphone) [`cGems `9Used`0] = `6".. KOMA(USED_GEMS))
Sleep(2500)
SendPacket(2, "action|input\ntext|`0(megaphone) [ `bBlack Gems `9Used `0] = `6"..KOMA(USED_BGEMS).." (gems)")
LOGS("`0(megaphone) [`bBlack Gems `9Used`0] = `6"..KOMA(USED_BGEMS))
Sleep(2500)
SendPacket(2, "action|input\ntext|`5SuperBroadcast `0(megaphone) `0[ `cTotal `0: `9".. COUNT .." `0// `9".. JUMLAH_SB.." `0][ `4Remaining `0: `9".. SISA_SB.." `0]")
LOGS("`5SuperBroadcast `0(megaphone) `0[ c`cTotal`0 : `9".. COUNT .." `0// `9".. JUMLAH_SB.." `0][ `4Remaining `0: `9".. SISA_SB.." `0]")
Sleep(5000)
SendPacket(2, "action|input\ntext|`5SuperBroadcast `0(megaphone) `0[ `2Start Time `0: `9".. os.date(" `b%I:%M %p ", MULAI_SB) .. " `0] [ `4End Time `0: `9".. os.date(" `b%I:%M %p ", BERESSB).." `0]")
LOGS("`5SuperBroadcast (megaphone) `0[ `2Start Time `0: `9".. os.date(" `b%I:%M %p ", MULAI_SB) .. " `0] [ `4End Time `0: `9".. os.date(" `b%I:%M %p ", BERESSB).." `0]")
Sleep(5000)
Sleep(5000)
SendPacket(2, "action|input\ntext|`5SuperBroadcast `0(megaphone) `0[ `2Sending `cWebHook `0: (sleep) ]")
LOGS("`5SuperBroadcast `0(megaphone) `0[ `2Sending `cWebHook `0: (sleep) ]")
Sleep(2500)
success = false
else
SendPacket(2, "action|input\ntext|`0(megaphone) [ `4Queued `0]")
LOGS("`0(megaphone) [ `4Queued `0]")
Sleep(1000)
SendPacket(2, "action|input\ntext|`0(megaphone) [ `cGems `9Used `0] = `9".. KOMA(USED_GEMS) .." `0(gems) `0]")
LOGS("`0(megaphone) [`2Total Used`0] = `9".. KOMA(USED_GEMS) .." `0]")
Sleep(1000)
SendPacket(2, "action|input\ntext|`0(megaphone) [ `bBlack `cGems `9Used `0] = "..KOMA(USED_BGEMS).." `0(gems) `0]")
LOGS("`0(megaphone) [`2Total Used`0] = "..KOMA(USED_BGEMS))
Sleep(1000)
SendPacket(2, "action|input\ntext|`5SuperBroadcast `0(megaphone) `0[ `2Total `0: `9".. COUNT .." `0// `9".. JUMLAH_SB.." `0] [ `4Remaining `0: `9".. SISA_SB.." `0]")
LOGS("`5SuperBroadcast `0(megaphone) `0[ `2Total `0 : `9".. COUNT .." `0// `9".. JUMLAH_SB.." `0] [ `4Remaining `0: `9".. SISA_SB.." `0]")
Sleep(19500)
end
MENITS = ALLSB - COUNTS
SendPacket(2, "action|input\ntext|`5SuperBroadcast `0(megaphone) `0[ `4Remaining `0: `9"..MENITS.." `cMinutes Left]")
LOGS("`5SuperBroadcast `0(megaphone) `0[ `4Remaining `0: `9"..MENITS.." `cMinutes Left]")
Sleep(1000)
MakeRequest(WEBHOOK_SB,"POST",{["Content-Type"] = "application/json"}, [[
{
"username": "AwZka Community",
"avatar_url": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747527775092736/Apr_8_2025_03_02_12_PM.png?ex=6803cfd1&is=68027e51&hm=7f44efab0b48240c3945b0da4f34cc9ff8fc53f1b16d508ff6fd5472ed3737ab&",
"embeds": [
{
"author": {
"name": "SB Logs - AwZka"
},
"title": ":pushpin: INFORMATION :pushpin:",
"description": "APP : ʙᴏᴛʜᴀx\nText : ]]..namebersih(TEXT_SB)..[[",
"color": 15258703,
"fields": [
{
"name": ":alien: ACCOUNT INFORMATION",
"value": "Name : ]]..  namebersih(NAME) .. [[\nCurrent World : ]] .. WORLD_SB .. [[ ",
"inline": false
},{
"name": ":loudspeaker: SB INFORMATION ",
"value": "Amount : ]] .. JUMLAH_SB ..[[\nSending : ]] .. COUNT .. [[ ( Done sending )\nRemains : ]]..SISA_SB..[[ ( SuperBroadcast Left !) ",
"inline": false
},{
"name": ":gem: GEMS INFORMATION",
"value": "Owned : ]].. KOMA(SISABGEMS) .. [[\nUsed : ]].. KOMA(GEMSC) .. [[\nTotal Used : ]].. KOMA(USED_GEMS) .. [[ gems / ]]..KOMA(USED_BGEMS)..[[ Bgems",
"inline": false
},{
"name": "🕰️ TIME INFORMATION",
"value": "START: ]].. os.date(" %I:%M %p ", MULAI_SB) .. [[\nEND : ]].. os.date(" %I:%M %p ", BERESSB) .. [[\nSB Duration : ]].. math.floor(JUMLAH_SB*1.5)..[[ Minutes\nRemains : ]] .. MENITS .. [[ Minutes Left!",
"inline": false
},{
"name": "PLAYING TIME",
"value": "]].. math.floor(PTIME%86400/3600) ..[[ Hours ]].. math.floor(PTIME%86400%3600/60) ..[[ Minutes ]].. math.floor(PTIME%3600%60) ..[[ Seconds !",
"inline": false
}],
"thumbnail": {
"url": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747527775092736/Apr_8_2025_03_02_12_PM.png?ex=6803cfd1&is=68027e51&hm=7f44efab0b48240c3945b0da4f34cc9ff8fc53f1b16d508ff6fd5472ed3737ab&"
},
"image": {
"url": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747528307904592/ChatGPT_Image_Apr_8_2025_01_52_14_PM.png?ex=6803cfd1&is=68027e51&hm=22fa755cb2ef7424ceb89ba0b39842a02571ca50c91fc1463ff4f2241629963d&"
},
"footer": {
"text": "TIME : ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[ ",
"icon_url": "https://cdn.discordapp.com/emojis/1249259697492459652.webp?size=96&quality=lossless"
}}
]}]])
SendPacket(2, "action|input\ntext|`5SuperBroadcast `0(megaphone) `0[ `cSending WebHook `0: `2SUCCESS `0(cool) ]")
LOGS("`5SuperBroadcast `0(megaphone) `0[ cSending WebHook `0: `2SUCCESS `0(cool) ]")
Sleep(500)
Sleep(60000)
if COUNT == JUMLAH_SB then
STARTSB = false
MakeRequest(WEBHOOK_SB,"POST",{["Content-Type"] = "application/json"}, 
[[{
"username": "DONE SUPER BROADCAST",
"avatarurl": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747527775092736/Apr_8_2025_03_02_12_PM.png?ex=6803cfd1&is=68027e51&hm=7f44efab0b48240c3945b0da4f34cc9ff8fc53f1b16d508ff6fd5472ed3737ab&",
"content": " <@]]..USER_TO_PING..[[>",
"allowed_mentions": { "parse": ["users"]},
"embeds": [{
"title": "Super Broadcast Hook",
"color": 15258703,
"fields": [
{
"name": ":pushpin: INFORMATION :pushpin:",
"value": "Name : ]].. namebersih(GetLocal().name) .. [[\nWorld : ]] .. WORLD_SB .. [[ ",
"inline": false
},{
"name": ":gem: Gems",
"value": "Gems Sisa : ]] ..  KOMA(GetPlayerInfo().gems) ..[[",
"inline": false
}],
"thumbnail": {
"url": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747527775092736/Apr_8_2025_03_02_12_PM.png?ex=6803cfd1&is=68027e51&hm=7f44efab0b48240c3945b0da4f34cc9ff8fc53f1b16d508ff6fd5472ed3737ab&"
},
"image": {
"url": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747528307904592/ChatGPT_Image_Apr_8_2025_01_52_14_PM.png?ex=6803cfd1&is=68027e51&hm=22fa755cb2ef7424ceb89ba0b39842a02571ca50c91fc1463ff4f2241629963d&"
},
"footer": {
"text": "TIME : ]] .. os.date("%Y-%m-%d %H:%M:%S") .. [[ ",
"icon_url": "https://cdn.discordapp.com/emojis/1249259697492459652.webp?size=96&quality=lossless"
}}
]
}]])
SendPacket(2, "action|input\ntext|`5SuperBroadcast `5Mode `0[ `4END `0]")
Sleep(820)
SendPacket(2, "action|input\ntext|`0[ `5Thanks `0] `2"..WORLD_SB.."")
Sleep(820)
SendPacket(2, "action|input\ntext|`9Ditunggu Orderan Selanjutnya!")
Sleep(820)
SendPacket(2, "action|input\ntext|/nick")
Sleep(820)
RemoveHooks()
if WDON then
SendPacket(2, "action|input\ntext|/warp "..DONE_WORLD.."")
end
end
end
end
Sleep(1000)
end