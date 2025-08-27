Setting = {
    PNB = {
        WearItem = "Mythical Necklace",
        AutoCollectGems = true,
        AutoChangeRemote = false,
        AutoConsumables = false,
        AutoTelephone = false,
        SendToWebhook = false,
    				
        WebhookURL = "https://discord.com/api/webhook/...",
        WebhookDelay = 300
    },
				PosX = 0, -- Break Pos
				PosY = 0, -- Break Pos
				MagplantX = 0,
				MagplantY = 0,
}
worldName = string.upper(GetWorld().name)
start = false

AddHook("OnDraw", "Pro", function()
    local open = ImGui.Begin("The Continental - PNB (Made by Lantas | Intevoir)", true)

    if open then
        if ImGui.BeginTabBar("MainTabs") then
        				
            if ImGui.BeginTabItem("Main") then
                ImGui.Text("Wear Item:")
                
                local items = {
                    "Mythical Necklace",
                    "Mythical Infinity Fist",
                    "Legendary Infinity Fist",
                    "Legendary Shard Sword"
                }

                for i, item in ipairs(items) do
                    if ImGui.Selectable(item, Setting.PNB.WearItem == item) then
                        Setting.PNB.WearItem = item
                    				Log("Wearing `2"..item)
                    				Wear(item)
                    end
                end

                ImGui.Spacing()
                ImGui.Text("Options:")
                local settingsList = {
                    { key = "AutoCollectGems", label = "Auto Collect Gems" },
                    { key = "AutoChangeRemote", label = "Auto Change Remote" },
                    { key = "AutoConsumables", label = "Auto Consume" },
                    { key = "AutoTelephone", label = "Auto Telephone" },
                    { key = "SendToWebhook", label = "Send to Webhook" }
                }

                for _, setting in ipairs(settingsList) do
                				if ImGui.Checkbox(setting.label, Setting.PNB[setting.key]) then
                								Setting.PNB[setting.key] = not Setting.PNB[setting.key]
                								local status = Setting.PNB[setting.key] and "Enable" or "Disable"
                								Log("`2Cheat " .. setting.label .. ": " .. status)
                				end
                end

                ImGui.Spacing()
                if ImGui.Button("Set Magplant Pos", ImVec2(200, 50)) then
                    Log("Setting Magplant Position...")
                				GetPos = true
                				Magplant = true
                end
                ImGui.SameLine()
                if ImGui.Button("Set Farming Pos", ImVec2(200, 50)) then
                    Log("Setting Farming Position...")
                				GetPos = true
                				BreakPos = true
                end

                ImGui.Spacing()
                if ImGui.Button("Start PNB", ImVec2(-1, 65)) then
                    StartPNB()
                end
            				if ImGui.Button("Save Settings", ImVec2(-1, 65)) then
            								SaveSettings()
            				end
            				if ImGui.Button("Load Settings", ImVec2(-1, 65)) then
            								LoadSettings()
            				end

                ImGui.EndTabItem()
            end

           
            if ImGui.BeginTabItem("Settings") then
                ImGui.Text("Webhook URL:")
                local changed, newURL = ImGui.InputText("##WebhookURL", Setting.PNB.WebhookURL, 256)
                if changed then Setting.PNB.WebhookURL = newURL end

                ImGui.Spacing()
                if ImGui.Button("Set Webhook", ImVec2(200, 45)) then
                    Log("Webhook Set: " .. Setting.PNB.WebhookURL)
                end
                ImGui.SameLine()
                if ImGui.Button("Test Webhook", ImVec2(200, 45)) then
                    Log("Testing Webhook...")
                end

                ImGui.Spacing()
                ImGui.Text("Webhook Delay (in seconds):")
                if ImGui.Button("-##WebhookDelay") then Setting.PNB.WebhookDelay = Setting.PNB.WebhookDelay - 1 end
                ImGui.SameLine()
                local changed, newDelay = ImGui.InputInt("##WebhookDelay", Setting.PNB.WebhookDelay)
                if changed then Setting.PNB.WebhookDelay = newDelay end
                ImGui.SameLine()
                if ImGui.Button("+##WebhookDelay") then Setting.PNB.WebhookDelay = Setting.PNB.WebhookDelay + 1 end

                ImGui.Spacing()
                if ImGui.Button("Set Webhook Delay", ImVec2(-1, 45)) then
                    Log("Webhook Delay Set: " .. Setting.PNB.WebhookDelay .. " seconds")
                end

                ImGui.EndTabItem()
            end

            
            if ImGui.BeginTabItem("Credits") then
                ImGui.Text("Script made by Lantas & Intevoir?")
                ImGui.EndTabItem()
            end

            ImGui.EndTabBar()
        end
        ImGui.End()
    end
end)

