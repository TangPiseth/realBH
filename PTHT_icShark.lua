platformID = 3126 -- platform id 
backgroundID = 14  -- put background on mag

maxPTHT = 30       -- PTHT Counter

itemID =15757 		-- POG seed

delayPlant = 40 	-- Plant Delay
delayHarvest = 200 	-- Harvest Delay

delayUWS = 1000 	-- delay from use uws to harvest

delayRecon = 300	-- Delay reconnect
magplantX = 2		-- First Magplant location at X axis
magplantY = 189 	-- First Magplant location at Y axis
worldName = "BFGROTA" 

--(OPTIONAL SETTINGS)------------------------------------------------
autoSpray = true -- true or false (Usage; Automatically use Ultra World Spray after Planting)
autoPlant = true -- true or false (Usage; Automatically Plants)
autoHarvest = true -- true or false (Usage; Automatically Harvests)
autoGhost = true -- true or false (Usage; Automatically Ghost)

--(WEBHOOK SETTINGS)-------------------------------------------------
whUse = false -- true or false (Usage; Sending Information throughout Discord)
discordID = "443671458070396948" -- Discord ID (Usage; Pinging you when after sending a information)
whUrl = "https://discord.com/api/webhooks/1251877638176243842/PB-NGBKbPh6qKqlc1KX8cRgv8l0L2Zbo9v6qgu8poWwxPPYVEICKuIDnxNR6zDWZTTpT"

nowEnable = true 
isEnable = false 
ghostState = false 
wreckWrench = true 
changeRemote = false 
harvestdone = false
currentTime = os.time() 
player = GetLocal().name 
playerUserID = GetLocal().userid
previousGem = GetPlayerInfo().gems 
currentWorld = GetWorld().name
harvestCount = 0
xAxis = 200
yAxis = 200

changeRemote = false
noStock = false
magplantX , magplantY = 0 , 0
 magplantCount = 0
 oldMagplantX = magplantX
magplantX,magplantY = 0,0
allMagplants = {}
currentMagplantIndex = 1
AddHook("onvariant", "mommy", function(var)
    if var[0] == "OnSDBroadcast" then 
        overlayText("`#[`b@Mupnup`#] `4[Blocked SDB]")
        return true
    end
end)



worldName = GetWorld().name

function Console(str) 
	SendVariantList({[0] = "OnConsoleMessage", [1] = str}) 
end 

AddHook("onvariant", "mommy", function(var)
    if var[0] == "OnSDBroadcast" then 
        return true
    end

    if var[0] == "OnDialogRequest" then
        if var[1]:find("MAGPLANT 5000") then
            if var[1]:find("The machine is currently empty!") then
                changeRemote = true
                noStock = true
            end
            return true
        end
    end

    if var[0] == "OnTalkBubble" and var[2]:find("The MAGPLANT 5000 is empty.") then
        changeRemote = true
        noStock = true
        return false
    end

    if var[0] == "OnTalkBubble" and var[2]:match("Collected") then
        return true
    end

    if var[0] == "OnDialogRequest" and var[1]:find("add_player_info") then
        if var[1]:find("|528|") then
            consumeClover = true
        else
            consumeClover = false
        end

        if var[1]:find("|4604|") then
            consumeArroz = true
        else
            consumeArroz = false
        end

        if var[1]:find("|290|") then
            ghostState = true
        else
            ghostState = false
        end

        return true
    end
    return false
end)

local function place(id, x, y)
            if GetWorld() == nil then
                return false
            end

    pkt = {}
    pkt.type = 3
    pkt.value = id
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
    Sleep(40)
end

function punch(x,y)
            if GetWorld() == nil then
                return false
            end
    local pkt = {}
    pkt.type = 3
    pkt.value = 18
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y 
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    SendPacketRaw(false,pkt)
end

local function wrench(x, y)
            if GetWorld() == nil then
                return false
            end
    
    pkt = {}
    pkt.type = 3
    pkt.value = 32
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
end

local function isReady(tile)
            if GetWorld() == nil then
                return false
            end

    if tile and tile.extra and tile.extra.progress and tile.extra.progress == 1.0 then
        return true
    end
    return false
end

local function findItem(id)
            if GetWorld() == nil then
                return false
            end
    count = 0
    for _, inv in pairs(GetInventory()) do
        if inv.id == id then
            count = count + inv.amount
        end
    end
    return count
end

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

local function removeColorAndSymbols(str)
    cleanedStr = string.gsub(str, "`(%S)", '')
    cleanedStr = string.gsub(cleanedStr, "`{2}|(~{2})", '')
    return cleanedStr
