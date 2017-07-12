// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#namespace wardog_load;

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::add_callback(#"on_finalize_initialization", &__init__);
	callback::add_callback(#"on_start_gametype", &__post_init__);
	callback::on_connect(&__player_connect__);
}

function __pre_init__()
{
	level.debug = false;
	level.debug_coord = false;
}

function __init__()
{
}

function __post_init__()
{
	
}

function __player_connect__()
{
	if(isdefined(level.debug) && !level.debug)
	{		
		level thread anti_cheat();
	}

	if(isdefined(level.debug_coord) && isdefined(level.debug) && level.debug_coord && level.debug)
	{
		level thread origin_angle_print();
	}
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

function anti_cheat()
{
	ModVar( "god", 0 ); 
	ModVar( "noclip", 0 ); 
	ModVar( "give", 0 ); 
	ModVar( "notarget", 0 ); 
	ModVar( "demigod", 0 ); 
	ModVar( "ufo", 0 );  
}