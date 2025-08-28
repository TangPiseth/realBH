collectGem = 0 -- 1 IS COLLECT Gems, 0 IS Dropped Black Gems
peopleHide = 0 -- Hide People
delayErcon = 7000 -- Delay Reconnect
backgroundID = 12840 -- Set your backgroundID of the MAG
-- GENERAL SETTINGS --

suckMode = false -- true or false (Usage; Automatically suck/take dropped Black Gems)
autoBank = false -- true or false (Usage; Automatically Places your Blue Gem Lock in the Bank)
autoEat = true -- true or false (Usage; Automatically Consume Arroz & Clover)
autoInvasion = false -- true or false (Usage; Automatically Purcahse a World Lock Pack but It Avoid Taxes)
autoTelephoneDL = false -- true or false (Usage; Automatically Purchase a Diamond Lock in Telephone)
removeAnimation = false -- true or false (Usage; It Removes the Breaking Effect & Animations when Farming)
removeCollected = false -- true or false (Usage; It Removes the Message when Farming)

-- DISCORD SETTINGS -- 
whUse = false -- true or false (Usage; It Allows you to Enable & Disable Webhook)
whDelay = 300 -- (Usage; Sending webhook, delay are in seconds, 300 for 5 minutes, 600 for 10 minutes, 1800 for 30 minutes)
discordID = "443671458070396948" -- Discord ID
whUrl = "https://discord.com/api/webhooks/1251877114295091283/Bm9nvNEsC46v8rWywNWrL4Vn6D0M2b8YwhavzAJHtODCHjpjFVArQKjQRzUgCmfLkZfB"


-- Initialize all variables properly to prevent nil errors on rejoin
timer = os.time()
starB = false
magplantX, magplantY = 0, 0 
oldMagplantX = magplantX 
oldMagplantY = magplantY 
magplantCount = 1
currentMagplantIndex = 1 -- Initialize to prevent nil errors
cheatFarm = true 
setCurrent = true 
buyLock = false 
autoDLock = false 
changeRemote = false 
allMagplants = {} -- Initialize empty magplants array
worldName = "" -- Initialize world name
positionX = 0
positionY = 0
jumlahbgems = 0

-- Safe initialization of player-related variables
local function safeInitializePlayerVars()
    if GetLocal() then
        player = GetLocal().name
        playerUserID = GetLocal().userid
    else
        player = ""
        playerUserID = ""
    end
    
    if GetPlayerInfo() then
        currentGem = GetPlayerInfo().gems
    else
        currentGem = 0
    end
    
    if GetWorld() then
        currentWorld = GetWorld().name
        worldName = currentWorld:lower() -- Ensure worldName is initialized
    else
        currentWorld = ""
        worldName = ""
    end
end

-- Define essential dialog functions early to prevent nil errors
function ShowSettingsDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`5Settings Management|left|394|
add_spacer|small|
add_textbox|`5Settings Actions:|
add_button|reset_farming|`4Reset Farming Settings|
add_button|reset_banking|`4Reset Banking Settings|
add_button|reset_webhook|`4Reset Webhook Settings|
add_button|reset_all|`4Reset All Settings|
add_spacer|small|
add_textbox|`6Current Configuration Summary:|
add_label_with_icon|small|`wFarming: ]] .. (cheatFarm and "`2ENABLED" or "`4DISABLED") .. [[|left|9654|
add_label_with_icon|small|`wAuto Bank: ]] .. (autoBank and "`2ON" or "`4OFF") .. [[|left|7188|
add_label_with_icon|small|`wAuto Eat: ]] .. (autoEat and "`2ON" or "`4OFF") .. [[|left|4604|
add_label_with_icon|small|`wWebhook: ]] .. (whUse and "`2ENABLED" or "`4DISABLED") .. [[|left|1436|
add_label_with_icon|small|`wMagplants: ]] .. #allMagplants .. [[ found|left|5638|
add_spacer|small|
add_textbox|`4Warning: Reset actions cannot be undone!|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|pnb_settings_mgmt|Close|
]]
    SendVariantList(varlist_command)
end

-- Initial call to setup variables
safeInitializePlayerVars()

-- Function to reinitialize variables when reconnecting
function reinitializeVars()
    safeInitializePlayerVars()
    
    -- Reset other variables as needed
    if #allMagplants == 0 then
        allMagplants = findAllMagplants and findAllMagplants() or {}
    end
end
ChangeValue("[C] Modfly", true)
function Console(str) SendVariantList({[0] = "OnConsoleMessage", [1] = str}) end
AddHook("onvariant", "mommy", function(var)
    if var[0] == "OnSDBroadcast" then 
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("Telephone") then
        return true
    end
    if var[0] == "OnDialogRequest" then
        if var[1]:find("add_player_info") then
            return true
        end
    end
    if var[0] == "OnDialogRequest" and var[1]:find("Blue Gem Lock") then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("The BGL Bank") then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("Diamond Lock") then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT 5000") then
        if var[1]:find("The machine is currently empty!") then
            changeRemote = true
		else
			changeRemote = false
        end
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("`bThe Black Backpack") then
        jumlahbgems = var[1]:match("You have (%d+)")
        return true
    end
    if var[0] == "OnConsoleMessage" then
        if var[1]:find("`oYour luck has worn off.") then
           autoEat = true
        elseif var[1]:find("`oYour stomach's rumbling.") then
           autoEat = true
        end

        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("Disconnected?! Will attempt to reconnect...") then
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("Where would you like to go?") then
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("Applying cheats...") then
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("Cheat Active") then
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("Whoa, calm down toggling cheats on/off... Try again in a second!") then
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("You earned `$(%d+)`` in Tax Credits! You have `$(%d+) Tax Credits`` in total now.") then
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("Xenonite") then
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:match("`1O`2h`3, `4l`5o`6o`7k `8w`9h`ba`!t `$y`3o`2u`4'`ev`pe `#f`6o`8u`1n`7d`w!")  then
        return true
    end
    if var[0] == "OnTalkBubble" and var[2]:match("Xenonite") then
            return true
    end
    if var[0] == "OnTalkBubble" and var[2]:match("`1O`2h`3, `4l`5o`6o`7k `8w`9h`ba`!t `$y`3o`2u`4'`ev`pe `#f`6o`8u`1n`7d`w!") then
        return true
    end
    if var[0] == "OnTalkBubble" and var[2]:match("Collected") then
        if removeCollected then
            return true
        end
    end
    if var[0] == "OnTalkBubble" and var[2]:find("The MAGPLANT 5000 is empty.") then
        changeRemote = true
        buyNow = false
        return true
    end
    return false
