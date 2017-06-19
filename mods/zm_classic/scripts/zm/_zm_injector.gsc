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

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_score;
#using scripts\zm\gametypes\_globallogic_score;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_kishkumen_utility;

#using scripts\zm\_zm_perk_phdflopper;

#using scripts\zm\_zm_weap_ammo_counter;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_ammo_counter.gsh;

#insert scripts\zm\_zm_perk_phdflopper.gsh;

#precache( "fx", "weapon/fx_muz_sm_pistol_1p" );
#precache( "fx", "weapon/fx_muz_sm_pistol_3p" );
#precache( "fx", "weapon/fx_shellejects_pistol" );
#precache( "fx", "explosions/fx_exp_molotov_lotus" );
#precache( "fx", "weapon/fx_trail_fake_bullet" );
#precache( "model", "t7_props_dlc/zm/dlc0/der_riese/p7_zm_der2_teleporter_control_panel/p7_zm_der2_teleporter_control_panel_lod0" );

#precache( "fx", "weapon/fx_trail_crossbow" );

#namespace zm_injector;

REGISTER_SYSTEM( "zm_injector", &__init__, undefined )

function __init__()
{
	callback::on_start_gametype( &init );
	callback::on_spawned( &on_player_spawned ); 
}	

function init()
{
	level thread zm_kishkumen_utility::initBGBMachines();	
	level thread zm_kishkumen_utility::RemoveAllBGBMachines();

	level thread MapSpecific();

	level thread load_weapons();	
	level thread zm_kishkumen_utility::anti_cheat();

	//level thread zm_kishkumen_utility::debug();
	//level thread zm_kishkumen_utility::origin_angle_print();

	if(!(level.script == "zm_zod" || level.script == "zm_tomb"))
	{
		level.start_weapon = getWeapon("pistol_m1911");

		//playing coop
		level.default_laststandpistol = GetWeapon("pistol_m1911");

		//playing solo
		level.default_solo_laststandpistol = GetWeapon("aw_m1911_upgraded");
	};
}

function on_player_spawned()
{	
	
}

function load_weapons()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );

	if(zm_perk_utility::is_waw_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_waw_weapons.csv", 1 );		
	}

	if(zm_perk_utility::is_zc_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_zc_blackop3.csv", 1 );
	}

	if(zm_perk_utility::is_stock_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_vanilla_blackop3.csv", 1 );
	}
}

function MapSpecific()
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
			zm_kishkumen_utility::initWunderfizzMachines();
			zm_kishkumen_utility::RemoveAllWunderfizz();
		}
	};
}