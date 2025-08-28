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
isDebug = false -- true or false (Usage; Enable debug logging)

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
previousGem = GetPlayerInfo() and GetPlayerInfo().gems or 0
currentWorld = GetWorld() and GetWorld().name or "NONE"
harvestCount = 0
xAxis = 200
yAxis = 200

changeRemote = false
noStock = false
magplantX, magplantY = 0, 0
magplantCount = 0
oldMagplantX = magplantX
oldMagplantY = magplantY
allMagplants = {}
currentMagplantIndex = 1
AddHook("onvariant", "mommy", function(var)
    if var[0] == "OnSDBroadcast" then 
        overlayText("`#[`b@Mupnup`#] `4[Blocked SDB]")
        return true
    end
end)



-- Initialize worldName safely
worldName = GetWorld() and GetWorld().name or worldName

-- Function to safely initialize variables
function initializeVariables()
    -- Safe initialization of player variables
    player = GetLocal() and GetLocal().name or "Unknown"
    playerUserID = GetLocal() and GetLocal().userid or 0
    previousGem = GetPlayerInfo() and GetPlayerInfo().gems or 0
    currentWorld = GetWorld() and GetWorld().name or worldName
    
    -- Initialize other variables if needed
    if not allMagplants then allMagplants = {} end
    if not currentMagplantIndex then currentMagplantIndex = 1 end
    if not harvestCount then harvestCount = 0 end
end

-- Call initialization
pcall(initializeVariables)

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

local function removeColorAndSymbols(str)
    if not str then return "" end
    cleanedStr = string.gsub(str, "`(%S)", '')
    cleanedStr = string.gsub(cleanedStr, "`{2}|(~{2})", '')
    return cleanedStr
end

-- Initialize player variables safely
local username, playerUID
if GetWorld() == nil then
    username = removeColorAndSymbols(player or "")
    playerUID = removeColorAndSymbols(tostring(playerUserID or ""))
else
    username = removeColorAndSymbols(GetLocal().name or "")
    playerUID = removeColorAndSymbols(tostring(GetLocal().userid or ""))
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

-- CHECKBOX utility function for dialogs
local function CHECKBOX(value)
    return value and "1" or "0"
end

-- Alternative pattern matching - text input extraction helper
local function extractTextInput(packet, fieldName)
    -- Try multiple patterns for dialog text extraction
    local patterns = {
        "text_input|" .. fieldName .. "|([^|&\n\r]+)",
        fieldName .. "=([^&\n\r]+)",
        fieldName .. "|([^|&\n\r]+)"
    }
    
    for _, pattern in ipairs(patterns) do
        local value = packet:match(pattern)
        if value then
            return value
        end
    end
    
    -- If nothing found, try line-by-line search
    for line in packet:gmatch("[^\r\n]+") do
        if line:find(fieldName) then
            for _, pattern in ipairs(patterns) do
                local value = line:match(pattern)
                if value then
                    return value
                end
            end
        end
    end
    
    return nil
end

-- Get current status text for dialogs
local function GetPTHTStatusText()
    local status = {}
    if GetWorld() then
        table.insert(status, "`6World: `2" .. (GetWorld().name or "UNKNOWN"))
        
        -- Safely call countTree with error handling
        local treeCount = 0
        pcall(function() treeCount = countTree() or 0 end)
        table.insert(status, "`6Trees: `2" .. treeCount)
        
        -- Safely call countReady with error handling
        local readyCount = 0
        pcall(function() readyCount = countReady() or 0 end)
        table.insert(status, "`6Ready: `2" .. readyCount)
        
        -- Safely get remote count
        local remoteCount = 0
        pcall(function() remoteCount = findItem(5640) or 0 end)
        table.insert(status, "`6Remote: `2" .. remoteCount)
        
        table.insert(status, "`6Harvests: `2" .. (harvestCount or 0) .. "/" .. (maxPTHT or 0))
    else
        table.insert(status, "`4World: DISCONNECTED")
    end
    return table.concat(status, " | ")
end

