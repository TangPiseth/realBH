webhookURL = "https://discord.com/api/webhooks/1359580327307251874/VfqwYAP4oQwcxW7bzNLoEZ8GbAS19h11Bn9ryHDo4QMbJpx3Yg14mMkmR3lyW8JjgOy6"
world = GetWorld().name

function SendWebhook(url, data)
		MakeRequest(url, "POST", {["Content-Type"] = "application/json"}, data)
end

function join(x)
  SendPacket(3, "action|join_request\nname|".. x .."|\ninvitedWorld|0")
end

AddHook("OnVariant", "Lant", function(var)
  if var[0] == "OnTalkBubble" and var[2]:find("Donation Box") then
    local text = var[2]
    text = text:gsub("#%d", ""):gsub("`%d", ""):gsub("`#", ""):gsub("`%a", ""):gsub("`", ""):gsub("%[", ""):gsub("%]", "")

    local Nick = text:match("^(.-) places"):gsub("w", "") or "Unknown"
    local Amount, Name = text:match("places (%d+) (.+) into")
    if not Amount or not Name then
      Name = text:match("places (.+) into"):gsub("%d", ""):gsub("", "") or "Unknown"
      Amount = text:match("places (.+) into"):gsub("%a", "") or "0"
    end

    LogToConsole("Nick: " .. Nick)
    LogToConsole("Amount: " .. Amount)
    LogToConsole("Item Name: " .. Name)

    local validItems = {
      ["World Lock"] = true,
      ["Diamond Lock"] = true,
      ["Blue Gem Lock"] = true,
      ["Black Gem Lock"] = true
    }

    if validItems[Name] then
      LogToConsole("Real Dono")
      local myData = [[
      {
        "username": "Babu - AwZka",
        "embeds": [
        {
          "title": ":inbox_tray: Depo Logs",
          "color": 5763719,
          "fields": [
          { "name": ":pushpin: Nick", "value": "]] .. Nick .. [[", "inline": false },
          { "name": ":money_with_wings: Payment", "value": "]] .. Name .. [[", "inline": false },
          { "name": ":moneybag: Amount", "value": "]] .. Amount .. [[ ]] .. Name .. [[", "inline": false },
          { "name": ":white_check_mark: Status", "value": "Real Depo", "inline": false }
          ],
          "footer": {
            "text": "Date: ]] .. os.date("%A %b %d, %Y | Time: %I:%M %p") .. [["
          }
        }
        ]
      }
      ]]
      SendWebhook(webhookURL, myData)
    else
      LogToConsole("Fak dono")
      local myData = [[
      {
        "username": "Babu - AwZka",
        "embeds": [
        {
          "title": ":inbox_tray: Depo Logs",
          "color": 16711680,
          "fields": [
          { "name": ":pushpin: Nick", "value": "]] .. Nick .. [[", "inline": true },
          { "name": ":money_with_wings: Payment"]] .. Name .. [[", "inline": true },
          { "name": ":moneybag: Amount", "value"]] .. Amount .. [[ ]] .. Name .. [[", "inline": true },
          { "name": ":white_check_mark: Status": "Fake Depo", "inline": false }
          ],
          "footer": {
            "text": "Date: ]] .. os.date("%A %b %d, %Y | Time: %I:%M %p") .. [["
          }
        }
        ]
      }
      ]]
      SendWebhook(webhookURL, myData)
    end
    return true
  end
  return false
end)

while true do
  Sleep(3000)
  if GetWorld == nil or GetWorld().name ~= world then
    join(world)
    Sleep(5000)
  end
end
