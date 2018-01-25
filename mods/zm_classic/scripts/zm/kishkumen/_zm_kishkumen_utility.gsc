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

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_score;

#namespace zm_kishkumen_utility; 

function private dev_mode()
{
	if(!isdefined(level.debug))
	{
		level.debug = false;
	}

	if(level.debug)
	{
		wait 10;

		iPrintLn( "GIVE POINTS" );

		players = GetPlayers();
		for ( i = 0; i < players.size; i++ )
		{
			players[ i ] zm_score::add_to_player_score( 500000 );
		}

		level.perk_purchase_limit = 10;
	}
	else
	{
		anti_cheat();
	}
}

function RemoveAllBGBMachines()
{
	if(!isdefined(level.bgb_machine_spots))
	{
		level.bgb_machine_spots = GetEntArray("bgb_machine_use","targetname");
	}

	for( i = 0; i < level.bgb_machine_spots.size; i++)
	{
		spot = level.bgb_machine_spots[i];
		spot Delete();	
	}	
}

function RemoveAllWunderfizz()
{
	if(!isdefined(level.wunderfizz_machine_spots))
	{
		level.wunderfizz_machine_spots = GetEntArray("perk_random_machine","targetname");
	}

	for( i = 0; i < level.wunderfizz_machine_spots.size; i++)
	{
		spot = level.wunderfizz_machine_spots[i];
		spot Delete();
	}	
}

function origin_angle_print()
{
	if(!isdefined(level.debug_coord))
	{
		level.debug_coord = false;
	}

	if(level.debug_coord)
	{
		wait 5;
		while( 1 )
		{
			players = GetPlayers();
			
			iPrintLn( "RUNNING" );
			iPrintLn( "ORIGIN: " + players[ 0 ].origin );
			iPrintLn( "ANGLES: " + players[ 0 ].angles );
			wait 1;
		}
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