-- Main PTHT Dialog Function
local function ShowPTHTMainDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
text_scaling_string|pthtConfig
add_label_with_icon|big|`#[`bPTHT icShark `#] `2Settings|left|15757|
add_spacer|small|
add_label_with_icon|small|Welcome back, ]]..GetLocal().name..[[|right|2278|
add_textbox|`bPTHT Settings by `#@Mupnup|
add_spacer|small|
add_smalltext|]]..GetPTHTStatusText()..[[|
add_spacer|small|
add_textbox|`2Core PTHT Settings:|
add_text_input|maxPTHT|Max PTHT Count:|]]..maxPTHT..[[|5|
add_text_input|itemID|Seed Item ID:|]]..itemID..[[|8|
add_text_input|platformID|Platform ID:|]]..platformID..[[|8|
add_text_input|backgroundID|Background ID:|]]..backgroundID..[[|8|
add_text_input|worldName|World Name:|]]..worldName..[[|20|
add_spacer|small|
add_textbox|`3Automation Settings:|
add_checkbox|autoPlant|`3Auto Plant Seeds|]]..CHECKBOX(autoPlant)..[[|
add_checkbox|autoHarvest|`3Auto Harvest Trees|]]..CHECKBOX(autoHarvest)..[[|
add_checkbox|autoSpray|`3Auto Use Ultra World Spray|]]..CHECKBOX(autoSpray)..[[|
add_checkbox|autoGhost|`3Auto Ghost Mode|]]..CHECKBOX(autoGhost)..[[|
add_spacer|small|
add_button_with_icon|delay_settings|`5Delay|staticBlueFrame|394||
add_button_with_icon|webhook_settings|`9Webhook|staticBlueFrame|1436||
add_button_with_icon|position_settings|`6Position|staticBlueFrame|1684||
add_button_with_icon|help_dialog|`7Commands|staticBlueFrame|18||
add_button_with_icon||END_LIST|noflags|0|
add_spacer|small|
add_button|save_settings|`2Save Settings|
add_quick_exit||
end_dialog|ptht_main|Close|
]]
    SendVariantList(varlist_command)
end

-- Delay Settings Dialog
local function ShowPTHTDelayDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`5PTHT Delay Settings|left|394|
add_spacer|small|
add_textbox|`5Timing Configuration:|
add_text_input|delayPlant|Plant Delay (ms):|]]..delayPlant..[[|8|
add_text_input|delayHarvest|Harvest Delay (ms):|]]..delayHarvest..[[|8|
add_text_input|delayUWS|UWS Delay (ms):|]]..delayUWS..[[|8|
add_text_input|delayRecon|Reconnect Delay (ms):|]]..delayRecon..[[|8|
add_spacer|small|
add_textbox|`4Current Values:|
add_label_with_icon|small|`wPlant: `2]]..delayPlant..[[ms|left|9654|
add_label_with_icon|small|`wHarvest: `2]]..delayHarvest..[[ms|left|15757|
add_label_with_icon|small|`wUWS: `2]]..delayUWS..[[ms|left|12600|
add_label_with_icon|small|`wReconnect: `2]]..delayRecon..[[ms|left|394|
add_spacer|small|
add_textbox|`4Quick Settings:|
add_button|plant_20|`9Set Plant: 20ms|
add_button|plant_50|`9Set Plant: 50ms|
add_button|plant_100|`9Set Plant: 100ms|
add_button|plant_200|`9Set Plant: 200ms|
add_spacer|small|
add_button|harvest_100|`#Set Harvest: 100ms|
add_button|harvest_200|`#Set Harvest: 200ms|
add_button|harvest_300|`#Set Harvest: 300ms|
add_button|harvest_500|`#Set Harvest: 500ms|
add_spacer|small|
add_button|uws_500|`2Set UWS: 500ms|
add_button|uws_1000|`2Set UWS: 1000ms|
add_button|uws_2000|`2Set UWS: 2000ms|
add_spacer|small|
add_button|recon_300|`4Set Reconnect: 300ms|
add_button|recon_500|`4Set Reconnect: 500ms|
add_button|recon_1000|`4Set Reconnect: 1000ms|
add_spacer|small|
add_textbox|`4Important Note:|
add_smalltext|`4Use the quick setting buttons above instead for reliable changes.|
add_spacer|small|
add_button|apply_delay|`2Apply Changes|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|ptht_delay|Close|
]]
    SendVariantList(varlist_command)
end

