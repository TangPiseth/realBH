-- [ CONFIGURATION ] --

--[ WORLD SETTINGS ] --
World = {
  From = "AWZKASS", 
  To = "AWZKADD",
}

ITEM_ID = 10

-- [ MODE SETTINGS ] --

Mode = {
  From = {
    Vend = false, 
    Mag = false, 
    Drop = true,
  },
  To = {
    Vend = false,
    Mag = false,
    Drop = true,
  },
}

MainSettings = {
  From = {
    MagBG = 14, -- Background di magplant take
    VendPos = { 10, 24 }, -- Vending machine position
  },
  To = {
    MagBG = 14,
    VendPos = { 49, 24}, 
    PosDrop = { 49, 24 },
  },
  Delay = 2000,
}


function inv(id)
  local count = 0
  for _, itm in pairs(GetInventory()) do
    if itm.id == id then
      count = count + itm.amount
    end
  end
  return count
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

function drop()
  for attempts = 0, 6 do
    if inv(ITEM_ID) >= 250 then
      Log("Dropping Arroz Attempt: ["..attempts.." / 6]")
      SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|" .. ITEM_ID .. "|\nitem_count|"..inv(ITEM_ID))
      Sleep(300)
    end
  end
  if inv(ITEM_ID) >= 250 then
    MainSettings.To.PosDrop[1] = MainSettings.To.PosDrop[1] + 1
    move(MainSettings.To.PosDrop[1], MainSettings.To.PosDrop[2])
    SendPacket(2,"action|dialog_return\ndialog_name|drop\nitem_drop|" .. ITEM_ID .. "|\nitem_count|"..inv(ITEM_ID))
    Sleep(400)
    return
  end
end

function Log(x)
		LogToConsole("`0[`cAwZka`0] "..x)
end

function Join(w)
		SendPacket(3, "action|join_request\nname|".. w .."|\ninvitedWorld|0")
end

function move(tx, ty)
  local function dir(a, b) return (b - a) / math.max(1, math.abs(b - a)) end
  local function ease(t) return t * t * (3 - 2 * t) end  

  while true do
    local x, y = GetLocal().pos.x // 32, GetLocal().pos.y // 32
    if x == tx and y == ty then break end

    local nx, ny = x + dir(x, tx), y + dir(y, ty)
    FindPath(nx, ny)
    Sleep(30 + ease(math.abs(nx - tx + ny - ty)) * 20)
  end
end

function GetFloat(id)
  for _, itm in pairs(GetObjectList()) do
    if itm.id == id and inv(id) < 50 then
      move(itm.pos.x // 32, itm.pos.y // 32)
      Sleep(500)
      return GetFloat(id)
    end
  end
end

function mag(id)
  for _, tile in pairs(GetTiles()) do
    if tile.fg == 5638 and tile.bg == id then
      Raw(0, 0, 0, tile.x, tile.y)
      Sleep(500)
      Raw(3, 0, 32, tile.x, tile.y) 
      Sleep(350)
      SendPacket(2,"action|dialog_return\ndialog_name|magplant_edit\nx|".. tile.x .."|\ny|".. tile.y .."|\nbuttonClicked|additems")
    end
  end
end

function mag2(id)
  for _, tile in pairs(GetTiles()) do
    if tile.fg == 5638 and tile.bg == id then
      Raw(0, 0, 0, tile.x, tile.y)
      Sleep(500)
      Raw(3, 0, 32, tile.x, tile.y) 
      Sleep(350)
      SendPacket(2,"action|dialog_return\ndialog_name|magplant_edit\nx|".. tile.x .."|\ny|".. tile.y .."|\nbuttonClicked|withdraw")
    end
  end
end


function drop_setting()
  if Mode.From.Drop and Mode.To.Drop then
    if GetWorld().name == World.From then
      Sleep(MainSettings.Delay) 
      GetFloat(ITEM_ID)
      Sleep(300) 
      GetFloat(ITEM_ID) 
      Sleep(700)
      Join(World.To)
      Sleep(MainSettings.Delay)
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      Sleep(250) 
      move(MainSettings.To.PosDrop[1], MainSettings.To.PosDrop[2]) 
      Sleep(250)
      drop()
      Sleep(250)
      Join(World.From) 
      Sleep(MainSettings.Delay) 
    else
      Join(World.To)
      Sleep(MainSettings.Delay)
    end
  end
  if Mode.From.Drop and Mode.To.Mag then
    if GetWorld().name == World.From then
      Sleep(MainSettings.Delay)
      GetFloat(ITEM_ID) 
      Sleep(700)
      Join(World.To)
      Sleep(MainSettings.Delay)
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      if inv(ITEM_ID) > 0 then
        Sleep(400)
        mag(MainSettings.To.MagBG)
        Sleep(200)
        Join(World.From)
        Sleep(MainSettings.Delay)
      end
    else
      Join(World.To)
      Sleep(MainSettings.Delay)
    end
  end
  if Mode.From.Drop and Mode.To.Vend then
    if GetWorld().name == World.From then
      Sleep(MainSettings.Delay)
      GetFloat(ITEM_ID)
      Sleep(500)
      if inv(ITEM_ID) > 0 then
        Join(World.To)
        Sleep(MainSettings.Delay)
      end
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      Sleep(MainSettings.Delay)
      if GetTile(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2]).fg == 2978 or 
         GetTile(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2]).fg == 9268 then
        move(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2])
        Sleep(300)
        Raw(3, 0, 32, MainSettings.To.VendPos[1], MainSettings.To.VendPos[2])
        Sleep(200)
        SendPacket(2,"action|dialog_return\ndialog_name|vend_edit\nx|" .. MainSettings.To.VendPos[1] .. "|\ny|" .. MainSettings.To.VendPos[2] .. "|\nbuttonClicked|addstock")
        Sleep(350)
        Join(World.From)
        Sleep(MainSettings.Delay)
      else
        LogToConsole("`2PLEASE PUT CORRECT CORD OF VENDING MACHINE")
      end
    else
      if GetWorld().name ~= World.To then
        Join(World.To)
        Sleep(MainSettings.Delay)
      end
    end
  end
