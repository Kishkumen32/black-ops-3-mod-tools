#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

// Wardog Scripts
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;
#using scripts\wardog\zm\perks\wardog_perk_hud;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_pack_a_punch_util;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_phdflopper;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
#using scripts\zm\_zm_powerup_ww_grenade;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\_zm_perks;
#using scripts\zm\zm_usermap;

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::add_callback(#"on_finalize_initialization", &__init__);
	callback::add_callback(#"on_start_gametype", &__post_init__);
}

function __pre_init__()
{
	level.debug = true;
}

function __init__()
{

}

function __post_init__()
{
	zm_usermap::main();

	//Power Lights
	thread power_lights();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;

	init_zones[0] = "start_zone";

	level thread zm_zonemgr::manage_zones( init_zones );

	level thread add_zm_vox();

	level.pathdist_type = PATHDIST_ORIGINAL;

	level.random_pandora_box_start = true;

	level.start_weapon = getWeapon("bo3_m1911");

	//playing coop
	level.default_laststandpistol = GetWeapon("bo3_m1911");

	//playing solo
	level.default_solo_laststandpistol = GetWeapon("bo3_m1911_upgraded");
}

function power_lights()
{
	level flag::wait_till( "power_on" );
	level util::set_lighting_state( 0 );
	level flag::wait_till( "power_off" );
	level util::set_lighting_state( 1 );
	power_lights();
}

function usermap_test_zone_init()
{
	level flag::init( "always_on" );
	level flag::set( "always_on" );
}	

function custom_add_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function add_zm_vox()
{
	zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_vox.csv");
}