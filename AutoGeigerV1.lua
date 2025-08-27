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

function log(k)
   SendVariantList{[0] = "OnTextOverlay", [1] = k}
    LogToConsole(k)
    SendPacket(2, "action|input\n|text|"..k)
end

iGeiger = {
    crystalRed = 2242,
    crystalwhite = 2248,
    crystalblack = 2250,
    dbat = 3306,
    hchem = 1962,
    rchem = 2206,
    crystalgreen = 2244
}

iTrash = {
    purple = 1498,
    orange = 1500,
    green = 2804,
    blue = 2806,
    black = 8274,
    white = 8272,
    cblue = 2246,
    gtoken = 0,
    bat = 15250
}



redPosX = {25, 5, 5, 25, 15, 14}
redPosY = {5, 25, 5, 25, 25, 3}

listFound = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0} -- Stuff, Black, Green, Red, White, Hchem, Rchem, Growtoken, Battery, D Battery

red     = 0
yellow  = 1
green   = 2

currentRing = red
newRing     = false
itemFound   = false

breakLoop = false

function clamp(val, minVal, maxVal)
    return math.max(minVal, math.min(val, maxVal))
end

function renewRing()
    while newRing == false do
        Sleep(100)
    end
    newRing = false
end

function foundYellow()
    local foundPosX = GetLocal().pos.x // 32
    local foundPosY = GetLocal().pos.y // 32
    local currentLoc = 2
    local isLeft = false
    local isUp = false

    while true do
        if breakLoop == true then
            if GetLocal().pos.y // 32 <= 15 then
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 15, 0, 29))
            else
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -15, 0, 29))
            end
            breakLoop = false
            return
        end
        if itemFound == true then return end
        FindPath(clamp(foundPosX + currentLoc, 0, 29), foundPosY)
        isLeft = false
        renewRing()
        if currentRing ~= yellow then break end
        FindPath(clamp(foundPosX + -currentLoc, 0, 29), foundPosY)
        isLeft = true
        renewRing()
        if currentRing ~= yellow then break end
        currentLoc = currentLoc + 2
    end
-- X Yellow -> Red
    if currentRing == red then
        if isLeft == false then
            FindPath(clamp(GetLocal().pos.x // 32 + -12, 0, 29), foundPosY)
            renewRing()
            if currentRing ~= green then
                if GetLocal().pos.y // 32 >= 20 then
                    FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -8, 0, 29))
                else
                    FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 8, 0, 29))
                end
                return
            end
        else
            FindPath(clamp(GetLocal().pos.x // 32 + 12, 0, 29), foundPosY)
            renewRing()
            if currentRing ~= green then
                if GetLocal().pos.y // 32 >= 20 then
                    FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -8, 0, 29))
                else
                    FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 8, 0, 29))
                end
                return
            end
        end
        Sleep(10000)
-- X Yellow -> Green
    elseif currentRing == green then
        if isLeft == false then
            FindPath(clamp(GetLocal().pos.x // 32 + 4, 0, 29), foundPosY)
        else
            FindPath(clamp(GetLocal().pos.x // 32 + -4, 0, 29), foundPosY)
        end
        Sleep(10000)
    end
-- Reset For Y Axis
    foundPosX = GetLocal().pos.x // 32
    foundPosY = GetLocal().pos.y // 32
    currentLoc = 1

    while true do
        if breakLoop == true then
            if GetLocal().pos.y // 32 <= 15 then
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 15, 0, 29))
            else
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -15, 0, 29))
            end
            breakLoop = false
            return
        end
        if itemFound == true then return end
        FindPath(foundPosX, clamp(foundPosY + currentLoc, 0, 29))
        isUp = false
        renewRing()
        if currentRing ~= green then break end
        FindPath(foundPosX, clamp(foundPosY + -currentLoc, 0, 29))
        isUp = true
        renewRing()
        if currentRing ~= green then break end
        currentLoc = currentLoc + 1
    end
