Config = {}

Config.JobName = 'delivery'

Config.CheckLicense     = false
Config.TruckingLicense  = 'drive_truck'

Config.MissionCount     = 5

Config.MainPosition = {
    Blip = {
        Blip            = nil,
        Sprite          = 477,
        Colour          = 5,
        Scale           = 0.8,
        IsShortRange    = true,
        Name            = 'Delivery Job'
    },
    MenuLocation    = vector3(203.82, -3131.1, 4.89),
    VehicleLocation = { x = 205.79, y = -3096.49, z = 5.79, h = 357.14 },
    TrailerLocation = { x = 223.94, y = -3115.20, z = 5.79, h = 84.22 },
    DeleteLocation  = vector3(205.18, -3093.65, 5.78)
}

Config.Markers = {
    VehicleTakeout = {
        Enabled = true,
        Colour = {r = 255, g = 255, b = 255, a = 255},
        Scale = {x = 2.0, y = 2.0, z = 1.0},
        Type = 1,
        Rotate = false
    },
    Missions = {
        Enabled = true,
        Colour = {r = 255, g = 255, b = 0, a = 255},
        Scale = {x = 3.0, y = 3.0, z = 1.0},
        Type = 1,
        Rotate = false
    },
    DeleteLocation = {
        Enabled = true,
        Colour = {r = 255, g = 0, b = 0, a = 255},
        Scale = {x = 3.0, y = 3.0, z = 1.0},
        Type = 1,
        Rotate = false
    }
}

Config.Payouts = {
    ['small'] = math.random(1200, 5000), -- Je kan het verschillend plaatsen, of een vast bedrag : = 1000
    ['medium'] = math.random(5000, 7500),
    ['big'] = math.random(7500, 10000)
}

Config.Vehicles = {
    ['small'] = 'burrito3',
    ['medium'] = 'moonbeam',
    ['big'] = 'phantom'
}

Config.VehicleBootOffset = {
    ['small'] = 'door_pside_r',
    ['medium'] = 'door_pside_r'
}

Config.Missions = {
    ['small'] = {
        { vehicle = vector3(56.46, -1571.35, 29.46),    walk = vector3(48.36, -1594.43, 29.6) },
        { vehicle = vector3(-163.89, -793.43, 31.76),   walk = vector3(-209.89, -784.05, 30.67) },
        { vehicle = vector3(297.51, -140.19, 67.77),    walk = vector3(307.79, -146.26, 67.77) },
        { vehicle = vector3(-992.84, -295.14, 37.83),   walk = vector3(-992.56, -281.5, 38.19) },
        { vehicle = vector3(-444.36, 184.29, 75.2),     walk = vector3(-425.02, 186.09, 80.8) },
    },
    ['medium'] = {
        { vehicle = vector3(-136.89, 966.68, 235.86),   walk = vector3(-113.41, 985.82, 235.75) },
        { vehicle = vector3(-1978.72, 585.77, 117.46),  walk = vector3(-1994.94, 590.74, 117.9) },
        { vehicle = vector3(-728.14, -917.58, 19.01),   walk = vector3(-705.85, -906.08, 19.22) },
        { vehicle = vector3(-1074.89, -1529.38, 4.72),  walk = vector3(-1077.22, -1553.3, 4.63) },
        { vehicle = vector3(1358.81, -1838.6, 57.0),    walk = vector3(1365.9, -1833.72, 57.92) },
    },
    ['big'] = {
        { vehicle = vector3(2566.81, 389.22, 108.46),   walk = vector3(2549.43, 382.47, 108.62) },
        { vehicle = vector3(1984.87, 3771.67, 32.18),   walk = vector3(1997.09, 3779.87, 32.18) },
        { vehicle = vector3(198.29, 6606.2, 31.73),     walk = vector3(161.61, 6635.83, 31.58) },
        { vehicle = vector3(-2551.33, 2322.38, 33.06),  walk = vector3(-2566.39, 2307.09, 33.22) },
    }
}