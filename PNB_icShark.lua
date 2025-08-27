collectGem = 1 -- 1 IS COLLECT Gems, 0 IS Dropped Black Gems
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


timer = os.time()
starB = false
oldMagplantX = magplantX 
oldMagplantY = magplantY 
magplantCount = 1 
cheatFarm = true 
setCurrent = true 
buyLock = false 
autoDLock = false 
changeRemote = false 
player = GetLocal().name 
playerUserID = GetLocal().userid
currentGem = GetPlayerInfo().gems 
currentWorld = GetWorld().name 
jumlahbgems = 0
magplantX, magplantY = 0, 0 
positionX = 0
positionY = 0
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
SendPacket(2, "action|input\ntext|`#[`2Script by `b@Mupnup`#]")
overlayText("`#[`2Script by `b@Mupnup`#]")
Sleep(1000)
SendPacket(2, "action|input\ntext|`#[`2Script by `b@Mupnup`#]")
overlayText("`#[`2Script by `b@Mupnup`#]")
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
if GetWorld() == nil then return false end
    local magplants = {}
    for _, tile in pairs(GetTiles()) do
        if tile.bg == backgroundID and tile.fg == 5638 then
            table.insert(magplants, {x = tile.x, y = tile.y})

        end
    end
    return magplants
end

local function getCurrentMagplant()
if GetWorld() == nil then return false end
    if #allMagplants == 0 then
        allMagplants = findAllMagplants()
        Console("Found " .. #allMagplants .. " magplants with background ID " .. backgroundID)
    end
    
    if #allMagplants == 0 then
        return nil, nil
    end
    
    return allMagplants[currentMagplantIndex].x, allMagplants[currentMagplantIndex].y
end

local function switchToNextMagplant()
if GetWorld() == nil then return false end
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
    if GetWorld().name ~= (worldName:upper()) then
        -- test
        Sleep(delayErcon)
        RequestJoinWorld(worldName)
        overlayText("`#[`b@Mupnup`#] `^Request to join world `2".. worldName.."")
        Sleep(1000)
        playerHook("Reconnected, looks like you were recently disconnected")
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
