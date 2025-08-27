Settings = {
    lineY = 188,
    amtseed = 18000,
    FirstSeed = 117,
    delayPlant = 100,
    delayHarvest = 100,
    delayGrow = 93,
    FirstMagplant = {4, 192},
    TwoMagplant = {3, 192},
    World = "island"
}

--(DONT TOUCH)
y1 = 0
y2 = Settings.lineY

function IsReady(tile)
    if tile and tile.extra and tile.extra.progress and tile.extra.progress == 1.0 then
        return true
    end
    return false
end

AddHook("onvariant", "L", function(var)
    if var[0] == "OnSDBroadcast" then 
        return true
    end
    if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT 5000") then
        if var[1]:find("The machine is currently empty!") then
        end
        return true
    end
end)

function Raw(t, s, v, x, y)
		pkt = {
  		type = t,
    state = s,
    value = v,
    px = x, 
    py = y,
    x = x * 32,
    y = y * 32
  }
  SendPacketRaw(false, pkt)
end

function magplant(x, y, z)
    Raw(0, 0, 0, x, y)
    Sleep(200)
    Raw(3, 0, 32, x, y + 1)
    Sleep(200)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|"..x.."|\ny|"..(y + (below and 1 or -1)).."|\nbuttonClicked|"..z)
    Sleep(200)
end

function TakeMagplant1()
        Raw(0, 0, 0, Settings.FirstMagplant[1] -1, Settings.FirstMagplant[2] - 1)
        Sleep(100)
        magplant(Settings.FirstMagplant[1] - 1, Settings.FirstMagplant[2] - 1, "getRemote")
        Sleep(1000)
end

function TakeMagplant2()
        Raw(0, 0, 0, Settings.TwoMagplant[1] -1, Settings.TwoMagplant[2] - 1)
        Sleep(100)
        magplant(Settings.TwoMagplant[1] - 1, Settings.TwoMagplant[2] - 1, "getRemote")
        Sleep(1000)
end

function checkseed()
    local Ready = 0
    for y = y1, y2 do
        for x = 0, 199 do
            if IsReady(GetTile(x, y)) then
                Ready = Ready + 1
            end
        end
    end
    return Ready
end

function plant1(startX, endX, stepX, startY, endY, stepY)
    TakeMagplant1()
    if checkseed() < Settings.amtseed then
        for x = startX, endX, stepX do
            for y = startY, endY, stepY - 1 do
                if GetTile(x, y).fg == 0 then
                    Raw(0, 32, 0, x, y)
                    Sleep(Settings.delayPlant)
                    Raw(3, 0, 5640, x, y)
                    Sleep(Settings.delayPlant)
                end
            end
        end
    end
end

function plant2(startX, endX, stepX, startY, endY, stepY)
    TakeMagplant2()
    if checkseed() < Settings.amtseed then
        for x = startX, endX, stepX do
            for y = startY, endY, stepY - 1 do
                if GetTile(x, y).fg == Settings.FirstSeed then
                    Raw(0, 32, 0, x, y)
                    Sleep(Settings.delayPlant)
                    Raw(3, 0, 5640, x, y)
                    Sleep(Settings.delayPlant)
                end
            end
        end
    end
end

function harvest()
    if checkseed() > 0 then
        for y = y2,y1,-1 do
            for x = 0,0 do
                if IsReady(GetTile(x,y)) then
                    FindPath(x,y,50)
                    Sleep(Settings.delayHarvest)
                    Raw(3, 0, 18, x, y)
                    Sleep(Settings.delayHarvest)
                    end
                end
            end
        end
end

