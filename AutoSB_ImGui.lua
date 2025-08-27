Settings = {
    SBText = "AwZka Ganteng",
				WebhookURL = "https://discord.com/api/webhooks/1360477988986028082/S2oRmKiZG_0BlOm0jiTe9n1bbochizWh1_xl-IKbZDoQEiDhC_fS6_4K0z8ekYZE4Z-3",
				UseWebhook = false,
				RandEmoji = false,
   	RandColor = false,
				BlockSDB = false,
				BoostMode = false,
    SBTime = 0
}

AddHook("OnDraw", "A", function()
    local open = ImGui.Begin("Cheat SB (Made by AwZka | @azkassasin)", true)

    if open then
        if ImGui.BeginTabBar("MainTabs") then
        				
            if ImGui.BeginTabItem("Main") then
                ImGui.Text("The Continental - SB")  
                ImGui.Spacing()

                ImGui.Text("Status:")
                ImGui.BulletText("SB Text: " .. (Settings.SBText or "Not Set"))
                ImGui.BulletText("Boost Mode: " .. (Settings.BoostMode and "Enabled" or "Disabled"))
                ImGui.BulletText("Webhook: " .. (Settings.WebhookURL and "Set" or "Not Set"))
                ImGui.BulletText("Auto-SB Delay: " .. (Settings.SBTime or "Not Set") .. " Hour(s)")

                ImGui.Spacing()
                ImGui.Text("Features:")
                local features = {
                    "Auto Detect Queue Time",
                    "Perfect Super Broadcast",
                    "Auto Reconnect (Can Run 24/7)",
                    "Webhook Support",
                    "Easy Setup",
                    "Using Time Format",
                    "Optional Block SDB"
                }
                for _, feature in ipairs(features) do
                    ImGui.BulletText(feature)
                end

                ImGui.EndTabItem()
            end
        				
            if ImGui.BeginTabItem("Settings") then
                ImGui.Text("Text Settings:")
                ImGui.Text("Copy Sign within 5-block radius:")
                if ImGui.Button("Copy Sign", ImVec2(200, 45)) then
                    Log("Copying sign text within radius 5...")
                    CopySignText()
                end
                ImGui.SameLine()
                if ImGui.Button("Copy Sign (Wrench)", ImVec2(200, 45)) then
                    WrenchMode = true
                    Log("Copy sign using wrench enabled")
                end
                
                ImGui.Spacing()
                ImGui.Text("Custom SB Text (Optional):")
                local changed, newSBText = ImGui.InputText("##SBText", Settings.SBText or "", 256)
                if changed then Settings.SBText = newSBText end
                
                ImGui.Spacing()
                ImGui.Text("Webhook:")

                local changed, newURL = ImGui.InputText("##WebhookURL", Settings.WebhookURL or "", 256)
                if changed then Settings.WebhookURL = newURL end

                if ImGui.Button("Set Webhook", ImVec2(200, 45)) then
                    Log("Webhook Set: " .. Settings.WebhookURL)
                end
                ImGui.SameLine()
                if ImGui.Button("Test Webhook", ImVec2(200, 45)) then
                    Log("Testing Webhook...")
                end

                ImGui.Spacing()
                ImGui.Text("Auto-SB Settings:")
            				
                local autoSBSettings = {
                    { key = "RandEmoji", label = "Random Emoji" },
                    { key = "RandColor", label = "Random Color" },
                    { key = "BlockSDB", label = "Block SDB" },
                    { key = "UseWebhook", label = "Use Webhook" },
                    { key = "BoostMode", label = "Boost Mode" } 
                }
                
                for _, setting in ipairs(autoSBSettings) do
                    if ImGui.Checkbox(setting.label, Settings[setting.key] or false) then
                        Settings[setting.key] = not Settings[setting.key]
                        local status = Settings[setting.key] and "Enabled" or "Disabled"
                        Log("`2" .. setting.label .. ": " .. status)
                    end
                end
                
                ImGui.Spacing()
                ImGui.Text("Super-Broadcast Text: " .. (Settings.SBText or "Not Set"))
                ImGui.Spacing()

                ImGui.Text("Hour(s) To SuperBroadcast:")
                local changed, newDelay = ImGui.InputInt("##SBTime", Settings.SBTime or 1)
                if changed then Settings.SBTime = newDelay timestop = newDelay * 60 end
                
                ImGui.Spacing()
                if ImGui.Button("Start Super-Broadcast", ImVec2(-1, 50)) then
                    RunThread(function() StartSB() end)
                end
                
                ImGui.EndTabItem()
            end
        				
            if ImGui.BeginTabItem("Credits") then
                ImGui.Text("Script made by AwZka")
                ImGui.EndTabItem()
            end

            ImGui.EndTabBar()
        end
        ImGui.End()
    end
end)

