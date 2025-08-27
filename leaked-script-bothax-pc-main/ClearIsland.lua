--[[ Delay Breaking & Delay Taking Water ]]--
SpeedBreak = 70
SpeedWater = 200

local DiscorduserID = "1094219942309666860"
    local Sendme = "1094219942309666860"

SendPacket(2,"action|input\n|text|/ghost")
Sleep(1000)
ChangeValue("[C] Modfly", true)

-- DO NOT TOUCH ANY PART BELOW --
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

for y2 = 193, 0, -10 do
    y1 = y2 - 9
    for x = 0, 199 do
        for y = y1, y2 do
            if y >= 0 and y <= 193 then 
                local tile = GetTile(x, y)
                if tile and (tile.fg ~= 0 or tile.bg ~= 0) and tile.fg ~= 6 and tile.fg ~= 8 and tile.fg ~= 242 and tile.fg ~= 5638 and tile.fg ~= 1796 and tile.fg ~= 5260 and tile.fg ~= 11550 and tile.fg ~= 4992 and tile.fg ~= 7188 then
                    SendPacketRaw(false, {state = 32, x = x * 32, y = y * 32})
                    Sleep(1)
                    while true do
                        local updatedTile = GetTile(x, y)
                        if not updatedTile or (updatedTile.fg == 0 and updatedTile.bg == 0) then
                            break
                        end
                        SendPacketRaw(false, {type = 3, value = 18, px = x, py = y, x = x * 32, y = y * 32})
                        Sleep(SpeedBreak)
                    end
                end
            end
        end
    end
end

LogToConsole("`9Blocks has been Cleared")
LogToConsole("`6Continue to `4Removing `6Floating `cWater")

--[[ Water Clearing Function (Runs 2x just incase if it missed some spot) ]]--
local function clearWater()
    local waterCount = 0
    for x = 0, 199, 1 do
        for y = 199, 0, -1 do
            local tile = GetTile(x, y)
            if tile.flags.water == true then
                SendPacketRaw(false, {state = 32, x = x * 32, y = y * 32})
                Sleep(1)
                while GetTile(x, y).flags.water ~= false do
                    SendPacketRaw(false, {type = 3, value = 822, px = x, py = y, x = x * 32, y = y * 32})
                    Sleep(SpeedWater)
                    waterCount = waterCount + 1
                end
            end
        end
    end
    return waterCount
end

local WaterCollected = clearWater()
SendPacket(2, "action|input\n|text|`cWater `9Cleared in `8first `5run Total [`2" .. WaterCollected .. "`w]")
Sleep(1000)

local WaterCollectedSecondRun = clearWater()
SendPacket(2, "action|input\n|text|`cWater `9Cleared in `6second `5run Total [`2" .. WaterCollectedSecondRun .. "`w]")
Sleep(1000)

LogToConsole("`w[ `2FINISHED! `w] `8Island World `2Cleared `0!")
ChangeValue("[C] Modfly", false)

function WeeBhooks()
    local requestBody = [[
    {
        "content": "<@]]..DiscorduserID..[[> YOUR ISLAND WORLD HAS BEEN CLEARED",
        "embeds": [
            {
                "title": "Island World Notification",
                "description": "``World:`` **]]..GetWorld().name..[[**",
                "color": 8421504
            }
        ],
        "username": "Island World Bot",
        "avatar_url": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747527775092736/Apr_8_2025_03_02_12_PM.png?ex=67fb3e11&is=67f9ec91&hm=d947b436954547f3fcc192f83cbaacc310afda9fa4f56b30f389743d08f65b99&"
    }
    ]]
    
    local headers = {["Content-Type"] = "application/json"}
    local response = MakeRequest(Sendme, "POST", headers, requestBody)

    if response then
        LogToConsole("Webhook sent successfully!")
    else
        LogToConsole("Webhook failed to send.")
    end
end

WeeBhooks()
