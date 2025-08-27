--[Use /ghost]

--[Seed ItemID]
SeedID = 15461

--[Background ID of Magplant]
MagBG = 284

--[Start Count PTHT][number]
StartCount = 0

--[Total PTHT][number]
TotalPTHT = 10

--[Coordinate Y Bottom Plant/Plat/Gate/Door]
PlantY = 192

--[Delay Enter World][Milisecon]
DelayEntering = 5000

--[Delay Harvest][Milisecon][Recommended 200+]
DelayHarvest = 200

--[Delay Plant][Milisecon][Recommended 80+].
DelayPlant = 80

--[Use Mray][true/false]
UseMRAY = true

--[Use UWS][true/false]
--[UseUWS = false for 2nd Acc]
UseUWS = true

--[Webhook PTHT][true/false]
--[Enable MakeRequest & os Bothax API for Webhook PTHT]
WebhookPTHT = true
WebhookLink = "https://discord.com/api/webhooks/1359946739242504342/0Oh53Dp8KFBEtGM0H7-q3VV-WS_vA1bC064VKMY4ZQhrMFfSOi3AznAA1g7EcksCEcx6"


PoweredBy = AwZka
WorldName = GetWorld().name or "Unknown"
TotalPTHT = UseUWS and TotalPTHT or true

function TextOverlay(text)
  SendVariantList({
    [0] = "OnTextOverlay",
    [1] = text
  })
end

PlantY = (0 == GetTile(20, 0 == PlantY % 2 and 20 or 21).fg or GetTile(20, 0 == PlantY % 2 and 20 or 21).fg == SeedID) and PlantY or PlantY - 1
Nick = GetLocal().name:gsub("`(%S)", ""):match("%S+")
StartY = 0 == PlantY % 2 and 0 or 1
StartTime = os and os.time() or 0
PlantFar = UseMRAY and 10 or 1
RemoteEmpty = true
PTHT = StartCount
Harvest = true
Plant = false
RemoveHooks()
SprayUWS = 0
Missed = 0
Now = 1
if GetTile(209, 0) then
  PlantX = 210
elseif GetTile(199, 0) then
  PlantX = 200
elseif GetTile(149, 0) then
  PlantX = 150
elseif GetTile(99, 0) then
  PlantX = 100
elseif GetTile(29, 0) then
  PlantX = 30
end
PlantX = UseUWS and PlantX - PlantFar or PlantX - 1
if #WebhookLink <= 30 then
  PublicWebhook = true
end
if PublicWebhook then
  WebhookLink = "https://discord.com/api/webhooks/1359946739242504342/0Oh53Dp8KFBEtGM0H7-q3VV-WS_vA1bC064VKMY4ZQhrMFfSOi3AznAA1g7EcksCEcx6"
end

function cen(text, n)
  return n < #text and string.rep("#", #text - n) .. string.sub(text, -n) or string.rep("#", #text)
end

function SendWebhook(url, data)
  MakeRequest(url, "POST", {
    ["Content-Type"] = "application/json"
  }, data)
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

function inv(id)
  for _, item in pairs(GetInventory()) do
    if item.id == id then
      return item.amount
    end
  end
  return 0
end

UWS = pcall(inv) and inv(12600) or 0

function GetTree(int)
  if int then
    TotalTree = 0
    for y = PlantY, StartY, -2 do
      for x = 0, PlantX, 10 do
        if GetTile(x, y).fg == SeedID and 1 == GetTile(x, y).extra.progress then
          TotalTree = TotalTree + 1
        end
      end
    end
    return TotalTree
  else
    TotalLand = 0
    for y = PlantY, StartY, -2 do
      for x = 0, PlantX, 10 do
        if 0 == GetTile(x, y).fg then
          TotalLand = TotalLand + 1
        end
      end
    end
    return TotalLand
  end
end

function GetMag(a, b)
  tile = {}
  for y = 0, b do
    for x = 0, a do
      if GetTile(x, y).fg == 5638 and GetTile(x, y).bg == MagBG then
        table.insert(tile, {x = x, y = y})
      end
    end
  end
  return tile
end

if GetTile(209, 0) then
  Mag = GetMag(209, 209)
elseif GetTile(199, 0) then
  Mag = GetMag(199, 199)
elseif GetTile(149, 0) then
  Mag = GetMag(149, 149)
elseif GetTile(99, 0) then
  Mag = GetMag(99, 59)
elseif GetTile(29, 0) then
  Mag = GetMag(29, 29)
end

