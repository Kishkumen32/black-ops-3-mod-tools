#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_score;

#using scripts\zm\_zm_perk_phdflopper;

#using scripts\zm\_zm_weap_ammo_counter;

#insert scripts\zm\_zm.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_weap_ammo_counter.gsh;

#namespace zm_injector;

function autoexec init()
{
	level thread load_test_weapons();
}

function load_test_weapons()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t6_weapons.csv", 1 );
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_test_weapons.csv", 1 );
}