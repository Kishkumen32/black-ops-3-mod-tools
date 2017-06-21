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
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

#namespace zm_kishkumen_utility; 

function initBGBMachines()
{	
	level.bgb_machine_spots = GetEntArray( "bgb_machine_use", "targetname" );
}

function initWunderfizzMachines()
{
	level.wunderfizz_machine_spots = GetEntArray( "perk_random_machine", "targetname" );
}

function RemoveAllBGBMachines()
{
	for( i = 0; i < level.bgb_machine_spots.size; i++)
	{
		spot = level.bgb_machine_spots[i];

		if(isdefined(spot) && isdefined(spot.clip))
		{
			clip = spot.clip;

			clip Delete();
		}

		spot Delete();
	}	
}

function RemoveAllWunderfizz()
{
	for( i = 0; i < level.wunderfizz_machine_spots.size; i++)
	{
		spot = level.wunderfizz_machine_spots[i];

		if(isdefined(spot) && isdefined(spot.clip))
		{
			clip = spot.clip;

			clip Delete();
		}

		spot Delete();
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

	iPrintLn(level.script);

	a_keys = GetArrayKeys( level._custom_perks );
		
	for ( i = 0; i < a_keys.size; i++ )
	{
		iPrintLn(a_keys[ i ]);
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