# Attributions

This project incorporates code from several libraries and resources licensed under GPLv3, as it inherits their licensing, and the creators are credited below:

## r_bridge
- **Purpose**: Code for codem-inventory bridging, targeting, and framework item registration.
- **Modifications to the code**: Code was used for codem/tgian inventory bridge & targeting, the idea of native helper functions came from that entirely. Targeting code still remains as is and is used as well as the method of registering usables.
- **Credit**: **r_bridge** inventory bridging code for codem-inventory is used in this. Targeting code still remains as is and is used.
  [\[r_bridge\]](https://github.com/rumaier/r_bridge)

## clean_lib
- **Purpose**: Vehicle fuel, vehicle key bridging and the loading and saving methods of json files.
- **Modifications to the code**: None.
- **Credit**: **clean_lib** code is used to manage vehicle fuel and keys, bridging these systems seamlessly.
  [\[clean_lib\]](https://github.com/Clean-Server-Pack/clean_lib)

## ox_lib
- **Purpose**: Utility functions for printing raycasting and point registering.
- **Credit**: **ox_lib** provides various utility functions for printing and interacting with other objects in this resource. While theres no code pulled directly from the resource, it is still the backbone to it so a thanks is nessesary.
  [\[ox_lib\]](https://github.com/overextended/ox_lib)

## renewed_lib
- **Purpose**: Object placer functionality.
- **Modifications to the code**: Variable naming, added missing params for the natives used, updated a depreciated export from oxlib for the raycast camera, altered the showtext ui to now work with multiple showtextui systems, moved the text for placement into locales, the requestModel exports from ox_lib were replaced with the function my bridge uses to request models from ox_lib.
- **Credit**: **renewed_lib** code is used for its object placement snippet.
  [\[renewed_lib\]](https://github.com/Renewed-Scripts/Renewed-Lib)


## duff
- **Purpose**: Version Checker.
- **Modifications to the code**: Variables removed, now will pull repo information from passed string.
- **Credit**: **duff** code was refrenced and some used for version checker formatting and print style.
  [\[duff\]](https://github.com/DonHulieo/duff/blob/d89ed3b0051194babf5711114a0c437d4e41f433/server/init.lua#L10C1-L28C4)



Thank you to the creators and maintainers of these libraries/bridges/internet points for their hard work and contributions to the FiveM community.
