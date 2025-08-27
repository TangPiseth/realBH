Settings = {
    World = GetWorld().name,
    Mode = "PTHT",
				SizeX = 199, -- World Size
				SizeY = 184, -- World Size
    
				PTHT = { 
    				MagX = 1,
								MagY = 187,
								PosX = 0,
    				PosY = 182, 
        TotalPtht = 2,
        PlantRight = false, 
        SeedID = 15461,
        DelayHarvest = 200, 
        DelayPlant = 70, 
        DelayUWS = 2000 
    },

    PNB = { 
        MagX = 3, 
        MagY = 193,
        PosX = 11, 
        PosY = 192, 
        TelephoneX = 11, 
        TelephoneY = 193, 
        AutoConsume = false,
        AutoBuyDl = true,
        AutoCollectGems = true,
    },

    Webhook = { 
        Use = false, 
        URL = "", 
        Delay = 10 
    },

    TrashFloating = false
}

TotalCollected = 0

AddHook("OnVariant", "Lant", function(var)
				if var[0] == "OnSDBroadcast" then
								return true
				end
		    if var[0] == "OnTalkBubble" and var[2]:find("Collected") and var[2]:find("(%d+) Gems") and Settings.PNB.AutoBuyDl then
								local Collected = var[2]:match("(%d+) Gems")
								TotalCollected = TotalCollected + Collected
								Log("You've been collected ".. TotalCollected.." gems")
        if TotalCollected >= 130000 then
            cvdl = true
        end
								return true
				end
				if var[0] == "OnTalkBubble" and var[2]:find("The MAGPLANT 5000 is empty") then
								chgremote = true
								return true
				end
    if var[0] == "OnConsoleMessage" and var[1]:find("Where would you like to go") then
        dc = true
        return true
    end
    if var[0] == "OnConsoleMessage" and var[1]:find("Disconnected?! Will attempt to reconnect...") then
        dc = true
        return true
    end
				if var[0] == "OnConsoleMessage" and var[1]:find("Cheat Active") then
								return true
				end
				if var[0] == "OnConsoleMessage" and var[1]:find("Whoa, calm down toggling cheats on/off... Try again in a second!") then
								return true
				end
				if var[0] == "OnConsoleMessage" and var[1]:find("Applying cheats...") then
								return true
				end
				if var[0] == "OnConsoleMessage" and var[1]:find("** from") then
								return true
				end
				if var[0] == "OnConsoleMessage" and var[1]:find("Xenonite") then
								return true
				end
				if var[0] == "OnConsoleMessage" and var[1]:find("`1O`2h`3, `4l`5o`6o`7k `8w`9h`ba`!t `$y`3o`2u`4'`ev`pe `#f`6o`8u`1n`7d`w!") and removeRTEX then
								return true
				end
end)
    

function Log(x)
				LogToConsole("`0[`cAwZka`0] "..x)
end

function Join(w)
  SendPacket(3, "action|join_request\nname|".. w .."|\ninvitedWorld|0")
end
 
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

function inv(id)
				local count = 0
				for _, item in pairs(GetInventory()) do
								if item.id == id then
												count = count + item.amount
								end
				end
				return count
end

chgremote = false
getremote = false
hvremote = false
grow = GetLocal().name
World = Settings.World
px = 1

function GetPlat()
  Plat = 0
  for y = Settings.SizeY + 1, 0, - 2 do
    for x = px, Settings.SizeX, 1 do
      if (GetTile(x,y).fg ~= Settings.PTHT.SeedID) and (GetTile(x,y).fg ~= 0) then
        Plat = Plat + 1
      end
    end
  end
  return Plat
end

function GetTree()
  Tree = 0
  for y = Settings.SizeY, Settings.SizeY % 2 == 0 and 0 or 1, - 2 do
    for x = px, 199, 1 do
      if (GetTile(x,y).fg == Settings.PTHT.SeedID) then
        Tree = Tree + 1
      end
    end
  end
  return Tree
end

function UseUws()
				if not Settings.PTHT.PlantRight then
								SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
								Log("Using Ultra World Spray...")
								Sleep(Settings.PTHT.DelayUWS)
				end
end

plant = true
harvest = false

