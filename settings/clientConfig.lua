BridgeClientConfig                   = {}
BridgeClientConfig.InputSystem       = "auto"       -- [ auto | ox_lib | lation_ui | qb-input ]
BridgeClientConfig.MenuSystem        = "auto"       -- [ auto | ox_lib | wasabi_uikit | lation_ui | qb-menu ]
BridgeClientConfig.ProgressBarSystem = "auto"       -- [ auto | ox_lib | wasabi_uikit | lation_ui | ZSX_UIV2 | keep-progressbar | progressbar ]
BridgeClientConfig.VehicleKey        = "auto"       -- [ auto | qb-vehiclekeys | MrNewbVehicleKeys | jaksams_VehiclesKeys | wasabi_carlock | mk_vehiclekeys | qbx_vehiclekeys | qs-vehiclekeys | t1ger_keys | Renewed-Vehiclekeys | mono_carkeys| cd_garage | okokGarage | F_RealCarKeysSystem
BridgeClientConfig.Fuel              = "auto"       -- [ auto | LegacyFuel | ox_fuel | ps-fuel | qs-fuelstations | Renewed-Fuel | ti_fuel | lc_fuel | x-fuel | cdn-fuel | esx-sna-fuel | BigDaddy-Fuel | okokGasStation ]
BridgeClientConfig.TargetSystem      = "auto"       -- [ auto | ox_target | qb-target | sleepless_interact ] -- sleepless is only partially supported and would need another system in place
BridgeClientConfig.Debug             = false
return BridgeClientConfig
