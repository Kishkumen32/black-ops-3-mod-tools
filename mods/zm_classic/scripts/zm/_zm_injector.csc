#using scripts\codescripts\struct;

#using scripts\shared\system_shared;
#using scripts\zm\_zm_weapons;

#insert scripts\shared\shared.gsh;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_wunderfizz;

#namespace zm_injector;

function autoexec init()
{
	//load_t6_weapons();	
}

function load_t6_weapons()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t6_weapons.csv", 1 );
}