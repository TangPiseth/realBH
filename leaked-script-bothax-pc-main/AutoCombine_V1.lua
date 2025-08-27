local Mooncakes = {1828, 1096, 1098}
local Songpyeon = 1056
local DropPos = {27, 50}
local Combiner = {21, 53}
local Delay = 500
local Direction = "Right" -- Left or Right

function Punch()
    h = {}
    h.type = 3
    h.px = GetLocal().pos.x // 32 + ((Direction == "Right") and 1 or -1)
    h.py = GetLocal().pos.y // 32
    h.value = 18
    h.x = GetLocal().pos.x
    h.y = GetLocal().pos.y
    SendPacketRaw(false, h)
end

function GetItemCount(id)
    for _, itm in pairs(GetInventory()) do
        if itm.id == id then
            return itm.amount
        end
    end
    return 0
end

function move(tx, ty)
  local function dir(a, b) return (b - a) / math.max(1, math.abs(b - a)) end
  local function ease(t) return t * t * (3 - 2 * t) end  

  while true do
    local p = GetLocal().pos
    local x, y = p.x // 32, p.y // 32
    if x == tx and y == ty then break end

    local nx, ny = x + dir(x, tx), y + dir(y, ty)
    FindPath(nx, ny)
    Sleep(30 + ease(math.abs(nx - tx + ny - ty)) * 20)
  end
end

function GetDropped()
    for _, id in pairs(Mooncakes) do
        if GetItemCount(id) < 100 then
            for _, obj in pairs(GetObjectList()) do
                if obj.id == id then
                    move(obj.pos.x // 32, obj.pos.y // 32)
                    Sleep(Delay)
                    return GetDropped()
                end
            end
        end
    end
end

function DropMooncakes()
  for _, id in pairs(Mooncakes) do
    local count = GetItemCount(id)
    if count > 100 then
      SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. id .. "|\nitem_count|" .. count)
      Sleep(Delay)
    end
  end
end

function Main()
    move(Combiner[1], Combiner[2])
    Sleep(Delay)
    DropMooncakes()
    Sleep(Delay)
    Punch()
    Sleep(500)
    Punch()
    Sleep(500)
    FindPath(Combiner[1] + ((Direction == "Right") and 1 or -1), Combiner[2])
    Sleep(1000)
    FindPath(DropPos[1], DropPos[2])
    Sleep(600)
    SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..Songpyeon.."|\nitem_count|" .. GetItemCount(1056))
    Sleep(Delay)
end

while true do
    GetDropped()
    Sleep(700)
    Main()
end