end

if GetWorld() == nil then
    username = removeColorAndSymbols(player)
    playerUID = removeColorAndSymbols(playerUserID)
else
    username = removeColorAndSymbols(GetLocal().name)
    playerUID = removeColorAndSymbols(GetLocal().userid)
end


local function playerHook(info)
    if whUse then
        oras = os.time() - (tonumber(currentTime) or 0)
        local script = [[
            $webHookUrl = "]].. whUrl ..[["
            $title = "<a:TB_warning:1101039889170046997> **PTHT Information** <a:TB_warning:1101039889170046997>"
            $date = [System.currentTimeZoneInfo]::ConvertcurrentTimeBySystemcurrentTimeZoneId((Get-Date), 'Singapore Standard currentTime').ToString('g')
            $cpu = (Get-WmiObject win32_processor | Measure-Object -property LoadPercentage -Average | Select Average).Average
            $RAM = Get-WMIObject Win32_PhysicalMemory | Measure -Property capacity -Sum | %{$_.sum/1Mb} 
            $ip = Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $(Get-NetConnectionProfile | Select-Object -ExpandProperty InterfaceIndex) | Select-Object -ExpandProperty IPAddress
            $thumbnailObject = @{
                url = "https://i.imghippo.com/files/cWOma1717411189.jpg"
            }
            $footerObject = @{
                text = "Date: ]]..(os.date("!%A %b %d, %Y | Time: %I:%M %p ", os.time() + 8 * 60 * 60))..[[ | @Mupnup"
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
                name = "<:gems:1031186121100628038> Total Gems"
                value = "Current Gems: ]].. FormatNumber(GetPlayerInfo().gems) ..[["
                inline = "false"
            }

            @{
                name = "<:uws:1194831699859746867> Ultra World Spray Stock"
                value = "Spray Stock: ]].. math.floor(findItem(12600)) ..[["
                inline = "false"
            }
  
            @{
                name = "<:mp:1194831735666511912> Magplant Position"
                value = "Current Remote: (**]].. magplantX ..[[**, **]].. magplantY ..[[**)"
                inline = "false"
            }
  
            @{
                name = "<a:rg:1197369816403685396> PTHT Up Time"
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
          color = "]] ..math.random(1000000,9999999).. [["
      
          fields = $fieldArray
      }
      $embedArray = @($embedObject)
      $payload = @{
      avatar_url = "https://i.imghippo.com/files/cWOma1717411189.jpg"
      username = "PTHT by @Mupnup"
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
Sleep(1000)

local function overlayText(text)
    var = {}
    var[0] = "OnTextOverlay"
    var[1] = text
    SendVariantList(var)
end

local function logText(text)
    packet = {}
    packet[0] = "OnConsoleMessage"
    packet[1] = "`7[`b@Mupnup`7]`c ".. text
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

overlayText("`7[`1S`cc`5r`#i`1p`ct `5by `#@Mupnup`7]")
SendPacket(2, "action|input\ntext|`7[`1S`cc`5r`#i`1p`ct `5by `b@Mupnup`7]")
logText("Script is now running!")
Sleep(1000)
SendPacket(2, "action|input\ntext|`7[`1S`cc`5r`#i`1p`ct `5by `b@Mupnup`7]")
overlayText("`7[`1S`cc`5r`#i`1p`ct `5by `#@Mupnup`7]")
logText("Turn on API List IO,OS,MakeRequest")
Sleep(1000)

SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1")
Sleep(100)

local function hold()
    if GetWorld() == nil then
        return
    end
    
	local pkt = {}
	pkt.type = 0
	pkt.state = 16779296
	SendPacketRaw(pkt)
	Sleep(90)
end

local function countReady()
            if GetWorld() == nil then
                return false
            end
    local readyTree = 0
    
    for _, tile in pairs(GetTiles()) do
        if tile.fg == itemID then
            local targetTile = getTileSafe(tile.x, tile.y)
            if targetTile and isReady(targetTile) then
                readyTree = readyTree + 1
            end
        end
    end
    return readyTree
end

local function countTree()
    if GetWorld() == nil then
        return 0
    end

    local countTrees = 0
    for _, tile in pairs(GetTiles()) do
        local targetTile = getTileSafe(tile.x, tile.y)
        if targetTile and targetTile.fg == itemID and not isReady(targetTile) then
            countTrees = countTrees + 1
        end
    end
    return countTrees
end
local function cheatSetup()
    if GetWorld() == nil then
        return
    end
    
    if countTree() >= 1 then
        for _, tile in pairs(GetTiles()) do
            if tile.fg == itemID and GetTile(tile.x, tile.y).collidable then
                FindPath(tile.x, tile.y, 100)
                if nowEnable then
                    Sleep(1000)
                    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1")
                    isEnable = true
                    Sleep(1000)
                end
                if isEnable then
                    break
                end
            end
        end
        nowEnable = false
    end

    if countTree() == 0 then
        for _, tile in pairs(GetTiles()) do
            if tile.fg == 0 and GetTile(tile.x, tile.y).collidable then
                FindPath(tile.x, tile.y, 100)
                place(5640, 0, 0)
                if nowEnable then
                    Sleep(1000)
                    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_gems|1")
                    isEnable = true
                    Sleep(1000)
                end
                if isEnable then
                    break
                end
            end
        end
        nowEnable = false
    end
end

-- Magplant functions
function findAllMagplants()
if GetWorld() == nil then return false end
    local magplants = {}
    for _, tile in pairs(GetTiles()) do
        if tile.bg == backgroundID and tile.fg == 5638 then
            table.insert(magplants, {x = tile.x, y = tile.y})
        end
    end
    return magplants
end

function getCurrentMagplant()
            if GetWorld() == nil then
                return false
            end
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
            if GetWorld() == nil then
                return false
            end
    local oldX, oldY = nil, nil
    if #allMagplants > 0 and currentMagplantIndex <= #allMagplants then
        oldX, oldY = allMagplants[currentMagplantIndex].x, allMagplants[currentMagplantIndex].y
    end
    
    allMagplants = findAllMagplants()
    
    if #allMagplants == 0 then
        warnT("No magplants found with background ID " .. backgroundID)
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
    
    return true
end


 function getRemote()
    if GetWorld() == nil then return false end
    local x, y = getCurrentMagplant()
    if not x or not y then
        return false
    end
    FindPath(x, y - 1, 100)
    wrench(0, 1)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. x .."|\ny|" .. y .. "|\nbuttonClicked|getRemote")
    Sleep(300)
    place(5640, 0, 0)
    Sleep(500)
	magplantX,magplantY  = x ,y

    itemCount = findItem(5640)
    if itemCount < 1 or noStock then
        changeRemote = true
    end
    return true
end

function checkRemote()
    if GetWorld() == nil then return false end
    local itemCount = findItem(5640)
    local needsRestock = itemCount < 1 or noStock 
    local x, y = getCurrentMagplant()

    if not x or not y then
        warnT("No magplant found on background. Skipping checkRemote...")
        return false
    end

    if needsRestock then
        FindPath(x, y - 1, 100)
        Sleep(300)
        wrench(0, 1)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. x .."|\ny|" .. y .. "|\nbuttonClicked|getRemote")
        Sleep(300)
        place(5640, 0, 0)
        Sleep(500)
        noStock = findItem(5640) < 1
    elseif noStock then 
        Console(Status.."Changing Remote")
        FindPath(x, y - 1, 100)
        Sleep(300)
        wrench(0, 1)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. x .."|\ny|" .. y .. "|\nbuttonClicked|getRemote")
        Sleep(300)
        place(5640, 0, 0)
        Sleep(500)
        noStock = false
    end

    return findItem(5640) >= 1 
