#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\gametypes\_globallogic_score;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_score;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_wunderfizz;

#precache("fx","harry/multigrenade/fx_multigrenade_blue");
#precache("fx","harry/multigrenade/fx_multigrenade_green");
#precache("fx","harry/multigrenade/fx_multigrenade_red");
#precache("fx","harry/multigrenade/fx_multigrenade_yellow");

#namespace zm_injector;

function autoexec init()
{
	//load_t6_weapons();
	//level thread origin_angle_print();
	level thread RemoveBGBMachines();
	level thread debug();
}

function origin_angle_print()
{
	wait 5;
	while( 1 )
	{
		players = getPlayers();
		
		iPrintLn( "RUNNING" );
		iPrintLn( "ORIGIN: " + players[ 0 ].origin );
		iPrintLn( "ANGLES: " + players[ 0 ].angles );
		wait 1;
	}
}

function load_t6_weapons()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_t6_weapons.csv", 1 );
}

function debug()
{
	wait 10;
	iPrintLn( "GIVE POINTS" );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] zm_score::add_to_player_score( 500000 );
	}
	level.perk_purchase_limit = 13;
}

function RemoveBGBMachines()
{
	bgb_machines = GetEntArray( "bgb_machine_use", "targetname" );

	foreach(machine in bgb_machines)
	{
		machine delete();
	}
}