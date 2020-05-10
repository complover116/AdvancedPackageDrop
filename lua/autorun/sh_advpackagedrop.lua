ADVPACK_STATUS_IDLE = 0
ADVPACK_STATUS_LOCKING = 1
ADVPACK_STATUS_ASSEMBLING = 2
ADVPACK_STATUS_SHIPPING = 3
ADVPACK_STATUS_TRACKING = 4

ADVPACK_ITEMLIST = {
/*item_ammo_pistol_large={assembleTime=4, name="Pistol Ammo (100 rounds)"},
item_ammo_pistol={assembleTime=1, name="Pistol Ammo (20 rounds)"},
item_ammo_ar2_large={assembleTime=20, name="AR2 Ammo (100 rounds)"},
item_ammo_ar2={assembleTime=5, name="AR2 Ammo (20 rounds)", model="models/items/357ammo.mdl"},
item_ammo_357_large={assembleTime=12, name=".357 Ammo (20 rounds)", model="models/items/357ammo.mdl"},
item_ammo_357={assembleTime=5, name=".357 Ammo (6 rounds)"},
item_rpg_round={assembleTime=7, name="RPG Rocket"},
item_ammo_crossbow={assembleTime=15, name="Crossbow Bolts (6 bolts)"},
item_ammo_smg1_grenade={assembleTime=5, name="SMG1 Grenade"},
weapon_357={assembleTime=20, name="Magnum.357"},
weapon_ar2={assembleTime=20, name="AR2"},
weapon_crossbow={assembleTime=25, name="Crossbow"},
weapon_frag={assembleTime=3, name="Grenade"},
weapon_physcannon={assembleTime=60, name="Gravity Gun"},
weapon_pistol={assembleTime=5, name="Pistol"},
weapon_rpg={assembleTime=40, name="RPG"},
weapon_shotgun={assembleTime=20, name="Shotgun"},
weapon_slam={assembleTime=8, name="Slam"},
weapon_smg1={assembleTime=16, name="SMG1"},
weapon_stunstick={assembleTime=13, name="Stunstick"},
item_healthkit={assembleTime=5, name="Health Kit"},*/
item_ammo_ar2_altfire={assembleTime=2, name="Combine Ball", model="models/items/combine_rifle_ammo01.mdl"},
item_ammo_smg1={assembleTime=2, name="SMG Ammo", model="models/items/boxmrounds.mdl"},
item_box_buckshot={assembleTime=10, name="Shotgun Ammo", model="models/items/boxbuckshot.mdl"},
item_ammo_357={assembleTime=5, name="AR2 Ammo", model="models/items/357ammo.mdl"},
item_ammo_357_large={assembleTime=12, name=".357 Ammo", model="models/items/357ammo.mdl"},
item_battery={assembleTime=5, name="Battery", model="models/items/battery.mdl"},
item_healthvial={assembleTime=3, name="Health Vial", model="models/items/healthkit.mdl"},
npc_gman={assembleTime=5, name="PIDOR", model="models/gman_high.mdl"}
}

ADVPACK_ITEMNAMELIST = {}

for k, v in pairs(ADVPACK_ITEMLIST) do
	ADVPACK_ITEMNAMELIST[#ADVPACK_ITEMNAMELIST+1] = k
	v.assembleTime = v.assembleTime * 1
end
print("APD shared values loaded!")