function chgmode()
				if GetTree() >= 12000 then
								UseUws()
								plant = false
								harvest = true
								return
				else
								plant = true
								harvest = false
								return
				end
				if GetTree() < 100 then
								harvest = false
								plant = true
								return
				else
								harvest = true
								plant = false
								return
				end
end

pthtx = Settings.PTHT.MagX
oldpthtx = pthtx
pthty = Settings.PTHT.MagY
pooh = 9
pthtt = Settings.PTHT.TotalPtht
totalptht = 0
pthtc = 1
pthtcc = 0

function GetMagPtht()
    if GetWorld() == nil or dc or GetWorld().name ~= World then
        return
    else
        Raw(0, 32, 0, pthtx, pthty)
        Sleep(300)
        Raw(3, 0, 32, pthtx, pthty)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. pthtx .."|\ny|".. pthty .."|\nbuttonClicked|getRemote")
        Sleep(500)
        hvremote = true
        getremote = false
        return
    end
end

function ChangeMagPtht()
    if GetWorld() == nil or dc or GetWorld().name ~= World then
        return
    else
        if GetTile(pthtx + 1, pthty).fg == 5638 then
            pthtx, pthty = pthtx + 1, pthty
            pthtcc = pthtc
            pthtc = pthtc + 1
            LogToConsole("`wMAGPLANT `2"..pthtcc.." `wIS EMPTY, SWITCHING TO MAGPLANT `2"..pthtc)
        else
            LogToConsole("`wMAGPLANT `2"..pthtc.." `wIS EMPTY, SWITCHING TO MAGPLANT `21")
            pthtc = 1
            pthtx = oldpthtx
        end
    end
    chgremote = false
    GetMagPtht()
    Sleep(1000)
    return
end

function LogPtht(logText)
    local path = "/storage/emulated/0/android/media/com.rtsoft.growtopia/rotasi.txt"
    local file = io.open(path, "a")
    if file then
        file:write(logText .. "\n")
        file:close()
        Log("Log saved to: " .. path)
    else
        Log("Failed to save log!")
    end
end

function ptht()
    for x = (Settings.PTHT.PlantRight and Settings.SizeX or px), (Settings.PTHT.PlantRight and px or Settings.SizeX), (Settings.PTHT.PlantRight and -10 or 10) do
								if GetWorld() == nil or GetWorld().name ~= World or chgremote then
								    dc = true
												return
								else
												for i = 1, 3, 1 do
																for y = (i == 1 and Settings.SizeY or 0), (i == 1 and 0 or Settings.SizeY), (i == 1 and -2 or 2) do
																				if GetWorld() == nil or GetWorld().name ~= World or chgremote then
																								return
																				else 
																								if (plant and GetTile(x,y).fg == 0) or (harvest and GetTile(x,y).fg == Settings.PTHT.SeedID and GetTile(x,y).extra.progress) then
																												Raw(0, (Settings.PTHT.PlantRight and 48 or 32), 0, x, y)
																								    Sleep(plant and 120 or 300)
																												Raw(3, (Settings.PTHT.PlantRight and 48 or 32), (plant and 5640 or 18), x, y)
																												Sleep(plant and Settings.PTHT.DelayPlant or Settings.PTHT.DelayHarvest)
																												if GetWorld() == nil or GetWorld().name ~= World or chgremote then
																																return
																												end
																								end
																				end
																end
												end
								end
				end
    if GetWorld() == nil or GetWorld().name ~= World or chgremote then
        return
    else 
        chgmode()
    end
end


function BuyDL(x,y)
				if inv(1796) >= 100 then
				    SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..x.."|\ny|"..y.."|\nbuttonClicked|bglconvert")
				    Sleep(50)
				end
				SendPacket(2, "action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|"..x.."|\ny|"..y.."|\nbuttonClicked|dlconvert")
				Sleep(30)
end

ConsumeTime = os.time() - 60 * 30 

function Consume()
    local Consumable = {4604, 528, 1474}
    if os.time() - ConsumeTime >= 60 * 30 then
        ConsumeTime = os.time()
        LogToConsole("`wConsuming `9Arroz `wand `2Clover")
        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Settings.PNB.AutoCollectGems and 1 or 0))
        Sleep(2000)
        for _, Eat in pairs(Consumable) do
            if inv(Eat) > 0 then
                Raw(3, 0, Eat, posx, posy)
                Sleep(2000)
            end
        end
        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Settings.PNB.AutoCollectGems and 1 or 0))
        Sleep(2000)
    end