function Scanning()
  if Plant then
    Plant = false
    if GetTree(false) <= 100 then
      SprayUWS = SprayUWS + 1
      if UseUWS then
        TextOverlay("`2" .. SprayUWS .. " `wUWS Used")
        SendPacket(2, [[
action|dialog_return
dialog_name|ultraworldspray]])
      end
      Sleep(8000)
      TextOverlay("Harvesting...")
      Harvest = true
    else
      TextOverlay("Checking Land...")
      Plant = true
    end
    Sleep(2000)
  elseif Harvest then
    Harvest = false
    if 0 == GetTree(true) then
      TextOverlay("Planting...")
      Plant = true
    else
      TextOverlay("Checking Tree...")
      Harvest = true
    end
    Sleep(2000)
  end
end

function GetRemote()
  SendPacketRaw(false, {
    px = Mag[Now].x,
    py = Mag[Now].y,
    x = Mag[Now].x * 32,
    y = Mag[Now].y * 32
  })
  Sleep(500)
  SendPacketRaw(false, {
    type = 3,
    value = 32,
    px = Mag[Now].x,
    py = Mag[Now].y,
    x = Mag[Now].x * 32,
    y = Mag[Now].y * 32
  })
  Sleep(500)
  SendPacket(2, [[
action|dialog_return
dialog_name|magplant_edit
x|]] .. Mag[Now].x .. [[
|
y|]] .. Mag[Now].y .. [[
|
buttonClicked|getRemote]])
  Sleep(5000)
end

