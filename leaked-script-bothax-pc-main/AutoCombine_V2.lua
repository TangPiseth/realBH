local Recipes = {1828, 1096, 1098}
local Item = 1056
local DropPos = {27, 24}
local Delay = 500
function Punch()
    ch()
    h = {}
    h.type = 3
    h.px = GetLocal().pos.x // 32 + ((Direction == "Right") and 1 or -1)
    h.py = GetLocal().pos.y // 32
    h.value = 18
    h.x = GetLocal().pos.x
    h.y = GetLocal().pos.y
    SendPacketRaw(false, h)
    ch()
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

function Reconnect()
    LogToConsole("Disconnected or moved... reconnecting!")
    SendPacket(3, "action|join_request\nname|" .. World)
    Sleep(3000)
    while GetWorld() == nil or GetWorld().name:lower() ~= World:lower() do
        Sleep(1000)
        SendPacket(3, "action|join_request\nname|" .. World)
    end
    LogToConsole("Reconnected to " .. World)
end

function GetItemCount(id)
    for _, itm in pairs(GetInventory()) do
        if itm.id == id then
            return itm.amount
        end
    end
    return 0
end

function GetDroppedCount(x, y)
    for _, obj in pairs(GetObjectList()) do
        if (obj.pos.x // 32 == x) and (obj.pos.y // 32 == y) then
            return obj.amount
        end
    end
    return 0
end

function Dropp()
    for i = 1, 12 do
        ch()
        if GetItemCount(Item) >= 250 then
            SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..Item.."|\nitem_count|" .. GetItemCount(Item))
            Sleep(400)
        end
    end
    
    if GetItemCount(Item) >= 250 then
        dropy = dropy - 1
        Sleep(500)
        Raw(0, (Direction == "Right" and 32 or 48), 0, dropx, dropy)
        Sleep(300)
        SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|"..Item.."|\nitem_count|" .. GetItemCount(Item))
    end
end

function move(tx, ty)
  local function dir(a, b) return (b - a) / math.max(1, math.abs(b - a)) end
  local function ease(t) return t * t * (3 - 2 * t) end  

  while true do
    ch()
    local p = GetLocal().pos
    local x, y = p.x // 32, p.y // 32
    if x == tx and y == ty then break end

    local nx, ny = x + dir(x, tx), y + dir(y, ty)
    FindPath(nx, ny)
    Sleep(30 + ease(math.abs(nx - tx + ny - ty)) * 20)
  end
end

function GetDropped()
    for _, id in pairs(Recipes) do
        ch()
        if GetItemCount(id) < 100 then
            for _, obj in pairs(GetObjectList()) do
                ch()
                if obj.id == id then
                    ch()
                    move(obj.pos.x // 32, obj.pos.y // 32)
                    Sleep(Delay)
                    return GetDropped()
                end
            end
        end
    end
end

function DropRecipes()
  for _, id in pairs(Recipes) do
    local count = GetItemCount(id)
    if count > 100 then
      SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. id .. "|\nitem_count|" .. count)
      Sleep(Delay)
    end
  end
end

function ch()
    if GetWorld() == nil or GetWorld().name:lower() ~= World:lower() then
        Reconnect()
    end
end

World = GetWorld().name
dropx, dropy = DropPos[1], DropPos[2]
Direction = (GetLocal().isleft and "Left" or "Right")
Player = {GetLocal().pos.x // 32, GetLocal().pos.y // 32}
Combiner = {GetLocal().pos.x // 32 + (Direction == "Right" and 1 or -1), GetLocal().pos.y // 32}

function Main()
    ch()
    move(Player[1], Player[2])
    Sleep(Delay)
    DropRecipes()
    Sleep(Delay)
    Punch()
    Sleep(500)
    Punch()
    Sleep(500)
    FindPath(Combiner[1], Combiner[2])
    Sleep(1000)
    move(dropx, dropy)
    Sleep(500)
    Dropp()
end

while true do
    ch()
    GetDropped()
    Sleep(700)
    Main()
end