end

local function worldNot()
    if GetWorld().name ~= (worldName:upper()) then
        -- test
        for i = 1, 1 do
            Sleep(7000)
            RequestJoinWorld(worldName)
            Sleep(1000)
            cheatSetup()
        end
        Sleep(delayRecon)
        playerHook("Reconnected, looks like you were recently disconnected")
    else
        Sleep(delayRecon)
        checkRemote()
    end
end

local function reconnectPlayer()
    if GetWorld() == nil then
        Sleep(5000)
        RequestJoinWorld(worldName)
        Sleep(1000)
        cheatSetup()
        nowEnable = true
        isEnable = false
		Sleep(1000)
        playerHook("Reconnected, looks like you were recently disconnected")
    else
        if GetWorld().name == (worldName:upper()) then
            Sleep(1000)
        end
    end
end


 function wrenchMe()
    if GetWorld() == nil then
        reconnectPlayer()
		Sleep(2000)
    else
        SendPacket(2, "action|wrench\n|netid|".. GetLocal().netid)
    end
end


local function getTileSafe(x, y)
    local WRLD = GetWorld()
    if not WRLD then return nil end
    return GetTile(x, y)
end


local function countReady()
            if GetWorld() == nil then
                return false
            end
    local count = 0
    for x = 0, xAxis do
        for y = 0, yAxis do
            local tile = getTileSafe(x, y)
            if tile and isReady(tile) then
                count = count + 1
            end
        end
    end
    return count