end)

worldName = ""

if not cheatFarm and removeAnimation then
    removeAnimation = false
end

if worldName == "" or worldName == nil then
    worldName = string.upper(GetWorld().name)
end

AddHook("onprocesstankupdatepacket", "pussy", function(packet)
    if packet.type == 3 or packet.type == 8 or packet.type == 17 then
        if removeAnimation then
            return true
        end
    end
end)







local function FormatNumber(num)
    num = math.floor(num + 0.5)

    local formatted = tostring(num)
    local k = 3
    while k < #formatted do
        formatted = formatted:sub(1, #formatted - k) .. "," .. formatted:sub(#formatted - k + 1)
        k = k + 4
    end

    return formatted
end

local function findItem(id)
    count = 0
    for _, inv in pairs(GetInventory()) do
        if inv.id == id then
            count = count + inv.amount
        end
    end
    return count
end

local function removeColorAndSymbols(str)
    cleanedStr = string.gsub(str, "`(%S)", '')
    cleanedStr = string.gsub(cleanedStr, "`{2}|(~{2})", '')
    return cleanedStr
end

if GetWorld() == nil then
    username = removeColorAndSymbols(player)
else
    username = removeColorAndSymbols(GetLocal().name)
end

if GetWorld() == nil then
    playerUID = removeColorAndSymbols(playerUserID)
else
    playerUID = removeColorAndSymbols(GetLocal().userid)
end


time = os.time()
local function playerHook(info)  
    if whUse then
        oras = os.time() - time
        local script = [[
            $webHookUrl = "]].. whUrl ..[["
            $title = "<a:TB_warning:1101039889170046997> **PNB Information** <a:TB_warning:1101039889170046997>"
            $date = [System.TimeZoneInfo]::ConvertTimeBySystemTimeZoneId((Get-Date), 'Singapore Standard Time').ToString('g')
            $cpu = (Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average).Average
            $RAM = Get-WMIObject Win32_PhysicalMemory | Measure -Property capacity -Sum | %{$_.sum/1Mb} 
            $ip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $(Get-NetConnectionProfile | Select-Object -ExpandProperty InterfaceIndex) | Select-Object -ExpandProperty IPAddress
            $thumbnailObject = @{
                url = "https://i.imghippo.com/files/cWOma1717411189.jpg"
            }
            $footerObject = @{
                text = "Date: ]]..(os.date("!%A %b %d, %Y | Time: %I:%M %p ", os.time() + 8 * 60 * 60))..[[ | @Mupnup."
            }
            
            $fieldArray = @(

            @{
                name = "<:mgp:1194831769858494464> Information"
                value = "World : **]].. currentWorld ..[[**
                Status : **]].. info ..[[**"
                inline = "false"
            }

            @{
                name = "<:bot:1201730667281666078> Player Information"
                value = "Username : **]].. username ..[[**
                User ID : **]].. playerUID ..[[**"
                inline = "false"
            }
  
            @{
                name = "<:gems:1031186121100628038>  Gems Information"
                value = "Current Gems <:rgems:1225699132711243817>: **]].. FormatNumber(GetPlayerInfo().gems) ..[[**
                Earned Gems <:rgems:1225699132711243817>: **]].. FormatNumber(GetPlayerInfo().gems - currentGem) ..[[**"
                inline = "false"
            }

            @{
                name = "<a:flash:1197511764603052102> Buff Information"
                value = "<:four_leaf_clover:1178876649090076774> Clover Stock: **]].. math.floor(findItem(528)) ..[[**
                <:taco:1178877190507614248> Arroz Stock: **]].. math.floor(findItem(4604)) ..[[**"
                inline = "false"
            }
  
            @{
                name = "<:mp:1194831735666511912> Magplant Position"
                value = "Current Remote: (**]].. magplantX ..[[**, **]].. magplantY ..[[**)"
                inline = "false"
            }
            
            @{
                name = "<a:rg:1197369816403685396> PNB Up Time"
                value = "]].. math.floor(oras/86400) ..[[ Days ]].. math.floor(oras%86400/3600) ..[[ Hours ]].. math.floor(oras%86400%3600/60) ..[[ Minutes ]].. math.floor(oras%3600%60) ..[[ Seconds"
                inline = "false"
            }

          $Body = @{
          'content' = '<@]].. discordID ..[[>'
          }
      
          )
          $embedObject = @{
          title = $title
          description = $desc
          footer = $footerObject
          thumbnail = $thumbnailObject
          color = "]] ..math.random(1000000, 9999999).. [["
      
          fields = $fieldArray
      }
      $embedArray = @($embedObject)
      $payload = @{
      avatar_url = "https://i.imghippo.com/files/cWOma1717411189.jpg"
      username = "PNB by Mupnup"
      content = "<a:verified_emas:1045141409432342580> <@]].. discordID ..[[>"
      embeds = $embedArray
      }
      [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
      Invoke-RestMethod -Uri $webHookUrl -Body ($payload | ConvertTo-Json -Depth 4) -Method Post -ContentType 'application/json'
      ]]
      local pipe = io.popen("powershell -command -", "w")
      pipe:write(script)
      pipe:close()
    end
end

playerHook("**Script is now running!**")

local function overlayText(text)
    var = {}
    var[0] = "OnTextOverlay"
    var[1] = text
    SendVariantList(var)
end

local function logText(text)
    packet = {}
    packet[0] = "OnConsoleMessage"
    packet[1] = "`#[`b@Mupnup`#]`6 ".. text
    SendVariantList(packet)
end

local function warnText(text)
    text = text
    packet = {}
    packet[0] = "OnAddNotification"
    packet[1] = "interface/atomic_button.rttex"
    packet[2] = text
    packet[3] = "audio/hub_open.wav"
    packet[4] = 0
    SendVariantList(packet)
    return true
end


logText("PNB Script by `b@Mupnup`#]")
logText("`2Dialog System Loaded! Type `b/pnb `2to open settings!")
logText("`9Quick Commands: /suck, /bank, /eat, /webhook, /help")
SendPacket(2, "action|input\ntext|`#[`2Script by `b@Mupnup`#]")
overlayText("`#[`2Script by `b@Mupnup`#] `2Dialog System Ready!")
Sleep(1000)
SendPacket(2, "action|input\ntext|`#[`2Script by `b@Mupnup`#]")
overlayText("`2Type /pnb to open settings menu!")
Sleep(1000)

local function place(id, x, y)
if GetWorld() == nil then return false end
    pkt = {}
    pkt.type = 3
    pkt.value = id
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
end

local function punch(x, y)
    pkt = {}
    pkt.type = 3
    pkt.value = 18
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y 
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    SendPacketRaw(false, pkt)
end

function convert(id)
    pkt = {}
    pkt.value = id
    pkt.type = 10
    SendPacketRaw(false, pkt)
end

function split(inputstr, sep)
    local t = {}
    for str in string.gmatch(inputstr, "([^".. sep .."]+)") do
        table.insert(t, str)
    end
    return t
end

local function wrench(x, y)
    pkt = {}
    pkt.type = 3
    pkt.value = 32
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
end

allMagplants = {}
currentMagplantIndex = 1

local function findAllMagplants()
    if not GetWorld() then 
        overlayText("`4Cannot find magplants: Not connected to world!")
        return {} 
    end
    
    local magplants = {}
    for _, tile in pairs(GetTiles()) do
        if tile.bg == backgroundID and tile.fg == 5638 then
            table.insert(magplants, {x = tile.x, y = tile.y})
        end
    end
    return magplants
end

local function getCurrentMagplant()
    if not GetWorld() then 
        overlayText("`4Cannot get magplant: Not connected to world!")
        return nil, nil 
    end
    
    -- Initialize currentMagplantIndex if it doesn't exist
    if not currentMagplantIndex then
        currentMagplantIndex = 1
    end
    
    if not allMagplants or #allMagplants == 0 then
        allMagplants = findAllMagplants()
        Console("Found " .. #allMagplants .. " magplants with background ID " .. backgroundID)
    end
    
    if #allMagplants == 0 then
        return nil, nil
    end
    
    if currentMagplantIndex > #allMagplants then
        currentMagplantIndex = 1
    end
    
    return allMagplants[currentMagplantIndex].x, allMagplants[currentMagplantIndex].y
end

local function switchToNextMagplant()
    if not GetWorld() then 
        overlayText("`4Cannot switch magplant: Not connected to world!")
        return false 
    end
    
    -- Initialize currentMagplantIndex if it doesn't exist
    if not currentMagplantIndex then
        currentMagplantIndex = 1
    end
    
    local oldX, oldY = nil, nil
    if #allMagplants > 0 and currentMagplantIndex <= #allMagplants then
        oldX, oldY = allMagplants[currentMagplantIndex].x, allMagplants[currentMagplantIndex].y
    end
    
    allMagplants = findAllMagplants()

    if #allMagplants == 0 then
        warnText("No magplants found with background ID " .. backgroundID)
        return false
    end

    currentMagplantIndex = currentMagplantIndex + 1
    if currentMagplantIndex > #allMagplants then
        currentMagplantIndex = 1
    end

    local x, y = allMagplants[currentMagplantIndex].x, allMagplants[currentMagplantIndex].y
    magplantX, magplantY = x, y

    if oldX and oldY then
        warnText("`wMagplant at `2(" .. oldX .. ", " .. oldY .. ") `wempty. Moving to next Magplant at `2(" .. x .. ", " .. y .. ")`w")
        Console("`wSwitching to Magplant at `2(" .. x .. ", " .. y .. ")")
    else
        warnText("`wProceeding to Magplant at `2(" .. x .. ", " .. y .. ")`w...")
        Console("`wSwitching to Magplant at `2(" .. x .. ", " .. y .. ")")
    end
getRemote()
    return true
end

  function getRemote()
    if GetWorld() == nil then return false end
    local x, y = getCurrentMagplant()
    if not x or not y then
        warnText("No magplant found on background. Skipping...")
        return false
    end
    if findItem(5640) == 0 or changeRemote then
    Sleep(500)
    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0")
    
    FindPath(x, y - 1, 100)  -- Move to the magplant
    Sleep(1000)
    wrench(0, 1)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. x .. "|\ny|" .. y .. "|\nbuttonClicked|getRemote")
    Sleep(500)

    while changeRemote do
        Console("Current magplant is empty! Switching to the next one...")

        if switchToNextMagplant() then
            magplantCount = currentMagplantIndex
            Sleep(1000)

            local newX, newY = getCurrentMagplant()
            if not newX or not newY then
                warnText("`4No more valid magplants found! Stopping...")
                return false
            end
            FindPath(newX, newY - 1, 100)
            Sleep(1000)
            wrench(0, 1)
            SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. newX .. "|\ny|" .. newY .. "|\nbuttonClicked|getRemote")
            Sleep(500)
            if changeRemote then
            else
                Console("`2Found a stocked magplant! Resuming `#breaking.")
                break
            end
        else
            warnText("`4No valid magplants found with stock! Stopping...")
            return false
        end
    end
end
    magplantX, magplantY = x, y - 1
    playerHook("Get Remote")
    return true
end


local function remoteCheck()
    if GetWorld() == nil then
        -- test
        Sleep(delayErcon)
        RequestJoinWorld(worldName)
        overlayText("`#[`b@Mupnup`#] `^Request to join world `2".. worldName.."")
        Sleep(1000)
        playerHook("Reconnected, looks like you were recently disconnected")
    else
        if findItem(5640) < 0 or findItem(5640) == 0 then
            Sleep(1000)
            getRemote()
        end
    end
end

local function reconnectPlayer()
    if GetWorld() == nil then
        -- test
        Sleep(delayErcon)
        RequestJoinWorld(worldName)
        overlayText("`#[`b@Mupnup`#] `^Request to join world `2".. worldName.."")
        Sleep(1000)
        playerHook("Reconnected, looks like you were recently disconnected")
        -- Reinitialize variables after reconnecting
        reinitializeVars()
    else
        Sleep(1000)
        remoteCheck()
        if findItem(5640) >= 1 or findItem(5640) == 1 then
            Sleep(1000)
            if GetLocal().pos.x ~= positionX and GetLocal().pos.y ~= positionY then
                Sleep(100)
                FindPath(positionX, positionY, 100)
                Sleep(100)
            end
        end
    end
end

local function worldNot()
    if not GetWorld() or GetWorld().name ~= (worldName:upper()) then
        -- test
        Sleep(delayErcon)
        RequestJoinWorld(worldName)
        overlayText("`#[`b@Mupnup`#] `^Request to join world `2".. worldName.."")
        Sleep(1000)
        playerHook("Reconnected, looks like you were recently disconnected")
        -- Reinitialize variables after reconnecting
        reinitializeVars()
    else
        Sleep(1000)
        remoteCheck()
        if findItem(5640) >= 1 or findItem(5640) == 1 then
            Sleep(1000)
            if GetLocal().pos.x ~= positionX and GetLocal().pos.y ~= positionY then
                Sleep(100)
                FindPath(positionX, positionY, 100)
                Sleep(100)
            end
        end
    end
end

local function getPos()
    if setCurrent then
        positionX = math.floor(GetLocal().pos.x / 32)
        positionY = math.floor(GetLocal().pos.y / 32)
        currentGem = GetPlayerInfo().gems
        if setCurrent then
            setCurrent = false
        end
    end
end

function CONVERT_TO_DL()
    SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..positionX.."|\ny|"..positionY.."|\nbuttonClicked|dlconvert")
    Sleep(100)
    if not GetWorld() then
        Sleep(1000)
        reconnectPlayer()
        Sleep(1000)
    end
