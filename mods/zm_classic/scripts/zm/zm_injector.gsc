// Author: HarryBo21

#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_score;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

#namespace zm_injector;

function autoexec init()
{
	level thread origin_angle_print();
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