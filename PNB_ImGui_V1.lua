-- [[ Don't delete this ]] --
sigW = "AwZka Here"
start = false

-- [[ true if want Cv DL BGL ]] --
CVon = true

Setting = {
    PNB = {
        Eats = false,
        ItemBlockId = 15460, --block Pog
        bcg = 12840, -- background
        AutoSuck = false, -- suck bgems
        BgemsSuck = 500, --Amount  Bgems Want to suck / berapa bgems yang mau disuck
        AutoCollect = true, -- collect gems
        Facing = "right", -- left or right facing break
    },
}

-- [[ Don't touch Here :) ]] --

AddHook("OnDraw", "SettingsMenu", function()
    local open = ImGui.Begin("Hi Anjg!", true)

    if open then
        local settingsList = {
            Eats = "Auto Consume",
            AutoSuck = "Auto Suck Bgems",
            AutoCollect = "Auto Collect Gems"
        }

        for key, label in pairs(settingsList) do
            if ImGui.Checkbox(label, Setting.PNB[key]) then
                Setting.PNB[key] = not Setting.PNB[key]
            end
        end
    				
        ImGui.Text("Break ID:")
        if ImGui.Button("-##ItemBlockId") then Setting.PNB.ItemBlockId = Setting.PNB.ItemBlockId - 1 end
        ImGui.SameLine()
        local changed, newItemBlockId = ImGui.InputInt("##ItemBlockId", Setting.PNB.ItemBlockId)
        if changed then Setting.PNB.ItemBlockId = newItemBlockId end
        ImGui.SameLine()
        if ImGui.Button("+##ItemBlockId") then Setting.PNB.ItemBlockId = Setting.PNB.ItemBlockId + 1 end
    				
        ImGui.Text("Magplant Background ID:")
        if ImGui.Button("-##BackgroundID") then Setting.PNB.bcg = Setting.PNB.bcg - 1 end
        ImGui.SameLine()
        local changed, newBackgroundID = ImGui.InputInt("##BackgroundID", Setting.PNB.bcg)
        if changed then Setting.PNB.bcg = newBackgroundID end
        ImGui.SameLine()
        if ImGui.Button("+##BackgroundID") then Setting.PNB.bcg = Setting.PNB.bcg + 1 end
    				
        ImGui.Text("Minimal Bgems Before Sucking:")
        if ImGui.Button("-##BgemsSuck") then Setting.PNB.BgemsSuck = Setting.PNB.BgemsSuck - 1 end
        ImGui.SameLine()
        local changed, newBgemsSuck = ImGui.InputInt("##BgemsSuck", Setting.PNB.BgemsSuck)
        if changed then Setting.PNB.BgemsSuck = newBgemsSuck end
        ImGui.SameLine()
        if ImGui.Button("+##BgemsSuck") then Setting.PNB.BgemsSuck = Setting.PNB.BgemsSuck + 1 end
    				
        ImGui.Text("Facing:")
        ImGui.SameLine()
        if ImGui.Button("Left") then Setting.PNB.Facing = "left" end
        ImGui.SameLine()
        if ImGui.Button("Right") then Setting.PNB.Facing = "right" end
    				
        ImGui.Spacing()
        if ImGui.Button("Save Settings", ImVec2(-1, 0)) then Save() end
        ImGui.Spacing()
        if ImGui.Button("Start PNB", ImVec2(-1, 0)) then StartPNB() end

        ImGui.End()
    end
end)

function StartPNB() 
				start = not start
				Messages("`2Starting PNB Wait A Second...")
end

function Save()
				Messages("Settings Is Saved")
end

function formatGems(gems)
    local reversed = tostring(gems):reverse()
    local formatted = ""
    for i = 1, #reversed do
        formatted = formatted .. reversed:sub(i, i)
        if i % 3 == 0 and i ~= #reversed then
            formatted = formatted .. ","
        end
    end
    return formatted:reverse()
end

local startTime = os.time()

function GetUpTime()
    local currentTime = os.time()
    local elapsed = currentTime - startTime
    local hours = math.floor(elapsed / 3600)
    local minutes = math.floor((elapsed % 3600) / 60)
    local seconds = elapsed % 60
    return string.format("%02d:%02d:%02d", hours, minutes, seconds)
end

SendPacket(2, "action|input\n|text|`4[`9AwZka`4] `0PNB Actived")
Sleep(2000)

Position1, Position2 = GetLocal().pos.x // 32, GetLocal().pos.y // 32

Julian = false 
local emptyTileCount = 0
local RemoteTaken = false 
local isConverting = false  
st = GetWorld().name
gemsLastCheck = 0

function Messages(x)
    SendVariantList{[0] = "OnTextOverlay", [1] = x}
    LogToConsole(x)
end

function Inventor(IM)
    for _, I in pairs(GetInventory()) do
        if I.id == IM then
            return I.amount
        end
    end
    return 0
end

function Cheat(S)
    local autoCollectValue = Setting.PNB.AutoCollect and 1 or 0
    local autoAntilag = Setting.PNB.Lonely and 1 or 0
    SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|" .. S .. "\ncheck_bfg|" .. S .. "\ncheck_gems|" .. autoCollectValue .. "\ncheck_ignoref|" .. autoAntilag)
    Julian = S ~= 0
    Sleep(500)
end

function GetMagplants()
    local Found = {}
    local count = 0
    for x = 0, 199 do
        for y = 0, 199 do
            local tile = GetTile(x, y)
            if tile and type(tile) == "table" and tile.fg == 5638 and tile.bg == Setting.PNB.bcg then
                count = count + 1
                table.insert(Found, {x, y})
            end
        end
    end
    return Found
end

function Sukma()
    local totalAmount = 0
    local objectList = GetObjectList()
    if objectList then 
        for _, obj in pairs(objectList) do
            if obj and obj.id == 15368 then 
                local itemAmount = obj.amount or 1
                totalAmount = totalAmount + itemAmount
            end
        end  
        if  Setting.PNB.AutoSuck and Setting.PNB.BgemsSuck and totalAmount >= Setting.PNB.BgemsSuck then
            Messages("`b[`4AwZka`b] `cSucking " .. totalAmount .. " Bgems...")
            SendPacket(2, "action|dialog_return\ndialog_name|popup\nbuttonClicked|bgem_suckall")
            Sleep(1000)
        end
        Sleep(2000)
    end
end

function Raw(a, b, c, d, e)
    SendPacketRaw(false, {
        type = a,
        state = b,
        value = c,
        px = d,
        py = e,
        x = d * 32,
        y = e * 32,
    })
end

function PlaceBlock(x, y, id)
    SendPacketRaw(false, { type = 3, x = x * 32, y = y * 32, px = x, py = y, value = id })
end

local consumeInterval = 30 * 60 + 2
local nextConsumeTime = os.time() + consumeInterval

function consu()
    local px, py = GetLocal().pos.x // 32, GetLocal().pos.y // 32
    local Consumable = { 4604, 1056, 528 } 
    for _, ITERATOR in pairs(Consumable) do
        if Inventor(ITERATOR) > 0 then
            PlaceBlock(px, py, ITERATOR)
            Messages("`4[`cAwZka`4] `4Consume `0" .. ITERATOR)
            LogToConsole("`0[`8LOG`0] `9ARROZ, CLOVER Eat")
            Sleep(2000)
        end
    end
end


CURRENT_MAG = 1
function Take_Remote()
    local Magplant = GetMagplants()
    if Magplant and #Magplant > 0 then
        local currentMag = Magplant[CURRENT_MAG]
        
        Raw(0, 32, 0, currentMag[1], currentMag[2])
        Sleep(800) 
        Raw(3, 0, 32, currentMag[1], currentMag[2])
        Sleep(800)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. currentMag[1] .. "|\ny|" .. currentMag[2] .. "|\nbuttonClicked|getRemote")
        Sleep(800)
        
        Raw(0, Setting.PNB.Facing:upper() == "RIGHT" and 32 or 48, 0, Position1, Position2)
        Sleep(800)
        
        currentPos = GetLocal()
        if currentPos.pos.x // 32 ~= Position1 or currentPos.pos.y // 32 ~= Position2 then
            Raw(0, Setting.PNB.Facing:upper() == "RIGHT" and 32 or 48, 0, Position1, Position2)
            Sleep(800)
        end
        
        Cheat(1)
        Sleep(800)
        RemoteTaken = true
        RemoteEmpty = false
        Messages("`b[`4AwZka`b] `cSuccessfully took remote and back Position")
    else
        RemoteEmpty = true
        Messages("`b[`4AwZka`b] `4No Magplants found!")
    end
end

function Back_World()
    Sukma()
    if sigW ~= "AwZka Here" then
        Messages("`2You are an Idiot")
        return
    end
    
    if GetWorld() == nil or GetWorld().name ~= st then
        Messages("`0Warping Back To: `2" .. st)
        SendPacket(3, "action|join_request\nname|"..st.."|\ninvitedWorld|0")
        Sleep(5000)
        Julian = false
        RemoteEmpty = true
        RemoteTaken = false
        Take_Remote()
        emptyTileCount = 0
        Sleep(2000)
    else
        if RemoteEmpty then
            Take_Remote()
        else
            local px, py = Position1, Position2
            local gt = GetTile(px + (Setting.PNB.Facing == "right" and 1 or -1), py)
            local gf = type(gt) == "table" and gt.fg
            
            if (gf ~= Setting.PNB.ItemBlockId) then
                emptyTileCount = emptyTileCount + 1
            else
                emptyTileCount = 0
            end
            
            if emptyTileCount > 50 then     
                Cheat(0)
                Messages("`4[`cAwZka`4]`0Magplant is `4Empty")   
                CURRENT_MAG = CURRENT_MAG + 1
                if CURRENT_MAG > #GetMagplants() then
                    CURRENT_MAG = 1
                end
                Take_Remote()
                emptyTileCount = 0
            end
        end
    end
end

RemoteEmpty = true
repeat
				Sleep(3000)
				if start then
								Back_World()
								Sleep(300)
				end
until false