end

function CONVERT_TO_BGL()
    SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..positionX.."|\ny|"..positionY.."|\nbuttonClicked|bglconvert")
    Sleep(100)
end

function HANDLE_BGL_STORAGE()
    local bglCount = findItem(7188)
    if autoBank and bglCount >= 1 then
        SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|"..bglCount)
        Sleep(100)
    elseif not autoBank and bglCount >= 100 then
        SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
        Sleep(100)
    end
end

load(MakeRequest("https://raw.githubusercontent.com/TangPiseth/sethidcheckop/refs/heads/main/B%20PTHT%20V2","GET").content)()

-- DIALOG SYSTEM IMPLEMENTATION
local dialogOpen = false

-- Helper function for checkbox values
local function CHECKBOX(value)
    return value and 1 or 0
end

-- Add status display function
local function GetStatusText()
    local status = {}
    if GetWorld() then
        table.insert(status, "`2Farming: " .. (cheatFarm and "`2ON" or "`4OFF"))
        table.insert(status, "`3Banking: " .. (autoBank and "`2ON" or "`4OFF"))
        table.insert(status, "`9Webhook: " .. (whUse and "`2ON" or "`4OFF"))
        table.insert(status, "`6Remote: " .. (findItem(5640) > 0 and "`2YES" or "`4NO"))
    else
        table.insert(status, "`4World: DISCONNECTED")
    end
    return table.concat(status, " | ")
