DropPos = {
  94, 53 -- ( X, Y ) --
}

World = GetWorld().name
posx = GetLocal().pos.x // 32
posy = GetLocal().pos.y // 32

ingredients = { 4602, 962, 3472, 4570, 4568, 4588 } 

local ovenid = {
    [952] = true,
    [4498] = true,
    [4618] = true,
    [4620] = true,
    [8586] = true,
    [8938] = true,
    [10820] = true
}

function Drop(id)
  SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. id .. "|\nitem_count|250")
end

function Open(x, y, z, t)
  SendPacket(2, "action|dialog_return\ndialog_name|homeoven_edit\nx|"..x.."|\ny|"..y.."|\ncookthis|"..z.."|\nbuttonClicked|"..t)
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


function GetOven()
  local found = {}
  local pos = {GetLocal().pos.x // 32, GetLocal().pos.y // 32}
  for y = pos[2] - 4, pos[2] + 4 do
    for x = pos[1] - 4, pos[1] + 4 do
      local tile = GetTile(x, y)
      if tile and ovenid[tile.fg] then
        table.insert(found, {x, y})
        if #found >= 50 then
          return found
        end
      end
    end
  end
  return found
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

function GetDropped()
  for _, id in pairs(ingredients) do
    if inv(id) < 100 then
      for _, obj in pairs(GetObjectList()) do
        if obj.id == id then
          move(obj.pos.x // 32, obj.pos.y // 32)
          Sleep(300)
          return GetDropped()
        end
      end
    end
  end
end
 
function DropArroz()
  for attempts = 1, 24 do
    if inv(4604) >= 250 then
      Log("Dropping Arroz Attempt: ["..attempts.." / 24]")
      Drop(4604)
      Sleep(400)
    else
      return
    end
  end
  if inv(4604) >= 250 then
    DropPos[2] = DropPos[2] - 1
    move(DropPos[1], DropPos[2])
    Sleep(400)
    Drop(4604)
    return
  end
end

Oven = GetOven()


function PlaceIngredient(id, delay)
  for _, ov in pairs(Oven) do
    if GetWorld() == nil or GetWorld().name ~= World then
      return
    else
      Raw(3, 0, id, ov[1], ov[2])
      Sleep(delay or 300)
    end
  end
end

function Place2Ingredient(id, id2, delay)
  for _, ov in pairs(Oven) do
    if GetWorld() == nil or GetWorld().name ~= World then
      return
    else
      Raw(3, 0, id, ov[1], ov[2])
      Sleep(delay or 150)
      Raw(3, 0, id2, ov[1], ov[2])
      Sleep(300)
    end
  end
end

function Rice()
  for _, ov in pairs(Oven) do
    if GetWorld() == nil or GetWorld().name ~= World then
      return
    else
      Open(ov[1], ov[2], 3472, "low")
      Sleep(300)
    end
  end
end

function Main()
  if GetWorld() == nil or GetWorld().name ~= World then
    return
  else
    Rice()
    PlaceIngredient(4568, 300)
    Sleep(((33700-(#Oven*300))/1) - (#Oven*300))
    
    Place2Ingredient(4602, 4588, 150)
    PlaceIngredient(4570, 300)
    Sleep(((36300-(#Oven*300))/1) - (#Oven*300))

    PlaceIngredient(962, 300)
    PlaceIngredient(4570, 300)
    Sleep(((30000-(#Oven*300))/1) - (#Oven*300))
    
    PlaceIngredient(18, 300)
  end
end

function Log(x)
		LogToConsole("`0[`cAwZka`0] [`cSTATUS`0] "..x)
end

function Join(w)
		SendPacket(3, "action|join_request\nname|".. w .."|\ninvitedWorld|0")
end
dc = false

while true do
  Sleep(3000)
  if GetWorld() == nil or GetWorld().name ~= World then
    Log("Disconnected!? Trying to reconnect..")
    Join(World)
    Sleep(5000)
    dc = true
  end
  if inv(4604) >= 250 then
    move(DropPos[1], DropPos[2])
    Sleep(500)
    DropArroz()
    Sleep(500)
  end
  for _, ing in pairs(ingredients) do
    local co = inv(ing)
    if co < 100 then
      GetDropped()
    end
  end
  if dc then
    PlaceIngredient(18, 300)
    Sleep(500)
    dc = false
  end
  if GetLocal().pos.x // 32 ~= posx and GetLocal().pos.y // 32 ~= posy then
    move(posx, posy)
    Sleep(500)
  end
  Main()
end