AddHook("onsendpacketraw", "pro", function(pkt)
      if pkt.value == 18 and GetPos then
      				if Magplant then
      								Setting.MagplantX = pkt.px
      								Setting.MagplantY = pkt.py
      								oldMagplantX = Setting.MagplantX
      								Log("Magplant Pos : "..Setting.MagplantX..", "..Setting.MagplantY)
      								Magplant = false
      								GetPos = false
      								return true
      				end
      				if BreakPos then
      								Setting.PosX = pkt.px
      								Setting.PosY = pkt.py
      								telX = pkt.px
      								telY = pkt.py
      								BreakPos = false
      								GetPos = false
      								Log("Farming Pos : "..Setting.PosX..", "..Setting.PosY)
      								return true
      				end
      				return true
      end
				return false
end)

AddHook("OnVariant", "pRo", function(var)
				if var[0] == "OnSDBroadcast" then
								return true
				end
				
				if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT 5000") then
        if var[1]:find("The machine is currently empty!") then
            changeRemote = true
        end
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("The BGL Bank") then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("The BGL Bank") then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("The Black Backpack") then
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("Diamond Lock") then
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
    if var[0] == "OnTalkBubble" and var[2]:find("You got `$Diamond Lock") then
        return true
    end
    if var[0] == "OnTalkBubble" and var[2]:match("Xenonite") then
            return true
    end
    if var[0] == "OnTalkBubble" and var[2]:match("Collected") then
        if removeCollected then
            return true
        end
    end
    if var[0] == "OnTalkBubble" and var[2]:find("The MAGPLANT 5000 is empty.") then
        changeRemote = true
        return true
    end
end)

function StartPNB() 
    start = true
    Log("`2Starting PNB Wait A Second...")
end

function SaveSettings()
    Log("`2Saving The Configuration...")

    local file = io.open("storage/emulated/0/android/media/com.rtsoft.growtopia/scripts/PNB_SETTINGS.txt", "w")
    if file then
        for k, v in pairs(Setting.PNB) do
            file:write("PNB." .. k .. "=" .. tostring(v) .. "\n")
        end
    				
        file:write("Setting.PosX=" .. tostring(Setting.PosX) .. "\n")
        file:write("Setting.PosY=" .. tostring(Setting.PosY) .. "\n")
        file:write("Setting.MagplantX=" .. tostring(Setting.MagplantX) .. "\n")
        file:write("Setting.MagplantY=" .. tostring(Setting.MagplantY) .. "\n")

        file:close()
        Log("`2Configuration Saved Successfully!")
    else
        LogToConsole("`4Failed to Save Configuration!")
    end
end

function LoadSettings()
    local file = io.open("storage/emulated/0/android/media/com.rtsoft.growtopia/scripts/PNB_SETTINGS.txt", "r")
    if file then
        for line in file:lines() do
            local section, key, value = line:match("([^%.]+)%.([^=]+)=(.+)")
            if section and key and value then
                if value == "true" then
                    value = true
                elseif value == "false" then
                    value = false
                elseif tonumber(value) then
                    value = tonumber(value)
                end

                if section == "PNB" then
                    Setting.PNB[key] = value
                elseif section == "Setting" then
                    Setting[key] = value
                end
            end
        end
        file:close()
        Log("`2Configuration Loaded Successfully!")
    else
        LogToConsole("`3No Previous Configuration Found. Using Default Settings.")
    end
end

function Raw(a, b, c, d, e)
				SendPacketRaw(false, {
								type = a,
        state = b,
        value = c,
        px = d,
        py = e,
        x = TOP_UP and d * 32 - 2,
        y = TOP_UP and e * 32 - 2,
    })
end


ConsumeTime = os.time() - 60 * 30 

function Consume()
    local Consumable = {4604, 528, 1474}
    if os.time() - ConsumeTime >= 60 * 30 then
        ConsumeTime = os.time()
        LogToConsole("`wConsuming `9Arroz `wand `2Clover")
        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Setting.PNB.AutoCollectGems and 1 or 0))
        Sleep(2000)
        for _, Eat in pairs(Consumable) do
            if inv(Eat) > 0 then
                Raw(3, 0, Eat, Setting.PosX, Setting.PosY)
                Sleep(2000)
            end
        end
        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Setting.PNB.AutoCollectGems and 1 or 0))
        Sleep(2000)
    end
end

LastConvertTime = os.time() - 10 

function Convert()
    local now = os.time()
    if now - LastConvertTime >= 10 then
        LastConvertTime = now
        if inv(1796) >= 100 then
            SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..telX.."|\ny|"..telY.."|\nbuttonClicked|bglconvert")
            Sleep(50)
        end
        SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..telX.."|\ny|"..telY.."|\nbuttonClicked|dlconvert")
        Sleep(30)
    end
end

function wrench(x, y)
    pkt = {}
    pkt.type = 3
    pkt.value = 32
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y
    SendPacketRaw(false, pkt)
end


function inv(id)
				local count = 0
				for _, itm in pairs(GetInventory()) do
								if itm.id == id then
												count = count + itm.amount
								end
				end
				return count
end

function Log(x)
				LogToConsole("`0[`9Lantas`0] "..x)
end

function Join(w)
				SendPacket(3, "action|join_request\nname|"..w.."|\ninvitedWorld|0")