-- Y Green -> Yellow
    if currentRing == yellow then
        if isUp == false then
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + -5, 0, 29))
        else
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + 5, 0, 29))
        end
        Sleep(10000)
    end
end

function foundGreen()
    local foundPosX = GetLocal().pos.x // 32
    local foundPosY = GetLocal().pos.y // 32
    local currentLocX = 1
    local isLeft = false
    local isUp = false

    while true do
        if breakLoop == true then
            if GetLocal().pos.y // 32 <= 15 then
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 15, 0, 29))
            else
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -15, 0, 29))
            end
            breakLoop = false
            return
        end
        if itemFound == true then return end
        FindPath(clamp(foundPosX + currentLocX, 0, 29), foundPosY)
        isLeft = false
        renewRing()
        if currentRing ~= green then break end
        FindPath(clamp(foundPosX + -currentLocX, 0, 29), foundPosY)
        isLeft = true
        renewRing()
        if currentRing ~= green then break end
        currentLocX = currentLocX + 1
    end
-- X Green -> Yellow
    if currentRing == yellow then
        if isLeft == false then
            FindPath(clamp(GetLocal().pos.x // 32 + -5, 0, 29), foundPosY)
        else
            FindPath(clamp(GetLocal().pos.x // 32 + 5, 0, 29), foundPosY)
        end
        Sleep(10000)
    end
-- Reset For Y Axis
    foundPosX = GetLocal().pos.x // 32
    foundPosY = GetLocal().pos.y // 32
    local currentLocY = 1

    while true do
        if breakLoop == true then
            if GetLocal().pos.y // 32 <= 15 then
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 15, 0, 29))
            else
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -15, 0, 29))
            end
            breakLoop = false
            return
        end
        if itemFound == true then return end
        FindPath(foundPosX, clamp(foundPosY + currentLocY, 0, 29))
        isUp = false
        renewRing()
        if currentRing ~= green then break end
        FindPath(foundPosX, clamp(foundPosY + -currentLocY, 0, 29))
        isUp = true
        renewRing()
        if currentRing ~= green then break end
        currentLocY = currentLocY + 1
    end
-- Y Green -> Yellow
    if currentRing == yellow then
        if isUp == false then
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + -5, 0, 29))
        else
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + 5, 0, 29))
        end
        Sleep(10000)
    end
end

function mO(w)
    for _, I in pairs(GetInventory()) do
        if I.id == w then
            return I.amount
        end
    end
    return 0
end

function trs(ID)
    SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|"..ID.. "|\nitem_count|".. mO(w).."\n")
	Sleep(1000)
end

AddHook("onprocesstankupdatepacket", "debug", function(packet)
    if packet.type == 17 then
        if packet.xspeed == 2.00 then
            LogToConsole("`0[`cAwZka`0] `5Signal is `0~ `2GREEN")
            currentRing = green
            newRing = true
        elseif packet.xspeed == 1.00 then
            LogToConsole("`0[`cAwZka`0] `5Signal is `0~ `9YELLOW")
            currentRing = yellow
            newRing = true
        else
            LogToConsole("`0[`cAwZka`0] `5Signal is `0~ `4RED")
            currentRing = red
            newRing = true
        end
    end
end)


while true do
wbsent = false
    for i in pairs(redPosX) do
        if itemFound == true then 
            currentRing = red 
            break
        end
        if currentRing ~= red then break end
        FindPath(redPosX[i], redPosY[i])
        renewRing()
    end
    if currentRing == yellow then
        foundYellow()
    elseif currentRing == green then
        foundGreen()
    end
    itemFound = false

for name, id in pairs(iGeiger) do
        if mO(id) > 0 and not wbsent then
         wbsent = true
            so()         
            break
        end
    end

    for S, itemId in pairs(iTrash) do
        if mO(itemId) >= 15 then
            trs(itemId)
          Sleep(500)
        end
    end
end