end

function vend_setting()
  if Mode.From.Vend and Mode.To.Drop then
    if GetWorld().name == World.From then
      if GetTile(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2]).fg == 2978 or 
        GetTile(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2]).fg == 9268 then
        Sleep(MainSettings.Delay) 
        move(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2])
        Sleep(300)
        Raw(3, 0, 32, MainSettings.From.VendPos[1], MainSettings.From.VendPos[2])
        Sleep(200)
        SendPacket(2, "action|dialog_return\ndialog_name|vend_edit\nx|" .. MainSettings.From.VendPos[1] .. "|\ny|" .. MainSettings.From.VendPos[2] .. "|\nbuttonClicked|pullstock")
        Sleep(200)
        Join(World.To) 
        Sleep(MainSettings.Delay)
      else
        LogToConsole("`bPlease Put Correct Cord Of Vending Machine")
      end
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      Sleep(450)
      move(MainSettings.To.PosDrop[1], MainSettings.To.PosDrop[2])
      Sleep(200)
      drop()
      Sleep(200)
      Join(World.From)
      Sleep(MainSettings.Delay)
    else
      Join(World.To)
      Sleep(MainSettings.Delay)
    end
  end
  if Mode.From.Vend and Mode.To.Vend then
    if GetWorld().name == World.From then
      if GetTile(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2]).fg == 2978 or 
         GetTile(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2]).fg == 9268 then
           Sleep(500)
           move(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2])
        Sleep(300)
        Raw(3, 0, 32, MainSettings.From.VendPos[1], MainSettings.From.VendPos[2])
        Sleep(200)
        SendPacket(2, "action|dialog_return\ndialog_name|vend_edit\nx|" .. MainSettings.From.VendPos[1] .. "|\ny|" .. MainSettings.From.VendPos[2] .. "|\nbuttonClicked|pullstock")
        Sleep(200)
        Join(World.To)
        Sleep(MainSettings.Delay)
      else
        LogToConsole("`bPLEASE PUT CORRECT CORD OF VENDING MACHINE")
      end
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      if GetTile(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2]).fg == 2978 or 
         GetTile(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2]).fg == 9268 then
        move(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2])
        Sleep(300)
        Raw(3, 0, 32, MainSettings.To.VendPos[1], MainSettings.To.VendPos[2])
        Sleep(200)
        SendPacket(2, "action|dialog_return\ndialog_name|vend_edit\nx|" .. MainSettings.To.VendPos[1] .. "|\ny|" .. MainSettings.To.VendPos[2] .. "|\nbuttonClicked|addstock")
        Sleep(200)
        Join(World.From)
        Sleep(MainSettings.Delay)
      else
        LogToConsole("`bPLEASE PUT CORRECT CORD OF VENDING MACHINE")
      end
    else
      if GetWorld().name ~= World.To then
        Join(World.To)
        Sleep(MainSettings.Delay)
      end
    end
  end
  if Mode.From.Vend and Mode.To.Mag then
    if GetWorld().name == World.From then
      if GetTile(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2]).fg == 2978 or 
        GetTile(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2]).fg == 9268 then
        move(MainSettings.From.VendPos[1], MainSettings.From.VendPos[2])
        Sleep(300)
        Raw(3, 0, 32, MainSettings.From.VendPos[1], MainSettings.From.VendPos[2])
        Sleep(200)
        SendPacket(2, "action|dialog_return\ndialog_name|vend_edit\nx|" .. MainSettings.From.VendPos[1] .. "|\ny|" .. MainSettings.From.VendPos[2] .. "|\nbuttonClicked|pullstock")
        Sleep(200)
        Join(World.To)
        Sleep(MainSettings.Delay)
      else
        LogToConsole("`bPLEASE PUT CORRECT CORD OF VENDING MACHINE")
      end
    else
      if GetWorld().name ~= World.From then
        Join(World.From)
        Sleep(MainSettings.Delay)
      end
    end
    if GetWorld().name == World.To then
      Sleep(300)
      mag(MainSettings.To.MagBG)
      Sleep(300)
      Join(World.From)
      Sleep(MainSettings.Delay)
    else
      Join(World.To)
      Sleep(MainSettings.Delay)
    end
  end
