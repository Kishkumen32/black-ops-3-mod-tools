#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\_load;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perks;

#namespace dev;

function init()
{
	level thread lots_o_points( 500000 );
	level thread set_perk_limit(13);
}

function lots_o_points( points )
{
	level flag::wait_till( "all_players_connected" );
	players = getplayers(); 
	for( i=0;i<players.size;i++ )
	{
		players[i].score = points; 
	}
}

function set_perk_limit(num)
{
	wait( 30 ); 
	level.perk_purchase_limit = num;
}