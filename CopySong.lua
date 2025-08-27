WORLD_COPY = "FILAS4"
WORLD_PASTE = "DESIGNZANGH"
debugStore = "buy_composerspack"


x, y = 99, 53
local sheets = {
    412, 413, 414, 415, 416, 417, 418, 419,
    420, 421, 422, 423, 424, 425, 426, 427,
    4192, 4193, 4634, 4635, 4636, 4637, 4638, 4639,
    4640, 4641, 4642, 4643, 5370, 5371, 5726, 5727,
    5728, 5729, 5730, 5731, 6030, 6031, 6032, 6033,
    6034, 6035, 6808, 6809, 6810, 6811, 6812, 6813,
    7218, 7219, 7220, 7221, 7222, 7223, 10528, 10529,
    10530, 10531, 10532, 10533, 10828, 10829, 10830, 10831,
    10832, 10833
}

function trs(ID)
		SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|"..ID.. "|\nitem_count|50\n")
end

function trash()
  for _, item in pairs(sheets) do
    if inv(item) > 0 then
      trs(item)
      Sleep(200)
    end
  end
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

function inv(x)
  for _, itm in pairs(GetInventory()) do
    if itm.id == x then
      return itm.amount
    end
  end
return 0
end


function join(x)
  SendPacket(3, "action|join_request\nname|".. x .."|\ninvitedWorld|0")
end


function pt(x, y)
  plx, ply = GetLocal().pos.x // 32, GetLocal().pos.y // 32
    while plx ~= x or ply ~= y do
        if plx > x then
            plx = plx - 6
            if plx <= x then
                plx = x
            end
        elseif plx < x then
            plx = plx + 6
            if plx >= x then
                plx = x 
            end
        end
        if ply > y then
            ply = ply - 6
            if ply <= y then
                ply = y
            end
        elseif ply < y then
            ply = ply + 6
            if ply >= y then
                ply = y
            end
        end
        FindPath(plx, ply)
        Sleep(120)
    end
    Sleep(50)
end

function c()
  b = {}
  local l = {}
		for _, id in pairs(sheets) do
    l[id] = true
  end
  for d = 0, y do
    for c = 0, x do
      e = GetTile(c, d)
      if (e.fg ~= 0) and (e.fg ~= 6) and (e.fg ~= 8) and (e.fg ~= 422) and (e.fg ~= 242) and (e.fg ~= 1769) and (e.fg ~= 7188) then
      else
        if l[e.bg] then 
          table.insert(b, {g = e.bg, x = c, y = d})
        end
      end
    end
  end
end

function p()
  n = 0
  for _, z in pairs(b) do
    if inv(z.g) > 0 then
      e = GetTile(z.x, z.y)
      if (e.fg ~= z.g and e.bg ~= z.g) then
        n = n + 1
        pt(z.x, z.y + 1)
        Sleep(250) 
        raw(3, 0, z.g, z.x, z.y)
        Sleep(250) 
      end
    elseif inv(z.g) < 2 then
       trash()
      SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. z.g .. "|1")
      Sleep(500)
      for i = 0, 7 do
        SendPacket(2, "action|buy\nitem|".. debugStore)
        Sleep(300)
      end
    end
    if n == #b then
      LogToConsole("Finished! SC Leaked by AwZka")
      break
    end
  end
end

while true do
  join(WORLD_COPY) 
  Sleep(3000) 
  c()
  join(WORLD_PASTE)
  Sleep(3000)
  p()
end
