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

#using scripts\zm\_zm_weapons_custom;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perk_phdflopper;

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

function __init__()
{
	if( level.CurrentMap == "zm_cosmodrome" || level.CurrentMap == "zm_temple" || level.CurrentMap == "zm_moon" || level.CurrentMap == "zm_tomb" )
	{
		replace_widows_wine();
	}

	zm_weapons_custom::include_weapons();
	zm_weapons_custom::ReplaceWallWeapons();

	callback::on_start_gametype( &init );
}

function init()
{
	zm_injector::main();
}

function main()
{
	zm_weapons_custom::include_weapons();

	if(!(level.CurrentMap == "zm_zod" || level.CurrentMap == "zm_tomb"))
	{
		level.start_weapon = getWeapon("bo3_m1911");

		//playing coop
		level.default_laststandpistol = GetWeapon("bo3_m1911");

		//playing solo
		level.default_solo_laststandpistol = GetWeapon("pistol_standard_upgraded");

        level.laststandpistol = level.default_laststandpistol;
	};

	MapSpecific();

	//zm_kishkumen_utility::anti_cheat();
	zm_kishkumen_utility::debug();
}

function replace_widows_wine()
{
	machines = struct::get_array( "zm_perk_machine", "targetname" );

	for( i = 0; i < machines.size; i++ )
	{
		if(machines[i].script_noteworthy == "specialty_widowswine")
		{
			machines[i].model = "zombie_vending_nuke";
			machines[i].script_noteworthy = "specialty_phdflopper";
		}
	}

	vending_triggers = GetEntArray( "zombie_vending", "targetname" );

	for( i = 0; i < vending_triggers.size; i++ )
	{
		if(vending_triggers[i].script_noteworthy == "specialty_widowswine")
		{
			vending_triggers[i].script_noteworthy = "specialty_phdflopper";
		}
	}
}

function MapSpecific()
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
		}
	};
}
