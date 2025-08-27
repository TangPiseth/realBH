-- [ WORLD TO WORLD SCRIPT BY icShark ] --
-- [ FULL OWNERSHIP TO icShark ] --

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

-- [ SCRIPT CONTROL ] --
local ScriptRunning = false

-- [ DIALOG FUNCTIONS ] --
local function MainDialog()
    local dialog = [[
set_default_color|`o
add_label_with_icon|big|`9World To World Script|left|3802|
add_spacer|small|
add_label_with_icon|small|`cFull Ownership: `eicShark|left|2278|
add_spacer|small|
add_textbox|`9World Settings:|
add_text_input|world_from|From World:|]]..World.From..[[|20|
add_text_input|world_to|To World:|]]..World.To..[[|20|
add_spacer|small|
add_textbox|`9Item Settings:|
add_text_input|item_id|Item ID:|]]..ITEM_ID..[[|10|
add_spacer|small|
add_textbox|`9From World Mode:|
add_checkbox|from_drop|Drop Mode|]]..(Mode.From.Drop and "1" or "0")..[[|
add_checkbox|from_vend|Vend Mode|]]..(Mode.From.Vend and "1" or "0")..[[|
add_checkbox|from_mag|Magplant Mode|]]..(Mode.From.Mag and "1" or "0")..[[|
add_spacer|small|
add_textbox|`9To World Mode:|
add_checkbox|to_drop|Drop Mode|]]..(Mode.To.Drop and "1" or "0")..[[|
add_checkbox|to_vend|Vend Mode|]]..(Mode.To.Vend and "1" or "0")..[[|
add_checkbox|to_mag|Magplant Mode|]]..(Mode.To.Mag and "1" or "0")..[[|
add_spacer|small|
add_button|settings|`9Advanced Settings|
add_spacer|small|
add_button|]]..(ScriptRunning and "stop" or "start")..[[|`]]..(ScriptRunning and "4Stop Script" or "2Start Script")..[[|
add_spacer|small|
add_button|info|`9Script Info|
end_dialog|wtw_main|Close|Save Settings|
add_quick_exit||
]]
    SendVariantList({[0] = "OnDialogRequest", [1] = dialog})
end

local function SettingsDialog()
    local dialog = [[
set_default_color|`o
add_label_with_icon|big|`9Advanced Settings|left|32|
add_spacer|small|
add_label_with_icon|small|`cFull Ownership: `eicShark|left|2278|
add_spacer|small|
add_textbox|`9From World Settings:|
add_text_input|from_magbg|Magplant BG ID:|]]..MainSettings.From.MagBG..[[|10|
add_text_input|from_vendx|Vend X Position:|]]..MainSettings.From.VendPos[1]..[[|10|
add_text_input|from_vendy|Vend Y Position:|]]..MainSettings.From.VendPos[2]..[[|10|
add_spacer|small|
add_textbox|`9To World Settings:|
add_text_input|to_magbg|Magplant BG ID:|]]..MainSettings.To.MagBG..[[|10|
add_text_input|to_vendx|Vend X Position:|]]..MainSettings.To.VendPos[1]..[[|10|
add_text_input|to_vendy|Vend Y Position:|]]..MainSettings.To.VendPos[2]..[[|10|
add_text_input|to_dropx|Drop X Position:|]]..MainSettings.To.PosDrop[1]..[[|10|
add_text_input|to_dropy|Drop Y Position:|]]..MainSettings.To.PosDrop[2]..[[|10|
add_spacer|small|
add_textbox|`9General Settings:|
add_text_input|delay|Script Delay (ms):|]]..MainSettings.Delay..[[|10|
add_spacer|small|
add_button|main|`9Back to Main|
end_dialog|wtw_settings|Close|Save Settings|
add_quick_exit||
]]
    SendVariantList({[0] = "OnDialogRequest", [1] = dialog})
end

local function InfoDialog()
    local dialog = [[
set_default_color|`o
add_label_with_icon|big|`9Script Information|left|3524|
add_spacer|small|
add_label_with_icon|small|`cFull Ownership: `eicShark|left|2278|
add_spacer|small|
add_textbox|`9Current Status:|
add_smalltext|Script Status: ]]..(ScriptRunning and "`2Running" or "`4Stopped")..[[|
add_smalltext|Current World: `e]]..GetWorld().name..[[|
add_smalltext|Player Position: `9]]..math.floor(GetLocal().pos.x / 32)..[[`w, `6]]..math.floor(GetLocal().pos.y / 32)..[[|
add_spacer|small|
add_textbox|`9Configuration:|
add_smalltext|From World: `c]]..World.From..[[|
add_smalltext|To World: `c]]..World.To..[[|
add_smalltext|Item ID: `e]]..ITEM_ID..[[|
add_smalltext|From Mode: Drop:`]]..(Mode.From.Drop and "2ON" or "4OFF")..[[ Vend:`]]..(Mode.From.Vend and "2ON" or "4OFF")..[[ Mag:`]]..(Mode.From.Mag and "2ON" or "4OFF")..[[|
add_smalltext|To Mode: Drop:`]]..(Mode.To.Drop and "2ON" or "4OFF")..[[ Vend:`]]..(Mode.To.Vend and "2ON" or "4OFF")..[[ Mag:`]]..(Mode.To.Mag and "2ON" or "4OFF")..[[|
add_spacer|small|
add_textbox|`9Commands:|
add_smalltext|`9/wtw `w- Open main dialog|
add_spacer|small|
add_textbox|`9Credits:|
add_smalltext|Script Owner: `eicShark|
add_smalltext|Script Type: World to World Transfer|
add_smalltext|Version: 1.0 with Dialog|
add_spacer|small|
add_button|main|`9Back to Main|
add_quick_exit||
]]
    SendVariantList({[0] = "OnDialogRequest", [1] = dialog})
