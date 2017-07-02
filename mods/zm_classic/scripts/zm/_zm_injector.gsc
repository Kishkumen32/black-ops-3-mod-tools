#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// 3arc - Zombiemode
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#insert scripts\wardog\shared\wardog_shared.gsh; // This line is required so the below macro is valid
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;

#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_powerup_ww_grenade;
#using scripts\zm\_zm_perk_phdflopper;

#using scripts\zm\_zm_weapons;

#using scripts\zm\_zm_weapons_custom;
#using scripts\zm\_zm_kishkumen_utility;

#precache( "model", "t7_props_dlc/zm/dlc0/der_riese/p7_zm_der2_teleporter_control_panel/p7_zm_der2_teleporter_control_panel_lod0" );

#namespace zm_injector;

REGISTER_SYSTEM( "zm_injector", &__init__, undefined )

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::add_callback(#"on_finalize_initialization", &__init__);
	callback::add_callback(#"on_start_gametype", &__post_init__);
	callback::on_connect(&__player_connect__);
}

function __pre_init__()
{
	zm_weapons_custom::include_weapons();
	zm_weapons_custom::ReplaceWallWeapons();

	level thread zm_kishkumen_utility::RemoveAllBGBMachines();
	level thread modify_3arc_maps();
	level thread place_perks();

	// Replace Widows Wine with PHD Flopper
	if(level.CurrentMap == "zm_cosmodrome" || level.CurrentMap == "zm_moon" || level.CurrentMap == "zm_temple")
	{
		level thread wardog_zm_util::replace_perk_spawn_struct("specialty_widowswine", "specialty_phdflopper");
	}
}

function __init__()
{
	level.debug = true;
}

function __post_init__()
{	
	if(wardog_zm_util::is_zc_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );
	}

	if(!(level.CurrentMap == "zm_zod" || level.CurrentMap == "zm_tomb"))
	{
		level.start_weapon = getWeapon("bo3_m1911");

		//playing coop
		level.default_laststandpistol = GetWeapon("bo3_m1911");

		//playing solo
		level.default_solo_laststandpistol = GetWeapon("pistol_standard_upgraded");

        level.laststandpistol = level.default_laststandpistol;
	};
}

function __player_connect__()
{	
	
}

function modify_3arc_maps()
{
	mapname = level.script;

	switch(mapname)
	{
		case "zm_island": 
		{
			origin = (-176.359,2410.86,-383.875);
			angles = (0,176,0);

			origin_dragon = (-1924.52,800.659,276.125);
			angles_dragon = (0, -71.7902, 0);

			t_use = spawn( "trigger_radius_use", origin + ( 0, 0, 30), 0, 40, 80 );
			t_use.targetname = "dragon_room_teleport";
			t_use UseTriggerRequireLookAt();
			t_use TriggerIgnoreTeam();

			control_panel = spawn("script_model", origin + ( 0, 0, 30) );
			control_panel.angles = angles + (0, 270, 0);
			control_panel setModel("p7_zm_der2_teleporter_control_panel");

			collision = spawn("script_model", origin, 1 );
			collision.angles = angles;
			collision setModel("zm_collision_perks1");
			collision.script_noteworthy = "clip";
			collision disconnectPaths();

			t_use.clip = collision;
			t_use.machine = control_panel;

			while(1)
			{
				t_use SetHintString( "Press ^3&&1^7 to Teleport to Dragon Room" );
				t_use SetCursorHint( "HINT_NOICON" );

				t_use waittill( "trigger", player);
				t_use SetHintString( "" );

				player SetOrigin(origin_dragon);
				player SetPlayerAngles(angles_dragon);
				wait(2);
			}

			break;
		}
		case "zm_prototype":
		case "zm_asylum":
		case "zm_sumpf":
		case "zm_theater":
		case "zm_cosmodrome":
		case "zm_temple":
		case "zm_moon":
		{
			level thread zm_kishkumen_utility::RemoveAllWunderfizz();
			break;
		}
		default:
		{
			break;
		}
	};
}

function place_perks()
{
	perks = [];
	perks[PERK_PHDFLOPPER] = [];

	switch(level.script)
	{
		case "zm_zod":
			perks[PERK_PHDFLOPPER][0] = (2316.48, -4929.27, -399.875);
			perks[PERK_PHDFLOPPER][1] = (0, 180, 0);
			perks[PERK_PHDFLOPPER][2] = 7;
			break;
		case "zm_factory":
			perks[PERK_PHDFLOPPER][0] = (-353.359, -1409.74, 191.125);
			perks[PERK_PHDFLOPPER][1] = (0, 90, 0);
			break;
		case "zm_castle":
			perks[PERK_PHDFLOPPER][0] = (4010.19, -2198.33, -2291.88);
			perks[PERK_PHDFLOPPER][1] = (0, 73.7567, 0);
			break;
		case "zm_island":
			perks[PERK_PHDFLOPPER][0] = (2264.84, -1901.65, -415.841);
			perks[PERK_PHDFLOPPER][1] = (0, 142.3662, 0);
			break;
		case "zm_stalingrad":
			perks[PERK_PHDFLOPPER][0] = (145.807, 4600.25, 145.121);
			perks[PERK_PHDFLOPPER][1] = (0, 0, 0);
			break;
		case "zm_genesis":
			perks[PERK_PHDFLOPPER][0] = (-2026.65, -3862.31, -1714.55);
			perks[PERK_PHDFLOPPER][1] = (0, 180.1044, 0);
			perks[PERK_PHDFLOPPER][2] = 3;
			break;
		default:
			break;
	}

	create_bumps = level._no_vending_machine_bump_trigs;
	create_collision = level._no_vending_machine_auto_collision;

	level._no_vending_machine_bump_trigs = false;
	level._no_vending_machine_auto_collision = false;

	foreach(perk in GetArrayKeys(perks))
	{
		if(!isdefined(perks[perk][0]))
			continue;

		struct = wardog_zm_util::create_perk_spawn_struct(perk, perks[perk][0], perks[perk][1], perks[perk][2]);
		trigger = struct wardog_zm_util::spawn_perk_from_struct();
		struct struct::delete();
	}

	level._no_vending_machine_bump_trigs = create_bumps;
	level._no_vending_machine_auto_collision = create_collision;
}