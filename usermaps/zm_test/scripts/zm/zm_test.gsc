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
#using scripts\zm\_zm_perk_wunderfizz;
#using scripts\zm\_zm_perk_phdflopper;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;
//#using scripts\zm\_zm_powerup_weapon_minigun;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

// NSZ Empty Bottle Powerup
#using scripts\_NSZ\nsz_powerup_empty_bottle;

// NSZ Zombie Blood Powerup
#using scripts\_NSZ\nsz_powerup_zombie_blood;

// NSZ Zombie Money Powerup
#using scripts\_NSZ\nsz_powerup_money;

// NSZ Kino Teleporter
#using scripts\_NSZ\nsz_kino_teleporter;

// NSZ Brutus
#using scripts\_NSZ\nsz_brutus;
#using scripts\_NSZ\nsz_buyable_ending;

#using scripts\zm\zm_flamethrower;

//*****************************************************************************
// MAIN
//*****************************************************************************

function main()
{
	// NSZ Kino Teleporter
	level thread nsz_kino_teleporter::init(); 

	// NSZ Brutus
	brutus::init(); 

	// NSZ Temp Wall Buys
	level thread buyable_ending::init(); 

	zm_usermap::main();

	zm_flamethrower::init();

	//Power Lights
	thread power_lights();
	
	level._zombie_custom_add_weapons =&custom_add_weapons;
	
	//Setup the levels Zombie Zone Volumes
	level.zones = [];
	level.zone_manager_init_func =&usermap_test_zone_init;

	init_zones[0] = "start_zone";
	init_zones[1] = "start_zone_left";
	init_zones[2] = "start_zone_middle";
	init_zones[3] = "start_zone_right";
	init_zones[4] = "black_box_zone";
	init_zones[5] = "pap_zone";
	init_zones[6] = "pap_random_zone";

	level thread zm_zonemgr::manage_zones( init_zones );

	level thread add_zm_vox();

	level.pathdist_type = PATHDIST_ORIGINAL;

	level.random_pandora_box_start = true;

	level.start_weapon = getWeapon("bo3_m1911");

	//playing coop

	level.default_laststandpistol = GetWeapon("bo3_m1911");

	//playing solo

	level.default_solo_laststandpistol = GetWeapon("bo3_m1911_upgraded");

	//level anti_cheat();

	level thread set_perk_limit(13);

	level.player_starting_points = 500000;
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

function anti_cheat()
{
	ModVar( "god", 0 ); 
	ModVar( "noclip", 0 ); 
	ModVar( "give", 0 ); 
	ModVar( "notarget", 0 ); 
	ModVar( "demigod", 0 ); 
	ModVar( "ufo", 0 );  
}

function set_perk_limit(num)
{
	wait( 30 ); 
	level.perk_purchase_limit = num;
}

function add_zm_vox()
{
 zm_audio::loadPlayerVoiceCategories("gamedata/audio/zm/zm_vox.csv");
}

function power_lights()
{
	level flag::wait_till( "power_on" );
	level util::set_lighting_state( 0 );
	level flag::wait_till( "power_off" );
	level util::set_lighting_state( 1 );
	power_lights();
}