SendPacket(2,"action|input\ntext|`bSCRIPT `0BY `c@AwZka `2ACTIVATED !! `0(tongue)")

SendVariantList({[0] = "OnDialogRequest", [1] = [[
add_label_with_icon|small|`8Script by `c@AwZka                   |left|3524|
add_spacer|small|
add_label_with_icon|small|`9Username: `c]]..GetLocal().name..[[|right|1794|
add_spacer|small|
add_label_with_icon|small|`9Current World: `#]]..GetWorld().name..[[|left|3802|
add_spacer|small|
add_label_with_icon|small|`4!! `bDon't Sell My `9SCRIPT `4!!|left|6278|
add_spacer|small|
add_url_button|comment|`eDiscord Server|noflags|https://discord.gg/gT47nWgm|Would you like to join my `eDiscord Server?|
end_dialog|c|Close|
add_quick_exit|]]})

yAxis = 200 -- y
xAxis = 200 -- x
delayHarvest = 80 -- Delay

local function punch(x, y)
    pkt = {}
    pkt.type = 3
    pkt.value = 18
    pkt.x = GetLocal().pos.x
    pkt.y = GetLocal().pos.y 
    pkt.px = math.floor(GetLocal().pos.x / 32 + x)
    pkt.py = math.floor(GetLocal().pos.y / 32 + y)
    SendPacketRaw(false, pkt)
    Sleep(40)
end

local function isReady(tile)
    if tile and tile.extra and tile.extra.progress and tile.extra.progress == 1.0 then
        return true
    end
    return false
end

local function harvest()
    for y = 0, yAxis do
        for x = 0, xAxis do
            if isReady(GetTile(x, yAxis - y)) then
                FindPath(x, yAxis - y, delayHarvest)
                punch(0, 0)
            end
        end
    end
end

while true do
    Sleep(100)
    harvest()
end