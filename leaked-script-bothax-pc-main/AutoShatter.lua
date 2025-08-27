local ID = {
  858,
  5746,
  460,
  4,
  6030,
  822,
  4634
}

ID1 = 858
ID2 = 5746
ID3 = 460
ID4 = 4
ID5 = 6030
ID6 = 822 
ID7 = 4634

R = 2242
G = 2244
B = 2246
W = 2248

AddHook("onsendpacket", "awzka?", function(type, packet)
  if packet:find("action|input\n|text|/1") then
    RunThread(function()
      posx = GetLocal().pos.x//32
      posy = GetLocal().pos.y//32
      Log("Making Crystal Gate")
      Sleep(500)
      raw(3, 0, R, posx, posy - 2)
      Sleep(150)
      raw(3, 0, R, posx, posy - 2)
      Sleep(150)
      raw(3, 0, R, posx, posy - 2)
      Sleep(150)
      raw(3, 0, B, posx, posy - 2)
      Sleep(150)
      raw(3, 0, W, posx, posy - 2)
      Sleep(300)
      shatter()
    end)
    return true
  end
  if packet:find("action|input\n|text|/2") then
    RunThread(function()
      posx = GetLocal().pos.x//32
      posy = GetLocal().pos.y//32
      Log("Making Shifty Block")
      Sleep(500)
      raw(3, 0, W, posx, posy - 2)
      Sleep(150)
      raw(3, 0, R, posx, posy - 2)
      Sleep(150)
      raw(3, 0, R, posx, posy - 2)
      Sleep(150)
      raw(3, 0, G, posx, posy - 2)
      Sleep(150)
      raw(3, 0, B, posx, posy - 2)
      Sleep(300)
      shatter()
    end)
    return true
  end
  return false
end)

function RunThread(task)
  co = coroutine.create(task)
  local status, result = coroutine.resume(co)
  if not status then
  		LogToConsole("Error running thread: " .. tostring(result))
  end
end

function Log(x)
		LogToConsole("`0[`cAwZka`0] "..x)
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

function find()
  for _, cr in pairs(ID) do
    local co = inv(cr)
    if co < 10 then
      SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. cr .. "|1")
      Sleep(300)
      return find()
    end
  end
end

local function split(inputstr, sep)
  t = {}
  for str in string.gmatch(inputstr, "([^".. sep .."]+)") do
    table.insert(t, str)
  end
  return t
end

function raw(t, s, v, x, y)
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

function shatter()
  find()
  Sleep(300)
  raw(0, 32, 0, posx, posy -2)
  Sleep(150)
  raw(3, 0, ID4, posx - 1, posy - 1)
  Sleep(150)
  raw(3, 0, ID1, posx, posy - 1)
  Sleep(150)
  raw(3, 0, ID6, posx, posy - 1)
  Sleep(150)
  raw(3, 0, ID7, posx + 1, posy -1)
  Sleep(150)
  raw(3, 0, ID2, posx + 1, posy -2)
  Sleep(150)
  raw(3, 0, ID6, posx + 1, posy -2)
  Sleep(150)
  raw(3, 0, ID2, posx + 1, posy -3)
  Sleep(150)
  raw(3, 0, ID6, posx + 1, posy -3)
  Sleep(150)
  raw(3, 0, ID4, posx, posy -3)
  Sleep(150)
  raw(3, 0, ID6, posx, posy -3)
  Sleep(150)
  raw(3, 0, ID3, posx - 1, posy -3)
  Sleep(150)
  raw(3, 0, ID6, posx - 1, posy -3)
  Sleep(150)
  raw(3, 0, ID3, posx - 1, posy - 2)
  Sleep(150)
  raw(3, 0, ID5, posx -1, posy -2)
  Sleep(150)
  raw(3, 0, 18, posx, posy -2)
  Sleep(150)
end

