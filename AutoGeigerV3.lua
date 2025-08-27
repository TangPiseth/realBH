worldGeiger = "GEIGERA"
worldSave   = "AWZKASDADA"

aliveGeigerPos  = {34, 24} -- {x, y}
deadDropLeft = {36, 24} -- {x, y}
itemDropLeft = {38, 24} -- {x, y}

redPosX = {25, 5, 5, 25, 15, 14}
redPosY = {5, 25, 5, 25, 25, 3}

listFound = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0} -- Stuff, Black, Green, Red, White, Hchem, Rchem, Growtoken, Battery, D Battery, Charger
log = LogToConsole
red     = 0
yellow  = 1
green   = 2

currentRing = red
newRing     = false
itemFound   = false

function GetItemCount(id)
    for _, itm in pairs(GetInventory()) do
        if itm.id == id then
            return itm.amount
        end
    end
    return 0
end


aliveGeiger = GetItemCount(2204)
totalFound = 0
canDrop = true

breakLoop = false

-- EditToggle("antibounce", true)
-- EditToggle("modfly", true)

function clamp(val, minVal, maxVal)
    return math.max(minVal, math.min(val, maxVal))
end

function reconnect()
    while GetWorld().name ~= worldGeiger do
        SendPacket(2, "action|input\n|text|/warp "..worldGeiger.."\n")
        Sleep(5000)
    end
end


function renewRing()
    while newRing == false do
        reconnect()
        Sleep(500)
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

function ringHook(packet)
    if packet.type == 17 then
        if packet.xspeed == 2.00 then
            log("Green")
            currentRing = green
            newRing = true
        elseif packet.xspeed == 1.00 then
            log("Yellow")
            currentRing = yellow
            newRing = true
        else
            log("Red")
            currentRing = red
            newRing = true
        end
    end
end

function foundHook(varlist)
    if varlist[0]:find("OnConsoleMessage") and varlist[1]:find("oGiven") then
        if varlist[1]:find("Stuff") then
            listFound[1] = listFound[1] + 1
            totalFound = totalFound + 1
        elseif varlist[1]:find("Crystal") then
            if varlist[1]:find("Black") then
                listFound[2] = listFound[2] + 1
                totalFound = totalFound + 1
            elseif varlist[1]:find("Green") then
                listFound[3] = listFound[3] + 1
                totalFound = totalFound + 1
            elseif varlist[1]:find("Red") then
                listFound[4] = listFound[4] + 1
                totalFound = totalFound + 1
            elseif varlist[1]:find("White") then
                listFound[5] = listFound[5] + 1
                totalFound = totalFound + 1
            end
        elseif varlist[1]:find("Haunted") then
            listFound[6] = listFound[6] + 1
            totalFound = totalFound + 1
        elseif varlist[1]:find("Radioactive") then
            listFound[7] = listFound[7] + 1
            totalFound = totalFound + 1
        elseif varlist[1]:find("Growtoken") then
            listFound[8] = listFound[8] + 1
            totalFound = totalFound + 1
        elseif varlist[1]:find("`w1 Battery") then
            listFound[9] = listFound[9] + 1
            totalFound = totalFound + 1
        elseif varlist[1]:find("D Battery") then
            listFound[10] = listFound[10] + 1
            totalFound = totalFound + 1
        elseif varlist[1]:find("Charger") then
            listFound[11] = listFound[11] + 1
            totalFound = totalFound + 1
        end
        log(string.format([[
Item Found : %d
Stuff : %d
Crystal Black : %d
Crystal Green : %d
Crystal Red : %d
Crystal White : %d
Chemical Haunted : %d
Chemical Radioactive : %d
Growtoken : %d
Battery : %d
D Battery : %d
Geiger Charger : %d
]], totalFound, listFound[1], listFound[2], listFound[3], listFound[4], listFound[5], listFound[6], listFound[7], listFound[8], listFound[9], listFound[10], listFound[11]))
        itemFound = true
    end
    if varlist[0]:find("OnTextOverlay") and varlist[1]:find("You can't drop") then
        canDrop = false
    end
end

AddHook("onvariant", "lah", foundHook)
AddHook("onprocesstankupdatepacket", "haha", ringHook)

function fullAFK()
    SendPacket(2, "action|input\n|text|/warp "..worldSave.."\n")
    Sleep(5000)
    while GetWorld().name ~= worldSave do
        Sleep(5000)
        SendPacket(2, "action|input\n|text|/warp "..worldSave.."\n")
    end
    FindPath(aliveGeigerPos[1], aliveGeigerPos[2])

    Sleep(3000)
    local itemDrop = itemDropLeft[1]
    local deadDrop = deadDropLeft[1]
    local loop = true
    while loop == true do
        if breakLoop == true then
            if GetLocal().pos.y // 32 <= 15 then
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 15, 0, 29))
            else
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -15, 0, 29))
            end
            breakLoop = false
            return
        end
        loop = false
        FindPath(itemDrop, itemDropLeft[2])
        Sleep(500)
        for _,cur in pairs(GetInventory()) do
            if cur.id == 2242 or cur.id == 2244 or cur.id == 2246 or cur.id == 2248 or cur.id == 2250 or cur.id == 3306 or cur.id == 1962 or cur.id == 2206 or cur.id == 1482 then
                loop = true
                Sleep(500)
                SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..cur.id.."|\nitem_count|"..cur.amount.."\n")
                Sleep(500)
                if canDrop == false then
                    itemDrop = itemDrop - 1
                end
            elseif cur.id == 1498 or cur.id == 1500 or cur.id == 2804 or cur.id == 2806 or cur.id == 15250 then
                SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|"..cur.id.."|\nitem_count|"..cur.amount.."\n")
                Sleep(500)
                if canDrop == false then
                    itemDrop = itemDrop - 1
                end
            end
        end
    end
    loop = true
    while loop == true do
        if breakLoop == true then
            if GetLocal().pos.y // 32 <= 15 then
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 15, 0, 29))
            else
                FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -15, 0, 29))
            end
            breakLoop = false
            return
        end
        loop = false
        FindPath(deadDrop, deadDropLeft[2])
        Sleep(500)
        for _,cur in pairs(GetInventory()) do
            if cur.id == 2286 then
                loop = true
                SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..cur.id.."|\nitem_count|"..cur.amount.."\n")
                Sleep(500)
                if canDrop == false then
                    deadDrop = deadDrop - 1
                end
            end
        end
    end
    SendPacket(2, "action|input\n|text|/warp "..worldGeiger.."\n")
    Sleep(5000)
    while GetWorld().name ~= worldGeiger do
        Sleep(5000)
        SendPacket(2, "action|input\n|text|/warp "..worldGeiger.."\n")
    end
end

RunThread(function()
    while true do
        Sleep(300000)
        breakLoop = true
        log("Break")
    end
end)

while true do
    if breakLoop == true then
        if GetLocal().pos.y // 32 <= 15 then
            FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + 15, 0, 29))
        else
            FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.y // 32 + -15, 0, 29))
        end
        breakLoop = false
    end
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
    aliveGeiger = aliveGeiger - 1
    if aliveGeiger <= 5 then
        fullAFK()
        aliveGeiger = GetItemCount(2204)
    end
end