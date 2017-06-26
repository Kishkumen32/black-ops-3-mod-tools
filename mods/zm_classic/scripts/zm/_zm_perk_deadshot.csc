#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_deadshot.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", "zombie/fx_perk_daiquiri_factory_zmb" );

#namespace zm_perk_deadshot;

REGISTER_SYSTEM( "zm_perk_deadshot", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( level.script == "zm_cosmodrome" || level.script == "zm_prototype" )
		return;

	enable_deadshot_perk_for_level();
}

function enable_deadshot_perk_for_level()
{
	zm_perks::register_perk_clientfields( 	PERK_DEAD_SHOT, &deadshot_client_field_func, &deadshot_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_DEAD_SHOT, DEADSHOT_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_DEAD_SHOT, &init_deadshot );
}

function init_deadshot()
{
	level._effect[ DEADSHOT_MACHINE_LIGHT_FX ]						= "zombie/fx_perk_daiquiri_factory_zmb";
}

function deadshot_client_field_func()
{
	clientfield::register( "toplayer", "deadshot_perk", VERSION_SHIP, 1, "int", &player_deadshot_perk_handler, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT ); 
}

function deadshot_code_callback_func() {}

function player_deadshot_perk_handler(localClientNum, oldVal, newVal, bNewEnt, bInitialSnap, fieldName, bWasTimeJump)
{
	if ( !self IsLocalPlayer() || IsSpectating( localClientNum, false ) || ( (isdefined(level.localPlayers[localClientNum])) && (self GetEntityNumber() != level.localPlayers[localClientNum] GetEntityNumber())) )
	{
		return;
	}
	
	if(newVal)
	{
		self UseAlternateAimParams();
	}
	else
	{
		self ClearAlternateAimParams();
	}
}