AddHook("OnVariant", "B", function(variant)
				if variant[0] == "OnSDBroadcast" and Settings.BlockSDB then
								return true
				end
				if variant[0] == "OnDialogRequest" and variant[1]:find("Sign") and variant[1]:find("display_text") and WrenchMode then
								local text = variant[1]:match("display_text||(.+)|128|")
								if text then
												Settings.SBText = text
												LogToConsole("Text: "..Settings.SBText)
												WrenchMode = false
												return true
								end
								return true
				end
				if variant[0] == "OnConsoleMessage" and variant[1]:find("**from (.+)") and not Settings.BoostMode then
								Nick = string.match(variant[1], "%((.-)%)")
								if Nick ~= nil then
												nick = Nick:gsub("[%d+`]", ""):gsub("#", ""):gsub("@", "")
												local localNick = cleanNickname(nickN)
												if nick == localNick then
																LogToConsole("`2Your SBs:")  
																RunThread(function() SendSB() end)
												end
								end
				end
				if variant[0] == "OnConsoleMessage" and variant[1]:find("You can annoy with broadcasts again") and Settings.BoostMode then
								HasBoost = true
								RunThread(function() SendSB() end)
			end
				if variant[0] == "OnConsoleMessage" and variant[1]:find("Broadcast-Queque is full or you already have a pending one.") then
								Log("Your Super-Broadcast got blocked, trying to send another one...")
								RunThread(function() Sleep(5000) SendSB() end )
								return true
				end
				if variant[0] == "OnConsoleMessage" and variant[1]:find("Where would you like to go") then
								RunThread(function()
												Join(worldName)
												Log("Disconnected trying to reconnect")
												Sleep(5000)
								end)
								return true
				end
				return false
end)

worldName = GetWorld().name
nickN = GetLocal().name
TotalSb = 0
HasBoost = Settings.BoostMode
SignIDs = {
    20, 24, 26, 28, 226, 608, 780, 986, 1426, 1428,  
    1430, 1432, 1446, 1906, 2396, 2414, 2586, 2948, 3690, 3758,  
    4470, 4488, 4538, 5622, 6102, 6272, 7456, 9406, 11186, 11234,  
    11408, 11412, 11426, 11444, 12204, 12900, 13364, 13676, 13678, 13802,  
    13974, 14434, 14436, 14686, 14998, 15516, 15590, 15754, 15758  
}

Colors = {
				"`2", "`9","`6","`9","`5","`e","`c","`^","`o","`$"
}
Emotes = {
  "(wl)","(yes)","(no)","(love)","(oops)","(shy)","(wink)","(tongue)","(agree)","(sleep)","(punch)","(music)","(build)","(megaphone)","(sigh)","(mad)","(wow)","(dance)","(see-no-evil)","(bheart)","(heart)","(grow)","(gems)","(kiss)","(gtoken)","(lol)","(smile)","(cool)","(cry)","(vend)","(bunny)","(cactus)","(pine)","(peace)","(terror)","(troll)","(evil)","(fireworks)","(football)","(alien)","(party)","(pizza)","(clap)","(song)","(ghost)","(nuke)","(halo)","(turkey)","(gift)","(cake)","(heartarrow)","(lucky)","(shamrock)","(grin)","(ill)","(eyes)","(weary)","(moyai)","(plead)"
}

function convertTime(unixTime)
    return os.date("%H.%M", unixTime)
end

