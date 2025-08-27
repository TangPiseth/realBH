--[[
SCRIPT BY Lantaas#6854
Credit to somebody in serper bothek for webhook sample
Repost without credit? nub kodir
Selling free script? Haha nub kodir
]]


Config = {
  -- Pastikan berdiri di atas donation box
  
  myLink = "https://discord.com/api/webhooks/1359580327307251874/VfqwYAP4oQwcxW7bzNLoEZ8GbAS19h11Bn9ryHDo4QMbJpx3Yg14mMkmR3lyW8JjgOy6",
  -- Link webhook buat deposit log

  World_name = "ZANDL",
  -- Name deposit world
  
  Auto_cv = false, 
  -- Auto convert wl > dl, dl > bgl, bgl > blgl
  -- REQUIRED TELEPHONE ON TOP OF PLAYER
  
  Auto_bank = false,
  -- Auto deposit bgl into your bank
  
  Total_deposit = 6, 
  -- Total deposit for auto deposit bgl

  Delay_withdraw = 6000,
  -- Delay withdraw donation box
}

local function split(inputstr, sep) -- credit to AsleepDream
    t = {}
    for str in string.gmatch(inputstr, "([^".. sep .."]+)") do
        table.insert(t, str)
    end
    return t
end

local function H4h4(str) -- Credit AsleepDream
  str = str:gsub("``", ""):gsub("`.", ""):gsub("@", ""):gsub(" of Legend", ""):gsub("%[BOOST%]", "")
  str = str:gsub("%[ELITE%]", ""):gsub("`w", ""):gsub("receives", ""):gsub(", how nice!", "")
  return str
end

local px = GetLocal().pos.x // 32
local py = GetLocal().pos.y // 32 + 1
spam = false
start = false

function raw(type, state, value, x, y)
    SendPacketRaw(false, {
        type = type, 
        state = state,
        value = value,
        px = x,
        py = y,
        x = x * 32,
        y = y * 32
    })
end

function changedls()
  SendPacket(2,"action|dialog_return\ndialog_name|telephone\nnum|53785|\nx|".. GetLocal().pos.x // 32 .."|\ny|".. GetLocal().pos.y // 32 - 1 .."|\nbuttonClicked|bglconvert")
  Sleep(400)
end

function putbank()
  SendPacket(2, "action|dialog_return\ndialog_name|bank_deposit\nbgl_count|"..Config.Total_deposit)
  Sleep(500)
end

function withdraw(x, y)
  Sleep(450)
  raw(3, 0, 32, x, y)
  Sleep(550)
  SendPacket(2,"action|dialog_return\ndialog_name|donate_edit\nx|"..x.."|\ny|".. y .."|\nbuttonClicked|withdrawall")
end

function inv(id) 
  for _, itm in pairs(GetInventory()) do
    if itm.id == id then
      return itm.amount
    end
  end
  return 0
end


function processDonation(text)
  payment, Items, growID = text:match("(@?%d*)%s([%a%s]+)%s*from%s(.+)")

  local status
  if Items:match("World Lock") or Items:match("Diamond Lock") or Items:match("Blue Gem Lock") or Items:match("Black Gem Lock") then
    status = "Success"
  else
    status = "False"
  end

  local donationMessage = [[\nGrowID: ]] .. growID .. [[\nPayment: ]] .. payment .. [[ ]] .. Items .. [[\nStatus: ]] .. status

  return donationMessage
end

function SendWebhook(url, data)
  MakeRequest(url, "POST", {["Content-Type"] = "application/json"}, data)
end

AddHook("onvariant", "mommy", function(var)
  if var[0] == "OnConsoleMessage" and var[1]:find("Labtas(.+)") then
    local HAha = var[1]:match("Labtas(.+)")
    local HahA = H4h4(HAha)
    local donationMessage = processDonation(HahA)

    local myData = [[
    {
      "embeds": [{
        "title": "Donation Logs",
        "description": "]] .. donationMessage .. [[",
        "color": 16711680,
        "thumbnail": {
          "url": "https://img.freepik.com/free-vector/girl-with-red-eyes_603843-3008.jpg?w=1380&t=st=1681986430~exp=1681987030~hmac=3ae57ed66c3bab13fbcb1c16666f5f54851a1531e7157ba4db05dd27c4def09c"
        }
      }]
    }
    ]]
    SendWebhook(Config.myLink, myData)
    return true
  end
end)

ds = false

AddHook("onsendpacket", "lantas?", function(type, packet)
  args = split(packet:gsub("action|input\n|text|", ""), " ")
  cmd = string.lower(args[1])
  if cmd == "/cbgl" then
    ds = true
    return true
  elseif cmd == "/black" then
    SendPacket(2,"action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bgl")
    LogToConsole("Successfully change bgls to blgl")
    return true
  elseif cmd == "/blue" then
    SendPacket(2,"action|dialog_return\ndialog_name|info_box\nbuttonClicked|make_bluegl")
    LogToConsole("Successfully change blgl to bgls")
    return true
  end
  if cmd == "/cekdepo" then
    start = true
    LogToConsole("Checking donation box...")
    return true
  elseif cmd == "/stop" then
    start = false
    LogToConsole("Checking donation box stopped...")
    return true
  end
  return false
end)
    
    
  
local px = GetLocal().pos.x // 32 - 1
local py = GetLocal().pos.y // 32
local pyy = GetLocal().pos.y // 32 + 1
local dpx = GetLocal().pos.x // 32
while true do
  Sleep(500)
  if start then
    px = px + 1
    pxx = GetLocal().pos.x // 32
    if GetWorld().name ~= Config.World_name then
      SendPacket(3, "action|join_request\nname|" .. Config.World_name .. "|\ninvitedWorld|0")
      Sleep(5000)
    end
    FindPath(px, py)
    Sleep(500)
    withdraw(pxx, pyy)
    Sleep(Config.Delay_withdraw)
    if px == dpx + 5 then
      px = px - 6
    end
  end
  if Config.Auto_cv and inv(1796) >= 101 then
    changedls()
  end
  if Config.Auto_bank and inv(7188) >= Config.Total_deposit then
    putbank()
  end
  if ds then
    changedls()
    LogToConsole("Successfully change dls to bgl")
  end
end

  