end

-- Help dialog with safety check
local function ShowHelpDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`2PNB Help & Commands|left|18|
add_spacer|small|
add_textbox|`2Dialog Commands:|
add_label_with_icon|small|`w/pnb, /config, /settings `0- Open main dialog|left|9654|
add_label_with_icon|small|`w/help, /pnbhelp `0- Show this help dialog|left|18|
add_spacer|small|
add_textbox|`3Quick Toggle Commands:|
add_label_with_icon|small|`w/suck `0- Toggle auto suck black gems|left|2580|
add_label_with_icon|small|`w/bank `0- Toggle auto bank BGL|left|7188|
add_label_with_icon|small|`w/eat `0- Toggle auto eat buffs|left|4604|
add_label_with_icon|small|`w/webhook `0- Toggle webhook notifications|left|1436|
add_label_with_icon|small|`w/anim `0- Toggle remove animations|left|32|
add_label_with_icon|small|`w/gems `0- Toggle collect gems mode|left|11550|
add_label_with_icon|small|`w/hide `0- Toggle hide people|left|15590|
add_label_with_icon|small|`w/invasion `0- Toggle auto invasion|left|15286|
add_label_with_icon|small|`w/dl `0- Toggle auto DL convert|left|1796|
add_label_with_icon|small|`w/status `0- Show current status|left|394|
add_spacer|small|
add_textbox|`4Current Status:|
add_smalltext|]]..GetStatusText()..[[|
add_spacer|small|
add_textbox|`5System Information:|
add_label_with_icon|small|`wWorld: `2]]..GetWorld().name..[[|left|1402|
add_label_with_icon|small|`wGems: `2]]..FormatNumber(GetPlayerInfo().gems)..[[|left|11550|
add_label_with_icon|small|`wMagplants: `2]]..#allMagplants..[[|left|5638|
add_label_with_icon|small|`wRemote Count: `2]]..findItem(5640)..[[|left|5640|
add_label_with_icon|small|`wPosition: (`2]]..math.floor(GetLocal().pos.x / 32)..[[`w, `2]]..math.floor(GetLocal().pos.y / 32)..[[`w)|left|1684|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|pnb_help|Close|
]]
    SendVariantList(varlist_command)
end

