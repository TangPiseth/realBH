--[COOK ARROZ VIP BOOLUA BOTHAX ANDROID]

--[Enable ModFly on Mod Menu]
--[Disable /ghost]
--[80 Oven]

--[Oven ItemID]
OvenID = 4498

--[Coordinate XY Drop Arroz]
ArrozDropX, ArrozDropY = 66, 50

--[Delay Enter World][milisecon]
DelayEntering = 5000

--[Webhook Cook][true/false]
--[Enable MakeRequest & os Bothax API for Webhook Cook]
WebhookCook = true
WebhookLink = "https://discord.com/api/webhooks/1350709151872843786/3i4sNv53QNEuStA-Odt8-PSLcO8oFUCLA5iddG8OvTDDnfOmhtNLhWO_jf1_zRNUHZHP"
DiscordID = 1094219942309666860

--[New Version Bothax Android][true/false][beta]
NewVersionBothax = true



WorldName = GetWorld().name or "Unknown"
ArrozDropX = ArrozDropX > 0 and ArrozDropX - 1 or ArrozDropX
Nick = GetLocal().name:gsub("`(%S)", ""):match("%S+")
CookItems = {
  962,
  3472,
  4602,
  4568,
  4570,
  4588
}
StartTime = os and os.time() or 0
StartDropX = ArrozDropX
SArroz, FArroz = 0, 0
Mid = 41
CountObject = {
  [962] = 0,
  [3472] = 0,
  [4568] = 0,
  [4570] = 0,
  [4574] = 0,
  [4576] = 0,
  [4588] = 0,
  [4602] = 0,
  [4604] = 0
}
CountItem = {
  [962] = 0,
  [3472] = 0,
  [4568] = 0,
  [4570] = 0,
  [4574] = 0,
  [4576] = 0,
  [4588] = 0,
  [4602] = 0,
  [4604] = 0
}

function TextOverlay(text)
  if NewVersionBothax then
    SendVariantList({
      [0] = "OnTextOverlay",
      [1] = text
    })
  else
    SendVariant({
      [0] = "OnTextOverlay",
      [1] = text
    })
  end
end

function SendWebhook(url, data)
  if NewVersionBothax then
    MakeRequest(url, "POST", {
      ["Content-Type"] = "application/json"
    }, data)
  else
    MakeRequests(url, "POST", {
      ["Content-Type"] = "application/json"
    }, data)
  end
end

function FPath(x, y, delay)
  DistX = x - iX
  DistY = y - iY
  if DistY > 6 then
    for i = 1, math.floor(DistY / 6) do
      iY = iY + 6
      FindPath(iX, iY, delay)
      Sleep(delay)
    end
  elseif DistY < -6 then
    for i = 1, math.floor(DistY / -6) do
      iY = iY - 6
      FindPath(iX, iY, delay)
      Sleep(delay)
    end
  end
  if DistX > 6 then
    for i = 1, math.floor(DistX / 6) do
      iX = iX + 6
      FindPath(iX, iY, delay)
      Sleep(delay)
    end
  elseif DistX < -6 then
    for i = 1, math.floor(DistX / -6) do
      iX = iX - 6
      FindPath(iX, iY, delay)
      Sleep(delay)
    end
  end
  iX, iY = x, y
  FindPath(x, y, delay)
  Sleep(delay)
end

function CheckInv()
  for id in pairs(CountItem) do
    CountItem[id] = 0
  end
  if pcall(GetTile) then
    return
  else
    for _, item in pairs(GetInventory()) do
      CountItem[item.id] = item.amount
    end
  end
  Pepper = CountItem[4570]
  Tomato = CountItem[962]
  Bland = CountItem[4576]
  CMeat = CountItem[4588]
  Arroz = CountItem[4604]
  Onion = CountItem[4602]
  Rice = CountItem[3472]
  Salt = CountItem[4568]
  Mess = CountItem[4574]
  Sleep(1000)
end

function CheckObjects()
  for id in pairs(CountObject) do
    CountObject[id] = 0
  end
  if pcall(GetTile) then
    return
  else
    for _, obj in pairs(GetObjectList()) do
      if CountObject[obj.id] then
        CountObject[obj.id] = CountObject[obj.id] + obj.amount
      else
        CountObject[obj.id] = 0
      end
    end
  end
  DPepper = CountObject[4570]
  DTomato = CountObject[962]
  DBland = CountObject[4576]
  DCMeat = CountObject[4588]
  DArroz = CountObject[4604]
  DOnion = CountObject[4602]
  DRice = CountObject[3472]
  DSalt = CountObject[4568]
  DMess = CountObject[4574]
end

