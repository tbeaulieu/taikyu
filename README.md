![image](https://github.com/user-attachments/assets/b664f7a2-16a6-483b-a3b0-871461a2c96e)

# taikyu
 GARW Dash, SuperTaikyu-inspired

Oil temperature, oil pressure and AFR are optional: turn each one on with its Show row in the settings menu.

The wideband input (`o2data`) arrives as lambda. The AFR menu can show it as lambda or AFR (lambda x 14.7) and set High / Low limits. The limits are always in AFR; outside them the readout turns red, and 0 turns a limit off. Coolant and oil temp High limits are in Celsius and the oil pressure Low limit is in bar; 0 turns them off too.

## Layout

- `Taikyu.qml` - entry file: live data, config load/save, joystick handling, settings menu
- `TaikyuDisplay.qml` - the dial itself
- `SettingsMenu.qml`, `SettingBox.qml`, `MonoText.qml`, `Theme.qml`, `GridBackground.qml` - settings menu (shared with AgeSolo)
- `SettingsPreview.qml` - standalone menu preview, not loaded by the dash
- `Taikyu.qml.png` - preview shown in the dash picker

Settings are saved as JSON in `/opt/IC7/screen_configs/Taikyu_config.json`. An existing `Taikyu_config.txt` is imported once on first run.

This dash will require you to update your gear settings (under settings -> gears) for the calculated gear (unless you're very fancy and running a sequential with a canbus output), the following works decently for me currently with a stock C64 transmission:

(1st) 123 (2nd) 83 (3rd) 60 (4th) 47 (5th) 37 (6th) 33

This file contains a font designed by me (23Segment.ttf), feel free to use it elsewhere, but credit me.