end

function mag_setting()
  if Mode.From.Mag and Mode.To.Drop then
    if GetWorld().name == World.From then
      Sleep(MainSettings.Delay)
      mag2(MainSettings.From.MagBG)
      Sleep(200)
      Join(World.To)
      Sleep(MainSettings.Delay) 
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      Sleep(MainSettings.Delay)
      move(MainSettings.To.PosDrop[1], MainSettings.To.PosDrop[2])
      Sleep(200)
      drop()
      Sleep(250)
      Join(World.From)
      Sleep(MainSettings.Delay) 
    else
      Join(World.To)
      Sleep(MainSettings.Delay)
    end
  end
  if Mode.From.Mag and Mode.To.Vend then
    if GetWorld().name == World.From then
      Sleep(MainSettings.Delay)
      mag2(MainSettings.From.MagBG)
      Sleep(200)
      Join(World.To)
      Sleep(MainSettings.Delay)
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      Sleep(MainSettings.Delay)
      if GetTile(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2]).fg == 2978 or 
        GetTile(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2]).fg == 9268 then
        move(MainSettings.To.VendPos[1], MainSettings.To.VendPos[2])
        Sleep(300)
        Raw(3, 0, 32, MainSettings.To.VendPos[1], MainSettings.To.VendPos[2])
        Sleep(200)
        SendPacket(2, "action|dialog_return\ndialog_name|vend_edit\nx|" .. MainSettings.To.VendPos[1] .. "|\ny|" .. MainSettings.To.VendPos[2] .. "|\nbuttonClicked|addstock")
        Sleep(200)
        Join(World.From)
      else
        LogToConsole("`bPLEASE PUT CORRECT CORD OF VENDING MACHINE")
      end
    else
      Join(World.To)
      Sleep(MainSettings.Delay)
    end
  end
  if Mode.From.Mag and Mode.To.Mag then
    if GetWorld().name == World.From then
      Sleep(MainSettings.Delay)
      mag2(MainSettings.From.MagBG)
      Sleep(200)
      Join(World.To)
      Sleep(MainSettings.Delay) 
    else
      Join(World.From)
      Sleep(MainSettings.Delay)
    end
    if GetWorld().name == World.To then
      Sleep(MainSettings.Delay)
      mag(MainSettings.To.MagBG)
      Sleep(200)
      Join(World.From)
      Sleep(MainSettings.Delay) 
    else
      Join(World.To)
      Sleep(MainSettings.Delay)
    end
  end
end

while true do
  Sleep(200)
  drop_setting()
  vend_setting()
  mag_setting()
end
