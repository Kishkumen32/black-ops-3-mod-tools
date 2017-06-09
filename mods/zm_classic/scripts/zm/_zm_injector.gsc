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

#precache( "fx", "weapon/fx_muz_sm_pistol_1p" );
#precache( "fx", "weapon/fx_muz_sm_pistol_3p" );
#precache( "fx", "weapon/fx_shellejects_pistol" );
#precache( "fx", "harry/beacon/fx_beacon_artillery_explode" );
#precache( "fx", "harry/beacon/fx_beacon_artillery_trail" );

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

	level thread load_test_weapons();	
	level thread zm_kishkumen_utility::anti_cheat();

	//level thread zm_kishkumen_utility::debug();
	//level thread zm_kishkumen_utility::origin_angle_print();

	if(!(level.script == "zm_zod"))
	{
		level.start_weapon = getWeapon("pistol_m1911");

		//playing coop
		level.default_laststandpistol = GetWeapon("pistol_m1911");

		//playing solo
		//level.default_solo_laststandpistol = GetWeapon("pistol_m1911_upgraded");
		level.default_solo_laststandpistol = GetWeapon("aw_m1911_upgraded");
	}
}

function on_player_spawned()
{	
	level flag::wait_till( "initial_blackscreen_passed" );
}

function load_test_weapons()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t6_weapons.csv", 1 );
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_test_weapons.csv", 1 );
}