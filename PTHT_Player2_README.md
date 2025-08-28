# PTHT Player 2 Script

## Overview
This script (`PTHT_icShark_Player2.lua`) is a modified version of the original `PTHT_icShark.lua` designed to act as a second player that operates from right to left instead of left to right.

## Key Differences from Original

### 1. Movement Pattern
- **Original**: Plants and harvests from left to right (x = 0 to xAxis)
- **Player 2**: Plants and harvests from right to left (x = xAxis to 0, step -1)

### 2. Player Facing Direction
- Added `ensureFacingLeft()` function to ensure the player faces left during operations
- Player automatically faces left during:
  - Planting operations
  - Harvesting operations
  - Main loop execution

### 3. Script Identification
- All messages, dialogs, and webhooks clearly identify this as "Player 2"
- Startup messages show "Player 2" branding
- Webhook notifications include "Player 2" in titles and usernames

### 4. Maintained Functionality
- All original safety checks and error handling preserved
- Zigzag planting pattern maintained (y-direction alternating)
- All configuration options remain functional
- No code duplication or missing function definitions

## Implementation Details

### Modified Functions
1. `plant()` - Reversed x-axis iteration, added facing left
2. `harvest()` - Reversed x-axis iteration, added facing left  
3. `plantMissedSpots()` - Reversed x-axis iteration, added facing left
4. Added `ensureFacingLeft()` - Ensures player faces left

### Planting Logic
- Seeds are planted at the current position (0,0 offset)
- Player moves from right side of the field to left side
- Maintains the original zigzag Y-pattern for efficiency

### Safety Features
- All original nil checks and world validation preserved
- GetWorld() safety checks in all critical functions
- Proper error handling for disconnections and magplant issues

## Usage
This script should be run alongside the original PTHT script to have two players working simultaneously - one going left to right, one going right to left, maximizing field coverage and efficiency.

## Testing
- Syntax validation passed
- All function calls verified to exist
- No nil reference errors detected
- Proper Player 2 identification in all outputs