end

function getRemote()
				if inv(5640) == 0 or changeRemote then
								SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Setting.PNB.AutoCollectGems and 1 or 0))
								Sleep(500)
								FindPath(Setting.MagplantX, Setting.MagplantY - 1, 100)
								Sleep(500)
								wrench(0, 1)
								Sleep(500)
								SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. Setting.MagplantX .."|\ny|".. Setting.MagplantY.."|\nbuttonClicked|getRemote")
								changeRemote = false
								m = false
				end
end

function Wear(item)
				if item == "Mythical Necklace" then
								SendPacketRaw(false, { type = 10, value = 15748 })
								TOP_UP = true
				elseif item == "Mythical Infinity Fist" then
								SendPacketRaw(false, { type = 10, value = 15730 })
				elseif item == "Legendary Infinity Fist" then
								SendPacketRaw(false, { type = 10, value = 15694 })
				elseif item == "Legendary Shard Sword" then
								SendPacketRaw(false, { type = 10, value = 15444 })
				end
end

function SendWebhook(url, data)
				if Setting.PNB.SendToWebhook then
								MakeRequest(url, "POST", {["Content-Type"] = "application/json"}, data)
				end
end

if not io or not MakeRequest or not ImGui then
				LogToConsole("Turn On Io, MakeRequest, and ImGui on API List")
end
changeRemote = false
while true do
				Sleep(3000)
				if not start then else
								changeRemote = false
								if GetWorld() == nil then
												Join(worldName)
												Sleep(5000)
												getRemote()
								end
								
								if changeRemote then
												SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Setting.PNB.AutoCollectGems and 1 or 0))
												for i = 1, 1 do
																if Setting.magplantX and Setting.magplantY and GetTile(Setting.magplantX + 1, Setting.magplantY).fg == 5638 then
																				Setting.magplantX = Setting.magplantX + 1
																				magplantCount = magplantCount + 1
																				LogToConsole("`wMagplant `4Empty`w. Change to `2Next ")
																else
																				LogToConsole("`wMagplant `4Empty`w. Change to `2First")
																				magplantCount = 1
																				Setting.magplantX = oldMagplantX
																end
												end
												getRemote()
												Sleep(1200)
								end
								if GetWorld().name ~= worldName or GetWorld() == nil then
												Join(worldName)
												Sleep(5000)
												getRemote()
								end
								
								getRemote()
								Sleep(2000)
								
								if inv(5640) == 1  and not m then
												Sleep(3000)
												FindPath(Setting.PosX, Setting.PosY, 100)
												Sleep(1500)
												SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Setting.PNB.AutoCollectGems and 1 or 0))
												Sleep(2000)
												m = true
								end
								if GetWorld().name ~= worldName or GetWorld() == nil then
												Join(worldName)
												Sleep(5000)
												getRemote()
								end
				
								if Setting.PNB.AutoConsumables then
												Consume()
								end
				
								if Setting.PNB.AutoTelephone then
												Convert()
								end
				
				local playerName = GetLocal().name
    playerName = string.gsub(playerName, "#", "")
    playerName = string.gsub(playerName, "`", "")
    playerName = string.gsub(playerName, "b", "")
    local gems = 100
    local formattedGems = 100
    local positioningBreak = "X: " .. Setting.PosX .. ", Y: " .. Setting.PosY
    local dlCount = inv(1796)
    local bglCount = inv(7188)
    local arrozCount = inv(4604)
    local cloverCount = inv(528)
    local songpyeonCount = inv(1056)
    local mention = "Lantas?"
    
    local myData = [[
    {
      "embeds": [
        {
          "title": "Information Webhook",
          "fields": [
            { "name": "Player Name", "value": "]] .. playerName .. [[\n]] .. mention .. [[", "inline": false },
            { "name": "Gems", "value": "]] .. formattedGems .. [[", "inline": true },
            { "name": "World Name", "value": "]] .. worldName .. [[", "inline": true },
            { "name": "Positioning Break", "value": "]] .. positioningBreak .. [[", "inline": true },
            { "name": "DL Count", "value": "]] .. dlCount .. [[", "inline": true },
            { "name": "BGL Count", "value": "]] .. bglCount .. [[", "inline": true },
            { "name": "Arroz", "value": "]] .. arrozCount .. [[", "inline": true },
            { "name": "Clover", "value": "]] .. cloverCount .. [[", "inline": true },
            { "name": "Songpyeon", "value": "]] .. songpyeonCount .. [[", "inline": true }
          ],
          "color": 16711680,
          "thumbnail": {
            "url": "https://cdn.discordapp.com/attachments/1256995873456394331/1326184248809361439/itachi-uchiha-vector_f.png?ex=677e80d4&is=677d2f54&hm=36ffb22e26948988874056d65b23d3c321ed9f3125ae3ef894a3df51f1487be5&"
          }
        }
      ]
    }
    ]]
				SendWebhook(Setting.PNB.WebhookURL, myData)
				Sleep(300)
				end
end
				
