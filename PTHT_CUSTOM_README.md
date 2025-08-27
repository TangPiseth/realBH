# PTHT Custom Script with ImGui Interface

## Overview
This is a comprehensive PTHT (Plant/Harvest Tree) script with an advanced ImGui configuration interface for Growtopia automation using Bothax. The script combines the best features from existing PTHT scripts with modern GUI controls and extensive customization options.

## Features

### 🎮 GUI Interface
- Modern ImGui-based configuration menu
- Real-time statistics display
- Tabbed settings organization
- Save/Load configuration to file
- Visual progress tracking

### 🔧 Core Functionality
- **Multiple Farming Modes**: Vertical and Horizontal planting patterns
- **Smart Tree Management**: Automatic switching between planting and harvesting
- **UWS Integration**: Ultra World Spray support with configurable thresholds
- **Magplant Management**: Automatic remote collection from multiple magplants
- **Anti-Detection**: Anti-lag and anti-SDB protection

### 📊 Monitoring & Reporting
- **Real-time Statistics**: Gems, trees, cycles, uptime tracking
- **Webhook Support**: Discord webhook notifications with detailed stats
- **Progress Tracking**: Visual progress indicators and completion estimates
- **Detailed Logging**: Configurable console logging

### ⚙️ Advanced Configuration
- **Flexible Positioning**: Customizable starting positions and farming areas
- **Timing Controls**: Adjustable delays for all actions
- **Account Support**: Second account mode for collaborative farming
- **Auto-reconnection**: Automatic world reconnection on disconnect

## Bothax Compatibility

This script is specifically designed for **Bothax** and requires the following APIs to be enabled:

### Required APIs:
- ✅ **ImGui** - For the graphical interface
- ✅ **IO** - For saving/loading settings
- ✅ **MakeRequest** - For webhook functionality
- ✅ **os** - For time tracking and webhook timestamps

### Optional APIs:
- **SendPacketRaw** - Already available in standard Bothax
- **AddHook** - For event handling and anti-detection

## Installation & Setup

1. **Download the Script**
   - Save `PTHT_IMGUI_CUSTOM.lua` to your Growtopia scripts folder
   - Typically: `storage/emulated/0/android/media/com.rtsoft.growtopia/scripts/`

2. **Enable Required APIs**
   - Open Bothax settings
   - Navigate to API settings
   - Enable: ImGui, IO, MakeRequest, os

3. **Load the Script**
   - In Growtopia, open Bothax console
   - Type: `run PTHT_IMGUI_CUSTOM.lua`
   - The GUI window will appear automatically

## Configuration Guide

### Main Window
- **Start/Stop**: Control script execution
- **World**: Target world name for farming
- **PTHT Amount**: Number of complete farming cycles
- **Mode Selection**: Choose between Vertical or Horizontal farming
- **Quick Settings**: Toggle UWS and second account mode

### Advanced Settings

#### General Tab
- **Seed ID**: Item ID of the seed to plant (default: 15461 for CTREE)
- **Magplant BG**: Background ID where magplants are placed (default: 284)
- **Max Trees**: Tree threshold before using UWS (default: 17000)
- **Starting Position**: X,Y coordinates to begin farming

#### Delays Tab
- **Plant Delay**: Milliseconds between each plant action
- **Harvest Delay**: Milliseconds between each harvest action
- **After Plant Delay**: Wait time after planting before UWS
- **After UWS Delay**: Wait time after using UWS
- **Enter World Delay**: Wait time when joining worlds

#### Features Tab
- **Anti-Lag**: Reduces packet spam for stability
- **Anti-SDB**: Blocks Super Broadcast messages
- **Auto Reconnect**: Automatically rejoins world on disconnect
- **Use MRAY**: Faster planting with MRAY support
- **Auto Collect Gems**: Automatically collect gems during farming
- **Enable Logging**: Console output for debugging

#### Webhook Tab
- **Enable Webhook**: Toggle Discord notifications
- **Webhook URL**: Your Discord webhook URL
- **Webhook Delay**: Minimum seconds between webhook messages
- **Test Webhook**: Send a test message to verify setup

### Statistics Window
- **Progress Tracking**: Current cycle and completion percentage
- **Resource Monitoring**: Gems, trees, UWS count
- **Performance Metrics**: Uptime, cycles per hour
- **Reset Option**: Clear statistics and restart counters

## Usage Instructions

### Basic Setup
1. Place magplants with background blocks (ID: 284) in your world
2. Set up a farming area with platform blocks
3. Configure the script settings through the GUI
4. Set your target world name
5. Click "Start" to begin farming

### Recommended Settings
```
World: YourFarmingWorld
Seed ID: 15461 (CTREE)
Mode: VERTICAL
Max Trees: 17000
Plant Delay: 15ms
Harvest Delay: 200ms
Use UWS: Enabled
```

### Webhook Setup (Optional)
1. Create a Discord webhook in your server
2. Copy the webhook URL
3. Paste it in the Webhook Settings tab
4. Enable webhook notifications
5. Test the connection using the "Test Webhook" button

## Safety Features

- **Anti-Detection**: Built-in anti-lag and anti-SDB protection
- **Error Handling**: Graceful handling of connection issues
- **Resource Monitoring**: Automatic UWS and magplant management
- **Safe Reconnection**: Intelligent world rejoining on disconnect

## Troubleshooting

### Common Issues

**Script won't start:**
- Check that all required APIs are enabled
- Verify world name is correct
- Ensure magplants are properly placed

**GUI not showing:**
- Confirm ImGui API is enabled
- Try reloading the script
- Check for script conflicts

**Webhook not working:**
- Verify MakeRequest API is enabled
- Check webhook URL format
- Test with Discord webhook tester

**Performance issues:**
- Increase delays in Advanced Settings
- Enable Anti-Lag protection
- Reduce Max Trees threshold

### Support

If you encounter issues:
1. Check the console for error messages
2. Verify all APIs are properly enabled
3. Review configuration settings
4. Test with default settings first

## Credits

- **Script Development**: Custom implementation for realBH repository
- **Based on**: Existing PTHT and PNB scripts in the repository
- **GUI Framework**: ImGui integration for Bothax
- **Bothax Compatibility**: Optimized for Bothax PC environment

## License

This script is part of the realBH repository and follows the same licensing terms. Use responsibly and respect the game's terms of service.

---

**Note**: This script is for educational and research purposes. Always follow the game's terms of service and use automation responsibly.