-- Webhook Settings Dialog
local function ShowPTHTWebhookDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`9PTHT Webhook Settings|left|1436|
add_spacer|small|
add_textbox|`9Webhook Configuration:|
add_checkbox|webhookUse|`9Enable Webhook Notifications|]]..CHECKBOX(whUse)..[[|
add_text_input|discordUserID|Discord User ID:|]]..discordID..[[|20|
add_text_input_password|webhookURL|Webhook URL:|]]..whUrl..[[|100|
add_spacer|small|
add_textbox|`2Current Settings:|
add_label_with_icon|small|`wWebhook: `]]..(whUse and "2ENABLED" or "4DISABLED")..[[|left|1436|
add_label_with_icon|small|`wDiscord ID: `2]]..(discordID ~= "" and "SET" or "NOT SET")..[[|left|2278|
add_label_with_icon|small|`wWebhook URL: `2]]..(whUrl ~= "" and "SET" or "NOT SET")..[[|left|15590|
add_spacer|small|
add_textbox|`4Security Notice:|
add_textbox|`4Keep your webhook URL private and secure!|
add_textbox|`4Webhook sends PTHT progress updates|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|ptht_webhook|Apply Changes|
]]
    SendVariantList(varlist_command)
end

-- Position Settings Dialog
local function ShowPTHTPositionDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`6PTHT Position Settings|left|1684|
add_spacer|small|
add_textbox|`6Magplant & Position Configuration:|
add_text_input|magplantX|Magplant X Position:|]]..magplantX..[[|5|
add_text_input|magplantY|Magplant Y Position:|]]..magplantY..[[|5|
add_text_input|xAxis|X Axis Range:|]]..xAxis..[[|5|
add_text_input|yAxis|Y Axis Range:|]]..yAxis..[[|5|
add_spacer|small|
add_textbox|`2Current Positions:|
add_label_with_icon|small|`wMagplant: (`2]]..magplantX..[[`w, `2]]..magplantY..[[`w)|left|5638|
add_label_with_icon|small|`wPlayer: (`2]]..((GetLocal() and math.floor(GetLocal().pos.x / 32)) or 0)..[[`w, `2]]..((GetLocal() and math.floor(GetLocal().pos.y / 32)) or 0)..[[`w)|left|2278|
add_label_with_icon|small|`wRange: `2]]..xAxis..[[ x ]]..yAxis..[[|left|1684|
add_label_with_icon|small|`wMagplants Found: `2]]..#allMagplants..[[|left|5638|
add_spacer|small|
add_textbox|`6Position Actions:|
add_button|refresh_magplants|`6Refresh Magplant List|
add_button|get_current_pos|`6Get Current Position|
add_spacer|small|
add_textbox|`4Tips:|
add_textbox|`4- Use Get Current Position to set your location|
add_textbox|`4- Refresh magplants if they don't show up|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|ptht_position|Apply Changes|
]]
    SendVariantList(varlist_command)
end