end


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

-- [ PACKET HANDLING ] --
AddHook("onsendpacket", "WTW_DIALOG", function(type, str)
    -- Command to open main dialog
    if str:find("/wtw") then
        MainDialog()
        return true
    end
    
    -- Handle dialog returns
    if str:find("action|dialog_return") then
        if str:find("dialog_name|wtw_main") then
            -- Parse main dialog settings
            if str:find("world_from|") then
                World.From = str:match("world_from|([^|]*)")
            end
            if str:find("world_to|") then
                World.To = str:match("world_to|([^|]*)")
            end
            if str:find("item_id|") then
                local itemId = str:match("item_id|([^|]*)")
                if itemId and tonumber(itemId) then
                    ITEM_ID = tonumber(itemId)
                end
            end
            
            -- Parse mode checkboxes
            Mode.From.Drop = str:find("from_drop|1") ~= nil
            Mode.From.Vend = str:find("from_vend|1") ~= nil
            Mode.From.Mag = str:find("from_mag|1") ~= nil
            Mode.To.Drop = str:find("to_drop|1") ~= nil
            Mode.To.Vend = str:find("to_vend|1") ~= nil
            Mode.To.Mag = str:find("to_mag|1") ~= nil
            
            -- Handle buttons
            if str:find("buttonClicked|settings") then
                SettingsDialog()
                return true
            elseif str:find("buttonClicked|info") then
                InfoDialog()
                return true
            elseif str:find("buttonClicked|start") then
                ScriptRunning = true
                Log("Script Started by icShark")
                MainDialog()
                return true
            elseif str:find("buttonClicked|stop") then
                ScriptRunning = false
                Log("Script Stopped by icShark")
                MainDialog()
                return true
            end
            
            Log("Settings saved by icShark")
            return true
            
        elseif str:find("dialog_name|wtw_settings") then
            -- Parse advanced settings
            if str:find("from_magbg|") then
                local magBG = str:match("from_magbg|([^|]*)")
                if magBG and tonumber(magBG) then
                    MainSettings.From.MagBG = tonumber(magBG)
                end
            end
            if str:find("from_vendx|") then
                local vendX = str:match("from_vendx|([^|]*)")
                if vendX and tonumber(vendX) then
                    MainSettings.From.VendPos[1] = tonumber(vendX)
                end
            end
            if str:find("from_vendy|") then
                local vendY = str:match("from_vendy|([^|]*)")
                if vendY and tonumber(vendY) then
                    MainSettings.From.VendPos[2] = tonumber(vendY)
                end
            end
            if str:find("to_magbg|") then
                local magBG = str:match("to_magbg|([^|]*)")
                if magBG and tonumber(magBG) then
                    MainSettings.To.MagBG = tonumber(magBG)
                end
            end
            if str:find("to_vendx|") then
                local vendX = str:match("to_vendx|([^|]*)")
                if vendX and tonumber(vendX) then
                    MainSettings.To.VendPos[1] = tonumber(vendX)
                end
            end
            if str:find("to_vendy|") then
                local vendY = str:match("to_vendy|([^|]*)")
                if vendY and tonumber(vendY) then
                    MainSettings.To.VendPos[2] = tonumber(vendY)
                end
            end
            if str:find("to_dropx|") then
                local dropX = str:match("to_dropx|([^|]*)")
                if dropX and tonumber(dropX) then
                    MainSettings.To.PosDrop[1] = tonumber(dropX)
                end
            end
            if str:find("to_dropy|") then
                local dropY = str:match("to_dropy|([^|]*)")
                if dropY and tonumber(dropY) then
                    MainSettings.To.PosDrop[2] = tonumber(dropY)
                end
            end
            if str:find("delay|") then
                local delay = str:match("delay|([^|]*)")
                if delay and tonumber(delay) then
                    MainSettings.Delay = tonumber(delay)
                end
            end
            
            -- Handle buttons
            if str:find("buttonClicked|main") then
                MainDialog()
                return true
            end
            
            Log("Advanced settings saved by icShark")
            return true
        elseif str:find("dialog_name|wtw_info") then
            -- Handle info dialog buttons
            if str:find("buttonClicked|main") then
                MainDialog()
                return true
            end
            return true
        end
    end
    
    return false
end)

-- [ MAIN SCRIPT LOOP ] --
-- Show initial dialog
MainDialog()

while true do
    Sleep(200)
    if ScriptRunning then
        drop_setting()
        vend_setting()
        mag_setting()
    end
end