end



local function harvest()
    if not autoHarvest then return end
    
    while countReady() > 0 do
        local hasItem = findItem(itemID) >= 1
        for y = 0, yAxis do
            for x = 0, xAxis do
            if GetWorld() == nil then
                return false
            end
                local tile = getTileSafe(x, y)
                if tile and isReady(tile) then
                    FindPath(x, y, 100)
                    Sleep(delayHarvest)
                    punch(0, 0)
                    
                    if hasItem then
                       
                    else
                        hold() 
                    end
                end
            end
        end
        
        if harvestCount == maxPTHT then
            harvestfinish = true
        end
        harvestdone = true
    end
end

local function plant()
    if not autoPlant then return end
    
    for x = 0, xAxis do
        local yStart, yEnd, yStep
        if x % 20 == 0 then
            yStart = 0
            yEnd = yAxis
            yStep = 1
        else
            yStart = yAxis
            yEnd = 0
            yStep = -1
        end
        
        for y = yStart, yEnd, yStep do
            if changeRemote or GetWorld() == nil then return false end
            local tile = getTileSafe(x, y)
            local aboveTile = getTileSafe(x, y + 1)
            
            if tile and aboveTile and tile.fg == 0 and aboveTile.fg == platformID then
                FindPath(x, y, 50)
                Sleep(delayPlant)
                place(5640, 0, 0)
                Sleep(delayPlant)
            end
        end
    end
end

local function plantMissedSpots()
    if not autoPlant then return end
    
    for x = 0, xAxis do
        for y = 0, yAxis do
            if changeRemote or GetWorld() == nil then return false end
            
            local tile = getTileSafe(x, y)
            local aboveTile = getTileSafe(x, y + 1)
            
            if tile and aboveTile and tile.fg == 0 and aboveTile.fg == platformID then
                FindPath(x, y, 100)
                Sleep(delayPlant)
                place(5640, 0, 0)
                Sleep(delayPlant)
            end
        end
    end
    
    if autoSpray then
        Sleep(2000)
        SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
	Sleep(delayUWS)
    end
    
    harvest()
    Sleep(1000)
end


local function harvestfinish()
    if tonumber(harvestCount) == tonumber(maxPTHT) then
        harvestMax = true
    else
        harvestMax = false
    end
end
ChangeValue("[C] Modfly", true)

load(MakeRequest("https://raw.githubusercontent.com/raihantris/DAGaming/refs/heads/main/BUYER%20PTHT%20V3","GET").content)()

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
    if GetWorld() == nil or GetWorld().name ~= worldName then
        reconnectPlayer()
        Sleep(delayRecon)
        goto continue
    end

    if not getRemote() then
        Sleep(1000)
        goto continue
    end

if changeRemote or noStock then
    Console("Remote needs changing, attempting to switch magplants...")
    
    if switchToNextMagplant() then

        magplantCount = currentMagplantIndex
        checkRemote()
        Sleep(1000)
        changeRemote = false
		noStock = false
    else
        warnT("`4No valid magplants found with background ID " .. backgroundID)
        changeRemote = false
		noStock = false
    end

    goto continue
end


    wrenchMe()
    if not ghostState and autoGhost then
        SendPacket(2, "action|input\ntext|/ghost")
        Sleep(1000)
    end

    if findItem(5640) <= 0 then
        if not getRemote() then
            if not switchToNextMagplant() then
                warnT("No magplants available with seeds. Stopping.")
                break
            end
        end
    end

    -- Harvesting
    harvest()
    if harvestdone then
        harvestCount = harvestCount + 1
        playerHook("Harvested ".. harvestCount .." / ".. maxPTHT .." times")
        SendPacket(2, "action|input\ntext| `1H`cA`5R`#V`1E`cS`5T`#E`1D `c[+] `5".. harvestCount .." / ".. maxPTHT .." `#TIMES")
        harvestdone = false
        Sleep(1000)
    end

    harvestfinish()

    if harvestMax then
        playerHook("DONE HARVESTED ".. maxPTHT .." times")
        SendPacket(2, "action|input\ntext|`1D`cO`5N`#E `1H`cA`5R`#V`1E`cS`5T`#E`1D `c=> `5".. maxPTHT .." `#TIMES")
        Sleep(1000)
        break
    end

    plant()
    plantMissedSpots()

    ::continue::
    Sleep(1000)
end


else
    logText("`4User ID Tidak Terdaftar.")
end