function FTime(sec)
  days = math.floor(sec / 86400)
  hours = math.floor(sec % 86400 / 3600)
  minutes = math.floor(sec % 3600 / 60)
  seconds = math.floor(sec % 60)
  if days > 0 then
    return string.format("%sd %sh %sm %ss", days, hours, minutes, seconds)
  elseif hours > 0 then
    return string.format("%sh %sm %ss", hours, minutes, seconds)
  elseif minutes > 0 then
    return string.format("%sm %ss", minutes, seconds)
  elseif seconds >= 0 then
    return string.format("%ss", seconds)
  end
end

function GetOven(a, b)
  tiles = {}
  for y = 0, b do
    for x = 0, a do
      tl = GetTile(x, y)
      if tl and tl.fg == OvenID then
        table.insert(tiles, {x = x, y = y})
      end
    end
  end
  return tiles
end

if GetTile(209, 0) then
  Oven = GetOven(209, 209)
elseif GetTile(199, 0) then
  Oven = GetOven(199, 199)
elseif GetTile(149, 0) then
  Oven = GetOven(149, 149)
elseif GetTile(99, 0) then
  Oven = GetOven(99, 59)
elseif GetTile(29, 0) then
  Oven = GetOven(29, 29)
end

function Place(x, y, id)
  SendPacketRaw(false, {
    type = 3,
    value = id,
    px = x,
    py = y,
    x = x * 32,
    y = y * 32
  })
end

function GetItems()
  if pcall(GetTile) then
    return
  else
    CheckInv()
    if Rice < 81 or Tomato < 81 or Onion < 81 or CMeat < 81 or Salt < 81 or Pepper < 162 then
      FoundObject = {}
      for _, obj in pairs(GetObjectList()) do
        if not FoundObject[obj.id] then
          for _, item in ipairs(CookItems) do
            if obj.id == item then
              if pcall(GetTile) then
                return
              else
                CheckInv()
                FPath(math.floor(obj.pos.x / 32), math.floor(obj.pos.y / 32), 250)
                Sleep(2000)
                if CountItem[item] == 250 then
                  FoundObject[obj.id] = true
                  break
                end
              end
            end
          end
        end
      end
    end
  end
end

function TrashItems()
  if pcall(GetTile) then
    return
  else
    CheckInv()
    if Mess > 0 or Bland > 0 then
      SendPacket(2, [[
action|dialog_return
dialog_name|trash
item_trash|4574|
item_count|]] .. Mess)
      FArroz = FArroz + Mess
      Sleep(200)
      SendPacket(2, [[
action|dialog_return
dialog_name|trash
item_trash|4576|
item_count|]] .. Bland)
      FArroz = FArroz + Bland
      Sleep(200)
    end
  end
end

