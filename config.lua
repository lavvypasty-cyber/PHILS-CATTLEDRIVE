Config = {}

Config.Debug = false

Config.RewardMoney = 150
Config.RewardAccount = 'cash'
Config.RewardPerMeter = 0.05  -- $0.05 per meter of distance
Config.BaseReward = 50        -- base reward regardless of distance
Config.RequiredJob = nil
Config.HerdSize = 6
Config.CowModel = 'A_C_Cow'

Config.InteractKey = 'J'          -- keybind from RSGShared.Keybinds
Config.NPCModel = 'A_M_M_VALDEPUTY_01' -- rancher npc model (change to taste)
Config.PanicDistance = 40.0
Config.DespawnTimer = 60 * 60 * 1000

Config.StartLocations = {
    { 
        label = 'Valentine Corral', 
        coords = vector3(-288.6, 642.3, 113.08), 
        heading = 130.0,
        blip = {
            sprite = 423351566,   -- cattle/corral style blip
            colour = 'BLIP_MODIFIER_MP_COLOR_6',
            name = 'Cattle Drive | Valentine',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords = vector3(-288.6, 643.3, 113.08 -1),
            heading = 220.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
    { 
        label = 'Emerald Ranch', 
        coords = vector3(1409.05, 291.77, 88.69), 
        heading = 100.0,
        blip = {
            sprite = 423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_6',
            name = 'Cattle Drive | Emerald',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords = vector3(1409.05, 290.77, 88.69 -1),
            heading = 190.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
    { 
        label = 'Strawberry', 
        coords = vector3(-1730.22, -429.6, 152.02), 
        heading = 250.0,
        blip = {
            sprite =423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_6',
            name = 'Cattle Drive | strawberry',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords = vector3(-1730.22, -428.6, 152.02 -1),
            heading = 60.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
	{ 
        label = 'St-denis', 
        coords = vector3(2607.6, -765.93, 42.36), 
        heading = 250.0,
        blip = {
            sprite =423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_6',
            name = 'Cattle Drive | st-denis',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords = vector3(2607.6, -765.93, 42.36 -1),
            heading = 60.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
}

Config.DeliveryPoints = {
    { 
        label = 'mcfarlanes', 
        coords = vector3(-2343.67, -2362.9, 62.02),
        blip = {
            sprite = 423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_8',
            name = 'Delivery | mcfarlanes',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords = vector3(-2343.67, -2362.9, 62.02 -1),
            heading = 40.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
    { 
        label = 'Rhodes Depot', 
        coords = vector3(1339.07, -1266.27, 77.61),
        blip = {
            sprite = 423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_8',
            name = 'Delivery | Rhodes Depot',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords = vector3(1339.07, -1266.27, 77.61 -1),
            heading = 260.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
    { 
        label = 'Van Horn Docks', 
        coords = vector3(2903.3, 1285.17, 44.94),
        blip = {
            sprite = 423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_8',
            name = 'Delivery | Van Horn Docks',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords = vector3(2903.3, 1285.17, 44.94 -1),
            heading = 140.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
	{ 
        label = 'Armadillo', 
        coords = vector3(-3663.03, -2563.95, -13.77),
        blip = {
            sprite = 423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_8',
            name = 'Delivery | Armadillo',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords =vector3(-3663.03, -2563.95, -13.77 -1),
            heading = 240.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
	{ 
        label = 'Tumbleweed', 
        coords = vector3(-5516.86, -3021.84, -2.63 -1),
        blip = {
            sprite = 423351566,
            colour = 'BLIP_MODIFIER_MP_COLOR_8',
            name = 'Delivery | Tumbleweed',
            scale = 0.9,
        },
        npc = {
            model = 'loansharking_horsechase1_males_01',
            coords =vector3(-5516.86, -3021.84, -2.63 -1),
            heading = 240.0,
            scenario = 'WORLD_HUMAN_SMOKE',
        },
    },
}

Config.MoveSpeed = { walk = 1.0, target = 1.8 }
