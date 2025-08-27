Settings = {
		-- [ Tile Settings ] --
		StartingPos = { 0, 192 }, -- ( x, y ) --
		MagBG = 284, -- ( Background ID ) --
		
		-- [ Main Settings ] --
		World = "DOCS",
		Mode = "VERTICAL", -- ( "VERTICAL" or "HORIZONTAL" ) --
		SeedID = 15461, 
		MaxTree = 17000, -- ( MaxTree before use UWS ) --
		AmountPTHT = 50, 
		
		-- [ Boolean Settings ] --
		SecondAcc = false, -- ( true = planting from right / false = planting from left ) --
		UseUws = true, -- ( true = using uws / false = not using uws ) --
		AntiLag = true,
		AntiSDB = true,
		
		-- [ Delay Settings ] --
		DelayPT = 15, 
		DelayHT = 200, 
		DelayAfterPT = 2500, -- ( Delay after planting before using uws ) --
		DelayAfterUWS = 2500, -- ( Delay after using uws ) --
		
}

AddHook("OnVariant", "Lant", function(var)
		if var[0] == "OnTalkBubble" then
				if var[2]:find("The MAGPLANT 5000 is empty") then
						chgremote = true
				end
		end
		if var[0] == "OnSDBroadcast" then
				if Settings.AntiSDB then
						return true
				end
		end
		if var[0] == "OnConsoleMessage" and var[1]:find("Where would you like to go") then
				return true
		end
		if var[0] == "OnConsoleMessage" and var[1]:find("Disconnected?! Will attempt to reconnect...") then
				return true
		end
		if var[0] == "OnConsoleMessage" and var[1]:find("** from") then
				return true
		end
		if var[0] == "OnConsoleMessage" and var[1]:find("Xenonite") then
				return true
		end
end)
World = Settings.World
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

function GetMagplant()
  local Found = {}
  for x = 0, 199, 1 do
    for y = 0, 199, 1 do
      if GetTile(x, y).fg == 5638 and GetTile(x, y).bg == Settings.MagBG then
        table.insert(Found, {x, y})
      end
    end
  end
  return Found
end

C = 1

function TakeMagplant()
		Mag = GetMagplant()
		if C >= #Mag then
				C = 1
		end
		Sleep(500)
		Raw(0, 32, 0, Mag[C][1], Mag[C][2])
		Sleep(500)
		Raw(3, 0, 32, Mag[C][1], Mag[C][2])
		Sleep(500)
		SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. Mag[C][1] .. "|\ny|".. Mag[C][2] .. "|\nbuttonClicked|getRemote")
		Sleep(500)
		getremote = false
		return
end

function GetPlat()
		local	Plat = 0
  for y = Settings.StartingPos[2] + 1, 0, - 2 do
    for x = Settings.StartingPos[1], Settings.StartingPos[2], 1 do
      if (GetTile(x,y).fg ~= Settings.SeedID) and (GetTile(x,y).fg ~= 0) then
        Plat = Plat + 1
      end
    end
  end
  return Plat
end

function GetTree()
		local Tree = 0
		for y = Settings.StartingPos[2], 0, - 1 do
    for x = Settings.StartingPos[1], 199, 1 do
      if (GetTile(x,y).fg == Settings.SeedID) then
        Tree = Tree + 1
      end
    end
  end
  return Tree
end

function UseUws()
		Sleep(Settings.DelayAfterPT)
		if Settings.UseUws then
				SendPacket(2, "action|dialog_return\ndialog_name|ultraworldspray")
				Log("Using Ultra World Spray...")
				Sleep(Settings.DelayAfterUWS)
		end
end

plant = true
harvest = false

function chgmode()
		if GetTree() > Settings.MaxTree then
				UseUws()
				plant = false
				harvest = true
				return
		else
				plant = true
				harvest = false
				return
		end
		Tree = 0
end
m = 0
function PTHT()
		if Settings.Mode == "HORIZONTAL" then
				for y = Settings.StartingPos[2], (Settings.StartingPos[2] % 2 == 0 and 0 or 1), -2 do
						if GetWorld() == nil or GetWorld().name ~= World or chgremote then
								return
						else
								Log("Currently [`9".. (plant and "Planting" or "Harvesting") .."`0] On Y: "..y)
								for i = 1, 2, 1 do
										for x = (Settings.SecondAcc and 199 or Settings.StartingPos[1]), (Settings.SecondAcc and 0 or Settings.StartingPos[2]), (Settings.SecondAcc and -10 or 10) do
												if GetWorld() == nil or GetWorld().name ~= World or chgremote then
														return
												else 
														if (plant and GetTile(x, y+1).fg ~= 0 and GetTile(x, y).fg == 0 and GetTile(x, y).fg ~= Settings.SeedID) 
														or (harvest and GetTile(x, y).fg == Settings.SeedID and GetTile(x, y).extra.progress) then
																Raw(0, (Settings.SecondAcc and 48 or 32), 0, x, y)
																Sleep(30)
																Raw(3, 0, (plant and 5640 or 18), x, y)
																Sleep(plant and Settings.DelayPT or Settings.DelayHT)
																if GetWorld() == nil or GetWorld().name ~= World or chgremote then
																		return
																end
														end
												end
										end
								end
						end
				end
		elseif Settings.Mode == "VERTICAL" then
				for x = (Settings.SecondAcc and 199 or Settings.StartingPos[1]), (Settings.SecondAcc and Settings.StartingPos[1] or 199), (Settings.SecondAcc and -10 or 10) do
						if GetWorld() == nil or GetWorld().name ~= World or chgremote then
								return
						else
								Log("Currently [`9".. (plant and "Planting" or "Harvesting") .."`0] On X: "..x)
								for i = 1, 2, 1 do
										for y = Settings.StartingPos[2], (Settings.StartingPos[2] % 2 == 0 and 0 or 1), -2 do
												if GetWorld() == nil or GetWorld().name ~= World or chgremote then
														return
												else
														if (plant and GetTile(x, y+1).fg ~= 0 and GetTile(x, y).fg == 0 and GetTile(x, y).fg ~= Settings.SeedID) 
														or (harvest and GetTile(x, y).fg == Settings.SeedID and GetTile(x, y).extra.progress) then
																Raw(0, (Settings.SecondAcc and 48 or 32), 0, x, y)
																Sleep(65)
																Raw(3, 0, (plant and 5640 or 18), x, y)
																Sleep(plant and Settings.DelayPT or Settings.DelayHT)
																if GetWorld() == nil or GetWorld().name ~= World or chgremote then
																		return
																end
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
				m = m + 1
		end
end
chgremote = false
getremote = true
function reConnect()
		if GetWorld() == nil or GetWorld().name ~= World then
				Join(World)
				Sleep(5000)
				getremote = true
		end
		if getremote then
				TakeMagplant()
		end
		if chgremote then
				TakeMagplant()
				C = C + 1
				chgremote = false
		end
		PTHT()
end

repeat
		reConnect()
until m // 2 == Settings.AmountPTHT