function DropArroz()
  if pcall(GetTile) then
    return
  else
    CheckInv()
    if Arroz >= 169 then
      FPath(ArrozDropX, ArrozDropY, 250)
      Sleep(2000)
      SendPacket(2, [[
action|dialog_return
dialog_name|drop
item_drop|4604|
item_count|]] .. Arroz)
      SArroz = SArroz + Arroz
      Sleep(5000)
      if pcall(GetTile) then
        return
      else
        CheckInv()
        if Arroz >= 169 then
          ArrozDropX = ArrozDropX - 1
          ArrozDropX = ArrozDropX >= 0 and ArrozDropX or StartDropX
          FPath(ArrozDropX, ArrozDropY, 250)
          Sleep(2000)
          SendPacket(2, [[
action|dialog_return
dialog_name|drop
item_drop|4604|
item_count|]] .. Arroz)
          SArroz = SArroz + Arroz
          Sleep(1000)
        end
      end
    end
    if WebhookCook then
      if pcall(GetTile) then
        return
      else
        math.randomseed(os.time())
        CheckObjects()
        Payload = [[
					{
						"embeds": [{
							"author": {"name": "COOK ARROZ VIP BOTHAX ANDROID", "icon_url": "https://i.imgur.com/EVbdcT3.png"},
							"fields": [
								{"name": ":identification_card: Account", "value": "]] .. Nick .. [[
", "inline": true},
								{"name": ":earth_asia: World", "value": "]] .. WorldName .. [[
", "inline": true},
								{"name": ":poultry_leg: Arroz", "value": "Dropped : ]] .. DArroz .. "\\nSuccess : " .. SArroz .. "\\nFailed : " .. FArroz .. [[
", "inline": true},
								{"name": ":salad: Dropped Ingredients", "value": "C. Meat : ]] .. DCMeat .. "\\nTomato : " .. DTomato .. "\\nPepper : " .. DPepper .. "\\nOnion : " .. DOnion .. "\\nRice : " .. DRice .. "\\nSalt : " .. DSalt .. [[
", "inline": true}],
							"footer": {"text": "Uptime : ]] .. FTime(os.time() - StartTime) .. [[
"},
							"color": ]] .. math.random(0, 16777215) .. [[
						}]
					}
				]]
        SendWebhook(WebhookLink, Payload)
      end
    end
  end
end

function Cook()
  if pcall(GetTile) then
    return
  else
    CheckInv()
    if Rice >= 81 and Tomato >= 81 and Onion >= 81 and CMeat >= 81 and Salt >= 81 and Pepper >= 162 then
      FPath(Oven[Mid].x, Oven[Mid].y, 250)
      Sleep(2000)
      for _, tile in pairs(Oven) do
        if pcall(GetTile) then
          return
        else
          SendPacket(2, [[
action|dialog_return
dialog_name|homeoven_edit
x|]] .. tile.x .. [[
|
y|]] .. tile.y .. [[
|
cookthis|3472|
buttonClicked|low
]])
          Sleep(175)
        end
      end
      for _, tile in pairs(Oven) do
        if pcall(GetTile) then
          return
        else
          Place(tile.x, tile.y, 4570)
          Sleep(175)
        end
      end
      for _, tile in pairs(Oven) do
        if pcall(GetTile) then
          return
        else
          Place(tile.x, tile.y, 4602)
          Sleep(175)
          Place(tile.x, tile.y, 4588)
          Sleep(175)
        end
      end
      for _, tile in pairs(Oven) do
        if pcall(GetTile) then
          return
        else
          Place(tile.x, tile.y, 4570)
          Sleep(175)
        end
      end
      Sleep(3900)
      for _, tile in pairs(Oven) do
        if pcall(GetTile) then
          return
        else
          Place(tile.x, tile.y, 962)
          Sleep(175)
        end
      end
      for _, tile in pairs(Oven) do
        if pcall(GetTile) then
          return
        else
          Place(tile.x, tile.y, 4568)
          Sleep(175)
        end
      end
      for i = 1, 2 do
        for _, tile in pairs(Oven) do
          if pcall(GetTile) then
            return
          else
            Place(tile.x, tile.y, 18)
            Sleep(175)
          end
        end
      end
    end
  end
end

function Reset()
  ResetCook = false
  FPath(Oven[Mid].x, Oven[Mid].y, 250)
  Sleep(2000)
  for i = 1, 2 do
    for _, tile in pairs(Oven) do
      if pcall(GetTile) then
        return
      else
        Place(tile.x, tile.y, 18)
        Sleep(175)
      end
    end
  end
end

function Loop()
  if pcall(GetTile) then
    return
  else
    GetItems()
  end
  Sleep(500)
  if pcall(GetTile) then
    return
  else
    TrashItems()
  end
  Sleep(500)
  if pcall(GetTile) then
    return
  else
    DropArroz()
  end
  Sleep(500)
  if pcall(GetTile) then
    return
  elseif ResetCook then
    Reset()
  end
  Sleep(500)
  if pcall(GetTile) then
    return
  else
    Cook()
  end
end

function dialog(teks)
  Var0 = "OnDialogRequest"
  Var1 = [[
add_label_with_icon|big|`2PTHT VIP BooLua||7064|
add_spacer|small|
add_textbox|]] .. GetLocal().name:match("%S+") .. [[
||
add_textbox|]] .. teks .. [[
||
add_spacer|small|
add_smalltext|`9BooLua SC! Join now!|
add_url_button||`qDiscord|NOFLAGS|https://discord.gg/Any9dcWNwE|`$BooLua SC.|0|0|
add_quick_exit|]]
  if NewVersionBothax then
    SendVariantList({
      [0] = Var0,
      [1] = Var1
    })
  else
    SendVariant({
      [0] = Var0,
      [1] = Var1
    })
  end
end

if os or not WebhookCook then
  Sleep(1000)
  SendPacket(3, [[
action|join_request
name|]] .. WorldName .. [[
|
invitedWorld|0]])
  Sleep(7000)
  dialog("`8Thanks for buy")
  ResX, ResY = math.floor(GetLocal().pos.x / 32), math.floor(GetLocal().pos.y / 32)
  iX, iY = ResX, ResY
  Sleep(1000)
  TrashItems()
  FArroz = 0
  Sleep(1000)
  ResetCook = true
  while true do
    if pcall(GetTile) then
      if WebhookCook then
        SendWebhook(WebhookLink, "{\"content\": \"<@" .. DiscordID .. "> " .. Nick .. " Cook Arroz Reconnecting...\"}")
      end
      ResetCook = true
      iX, iY = ResX, ResY
      SendPacket(3, [[
action|join_request
name|]] .. WorldName .. [[
|
invitedWorld|0]])
      TextOverlay("Entering World...")
      Sleep(DelayEntering)
    else
      Loop()
      Sleep(1000)
    end
  end
else
  dialog("`9Turn On API MakeRequest & os for Webhook Cook")
end
error("Powered by BooLua")