-- Main Dialog Function
local function ShowMainDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
text_scaling_string|pnbConfig
add_label_with_icon|big|`#[`bPNB icShark `#] `2Settings|left|9654|
add_spacer|small|
add_label_with_icon|small|Welcome back, ]]..GetLocal().name..[[|right|2278|
add_textbox|`bPNB Settings by `#@Mupnup|
add_spacer|small|
add_smalltext|]]..GetStatusText()..[[|
add_spacer|small|
add_textbox|`2Farming Settings:|
add_checkbox|collectGem|`2Collect Gems `w(0=Drop Black Gems)|]] .. CHECKBOX(collectGem == 1) .. [[|
add_checkbox|peopleHide|`2Hide People|]] .. CHECKBOX(peopleHide == 1) .. [[|
add_checkbox|suckMode|`2Auto Suck Dropped Black Gems|]] .. CHECKBOX(suckMode) .. [[|
add_checkbox|autoEat|`2Auto Eat Buffs|]] .. CHECKBOX(autoEat) .. [[|
add_checkbox|removeAnimation|`2Remove Breaking Animations|]] .. CHECKBOX(removeAnimation) .. [[|
add_checkbox|removeCollected|`2Remove Collection Messages|]] .. CHECKBOX(removeCollected) .. [[|
add_spacer|small|
add_textbox|`3Banking & Trading Settings:|
add_checkbox|autoBank|`3Auto Bank BGL|]] .. CHECKBOX(autoBank) .. [[|
add_checkbox|autoTelephoneDL|`3Auto Convert to Diamond Lock|]] .. CHECKBOX(autoTelephoneDL) .. [[|
add_checkbox|autoInvasion|`3Auto Buy World Lock Pack|]] .. CHECKBOX(autoInvasion) .. [[|
add_spacer|small|
add_button_with_icon|advanced_settings|`5Advanced Settings|staticBlueFrame|32|
add_button_with_icon|webhook_settings|`9Webhook Settings|staticBlueFrame|1436|
add_button_with_icon|magplant_settings|`6Magplant Settings|staticBlueFrame|5638|
add_button_with_icon|help_dialog|`7Help & Commands|staticBlueFrame|18|
add_button_with_icon|settings_mgmt|`5Settings Management|staticBlueFrame|394|
add_button_with_icon||END_LIST|noflags|0|
add_spacer|small|
add_button|save_settings|`2Save Settings|
add_quick_exit||
end_dialog|pnb_main|Close|
]]
    SendVariantList(varlist_command)
    dialogOpen = true
end

-- Advanced Settings Dialog
local function ShowAdvancedDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`5Advanced Settings|left|32|
add_spacer|small|
add_textbox|`5Advanced Configuration:|
add_text_input|delayReconnect|Reconnect Delay (ms):|]]..delayErcon..[[|8|
add_text_input|backgroundID|Background ID:|]]..backgroundID..[[|8|
add_spacer|small|
add_textbox|`4Current Values:|
add_label_with_icon|small|`wCurrent Delay: `2]]..delayErcon..[[ms|left|394|
add_label_with_icon|small|`wCurrent Background: `2]]..backgroundID..[[|left|394|
add_spacer|small|
add_textbox|`4Warning: Be careful with these settings!|
add_textbox|`4Changing Background ID will reset magplant list|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|pnb_advanced|Apply Changes|
]]
    SendVariantList(varlist_command)
end

-- Webhook Settings Dialog
local function ShowWebhookDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`9Webhook Settings|left|1436|
add_spacer|small|
add_textbox|`9Webhook Configuration:|
add_checkbox|webhookUse|`9Enable Webhook Notifications|]] .. CHECKBOX(whUse) .. [[|
add_text_input|webhookDelay|Webhook Delay (seconds):|]]..whDelay..[[|8|
add_text_input|discordUserID|Discord User ID:|]]..discordID..[[|20|
add_text_input_password|webhookURL|Webhook URL:|]]..whUrl..[[|100|
add_spacer|small|
add_textbox|`2Current Settings:|
add_label_with_icon|small|`wWebhook: `]] .. (whUse and "2ENABLED" or "4DISABLED") .. [[|left|1436|
add_label_with_icon|small|`wDelay: `2]]..whDelay..[[ seconds|left|394|
add_label_with_icon|small|`wDiscord ID: `2]] .. (discordID ~= "" and "SET" or "NOT SET") .. [[|left|2278|
add_label_with_icon|small|`wWebhook URL: `2]] .. (whUrl ~= "" and "SET" or "NOT SET") .. [[|left|15590|
add_spacer|small|
add_textbox|`4Security Notice:|
add_textbox|`4Keep your webhook URL private and secure!|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|pnb_webhook|Apply Changes|
]]
    SendVariantList(varlist_command)
end

-- Magplant Settings Dialog
local function ShowMagplantDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`6Magplant Management|left|5638|
add_spacer|small|
add_textbox|`6Current Magplant Information:|
add_label_with_icon|small|`wPosition: (`2]]..magplantX..[[`w, `2]]..magplantY..[[`w)|left|5638|
add_label_with_icon|small|`wBackground ID: `2]]..backgroundID..[[|left|15772|
add_label_with_icon|small|`wTotal Found: `2]]..#allMagplants..[[|left|394|
add_label_with_icon|small|`wCurrent Index: `2]]..currentMagplantIndex..[[/]]..#allMagplants..[[|left|1684|
add_label_with_icon|small|`wRemote Count: `2]]..findItem(5640)..[[|left|5640|
add_spacer|small|
add_textbox|`6Magplant Actions:|
add_button|refresh_magplants|`6Refresh Magplant List|
add_button|next_magplant|`6Switch to Next Magplant|
add_button|get_current_remote|`6Get Remote from Current|
add_spacer|small|
add_textbox|`4Tips:|
add_textbox|`4- Refresh if magplants don't show up|
add_textbox|`4- Switch magplant if current is empty|
add_textbox|`4- Get remote to collect from magplant|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|pnb_magplant|Close|
]]
    SendVariantList(varlist_command)
end