function Loop()
  if UseUWS then
    for x = 0, PlantX, PlantFar do
      if pcall(GetTile) or RemoteEmpty then
        return
      else
        LogToConsole("`c[AwZka] `2" .. (Plant and "Planting `9" .. math.floor(x / PlantX * 100) .. "`5%" or "Harvesting..."))
        for i = 1, 2 do
          if pcall(GetTile) or RemoteEmpty then
            return
          else
            for y = PlantY, StartY, -2 do
              if pcall(GetTile) or RemoteEmpty then
                return
              else
                if Plant and 0 == GetTile(x, y).fg or Harvest and GetTile(x, y).fg == SeedID and 1 == GetTile(x, y).extra.progress then
                  SendPacketRaw(false, {
                    state = 32,
                    x = x * 32,
                    y = y * 32
                  })
                  SendPacketRaw(false, {
                    type = 3,
                    state = 32,
                    value = Plant and 5640 or 18,
                    x = x * 32,
                    y = y * 32,
                    px = x,
                    py = y
                  })
                  Sleep(Plant and DelayPlant or DelayHarvest)
                  if Plant and x > 0 then
                    px = x - 1
                    if pcall(GetTile) or RemoteEmpty then
                      return
                    elseif GetTile(px, y).fg == SeedID then
                      Missed = 0
                    else
                      Missed = Missed + 1
                    end
                  end
                end
                if Missed >= 50 then
                  Now = Now < #Mag and Now + 1 or 1
                  Missed = 0
                  RemoteEmpty = true
                  return
                end
              end
            end
          end
        end
      end
    end
  else
    for x = PlantX, 0, -PlantFar do
      if pcall(GetTile) or RemoteEmpty then
        return
      else
        LogToConsole("`9[AwZka]`2" .. (Plant and "Planting `9" .. math.floor(100 - x / PlantX * 100) .. "`5%" or "Harvesting..."))
        for i = 1, 2 do
          if pcall(GetTile) or RemoteEmpty then
            return
          else
            for y = StartY, PlantY, 2 do
              if pcall(GetTile) or RemoteEmpty then
                return
              else
                if Plant and 0 == GetTile(x, y).fg or Harvest and GetTile(x, y).fg == SeedID and 1 == GetTile(x, y).extra.progress then
                  SendPacketRaw(false, {
                    state = 48,
                    x = x * 32,
                    y = y * 32
                  })
                  SendPacketRaw(false, {
                    type = 3,
                    state = 48,
                    value = Plant and 5640 or 18,
                    x = x * 32,
                    y = y * 32,
                    px = x,
                    py = y
                  })
                  Sleep(Plant and DelayPlant or DelayHarvest)
                  if Plant and x < PlantX then
                    px = x + 1
                    if pcall(GetTile) or RemoteEmpty then
                      return
                    elseif GetTile(px, y).fg == SeedID then
                      Missed = 0
                    else
                      Missed = Missed + 1
                    end
                  end
                end
                if Missed >= 50 then
                  Now = Now < #Mag and Now + 1 or 1
                  Missed = 0
                  RemoteEmpty = true
                  return
                end
              end
            end
          end
        end
      end
    end
  end
  if pcall(GetTile) then
    return
  else
    Scanning()
    if Plant and PTHT ~= SprayUWS then
      PTHT = PTHT + 1
      if UseUWS then
        if WebhookPTHT then
          math.randomseed(os.time())
          UWS = pcall(inv) and inv(12600) or UWS
          SendWebhook(WebhookLink, [[
{"embeds": [{
"author": {"name": "PTHT VIP BOTHAX WINDOWS",
"icon_url": "https://cdn.discordapp.com/attachments/1359017552965140533/1359747527775092736/Apr_8_2025_03_02_12_PM.png?ex=67fb3e11&is=67f9ec91&hm=d947b436954547f3fcc192f83cbaacc310afda9fa4f56b30f389743d08f65b99&"},
"fields": [{"name": ":identification_card: Account",
"value": "]] .. (PublicWebhook and cen(Nick, 3) or Nick) .. [[
",
"inline": true},
{"name": ":earth_asia: World",
"value": "]] .. (PublicWebhook and cen(WorldName, 1) or WorldName) .. [[
",
"inline": true},
{"name": ":atom: Magplant",
"value": "]] .. Now .. " of " .. #Mag .. [[
",
"inline": true},
{"name": ":ear_of_rice: Status",
"value": "]] .. PTHT .. (type(TotalPTHT) == "number" and "/" .. TotalPTHT or "X") .. [[
 Done",
"inline": true},
{"name": ":squeeze_bottle: UWS",
"value": "]] .. UWS .. [[
**Pcs**",
"inline": true},
{"name": ":timer: Uptime",
"value": "]] .. FTime(os.time() - StartTime) .. [[
",
"inline": true}],
"color": ]] .. math.random(0, 16777215) .. [[
}]
}]])
        end
        SendPacket(2, [[
action|input
text|`2]] .. PTHT .. " `8PTHT Done `c#AwZka")
      end
    end
  end
end

function Entering()
  if pcall(GetTile) then
    if WebhookPTHT and not PublicWebhook then
      SendWebhook(WebhookLink, "{\"content\": \"" .. Nick .. " PTHT Reconnecting...\"}")
    end
    SendPacket(3, [[
action|join_request
name|]] .. WorldName .. [[
|
invitedWorld|0]])
    TextOverlay("Entering World...")
    Sleep(DelayEntering)
    RemoteEmpty = true
  else
    if RemoteEmpty then
      TextOverlay("Taking Remote...")
      GetRemote()
      RemoteEmpty = false
    end
    Loop()
  end
end

function dialog(teks)
  SendVariantList({
    [0] = "OnDialogRequest",
    [1] = [[
add_label_with_icon|big|`2PTHT VIP AwZka||7064|
add_spacer|small|
add_textbox|]] .. GetLocal().name:match("%S+") .. [[
||
add_textbox|]] .. teks .. [[
||
add_spacer|small|
add_smalltext|`9AwZka SC! Join now!|
add_url_button||`qDiscord|NOFLAGS|https://discord.gg/|`$AwZka SC.|0|0|
add_quick_exit|]]
  })
end

  if os or not WebhookPTHT then
    dialog("`8Thanks for buy")
    Sleep(200)
    SendPacket(2, [[
action|dialog_return
dialog_name|cheats
check_gems|1
]])
    Sleep(200)
    Scanning()
    Sleep(200)
    if type(TotalPTHT) == "number" then
      repeat
        Entering()
        if PTHT == TotalPTHT then
          LogToConsole("`9[AwZka] `^PTHT " .. PTHT .. "X Is DONE! `c#AwZka")
          Sleep(820)
          SendPacket(2, [[
action|input
text|(party) `^PTHT ]] .. PTHT .. "X Is DONE! (party)")
          Sleep(820)
          SendPacket(2, [[
action|input
text|(party) `eII `cTHX FOR BUY `eII (party)]])
          Sleep(820)
          SendPacket(3, [[
action|join_request
name|EXIT|
invitedWorld|0]])
          if WebhookPTHT and not PublicWebhook then
            SendWebhook(WebhookLink, "{\"content\": \"" .. Nick .. " PTHT " .. PTHT .. "X Is DONE!\"}")
          end
        end
      until PTHT == TotalPTHT
    elseif TotalPTHT then
      while true do
        Entering()
      end
    end
  else
    dialog("`9Turn On API MakeRequest & os for Webhook PTHT")
  end
else
  dialog("`4UID not added")
end
PoweredByAwZka(AwZka)
