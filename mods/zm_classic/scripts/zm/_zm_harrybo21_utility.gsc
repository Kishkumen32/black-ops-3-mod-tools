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
#using scripts\zm\_zm_zonemgr;

#using scripts\shared\ai\zombie_utility;

#namespace zm_harrybo21_utility;

//*****************************************************************************
// MAIN
//*****************************************************************************

function ignoreme_failsafe()
{
	self endon( "kill_ignoreme" );
	self endon( "death" );
	self endon( "fake_death" );
	self endon( "player_downed" );
	while( 1 )
	{
		if ( !isDefined( self.ignoreme ) || !self.ignoreme )
			self.ignoreme = 1;
		
		wait .05;
	}
}

function clear_ignoreme()
{
	if ( isDefined( self.zombie_blood ) && self.zombie_blood )
		return;
	
	if ( isDefined( self.vulture_level ) && self.vulture_level > 0 )
		return;
	
	hud = undefined;
	if ( isDefined( self.perk_hud ) && self.perk_hud.size > 0 )
	{
		for ( i = 0; i < self.perk_hud.size; i++ )
		{
			if ( self.perk_hud[ i ].perk == "specialty_vultureaid" )
			{
				hud = self.perk_hud[ i ];
				break;
			}
		}
	}
	
	if ( isDefined( hud ) && isDefined( hud.mist_hud ) && isDefined( hud.glow_hud ) )
	{
		hud.mist_hud.alpha = 0;
		hud.glow_hud.alpha = 0;
	}
	
	self.ignoreme = 0;
	self notify( "kill_ignoreme" );
}

/* 
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
*/
function harrybo21_cache_script( string, something )
{
	if ( !isDefined( level.harrybo21_script_cache ) || level.harrybo21_script_cache.size < 1 )
		level.harrybo21_script_cache = [];
	
	if ( isDefined( level.harrybo21_script_cache[ string ] ) )
		return;
	
	level.harrybo21_script_cache[ string ] = something;
	
}

function harrybo21_error_callback_log( message, return_value )
{
	// STORE INFO HERE
	
	if ( isDefined( return_value ) )
		return return_value;
	
}

function harrybo21_spawn_trigger_radius_use( origin, angles, spawn_flag, radius, height )
{
	if ( !isDefined( origin ) )
		origin = harrybo21_error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", ( 0, 0, 0 ) ); // FUNCTION CALLED WITH NO ORIGIN
	if ( !isDefined( angles ) )
		angles = harrybo21_error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", ( 0, 0, 0 ) ); // FUNCTION CALLED WITH NO ANGLES
	if ( !isDefined( spawn_flag ) )
		spawn_flag = harrybo21_error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", 1 ); // FUNCTION CALLED WITH NO SPAWN FLAGS
	if ( !isDefined( radius ) )
		radius = harrybo21_error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", 256 ); // FUNCTION CALLED WITH NO RADIUS
	if ( !isDefined( height ) )
		height = harrybo21_error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", 128 ); // FUNCTION CALLED WITH NO HEIGHT
	
	trigger = spawn( "trigger_radius_use", origin, spawn_flag, radius, height );
	trigger.angles = angles;
	
	trigger triggerIgnoreTeam();
	trigger setVisibleToAll();
	trigger setTeamForTrigger( "none" );
	trigger useTriggerRequireLookAt();
	trigger setCursorHint( "HINT_NOICON" );
	trigger setHintString( "" );
	
	return trigger;
}

function harrybo21_spawn_blank_script_model( origin, angles )
{
	if ( !isDefined( origin ) )
		origin = harrybo21_error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", ( 0, 0, 0 ) ); // FUNCTION CALLED WITH NO ORIGIN
	if ( !isDefined( angles ) )
		angles = harrybo21_error_callback_log( "WE WOULD PASS OUR ERROR MESSAGE HERE", ( 0, 0, 0 ) ); // FUNCTION CALLED WITH NO ANGLES
	
	fx_ent = spawn( "script_model", origin );
	fx_ent.angles = angles;
	fx_ent setModel( "tag_origin" );
	
	return fx_ent;
}
/* 
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
#################################################################################################################
*/