end

pnbx = Settings.PNB.MagX
oldpnbx = pnbx
pnby = Settings.PNB.MagY
posx = Settings.PNB.PosX
posy = Settings.PNB.PosY
cheat = false
pnbc = 1
pnbcc = 0
tt = 0
maxck = 3

function pnb()
    if GetWorld() == nil or GetWorld().name ~= World or chgremote then
        return
    else
        if not cheat then
            FindPath(posx, posy)
            Sleep(400)
            SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|1\ncheck_bfg|1\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Settings.PNB.AutoCollectGems and 1 or 0))
            cheat = true
        end
        if GetWorld() == nil or GetWorld().name ~= World or chgremote then
            return
        else
            cheat = true
            if Settings.PNB.AutoConsume then
                Consume()
                Sleep(500)
            end
            if GetWorld() == nil or GetWorld().name ~= World or chgremote then
                return
            else
                if cvdl then
                    BuyDL(Settings.PNB.TelephoneX, Settings.PNB.TelephoneY)
                    Sleep(500)
                    cvdl = false
                    TotalCollected = 0
                end
            end
        end
    end
end

function GetMagPnb()
    if GetWorld() == nil or GetWorld().name ~= World then
        return
    else
        Raw(0, 0, 0, pnbx, pnby)
        Sleep(200)
        Raw(3, 0, 32, pnbx, pnby)
        Sleep(200)
        SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|".. pnbx .."|\ny|".. pnby .."|\nbuttonClicked|getRemote")
        Sleep(500)
        getremote = false
        hvremote = true
        return
    end
end

function ChangeMagPnb()
    if GetWorld() == nil or GetWorld().name ~= World then
        return
    else
        if tt >= maxck then
            chgstatus()
        end
        if GetTile(pnbx + 1, pnby).fg == 5638 then
            pnbx, pnby = pnbx + 1, pnby
            pnbcc = pnbc
            pnbc = pnbc + 1 
            LogToConsole("`wMAGPLANT `2"..pnbcc.." `wSWITCHING TO MAGPLANT `2"..pnbc) 
        else
            LogToConsole("`wMAGPLANT `2"..pnbcc.." `wSWITCHING TO MAGPLANT `21")
            pnbx = oldpnbx
            pnbc = 1
            tt = tt + 1
        end
    end
    chgremote = false
    GetMagPnb()
    Sleep(1000)
    return
end
    
function chgstatus()
    if Settings.Mode == "PTHT" and totalptht >= pthtt then
        Settings.Mode = "PNB"
        Log("Changing status to PNB")
        getremote = true
        chgremote = false
        pthtt = 0
        return
    end
    if Settings.Mode == "PNB" and tt > maxck then
        Settings.Mode = "PTHT"
        Log("Changing status to PTHT")
        getremote = true
        chgremote = false
        maxck = 0
        return
    end
end

getremote = true
while true do
    Sleep(2000)
    if GetWorld().name ~= World or dc or GetWorld() == nil then
        Join(World)
        Sleep(5000)
        getremote = true
        chgremote = false
    end
    if getremote and Settings.Mode == "PTHT" then
        GetMagPtht()
        Sleep(500)
    end
    if chgremote and Settings.Mode == "PTHT" then
        ChangeMagPtht()
        Sleep(500)
    end
    if Settings.Mode == "PTHT" and totalptht < pthtt then
        ptht()
        Sleep(300)
        totalptht = totalptht + 1
    end
    if Settings.Mode == "PTHT" and totalptht >= pthtt then
        chgstatus()
    end
    if getremote and Settings.Mode == "PNB" then
       SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Settings.PNB.AutoCollectGems and 1 or 0))
       GetMagPnb()
    end
    if chgremote and Settings.Mode == "PNB" then
        SendPacket(2, "action|dialog_return\ndialog_name|cheats\ncheck_autofarm|0\ncheck_bfg|0\ncheck_lonely|0\ncheck_ignoreo|0\ncheck_gems|".. (Settings.PNB.AutoCollectGems and 1 or 0))
        ChangeMagPnb()
    end
    if Settings.Mode == "PNB" and tt < maxck then
        pnb()
        Sleep(3000)
    end
    if Settings.Mode == "PNB" and tt >= maxck then
        chgstatus()
    end
end
