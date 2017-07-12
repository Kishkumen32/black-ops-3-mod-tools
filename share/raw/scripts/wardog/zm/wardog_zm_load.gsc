// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

// 3arc - Zombiemode
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\wardog\zm\perks\wardog_perk_hud;

#namespace wardog_zm_load;

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::add_callback(#"on_finalize_initialization", &__init__);
	callback::add_callback(#"on_start_gametype", &__post_init__);
}

function __pre_init__()
{
	level.CurrentMap = tolower(GetDvarString("mapname"));

	level.bgb_machine_spots = GetEntArray( "bgb_machine_use", "targetname" );
	level.wunderfizz_machine_spots = GetEntArray( "perk_random_machine", "targetname" );
}

function __init__()
{
	wardog_perk_hud::perk_hud_init();
}

function __post_init__()
{
	if(isdefined(level.debug) && level.debug)
	{
		dev_mode();
	}
}

function private dev_mode()
{
	wait 10;
	iPrintLn( "GIVE POINTS" );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] zm_score::add_to_player_score( 500000 );
	}

	level.perk_purchase_limit = 13;

	iPrintLn(level.CurrentMap);

	a_keys = GetArrayKeys( level._custom_perks );
		
	for ( i = 0; i < a_keys.size; i++ )
	{
		iPrintLn(a_keys[ i ]);
	}
}