Toool = { 1270, 1240, 1256, 1258, 1260, 1262, 1264, 1266, 1268 }

function Trash(ID)
  SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|"..ID.. "|\nitem_count|".. inv(ID) - 80 .."\n")
end

function BuyPack()
  for _, to in pairs(Toool) do
    local co = inv(to)
    if t and co > 240 then
      Sleep(200)
      Trash(to)
      Sleep(500)
      return BuyPack()
    end
  end
  for _, t0 in pairs(Toool) do
    if inv(t0) < 150 then
      SendPacket(2, "action|buy\nitem|buy_surgkit")
      Sleep(75)
      return BuyPack()
    end
  end
end

function auto()
	if tool == "Sponge" then
		tools = "command_0"
	elseif tool == "Scalpel" then
		tools = "command_1"
	elseif tool == "Anesthetic" then
		tools = "command_2"
	elseif tool == "Antiseptic" then
		tools = "command_3"
	elseif tool == "Antibiotics" then
		tools = "command_4"
	elseif tool == "Splint" then
		tools = "command_5"
	elseif tool == "Stitches" then
		tools = "command_6"
	elseif tool == "Fix It!" then
		tools = "command_7"
	end
	SendPacket(2, "action|dialog_return\ndialog_name|surgery\nbuttonClicked|" .. tools)
	LogToConsole("`9[`cAwZka`9] `0Used `2" .. tool)
end

local function split(inputstr, sep)
  t = {}
  for str in string.gmatch(inputstr, "([^".. sep .."]+)") do
    table.insert(t, str)
  end
  return t
end

function cleanNickname(nickname)
    nickname = nickname:gsub("[%d+_`#w@]", "")
    nickname = nickname:gsub("%[.-%]", "")
    nickname = nickname:match("^%s*(.-)%s*$")  
    return nickname
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

function RunThread(task)
  co = coroutine.create(task)
  local status, result = coroutine.resume(co)
  if not status then
  		LogToConsole("Error running thread: " .. tostring(result))
  end
end

AddHook("onsendpacket", "awzka?", function(type, packet)
  if packet:find("action|input\n|text|/bp") then
    Log("Buying Surgical Pack...")
    t = true
    return true
  end   
  if packet:find("action|wrench\n|netid|(%d+)") then
    surgid = packet:match("action|wrench\n|netid|(%d+)")
    SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|" .. surgid .. "|\nbuttonClicked|surgery")
    surging = true
    return true
  end
  return false
end)

AddHook("OnVariant", "Lant", function(var)
  if var[0] == "OnNameChanged" then
    j = cleanNickname(var[1])
    if j == cleanNickname(GetLocal().name) then
      mvp = true
    end
  end
  if var[0] == "OnConsoleMessage" and var[1]:find("You are not") then
    RunThread(function()
      Sleep(500)
      Log("Failed Kontol")
      if mvp then
        SendPacket(2, "action|input\n|text|/modage 999")
      elseif not mvp then
        Raw(10, 0, 3172, 0, 0)
      end
      surging = false
      Sleep(2000)
    end)
    return true
  elseif var[0] == "OnDialogRequest" and var[1]:find("Anatomical") then
    x = var[1]:match("|x|(%d+)")
    y = var[1]:match("|y|(%d+)")
    SendPacket(2, "action|dialog_return\n|dialog_name|surge_edit\nx|" .. x .. "|\ny|" .. y .. "|")
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("`4You can't see what you are doing(!+)") and var[1]:find("command_0") then
    tool = "Sponge"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("`6It is becoming hard to see your work(.+)") and var[1]:find("command_0") then
    tool = "Sponge"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient's fever is `3slowly rising") and var[1]:find("command_4") then
    tool = "Antibiotics"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient's fever is `6climbing") and var[1]:find("command_4") then
    tool = "Antibiotics"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Incisions: `60") and var[1]:find("command_7") then
    tool = "Fix It!"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Incisions: `30") and var[1]:find("command_7") then
    tool = "Fix It!"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("command_7") then
    tool = "Fix It!"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Operation site: `4Unsanitary") and var[1]:find("command_3") then
    tool = "Antiseptic"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Status: `4Awake!") and var[1]:find("command_2") then
    tool = "Anesthetic"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient is losing blood `4very quickly!") and var[1]:find("command_6") then
    tool = "Stitches"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient is losing blood `3slowly") and var[1]:find("command_6") then
    tool = "Stitches"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("Patient is `6losing blood!") and var[1]:find("command_6") then
    tool = "Stitches"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("command_7") and var[1]:find("command_6") then
    tool = "Stitches"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("command_7") and var[1]:find("Incisions: 0") then
    tool = "Stitches"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("command_7") and var[1]:find("command_1") then
    tool = "Scalpel"
    auto()
    return true
  elseif var[0]:find("OnDialogRequest") and var[1]:find("command_1") then
    tool = "Scalpel"
    auto()
    return true
  end
  if var[0] == "OnTalkBubble" and var[1] == GetLocal().netid then
    LogToConsole("Haha")
    surging = false
    Totalsurg = (Totalsurg or 0) + 1
    Log(""..Totalsurg)
    return true
  end
  return false
end)

surging = false
t = false
while true do
  Sleep(1000)
  if inv(1270) < 40 and not surging or t then
    BuyPack()
    t = false
  end
  
  if not surging and surgid then
    SendPacket(2, "action|dialog_return\ndialog_name|popup\nnetID|"..surgid.."|\nbuttonClicked|surgery")
    surging = true
  end
end
