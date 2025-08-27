Settings = {
    FindID = -274, 
    delayFind = 200, 
    findAmount = 5000, -- Total item yang bakal di find
  }
  
  x = GetLocal().pos.x // 32
  y = GetLocal().pos.y // 32 + 1
  
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
  
  
  AddHook("onvariant", "Lant", function(var)
    if var[0] == "OnDialogRequest" and var[1]:find("MAGPLANT") then
      return true
    end
  
    if var[0] == "OnConsoleMessage" and var[1]:find("This doesn't fit") then
      x = x + 1
      FindPath(x, y - 1)
      Raw(3, 0, 32, x, y)
      return true
    end
  
    return false
  end)
  rr = 0
  Raw(3, 0, 32, x, y)
  while true do
    Sleep(Settings.delayFind)
    SendPacket(2, "action|dialog_return\ndialog_name|item_search\n" .. Settings.FindID .. "|1")
    rr = rr + 250
    Sleep(Settings.delayFind)
    SendPacket(2, "action|dialog_return\ndialog_name|magplant_edit\nx|" .. x .. "|\ny|" .. y .. "|\nbuttonClicked|additems")
    Sleep(Settings.delayFind)
    if rr >= Settings.findAmount then
      LogToConsole("Done Finding Total: "..Settings.findAmount)
      RemoveHooks()
      break
    end
  end