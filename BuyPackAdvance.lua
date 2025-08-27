Settings = {
  PackName = "buy_cookingpack",
  
  DropPos = {89, 53}, 
  
  TrashID = {
    4572, 956, 4562, 4564, 4578, 4586, 874, 868, 4766, 4676, 4666, 822, 4582, 4618
  },
  
  DropID = {
    4602, 962, 3472, 4570, 4568, 4588
  }, 
}

DropPosY = {}

function inv(id)
  local count = 0
  for _, itm in pairs(GetInventory()) do
    if itm.id == id then
      count = count + itm.amount
    end
  end
  return count
end

function trash(id)
  SendPacket(2, "action|dialog_return\ndialog_name|trash\nitem_trash|" .. id .. "|\nitem_count|" .. inv(id) .. "\n")
  Sleep(100)
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

function drop(id, i)
  if not DropPosY[i] then
    DropPosY[i] = Settings.DropPos[2]
  end
  for attempt = 1, 24 do
    if inv(id) >= 100 then
      LogToConsole("Dropping Attempts: "..attempt.." / 24")
      SendPacket(2, "action|dialog_return\ndialog_name|drop\nitem_drop|" .. id .. "|\nitem_count|" .. inv(id) .. "\n")
      Sleep(400)
    end
  end
  if inv(id) >= 100 then
    DropPosY[i] = DropPosY[i] - 1
  end
end

function DropPack()
  for i, id in ipairs(Settings.DropID) do
    if inv(id) >= 100 then
      local posx = Settings.DropPos[1] + (i - 1)
      local posy = DropPosY[i] or Settings.DropPos[2]
      move(posx - 1, posy) 
      Sleep(500)
      drop(id, i)
      Sleep(500)
    end
  end
end

while true do
  for _, id in pairs(Settings.DropID) do
    if inv(id) < 100 then
      SendPacket(2, "action|buy\nitem|"..Settings.PackName)
      Sleep(200)
    end
  end
  for _, id in pairs(Settings.TrashID) do
    if inv(id) >= 100 then
      trash(id)
      Sleep(200)
    end
  end
  if next(Settings.DropID) then
    DropPack()
    Sleep(200)
  end
end
