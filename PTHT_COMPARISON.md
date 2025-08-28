# PTHT Script Comparison: Teleporting vs Stationary

## Original PTHT Scripts (Teleporting Mode)
The existing PTHT scripts (V1, V2, V3, icShark) work by:
- Moving around the entire world using `FindPath(x, y, delay)`
- Working on coordinates from (0,0) to (199,199) 
- Teleporting to each tile to plant or harvest
- Covering the entire world systematically

Example from PTHT_V2.lua:
```lua
for y = Settings.StartingPos[2], (Settings.StartingPos[2] % 2 == 0 and 0 or 1), -2 do
    for x = (Settings.SecondAcc and 199 or Settings.StartingPos[1]), (Settings.SecondAcc and 0 or Settings.StartingPos[2]), (Settings.SecondAcc and -10 or 10) do
        -- Teleports to each position
        Raw(0, (Settings.SecondAcc and 48 or 32), 0, x, y)
```

## New PTHT_Stationary.lua (Stationary Mode)
The new stationary script works by:
- Staying in one place (no teleporting around)
- Working only in a small radius around the player's current position
- Using relative coordinates to plant/harvest nearby tiles
- Configurable work radius (default 8 tiles around player)

Example from PTHT_Stationary.lua:
```lua
for relX = -Settings.WorkRadius, Settings.WorkRadius do
    for relY = -Settings.WorkRadius, Settings.WorkRadius do
        -- Works relative to player position, no teleporting
        punch(relX, relY)  -- or place(5640, relX, relY)
```

## Key Differences

| Feature | Original PTHT | Stationary PTHT |
|---------|---------------|-----------------|
| Movement | Teleports around entire world | Stays in one place |
| Work Area | Entire world (200x200) | Small radius around player (16x16 default) |
| Coordinates | Absolute world coordinates | Relative to player position |
| Efficiency | Covers everything but slow | Fast but limited area |
| Use Case | Large scale farming | Localized/targeted farming |

## Configuration Changes
- **WorkRadius**: New setting to control how far around the player to work
- **MaxTree**: Adjusted to lower value (100) since working area is smaller  
- **Starting Position**: Not used in stationary mode
- All other settings (delays, seed ID, world, etc.) work the same way

This stationary approach is perfect for users who want to farm a specific area without the script moving the player around the entire world.