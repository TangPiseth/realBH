# PTHT_Stationary.lua

A stationary Plant-and-Harvest script that stays in one place instead of teleporting around the world.

## What This Script Does

Unlike the original PTHT scripts that move around the entire world, this stationary version:

- **Stays in one place** - No teleporting or moving around the world
- **Works in a small radius** - Only plants and harvests in the immediate area around the player  
- **Uses relative coordinates** - All operations are relative to the player's current position
- **Same core functionality** - Still handles magplant management, mode switching, and all standard PTHT features

## Key Features

- ✅ **Stationary Operation** - Player doesn't move around the world
- ✅ **Configurable Work Radius** - Default 8 tiles around player (16x16 area)
- ✅ **Smart Mode Switching** - Automatically switches between plant and harvest modes
- ✅ **Magplant Integration** - Automatically gets seeds from magplants when needed
- ✅ **Status Reporting** - Shows tree counts, seed inventory, and current operation
- ✅ **All Standard Settings** - Delays, seed ID, world name, etc. all configurable

## Configuration

```lua
Settings = {
    -- Main Settings
    World = "DOCS", -- Change to your world name
    SeedID = 15461, -- Seed to plant
    WorkRadius = 8, -- Tiles around player to work in
    MaxTree = 100, -- Trees before switching to harvest mode
    
    -- Delays (in milliseconds)
    DelayPT = 40,    -- Plant delay
    DelayHT = 200,   -- Harvest delay
    
    -- Magplant Settings  
    MagBG = 284,     -- Background ID for magplants
    
    -- Features
    UseUws = true,   -- Use Ultra World Spray
}
```

## How It Works

1. **Position-Based**: Works around the player's current position
2. **Relative Coordinates**: Uses `relX, relY` offsets from player position
3. **Small Work Area**: Only operates within the configured radius
4. **No Teleporting**: Uses `punch(relX, relY)` and `place(id, relX, relY)` with relative positions

## Comparison with Original PTHT

| Feature | Original PTHT | Stationary PTHT |
|---------|---------------|-----------------|
| Coverage | Entire world (200x200) | Small area around player |
| Movement | Teleports everywhere | Stays in one place |
| Speed | Slower (travels far) | Faster (short distances) |
| Use Case | Large scale farming | Targeted/localized farming |

## Usage

1. Position your character where you want to plant/harvest
2. Make sure you have magplants with the correct background ID in the world
3. Configure the settings (especially `World` and `WorkRadius`)
4. Run the script
5. The script will plant and harvest only in the area around your character

## Perfect For

- **Targeted farming** in specific areas
- **Testing** PTHT functionality without affecting the whole world  
- **Localized operations** where you don't want to disturb other areas
- **Faster cycles** in smaller spaces

This script maintains all the reliability and features of the original PTHT scripts while providing a stationary, localized approach to plant and harvest operations.