function shuffleTable(tbl)
    for i = #tbl, 2, -1 do
        local j = math.random(i)
        tbl[i], tbl[j] = tbl[j], tbl[i] 
    end
end

function cleanNickname(nickname)
    nickname = nickname:gsub("[%d+`#@]", "")
    nickname = nickname:gsub("%[.-%]", "")
    nickname = nickname:match("^%s*(.-)%s*$")  
    return nickname
end

function RunThread(task)
  co = coroutine.create(task)
  local status, result = coroutine.resume(co)
  if not status then
    LogToConsole("Error running thread: " .. tostring(result))
  end
end

function checkTimeLocal(seconds)
    local hours = math.floor(seconds / 3600)
    local remainingSeconds = seconds % 3600
    local minutes = math.floor(remainingSeconds / 60)
    remainingSeconds = remainingSeconds % 60
    local result = ""

    if hours > 0 then 
        result = hours .. " Hours" 
    end
    if minutes > 0 then 
        result = result .. (result == "" and "" or " ") .. minutes .. " Min" 
    end
    if remainingSeconds > 0 then 
        result = result .. (result == "" and "" or " ") .. remainingSeconds .. " Sec" 
    end
    return result
end

function checkCurrentTime(l, a)
    local elapsedSeconds = os.time() - l
    return checkTimeLocal(elapsedSeconds) .. "/" .. checkTimeLocal(a * 60)
end


function Log(x)
				LogToConsole("`0[`cAwZka`0] "..x)
end

function Join(w)
				SendPacket(3, "action|join_request\nname|"..w.."|\ninvitedWorld|0")
end

function isSignID(id)
				for _, sign in ipairs(SignIDs) do
        if sign == id then
            return true
        end
    end
    return false
end

function CopySignText()
    local posX = GetLocal().pos.x // 32 
    local posY = GetLocal().pos.y // 32
    for x = posX - 5, posX + 5 do
        for y = posY - 5, posY + 5 do
            local tile = GetTile(x, y)
            if isSignID(tile.fg) then
                local text = tile.extra.label
                Log("Text: `2"..text)
                Settings.SBText = text
            end
        end
    end
end

function StartSB()
    startTimeSB = os.time()
    finishTime = (Settings.SBTime * 3600) + startTimeSB
    endTime = getEndTime(Settings.SBTime)
				Stop = false
    Started = true
    Log("`2Auto SB Started! Start Time: " .. os.date("%H:%M:%S", startTimeSB))
    SendSB()
end

function getEndTime(hours)
    local endTime = os.time() + (hours * 3600) 
    return os.date("%H:%M:%S", endTime) 
end

function checkTime()
    if not Started then return end 

    local elapsedSeconds = os.time() - startTimeSB 
    TotalHour = math.floor(elapsedSeconds / 3600)
				

    if TotalHour >= (Settings.SBTime or 0) then  
        Stop = true
    				Started = true
        RemoveHook("B") 
        LogToConsole("`4Auto SB berhenti setelah " .. TotalHour .. " jam.")
    end
end

function SendSB()
    checkTime()
    if not Stop and not HasBoost then
        Sleep(1000)
        SendPacket(2, "action|input\n|text|/sb " .. Settings.SBText)
        TotalSb = TotalSb + 1
    				Sleep(2500)
    				SendPacket(2, "action|input\n|text|`7Sended (megaphone),[Total:" .. TotalSb .. "],[" .. checkCurrentTime(startTimeSB, timestop) .. "][END : ".. endTime .."]")
    elseif not Stop and HasBoost then
    				Sleep(1000)
    				SendPacket(2, "action|input\n|text|/sb " .. Settings.SBText)
    				TotalSb = TotalSb + 1
    				Sleep(2500)
    				SendPacket(2, "action|input\n|text|`7Sended (megaphone),[Total:" .. TotalSb .. "],[" .. checkCurrentTime(startTimeSB, timestop) .. "][END : ".. endTime.."]")
    else
    				Sleep(1000)
    				SendPacket(2, "action|input\n|text|Auto SB berhenti setelah " .. endTime .. " jam.")
    				Started = false 
    				RemoveHook("B")
    end
end