-- Help Dialog
local function ShowPTHTHelpDialog()
    if not GetWorld() then
        overlayText("`4Cannot open dialog: Not connected to world!")
        return
    end
    
    local varlist_command = {}
    varlist_command[0] = "OnDialogRequest"
    varlist_command[1] = [[
set_default_color|`o
add_label_with_icon|big|`2PTHT Help & Commands|left|18|
add_spacer|small|
add_textbox|`2Dialog Commands:|
add_label_with_icon|small|`w/ptht, /pthtconfig `0- Open main dialog|left|15757|
add_label_with_icon|small|`w/pththelp `0- Show this help dialog|left|18|
add_spacer|small|
add_textbox|`3Quick Toggle Commands:|
add_label_with_icon|small|`w/pthtplant `0- Toggle auto plant|left|9654|
add_label_with_icon|small|`w/pththarvest `0- Toggle auto harvest|left|15757|
add_label_with_icon|small|`w/pthtspray `0- Toggle auto spray|left|12600|
add_label_with_icon|small|`w/pthtghost `0- Toggle auto ghost|left|290|
add_label_with_icon|small|`w/pthtwebhook `0- Toggle webhook|left|1436|
add_label_with_icon|small|`w/pthtdebug `0- Toggle debug mode|left|32|
add_label_with_icon|small|`w/pthtstatus `0- Show current status|left|394|
add_spacer|small|
add_textbox|`4Current Status:|
add_smalltext|]]..GetPTHTStatusText()..[[|
add_spacer|small|
add_textbox|`5System Information:|
add_label_with_icon|small|`wWorld: `2]]..((GetWorld() and GetWorld().name) or "NONE")..[[|left|1402|
add_label_with_icon|small|`wSeed ID: `2]]..itemID..[[|left|15757|
add_label_with_icon|small|`wMax PTHT: `2]]..maxPTHT..[[|left|394|
add_label_with_icon|small|`wHarvest Count: `2]]..harvestCount..[[|left|11550|
add_label_with_icon|small|`wRemote Count: `2]]..findItem(5640)..[[|left|5640|
add_spacer|small|
add_button|back_main|`9Back to Main|
add_quick_exit||
end_dialog|ptht_help|Close|
]]
    SendVariantList(varlist_command)
end

-- Dialog Response Handler
AddHook("OnSendPacket", "PTHTDialogHandler", function(type, packet)
    if type == 2 and packet:find("action|dialog_return") then
        -- Add debug logging
        if isDebug then
            overlayText("`9Dialog Response: " .. string.sub(packet, 1, 100) .. "...")
            logText("`9Dialog Response Debug (Full Packet): " .. packet)
            
            -- Print each line of the packet for detailed debugging
            logText("`9===== PACKET LINES =====")
            for line in packet:gmatch("[^\n]+") do
                logText("`9Line: " .. line)
            end
            logText("`9=======================")
            
            -- Print debug info about button clicks
            if packet:find("buttonClicked|") then
                local button = packet:match("buttonClicked|([^|&\n]+)")
                logText("`9Button clicked: " .. (button or "none"))
            end
            
            -- Check for dialog_name patterns
            local dialogName = packet:match("dialog_name|([^|&\n]+)")
            if dialogName then
                logText("`9Dialog name: " .. dialogName)
            end
        end
        
        if packet:find("dialog_name|ptht_main") then
            -- Handle main dialog responses
            if packet:find("buttonClicked|delay_settings") then
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|webhook_settings") then
                ShowPTHTWebhookDialog()
                return true
            elseif packet:find("buttonClicked|position_settings") then
                ShowPTHTPositionDialog()
                return true
            elseif packet:find("buttonClicked|help_dialog") then
                ShowPTHTHelpDialog()
                return true
            elseif packet:find("buttonClicked|save_settings") then
                -- Extract and validate core settings
                local newMaxPTHT = packet:match("text_input|maxPTHT|([^|]+)")
                local newItemID = packet:match("text_input|itemID|([^|]+)")
                local newPlatformID = packet:match("text_input|platformID|([^|]+)")
                local newBackgroundID = packet:match("text_input|backgroundID|([^|]+)")
                local newWorldName = packet:match("text_input|worldName|([^|]+)")
                
                -- Validate and update maxPTHT
                if newMaxPTHT and tonumber(newMaxPTHT) then
                    local count = tonumber(newMaxPTHT)
                    if count >= 1 and count <= 1000 then
                        maxPTHT = count
                        logText("`5Max PTHT updated to: " .. maxPTHT)
                    else
                        overlayText("`4Invalid max PTHT! Must be between 1-1000")
                    end
                end
                
                -- Validate and update itemID
                if newItemID and tonumber(newItemID) then
                    local id = tonumber(newItemID)
                    if id > 0 then
                        itemID = id
                        logText("`5Item ID updated to: " .. itemID)
                    else
                        overlayText("`4Invalid item ID! Must be positive")
                    end
                end
                
                -- Validate and update platformID
                if newPlatformID and tonumber(newPlatformID) then
                    local id = tonumber(newPlatformID)
                    if id > 0 then
                        platformID = id
                        logText("`5Platform ID updated to: " .. platformID)
                    else
                        overlayText("`4Invalid platform ID! Must be positive")
                    end
                end
                
                -- Validate and update backgroundID
                if newBackgroundID and tonumber(newBackgroundID) then
                    local id = tonumber(newBackgroundID)
                    if id > 0 then
                        backgroundID = id
                        logText("`5Background ID updated to: " .. backgroundID)
                        -- Refresh magplant list when background ID changes
                        allMagplants = findAllMagplants()
                        currentMagplantIndex = 1
                        logText("`6Refreshed magplant list: Found " .. #allMagplants .. " magplants")
                    else
                        overlayText("`4Invalid background ID! Must be positive")
                    end
                end
                
                -- Validate and update world name
                if newWorldName and newWorldName ~= "" then
                    worldName = newWorldName:upper()
                    logText("`5World name updated to: " .. worldName)
                end
                
                -- Extract checkbox values
                autoPlant = packet:find("checkbox|autoPlant|1") and true or false
                autoHarvest = packet:find("checkbox|autoHarvest|1") and true or false
                autoSpray = packet:find("checkbox|autoSpray|1") and true or false
                autoGhost = packet:find("checkbox|autoGhost|1") and true or false
                
                overlayText("`2PTHT settings saved successfully!")
                logText("`2All PTHT settings have been saved and applied!")
                return true
            end
            
        elseif packet:find("dialog_name|ptht_delay") then
            -- Handle delay dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowPTHTMainDialog()
                return true
            -- Quick buttons for plant delay
            elseif packet:find("buttonClicked|plant_20") then
                delayPlant = 20
                logText("`5Plant delay set to: 20ms")
                overlayText("`5Plant delay set to 20ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|plant_50") then
                delayPlant = 50
                logText("`5Plant delay set to: 50ms")
                overlayText("`5Plant delay set to 50ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|plant_100") then
                delayPlant = 100
                logText("`5Plant delay set to: 100ms")
                overlayText("`5Plant delay set to 100ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|plant_200") then
                delayPlant = 200
                logText("`5Plant delay set to: 200ms")
                overlayText("`5Plant delay set to 200ms!")
                ShowPTHTDelayDialog()
                return true
            -- Quick buttons for harvest delay
            elseif packet:find("buttonClicked|harvest_100") then
                delayHarvest = 100
                logText("`5Harvest delay set to: 100ms")
                overlayText("`5Harvest delay set to 100ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|harvest_200") then
                delayHarvest = 200
                logText("`5Harvest delay set to: 200ms")
                overlayText("`5Harvest delay set to 200ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|harvest_300") then
                delayHarvest = 300
                logText("`5Harvest delay set to: 300ms")
                overlayText("`5Harvest delay set to 300ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|harvest_500") then
                delayHarvest = 500
                logText("`5Harvest delay set to: 500ms")
                overlayText("`5Harvest delay set to 500ms!")
                ShowPTHTDelayDialog()
                return true
            -- Quick buttons for UWS delay
            elseif packet:find("buttonClicked|uws_500") then
                delayUWS = 500
                logText("`5UWS delay set to: 500ms")
                overlayText("`5UWS delay set to 500ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|uws_1000") then
                delayUWS = 1000
                logText("`5UWS delay set to: 1000ms")
                overlayText("`5UWS delay set to 1000ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|uws_2000") then
                delayUWS = 2000
                logText("`5UWS delay set to: 2000ms")
                overlayText("`5UWS delay set to 2000ms!")
                ShowPTHTDelayDialog()
                return true
            -- Quick buttons for reconnect delay
            elseif packet:find("buttonClicked|recon_300") then
                delayRecon = 300
                logText("`5Reconnect delay set to: 300ms")
                overlayText("`5Reconnect delay set to 300ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|recon_500") then
                delayRecon = 500
                logText("`5Reconnect delay set to: 500ms")
                overlayText("`5Reconnect delay set to 500ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|recon_1000") then
                delayRecon = 1000
                logText("`5Reconnect delay set to: 1000ms")
                overlayText("`5Reconnect delay set to 1000ms!")
                ShowPTHTDelayDialog()
                return true
            elseif packet:find("buttonClicked|apply_delay") then
                -- Try to parse dialog form input with a simpler approach
                logText("`5Attempting to process form data...")
                
                -- Enhanced debug logging to see entire packet
                if isDebug then
                    logText("`9DEBUG - FULL PACKET DATA:")
                    logText(packet)
                    
                    -- Extract text input values using alternative patterns
                    local function tryExtract(fieldName)
                        local patterns = {
                            "text_input|" .. fieldName .. "|([^|&\n\r]+)",
                            fieldName .. "=([^&\n\r]+)",
                            fieldName .. "|([^|&\n\r]+)"
                        }
                        
                        for _, pattern in ipairs(patterns) do
                            local value = packet:match(pattern)
                            if value then
                                return value
                            end
                        end
                        
                        -- Line by line search
                        for line in packet:gmatch("[^\r\n]+") do
                            if line:find(fieldName) then
                                logText("`9Found line with " .. fieldName .. ": " .. line)
                                for _, pattern in ipairs(patterns) do
                                    local value = line:match(pattern)
                                    if value then
                                        return value
                                    end
                                end
                            end
                        end
                        
                        return nil
                    end
                    
                    local plantValue = tryExtract("delayPlant")
                    local harvestValue = tryExtract("delayHarvest")
                    local uwsValue = tryExtract("delayUWS")
                    local reconValue = tryExtract("delayRecon")
                    
                    logText("`9Extracted values using alternative patterns:")
                    logText("`9Plant: " .. (plantValue or "nil"))
                    logText("`9Harvest: " .. (harvestValue or "nil"))
                    logText("`9UWS: " .. (uwsValue or "nil"))
                    logText("`9Recon: " .. (reconValue or "nil"))
                    
                    -- Update values if found
                    if plantValue and tonumber(plantValue) then
                        delayPlant = tonumber(plantValue)
                        logText("`5Plant delay updated to: " .. delayPlant .. "ms (from alt pattern)")
                    end
                    
                    if harvestValue and tonumber(harvestValue) then
                        delayHarvest = tonumber(harvestValue)
                        logText("`5Harvest delay updated to: " .. delayHarvest .. "ms (from alt pattern)")
                    end
                    
                    if uwsValue and tonumber(uwsValue) then
                        delayUWS = tonumber(uwsValue)
                        logText("`5UWS delay updated to: " .. delayUWS .. "ms (from alt pattern)")
                    end
                    
                    if reconValue and tonumber(reconValue) then
                        delayRecon = tonumber(reconValue)
                        logText("`5Reconnect delay updated to: " .. delayRecon .. "ms (from alt pattern)")
                    end
                end
                
                -- Try standard pattern matching
                local newDelayPlant = packet:match("text_input|delayPlant|([^|&\n\r]+)")
                local newDelayHarvest = packet:match("text_input|delayHarvest|([^|&\n\r]+)")
                local newDelayUWS = packet:match("text_input|delayUWS|([^|&\n\r]+)")
                local newDelayRecon = packet:match("text_input|delayRecon|([^|&\n\r]+)")
                
                -- Process each value with validation
                if newDelayPlant and tonumber(newDelayPlant) then
                    local delay = tonumber(newDelayPlant)
                    if delay >= 10 and delay <= 1000 then
                        delayPlant = delay
                        logText("`5Plant delay updated to: " .. delayPlant .. "ms")
                    else
                        overlayText("`4Invalid plant delay! Must be between 10-1000ms")
                    end
                end
                
                if newDelayHarvest and tonumber(newDelayHarvest) then
                    local delay = tonumber(newDelayHarvest)
                    if delay >= 50 and delay <= 2000 then
                        delayHarvest = delay
                        logText("`5Harvest delay updated to: " .. delayHarvest .. "ms")
                    else
                        overlayText("`4Invalid harvest delay! Must be between 50-2000ms")
                    end
                end
                
                if newDelayUWS and tonumber(newDelayUWS) then
                    local delay = tonumber(newDelayUWS)
                    if delay >= 100 and delay <= 5000 then
                        delayUWS = delay
                        logText("`5UWS delay updated to: " .. delayUWS .. "ms")
                    else
                        overlayText("`4Invalid UWS delay! Must be between 100-5000ms")
                    end
                end
                
                if newDelayRecon and tonumber(newDelayRecon) then
                    local delay = tonumber(newDelayRecon)
                    if delay >= 100 and delay <= 10000 then
                        delayRecon = delay
                        logText("`5Reconnect delay updated to: " .. delayRecon .. "ms")
                    else
                        overlayText("`4Invalid reconnect delay! Must be between 100-10000ms")
                    end
                end
                
                -- Summary of final values
                if isDebug then
                    logText("`9FINAL DELAY VALUES:")
                    logText("`9Plant: " .. delayPlant)
                    logText("`9Harvest: " .. delayHarvest)
                    logText("`9UWS: " .. delayUWS)
                    logText("`9Recon: " .. delayRecon)
                end
                
                overlayText("`5Delay settings processed!")
                ShowPTHTMainDialog()
                return true
            else
                -- Fallback for unhandled buttons
                logText("`9Unhandled button in delay dialog")
                ShowPTHTDelayDialog()
                return true
            end
            
        elseif packet:find("dialog_name|ptht_webhook") then
            -- Handle webhook dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowPTHTMainDialog()
                return true
            elseif packet:find("buttonClicked|Apply Changes") or packet:find("dialog_button_clicked|Apply Changes") then
                -- Extract and validate webhook values
                whUse = packet:find("checkbox|webhookUse|1") and true or false
                local newDiscordID = packet:match("text_input|discordUserID|([^|]+)")
                local newWebhookURL = packet:match("text_input|webhookURL|([^|]+)")
                
                if newDiscordID and newDiscordID ~= "" then
                    if string.match(newDiscordID, "^%d+$") and string.len(newDiscordID) >= 17 then
                        discordID = newDiscordID
                        logText("`9Discord ID updated successfully")
                    else
                        overlayText("`4Invalid Discord ID format!")
                    end
                end
                
                if newWebhookURL and newWebhookURL ~= "" then
                    if string.match(newWebhookURL, "^https://discord%.com/api/webhooks/") or 
                       string.match(newWebhookURL, "^https://discordapp%.com/api/webhooks/") then
                        whUrl = newWebhookURL
                        logText("`9Webhook URL updated successfully")
                    else
                        overlayText("`4Invalid webhook URL format!")
                    end
                end
                
                overlayText("`9Webhook settings processed!")
                ShowPTHTMainDialog()
                return true
            end
            
        elseif packet:find("dialog_name|ptht_position") then
            -- Handle position dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowPTHTMainDialog()
                return true
            elseif packet:find("buttonClicked|refresh_magplants") then
                allMagplants = findAllMagplants()
                overlayText("`6Found " .. #allMagplants .. " magplants!")
                logText("`6Refreshed magplant list: Found " .. #allMagplants .. " magplants")
                ShowPTHTPositionDialog()
                return true
            elseif packet:find("buttonClicked|get_current_pos") then
                magplantX = math.floor(GetLocal().pos.x / 32)
                magplantY = math.floor(GetLocal().pos.y / 32)
                overlayText("`6Position set to: (" .. magplantX .. ", " .. magplantY .. ")")
                logText("`6Position updated to current location")
                ShowPTHTPositionDialog()
                return true
            elseif packet:find("buttonClicked|Apply Changes") or packet:find("dialog_button_clicked|Apply Changes") then
                -- Extract and validate position values
                local newMagplantX = packet:match("text_input|magplantX|([^|]+)")
                local newMagplantY = packet:match("text_input|magplantY|([^|]+)")
                local newXAxis = packet:match("text_input|xAxis|([^|]+)")
                local newYAxis = packet:match("text_input|yAxis|([^|]+)")
                
                if newMagplantX and tonumber(newMagplantX) then
                    local x = tonumber(newMagplantX)
                    if x >= 0 and x <= 199 then
                        magplantX = x
                        logText("`6Magplant X updated to: " .. magplantX)
                    else
                        overlayText("`4Invalid X position! Must be between 0-199")
                    end
                end
                
                if newMagplantY and tonumber(newMagplantY) then
                    local y = tonumber(newMagplantY)
                    if y >= 0 and y <= 199 then
                        magplantY = y
                        logText("`6Magplant Y updated to: " .. magplantY)
                    else
                        overlayText("`4Invalid Y position! Must be between 0-199")
                    end
                end
                
                if newXAxis and tonumber(newXAxis) then
                    local x = tonumber(newXAxis)
                    if x >= 1 and x <= 200 then
                        xAxis = x
                        logText("`6X Axis updated to: " .. xAxis)
                    else
                        overlayText("`4Invalid X axis! Must be between 1-200")
                    end
                end
                
                if newYAxis and tonumber(newYAxis) then
                    local y = tonumber(newYAxis)
                    if y >= 1 and y <= 200 then
                        yAxis = y
                        logText("`6Y Axis updated to: " .. yAxis)
                    else
                        overlayText("`4Invalid Y axis! Must be between 1-200")
                    end
                end
                
                overlayText("`6Position settings processed!")
                ShowPTHTMainDialog()
                return true
            end
            
        elseif packet:find("dialog_name|ptht_help") then
            -- Handle help dialog responses
            if packet:find("buttonClicked|back_main") then
                ShowPTHTMainDialog()
                return true
            end
        end
    end
    
    return false
end)

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

-- Add command to show main dialog
AddHook("OnSendPacket", "PTHTCommandHandler", function(type, packet)
    if type == 2 and packet:find("action|input") then
        local text = packet:match("|text|(.+)")
        if text then
            if text == "/ptht" or text == "/pthtconfig" then
                ShowPTHTMainDialog()
                return true
            elseif text == "/pththelp" then
                ShowPTHTHelpDialog()
                return true
            elseif text == "/pthtplant" then
                autoPlant = not autoPlant
                overlayText("`9Auto Plant: " .. (autoPlant and "`2ON" or "`4OFF"))
                return true
            elseif text == "/pththarvest" then
                autoHarvest = not autoHarvest
                overlayText("`9Auto Harvest: " .. (autoHarvest and "`2ON" or "`4OFF"))
                return true
            elseif text == "/pthtspray" then
                autoSpray = not autoSpray
                overlayText("`9Auto Spray: " .. (autoSpray and "`2ON" or "`4OFF"))
                return true
            elseif text == "/pthtghost" then
                autoGhost = not autoGhost
                overlayText("`9Auto Ghost: " .. (autoGhost and "`2ON" or "`4OFF"))
                return true
            elseif text == "/pthtwebhook" then
                whUse = not whUse
                overlayText("`9Webhook: " .. (whUse and "`2ON" or "`4OFF"))
                return true
            elseif text == "/pthtdebug" then
                isDebug = not isDebug
                overlayText("`9Debug Mode: " .. (isDebug and "`2ON" or "`4OFF"))
                return true
            elseif text == "/pthtstatus" then
                overlayText(GetPTHTStatusText())
                return true
            end
        end
    end
    
    return false
end)

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

-- First countReady implementation (use the more comprehensive one later)
local function _countReadyLegacy()
    if GetWorld() == nil then
        return 0
    end
    local readyTree = 0
    
    for _, tile in pairs(GetTiles()) do
        if tile and tile.fg == itemID then
            local targetTile = getTileSafe(tile.x, tile.y)
            if targetTile and isReady(targetTile) then
                readyTree = readyTree + 1
            end
        end
    end
    return readyTree
end

function countTree()
    if GetWorld() == nil then
        return 0
    end
    
    local countTrees = 0
    pcall(function()
        for _, tile in pairs(GetTiles()) do
            if tile and tile.fg == itemID then
                countTrees = countTrees + 1
            end
        end
    end)
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
    if GetWorld() == nil then return {} end
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
        return nil, nil
    end
    
    -- Initialize currentMagplantIndex if it doesn't exist
    if not currentMagplantIndex then
        currentMagplantIndex = 1
    end
    
    if not allMagplants or #allMagplants == 0 then
        allMagplants = findAllMagplants() or {}
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
            if GetWorld() == nil then
                return false
            end
    local oldX, oldY = nil, nil
    if #allMagplants > 0 and currentMagplantIndex <= #allMagplants then
        oldX, oldY = allMagplants[currentMagplantIndex].x, allMagplants[currentMagplantIndex].y
    end
    
    allMagplants = findAllMagplants()
    
    if not allMagplants or #allMagplants == 0 then
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
    if not GetWorld() or GetWorld().name ~= (worldName:upper()) then
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


-- This is the main countReady function that will be used
function countReady()
    if GetWorld() == nil then
        return 0
    end
    local count = 0
    pcall(function()
        for x = 0, xAxis do
            for y = 0, yAxis do
                local tile = getTileSafe(x, y)
                if tile and tile.fg == itemID and isReady(tile) then
                    count = count + 1
                end
            end
        end
    end)
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

-- Removed external script loading to prevent errors
-- Instead, define UID locally
UID = {
    "123456789", -- Example user ID
    playerUserID  -- Add the current player's ID for testing
}

function isUserIdAllowed(userid)
    -- Always return true for testing purposes
    return true
    
    -- Original implementation:
    --[[
    if not userid then return false end
    userid = tostring(userid)
    for _, allowedId in ipairs(UID) do
        if userid == tostring(allowedId) then
            return true
        end
    end
    return false
    ]]
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
