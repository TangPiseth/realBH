log = LogToConsole 
redPosX = {25, 5, 5, 25, 15, 14}
redPosY = {5, 25, 5, 25, 25, 3}

listFound = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0} -- Stuff, Black, Green, Red, White, Hchem, Rchem, Growtoken, Battery, D Battery

red     = 0
yellow  = 1
green   = 2

currentRing = red
newRing     = false
itemFound   = false


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
    local foundPosX = GetLocal().pos.x
// 32
    local foundPosY = GetLocal().pos.y
// 32
    local currentLoc = 1
    local isLeft = false
    local isUp = false

    while currentLoc <= 8 do
        if itemFound == true then return end
        FindPath(clamp(foundPosX + currentLoc, 0, 29), foundPosY)
        isLeft = false
        renewRing()
        if currentRing ~= yellow then break end
        FindPath(clamp(foundPosX + -currentLoc, 0, 29), foundPosY)
        isLeft = true
        renewRing()
        if currentRing ~= yellow then break end
        currentLoc = currentLoc + 1
    end
-- Stuck
    if currentLoc >= 8 then
        if GetLocal().pos.y // 32 >= 20 then
            FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.x // 32 + -5, 0, 29))
        else
            FindPath(GetLocal().tile.x // 32, clamp(GetLocal().pos.x // 32 + 5, 0, 29))
        end
        return
    end
-- X Yellow -> Red
    if currentRing == red then
        if isLeft == false then
            FindPath(clamp(GetLocal().pos.x // 32 + -12, 0, 29), foundPosY)
        else
            FindPath(clamp(GetLocal().pos.x // 32 + 12, 0, 29), foundPosY)
        end
        Sleep(10000)
-- Stuck
    if currentRing == yellow then
        if GetLocal().pos.y // 32 >= 20 then
            FindPath(GetLocal().pos.x // 32, clamp(GetLocal().pos.x // 32 + -5, 0, 29))
        else
            FindPath(GetLocal().pos.y // 32, clamp(GetLocal().pos.y // 32 + 5, 0, 29))
        end
        return
    end
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
        if itemFound == true then return end
        FindPath(foundPosX, clamp(foundPosY + -currentLoc, 0, 29))
        isUp = false
        Sleep(1000)
        renewRing()
        if currentRing ~= green then break end
        FindPath(foundPosX, clamp(foundPosY + currentLoc, 0, 29))
        isUp = true
        Sleep(1000)
        renewRing()
        if currentRing ~= green then break end
        currentLoc = currentLoc + 1
    end
-- Y Green -> Yellow
    if currentRing == yellow then
        if isUp == false then
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + 5, 0, 29))
        else
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + -5, 0, 29))
        end
        Sleep(10000)
    end
end

function foundGreen()
    local foundPosX = GetLocal().pos.x // 32
    local foundPosY = GetLocal().pos.y // 32
    local currentLoc = 1
    local isLeft = false
    local isUp = false

    while true do
        if itemFound == true then return end
        FindPath(clamp(foundPosX + currentLoc, 0, 29), foundPosY)
        isLeft = false
        renewRing()
        if currentRing ~= green then break end
        FindPath(clamp(foundPosX + -currentLoc, 0, 29), foundPosY)
        isLeft = true
        renewRing()
        if currentRing ~= green then break end
        currentLoc = currentLoc + 1
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
    currentLoc = 1

    while true do
        if itemFound == true then return end
        FindPath(foundPosX, clamp(foundPosY + -currentLoc, 0, 29))
        isUp = false
        Sleep(1000)
        renewRing()
        if currentRing ~= green then break end
        FindPath(foundPosX, clamp(foundPosY + currentLoc, 0, 29))
        isUp = true
        Sleep(1000)
        renewRing()
        if currentRing ~= green then break end
        currentLoc = currentLoc + 1
    end
-- Y Green -> Yellow
    if currentRing == yellow then
        if isUp == false then
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + 5, 0, 29))
        else
            FindPath(foundPosX, clamp(GetLocal().pos.y // 32 + -5, 0, 29))
        end
        Sleep(10000)
    end
end

AddHook("onprocesstankupdatepacket", "debug", function(packet)
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
end)


while true do
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
end