function plantnormal()
    TakeMagplant1()
    plant1(0, 0, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(0, 0, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(10, 10, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(10, 10, 1, y2, y1, -1)
    plant2(10, 10, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(20, 20, 1, y2, y1, -1)
    plant1(20, 20, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(20, 20, 1, y2, y1, -1)
    plant2(20, 20, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(30, 30, 1, y2, y1, -1)
    plant1(30, 30, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(30, 30, 1, y2, y1, -1)
    plant2(30, 30, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(40, 40, 1, y2, y1, -1)
    plant1(40, 40, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(40, 40, 1, y2, y1, -1)
    plant2(40, 40, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(50, 50, 1, y2, y1, -1)
    plant1(50, 50, 1, y2, y1, -1)
    TakeMagplant2()	
    plant2(50, 50, 1, y2, y1, -1)
    plant2(50, 50, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(60, 60, 1, y2, y1, -1)
    plant1(60, 60, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(60, 60, 1, y2, y1, -1)
    plant2(60, 60, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(70, 70, 1, y2, y1, -1)
    plant1(70, 70, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(70, 70, 1, y2, y1, -1)
    plant2(70, 70, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(80, 80, 1, y2, y1, -1)
    plant1(80, 80, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(80, 80, 1, y2, y1, -1)
    plant2(80, 80, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(90, 90, 1, y2, y1, -1)
    plant1(90, 90, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(90, 90, 1, y2, y1, -1)
    plant2(90, 90, 1, y2, y1, -1)
end

function plantisland()
    TakeMagplant1()
    plant1(0, 0, 1, y2, y1, -1)
    plant1(0, 0, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(0, 0, 1, y2, y1, -1)
    plant2(0, 0, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(10, 10, 1, y2, y1, -1)
    plant1(10, 10, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(10, 10, 1, y2, y1, -1)
    plant2(10, 10, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(20, 20, 1, y2, y1, -1)
    plant1(20, 20, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(20, 20, 1, y2, y1, -1)
    plant2(20, 20, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(30, 30, 1, y2, y1, -1)
    plant1(30, 30, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(30, 30, 1, y2, y1, -1)
    plant2(30, 30, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(40, 40, 1, y2, y1, -1)
    plant1(40, 40, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(40, 40, 1, y2, y1, -1)
    plant2(40, 40, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(50, 50, 1, y2, y1, -1)
    plant1(50, 50, 1, y2, y1, -1)
    TakeMagplant2()	
    plant2(50, 50, 1, y2, y1, -1)
    plant2(50, 50, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(60, 60, 1, y2, y1, -1)
    plant1(60, 60, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(60, 60, 1, y2, y1, -1)
    plant2(60, 60, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(70, 70, 1, y2, y1, -1)
    plant1(70, 70, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(70, 70, 1, y2, y1, -1)
    plant2(70, 70, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(80, 80, 1, y2, y1, -1)
    plant1(80, 80, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(80, 80, 1, y2, y1, -1)
    plant2(80, 80, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(90, 90, 1, y2, y1, -1)
    plant1(90, 90, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(90, 90, 1, y2, y1, -1)
    plant2(90, 90, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(100, 100, 1, y2, y1, -1)
    plant1(100, 100, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(100, 100, 1, y2, y1, -1)
    plant2(100, 100, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(110, 110, 1, y2, y1, -1)
    plant1(110, 110, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(110, 110, 1, y2, y1, -1)
    plant2(110, 110, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(120, 120, 1, y2, y1, -1)
    plant1(120, 120, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(120, 120, 1, y2, y1, -1)
    plant2(120, 120, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(130, 130, 1, y2, y1, -1)
    plant1(130, 130, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(130, 130, 1, y2, y1, -1)
    plant2(130, 130, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(140, 140, 1, y2, y1, -1)
    plant1(140, 140, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(140, 140, 1, y2, y1, -1)
    plant2(140, 140, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(150, 150, 1, y2, y1, -1)
    plant1(150, 150, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(150, 150, 1, y2, y1, -1)
    plant2(150, 150, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(160, 160, 1, y2, y1, -1)
    plant1(160, 160, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(160, 160, 1, y2, y1, -1)
    plant2(160, 160, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(170, 170, 1, y2, y1, -1)
    plant1(170, 170, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(170, 170, 1, y2, y1, -1)
    plant2(170, 170, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(180, 180, 1, y2, y1, -1)
    plant1(180, 180, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(180, 180, 1, y2, y1, -1)
    plant2(180, 180, 1, y2, y1, -1)
    TakeMagplant1()
    plant1(190, 190, 1, y2, y1, -1)
    plant1(190, 190, 1, y2, y1, -1)
    TakeMagplant2()
    plant2(190, 190, 1, y2, y1, -1)
    plant2(190, 190, 1, y2, y1, -1)
end

while true do
 if World == "normal" then
    harvest()
    Sleep(200)
    harvest()
    Sleep(1500)
    plantnormal()
    Sleep(1000)
 elseif World == "island" then
    harvest()
    Sleep(200)
    harvest()
    Sleep(500)
    plantisland()
    Sleep(1000)
 end
end
