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

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\zm\wardog_zm_util;
#using scripts\wardog\zm\wardog_zm_load;

#using scripts\zm\_zm_perk_phdflopper;

#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_weapons_custom;

#using scripts\zm\_zm_kishkumen_utility;

#insert scripts\zm\_zm_perk_phdflopper.gsh;

#precache( "fx", "weapon/fx_muz_sm_pistol_1p" );
#precache( "fx", "weapon/fx_muz_sm_pistol_3p" );
#precache( "fx", "weapon/fx_shellejects_pistol" );
#precache( "fx", "explosions/fx_exp_molotov_lotus" );
#precache( "fx", "weapon/fx_trail_fake_bullet" );
#precache( "model", "t7_props_dlc/zm/dlc0/der_riese/p7_zm_der2_teleporter_control_panel/p7_zm_der2_teleporter_control_panel_lod0" );

#precache( "fx", "weapon/fx_trail_crossbow");
#precache( "fx", "zombie/fx_muz_rocket_xm_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_rocket_xm_1p_ug_zmb");
#precache( "fx", "explosions/fx_exp_rocket_default_sm");
#precache( "fx", "zombie/fx_muz_lg_mg_3p_ug_zm");
#precache( "fx", "zombie/fx_muz_lg_mg_1p_ug_zm");
#precache( "fx", "zombie/fx_muz_md_rifle_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_md_rifle_1p_ug_zmb");
#precache( "fx", "zombie/fx_muz_lg_shotgun_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_lg_shotgun_1p_ug_zmb");
#precache( "fx", "zombie/fx_muz_sm_pistol_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_sm_pistol_1p_ug_zmb");
#precache( "fx", "dlc3/stalingrad/fx_raygun_r_3p_red_zmb");
#precache( "fx", "dlc3/stalingrad/fx_raygun_r_1p_red_zmb");

#namespace zm_injector;

REGISTER_SYSTEM( "zm_injector", &__init__, undefined )

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::add_callback(#"on_start_gametype", &__post_init__);
}

function __pre_init__()
{
	zm_weapons_custom::include_weapons();
	zm_weapons_custom::ReplaceWallWeapons();

	modify_3arc_maps();
}

function __init__()
{
	level.debug = false;
}

function __post_init__()
{	
	level thread zm_kishkumen_utility::RemoveAllBGBMachines();

	if(wardog_zm_util::is_zc_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );
	}

	//include_perk_in_random_rotation("specialty_phdflopper");

	if( isdefined(level._random_perk_machine_perk_list) )
	{
		keys = GetArrayKeys( level._random_perk_machine_perk_list );

		for(i = 0; i < keys.size; i++)
		{
			if(level._random_perk_machine_perk_list[ keys[ i ] ] == "specialty_widowswine")
			{
				level._random_perk_machine_perk_list[ keys[ i ] ] = "specialty_phdflopper";
			}
		}
	}
}

function modify_3arc_maps()
{
	mapname = level.CurrentMap;

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

function private include_perk_in_random_rotation( perk )
{
	if( !isdefined(level._random_perk_machine_perk_list) )
	{
		level._random_perk_machine_perk_list = [];
	}

	level._random_perk_machine_perk_list = array::add(level._random_perk_machine_perk_list, perk);
}