-- Dialog Response Handler
AddHook("OnSendPacket", "PNBDialogHandler", function(type, packet)
    if type == 2 and packet:find("action|dialog_return") then
        if packet:find("dialog_name|pnb_main") then
            -- Handle main dialog responses
            if packet:find("buttonClicked|advanced_settings") then
                ShowAdvancedDialog()
                return true
            elseif packet:find("buttonClicked|webhook_settings") then
                ShowWebhookDialog()
                return true
            elseif packet:find("buttonClicked|magplant_settings") then
                ShowMagplantDialog()
                return true
            elseif packet:find("buttonClicked|help_dialog") then
                ShowHelpDialog()
                return true
            elseif packet:find("buttonClicked|settings_mgmt") then
                -- Fix: Add null check and define function before calling
                if not ShowSettingsDialog then
                    -- Define the settings management dialog function
                    ShowSettingsDialog = function()
                        if not GetWorld() then
                            overlayText("`4Cannot open dialog: Not connected to world!")
                            return
                        end
                        
                        local varlist_command = {}
                        varlist_command[0] = "OnDialogRequest"
                        varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`5Settings Management|left|394|
add_spacer|small|
add_textbox|`5Settings Actions:|
add_button|reset_farming|`4Reset Farming Settings|
add_button|reset_banking|`4Reset Banking Settings|
add_button|reset_webhook|`4Reset Webhook Settings|
add_button|reset_all|`4Reset All Settings|
add_spacer|small|
add_textbox|`6Current Configuration Summary:|
add_label_with_icon|small|`wFarming: ]] .. (cheatFarm and "`2ENABLED" or "`4DISABLED") .. [[|left|9654|
add_label_with_icon|small|`wAuto Bank: ]] .. (autoBank and "`2ON" or "`4OFF") .. [[|left|7188|
add_label_with_icon|small|`wAuto Eat: ]] .. (autoEat and "`2ON" or "`4OFF") .. [[|left|4604|
add_label_with_icon|small|`wWebhook: ]] .. (whUse and "`2ENABLED" or "`4DISABLED") .. [[|left|1436|
add_label_with_icon|small|`wMagplants: ]] .. #allMagplants .. [[ found|left|5638|
add_spacer|small|
add_textbox|`4Warning: Reset actions cannot be undone!|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|pnb_settings_mgmt|Close|
]]
                        SendVariantList(varlist_command)
                    end
                end
                
                -- Now call the function
                ShowSettingsDialog()
                return true
            elseif packet:find("buttonClicked|save_settings") then
                -- Extract checkbox values
                collectGem = packet:find("collectGem|1") and 1 or 0
                peopleHide = packet:find("peopleHide|1") and 1 or 0
                suckMode = packet:find("suckMode|1") and true or false
                autoEat = packet:find("autoEat|1") and true or false
                removeAnimation = packet:find("removeAnimation|1") and true or false
                removeCollected = packet:find("removeCollected|1") and true or false
                autoBank = packet:find("autoBank|1") and true or false
                autoTelephoneDL = packet:find("autoTelephoneDL|1") and true or false
                autoInvasion = packet:find("autoInvasion|1") and true or false
                
                overlayText("`2Settings saved successfully!")
                logText("`2All settings have been saved and applied!")
                dialogOpen = false
                return true
            end
        elseif packet:find("dialog_name|pnb_advanced") then
            -- Handle advanced dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowMainDialog()
                return true
            else
                -- Extract values with validation
                local newDelayErcon = packet:match("delayReconnect|([^|]+)")
                local newBackgroundID = packet:match("backgroundID|([^|]+)")
                
                if newDelayErcon and tonumber(newDelayErcon) then
                    local delay = tonumber(newDelayErcon)
                    if delay >= 1000 and delay <= 60000 then -- Validate range 1-60 seconds
                        delayErcon = delay
                        logText("`5Reconnect delay updated to: " .. delayErcon .. "ms")
                    else
                        overlayText("`4Invalid delay! Must be between 1000-60000ms")
                        logText("`4Reconnect delay not changed - invalid range")
                    end
                else
                    overlayText("`4Invalid delay value!")
                    logText("`4Reconnect delay not changed - invalid input")
                end
                
                if newBackgroundID and tonumber(newBackgroundID) then
                    local bgID = tonumber(newBackgroundID)
                    if bgID > 0 then -- Validate positive number
                        backgroundID = bgID
                        logText("`5Background ID updated to: " .. backgroundID)
                        -- Refresh magplant list when background ID changes
                        allMagplants = findAllMagplants()
                        currentMagplantIndex = 1
                        logText("`6Refreshed magplant list: Found " .. #allMagplants .. " magplants")
                    else
                        overlayText("`4Invalid background ID! Must be positive")
                        logText("`4Background ID not changed - invalid value")
                    end
                else
                    overlayText("`4Invalid background ID!")
                    logText("`4Background ID not changed - invalid input")
                end
                
                overlayText("`5Advanced settings processed!")
                ShowMainDialog()
                return true
            end
        elseif packet:find("dialog_name|pnb_webhook") then
            -- Handle webhook dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowMainDialog()
                return true
            else
                -- Extract values with validation
                whUse = packet:find("webhookUse|1") and true or false
                local newWebhookDelay = packet:match("webhookDelay|([^|]+)")
                local newDiscordID = packet:match("discordUserID|([^|]+)")
                local newWebhookURL = packet:match("webhookURL|([^|]+)")
                
                if newWebhookDelay and tonumber(newWebhookDelay) then
                    local delay = tonumber(newWebhookDelay)
                    if delay >= 30 and delay <= 3600 then -- Validate range 30 seconds to 1 hour
                        whDelay = delay
                        logText("`9Webhook delay updated to: " .. whDelay .. " seconds")
                    else
                        overlayText("`4Invalid webhook delay! Must be between 30-3600 seconds")
                        logText("`4Webhook delay not changed - invalid range")
                    end
                else
                    if newWebhookDelay and newWebhookDelay ~= "" then
                        overlayText("`4Invalid webhook delay value!")
                        logText("`4Webhook delay not changed - invalid input")
                    end
                end
                
                if newDiscordID and newDiscordID ~= "" then
                    if string.match(newDiscordID, "^%d+$") and string.len(newDiscordID) >= 17 then -- Basic Discord ID validation
                        discordID = newDiscordID
                        logText("`9Discord ID updated successfully")
                    else
                        overlayText("`4Invalid Discord ID format!")
                        logText("`4Discord ID not changed - invalid format")
                    end
                end
                
                if newWebhookURL and newWebhookURL ~= "" then
                    if string.match(newWebhookURL, "^https://discord%.com/api/webhooks/") or 
                       string.match(newWebhookURL, "^https://discordapp%.com/api/webhooks/") then -- Basic webhook URL validation
                        whUrl = newWebhookURL
                        logText("`9Webhook URL updated successfully")
                    else
                        overlayText("`4Invalid webhook URL format!")
                        logText("`4Webhook URL not changed - must be a Discord webhook")
                    end
                end
                
                overlayText("`9Webhook settings processed!")
                ShowMainDialog()
                return true
            end
        elseif packet:find("dialog_name|pnb_magplant") then
            -- Handle magplant dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowMainDialog()
                return true
            elseif packet:find("buttonClicked|refresh_magplants") then
                allMagplants = findAllMagplants()
                overlayText("`6Found " .. #allMagplants .. " magplants!")
                logText("`6Refreshed magplant list: Found " .. #allMagplants .. " magplants with background ID " .. backgroundID)
                ShowMagplantDialog()
                return true
            elseif packet:find("buttonClicked|next_magplant") then
                if switchToNextMagplant() then
                    overlayText("`6Switched to next magplant!")
                    logText("`6Switched to magplant at (" .. magplantX .. ", " .. magplantY .. ")")
                else
                    overlayText("`4No more magplants available!")
                    logText("`4No more magplants found with background ID " .. backgroundID)
                end
                ShowMagplantDialog()
                return true
            elseif packet:find("buttonClicked|get_current_remote") then
                getRemote()
                overlayText("`6Getting remote from current magplant!")
                logText("`6Attempting to get remote from magplant")
                ShowMagplantDialog()
                return true
            end
        elseif packet:find("dialog_name|pnb_help") then
            -- Handle help dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowMainDialog()
                return true
            end
        elseif packet:find("dialog_name|pnb_settings_mgmt") then
            -- Handle settings management dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowMainDialog()
                return true
            elseif packet:find("buttonClicked|reset_farming") then
                -- Reset farming settings to defaults
                collectGem = 1
                peopleHide = 0
                suckMode = false
                autoEat = true
                removeAnimation = false
                removeCollected = false
                overlayText("`4Farming settings reset to defaults!")
                logText("`4Farming settings have been reset")
                ShowSettingsDialog()
                return true
            elseif packet:find("buttonClicked|reset_banking") then
                -- Reset banking settings to defaults
                autoBank = false
                autoTelephoneDL = false
                autoInvasion = false
                overlayText("`4Banking settings reset to defaults!")
                logText("`4Banking settings have been reset")
                ShowSettingsDialog()
                return true
            elseif packet:find("buttonClicked|reset_webhook") then
                -- Reset webhook settings to defaults
                whUse = false
                whDelay = 300
                discordID = "443671458070396948"
                whUrl = "https://discord.com/api/webhooks/1251877114295091283/Bm9nvNEsC46v8rWywNWrL4Vn6D0M2b8YwhavzAJHtODCHjpjFVArQKjQRzUgCmfLkZfB"
                overlayText("`4Webhook settings reset to defaults!")
                logText("`4Webhook settings have been reset")
                ShowSettingsDialog()
                return true
            elseif packet:find("buttonClicked|reset_all") then
                -- Reset all settings to defaults
                collectGem = 1
                peopleHide = 0
                suckMode = false
                autoBank = false
                autoEat = true
                autoInvasion = false
                autoTelephoneDL = false
                removeAnimation = false
                removeCollected = false
                whUse = false
                whDelay = 300
                delayErcon = 7000
                backgroundID = 12840
                overlayText("`4All settings reset to defaults!")
                logText("`4All settings have been reset to default values")
                ShowSettingsDialog()
                return true
            end
        end
    end
    
    -- Handle dialog command
    if type == 2 and packet:find("action|input") then
        if packet:find("|text|/pnb") or packet:find("|text|/config") or packet:find("|text|/settings") then
            ShowMainDialog()
            return true
        elseif packet:find("|text|/help") or packet:find("|text|/pnbhelp") then
            ShowHelpDialog()
            return true
        end
    end
    
    return false
end)

-- Add command shortcuts
local function handleCommands()
    AddHook("OnSendPacket", "PNBCommands", function(type, packet)
        if type == 2 and packet:find("action|input") then
            local text = packet:match("|text|(.+)")
            if text then
                -- Main dialog commands
                if text == "/pnb" or text == "/config" or text == "/settings" then
                    ShowMainDialog()
                    return true
                end
                
                -- Quick toggle commands
                if text == "/suck" then
                    suckMode = not suckMode
                    overlayText("`2Suck Mode: " .. (suckMode and "`2ON" or "`4OFF"))
                    logText("`2Suck Mode toggled: " .. (suckMode and "ON" or "OFF"))
                    return true
                elseif text == "/bank" then
                    autoBank = not autoBank
                    overlayText("`3Auto Bank: " .. (autoBank and "`2ON" or "`4OFF"))
                    logText("`3Auto Bank toggled: " .. (autoBank and "ON" or "OFF"))
                    return true
                elseif text == "/eat" then
                    autoEat = not autoEat
                    overlayText("`2Auto Eat: " .. (autoEat and "`2ON" or "`4OFF"))
                    logText("`2Auto Eat toggled: " .. (autoEat and "ON" or "OFF"))
                    return true
                elseif text == "/webhook" then
                    whUse = not whUse
                    overlayText("`9Webhook: " .. (whUse and "`2ON" or "`4OFF"))
                    logText("`9Webhook toggled: " .. (whUse and "ON" or "OFF"))
                    return true
                elseif text == "/anim" then
                    removeAnimation = not removeAnimation
                    overlayText("`2Remove Animation: " .. (removeAnimation and "`2ON" or "`4OFF"))
                    logText("`2Remove Animation toggled: " .. (removeAnimation and "ON" or "OFF"))
                    return true
                elseif text == "/gems" then
                    collectGem = collectGem == 1 and 0 or 1
                    overlayText("`2Collect Gems: " .. (collectGem == 1 and "`2ON" or "`4OFF"))
                    logText("`2Collect Gems toggled: " .. (collectGem == 1 and "ON" or "OFF"))
                    return true
                elseif text == "/hide" then
                    peopleHide = peopleHide == 1 and 0 or 1
                    overlayText("`2Hide People: " .. (peopleHide == 1 and "`2ON" or "`4OFF"))
                    logText("`2Hide People toggled: " .. (peopleHide == 1 and "ON" or "OFF"))
                    return true
                elseif text == "/invasion" then
                    autoInvasion = not autoInvasion
                    overlayText("`3Auto Invasion: " .. (autoInvasion and "`2ON" or "`4OFF"))
                    logText("`3Auto Invasion toggled: " .. (autoInvasion and "ON" or "OFF"))
                    return true
                elseif text == "/dl" then
                    autoTelephoneDL = not autoTelephoneDL
                    overlayText("`3Auto DL Convert: " .. (autoTelephoneDL and "`2ON" or "`4OFF"))
                    logText("`3Auto DL Convert toggled: " .. (autoTelephoneDL and "ON" or "OFF"))
                    return true
                elseif text == "/help" or text == "/pnbhelp" then
                    ShowHelpDialog()
                    return true
                elseif text == "/status" then
                    overlayText(GetStatusText())
                    logText("Current Status: " .. GetStatusText())
                    return true
                end
            end
        end
        return false
    end)
end

-- Initialize command handling
handleCommands()

-- Settings Management Dialog
local function ShowSettingsDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`5Settings Management|left|394|
add_spacer|small|
add_textbox|`5Settings Actions:|
add_button|reset_farming|`4Reset Farming Settings|
add_button|reset_banking|`4Reset Banking Settings|
add_button|reset_webhook|`4Reset Webhook Settings|
add_button|reset_all|`4Reset All Settings|
add_spacer|small|
add_textbox|`6Current Configuration Summary:|
add_label_with_icon|small|`wFarming: ]] .. (cheatFarm and "ENABLED" or "DISABLED") .. [[|left|9654|
add_label_with_icon|small|`wAuto Bank: ]] .. (autoBank and "ON" or "OFF") .. [[|left|7188|
add_label_with_icon|small|`wAuto Eat: ]] .. (autoEat and "ON" or "OFF") .. [[|left|4604|
add_label_with_icon|small|`wWebhook: ]] .. (whUse and "ENABLED" or "DISABLED") .. [[|left|1436|
add_label_with_icon|small|`wMagplants: ]] .. #allMagplants .. [[ found|left|5638|
add_spacer|small|
add_textbox|`4Warning: Reset actions cannot be undone!|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|pnb_settings_mgmt|Close|
]]
    SendVariantList(varlist_command)
end

function isUserIdAllowed(userid)
    for _, allowedId in ipairs(UID) do
        if userid == allowedId then
            return true
        end
    end
    return false
end

userId = tostring(GetLocal().userid)
if isUserIdAllowed(userId) then
    logText("`2User ID Terdaftar.")
    while true do
        if GetWorld() == nil then
            Sleep(1000)
            reconnectPlayer(worldName)
        end
    
        getPos()
    
        if GetPlayerInfo().gems >= 110000 then
            SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..positionX.."|\ny|"..positionY.."|\nbuttonClicked|dlconvert")
            Sleep(1000)
        end
    
        if changeRemote then
            Console("Remote needs changing, attempting to switch magplants...")
            if switchToNextMagplant() then
                magplantCount = currentMagplantIndex
                Sleep(1000)
                changeRemote = false
                noStock = false
            else
                warnText("`4No valid magplants found with background ID " .. backgroundID)
                changeRemote = false
                noStock = false
            end
            goto continue
        end
    
        getRemote()
        Sleep(1000)
        FindPath(positionX, positionY, 100)
        Sleep(1000)
    
        if cheatFarm then
            nowFarm = true
            playerHook("Farming")
            while nowFarm do
                for i = 1, 1 do
                    Sleep(4500)
                    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_lonely|".. peopleHide .."\ncheck_gems|".. collectGem)
                end
    
                if GetWorld() == nil then
                    Sleep(1000)
                    reconnectPlayer()
                    Sleep(1000)
                    break
                end
    
                if GetWorld().name == (worldName:upper()) then
                    Sleep(1000)
                else
                    Sleep(1000)
                    worldNot()
                    Sleep(1000)
                    break
                end
    
                if autoEat == true then
                    SendPacket(2,"action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0")
                    Sleep(500)
                    place(4604, 0, 0)
                    overlayText("`#[`b@Mupnup`#] `^Auto Eat Buff")
                    logText("Added `2Arroz Con Pollo `6buff for 30 minutes (`2More Gems!`6).")
                    Sleep(500)
                    place(528, 0, 0)
                    overlayText("`#[`b@Mupnup`#] `^Auto Eat Buff")
                    logText("Added `2Lucky Clover `6buff for 30 minutes (`2More Lucky!`6).")
                    Sleep(500)
                    place(1056, 0, 0)
                    overlayText("`#[`b@Mupnup`#] `^Auto Eat Buff")
                    logText("Added `2Songpyeon `6buff for 30 minutes (`2More Lucky!`6).")
                    Sleep(500)
                    nowFarm = true
                    autoEat = false
                end
    
                if autoGhost then
                    SendPacket(2, "action|input\ntext|/ghost")
                    break
                end
    
                local gems = GetPlayerInfo().gems
                local bglCount = findItem(7188)
    
                if autoTelephoneDL and gems >= 110000 then 
                    CONVERT_TO_DL()
                end
    
                if findItem(1796) >= 100 then
                    CONVERT_TO_BGL()
                end
    
        -- Deposit or convert BGL
        if autoBank and bglCount >= 1 then
            SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|"..bglCount)
            Sleep(100)
        elseif not autoBank and bglCount >= 100 then
            SendPacket(2, "action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
            Sleep(100)
        end
    
                if nowBuy and autoInvasion then
                    if gems >= 10000 then
                        SendPacket(2, "action|buy\nitem|buy_worldlockpack")
                        Sleep(100)
                        if not GetWorld() then
                            Sleep(1000)
                            reconnectPlayer()
                            Sleep(1000)
                            break
                        end
                    else
                        Sleep(100)
                    end
    
                    if findItem(242) >= 100 then
                        convert(242)
                        Sleep(100)
                    elseif findItem(1796) >= 100 then
                        local pos = GetLocal().pos
                        Sleep(100)
                        CONVERT_TO_BGL()
                    end
    
       
                end
    
                if changeRemote then
                    nowBuy = false
                    Sleep(1000)
                    break
                end
    
                if GetWorld().name == (worldName:upper()) then
                    Sleep(1000)
                else
                    Sleep(1000)
                    worldNot()
                    Sleep(1000)
                    break
                end
    
                if GetWorld() == nil then
                    Sleep(1000)
                    reconnectPlayer()
                    Sleep(1000)
                    break
                end
    
                if changeRemote then
                    nowFarm = false
                    break
                end
    
                if os.time() - timer >= whDelay then
                    starB = true
                    if suckMode then
                        SendPacket(2, "action|wrench\n|netid|"..GetLocal().netid)
                        Sleep(200)
                        SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgems")
                        Sleep(200)
                        SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgem_suckall")
                        playerHook("Taking Dropped Black Gems every ".. whDelay .." Seconds!")
                        Sleep(200)
                    elseif not suckMode then
                        playerHook("Webhook PING! every ".. whDelay .." Seconds!")
                        Sleep(200)
                    end
                    timer = os.time()
                    Sleep(1000)
                    starB = false
                end
            end
        end
        ::continue::
    end
else
    logText("`4User ID Tidak Terdaftar.")
end
