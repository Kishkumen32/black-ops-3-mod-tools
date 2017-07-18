#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perk_wunderfizz.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "model", WUNDERFIZZ_MACHINE_MODEL );
#precache( "model", WUNDERFIZZ_MACHINE_MODEL_ON );
#precache( "model", WUNDERFIZZ_BEAR_BOTTLE_MODEL );

#precache( "xanim", WUNDERFIZZ_MACHINE_IDLE );
#precache( "xanim", WUNDERFIZZ_MACHINE_VENDING );
#precache( "xanim", WUNDERFIZZ_MACHINE_TURN_OFF );
#precache( "xanim", WUNDERFIZZ_MACHINE_TURN_ON );

#precache( "fx", WUNDERFIZZ_MARKER_FX );
#precache( "fx", WUNDERFIZZ_BOTTLE_GLOW_FX );
#precache( "fx", WUNDERFIZZ_SPARK_FX );
#precache( "fx", WUNDERFIZZ_SPOTLIGHT_FX );
#precache( "fx", WUNDERFIZZ_GREEN_LIGHT_FX );
#precache( "fx", WUNDERFIZZ_RED_LIGHT_FX );

#using_animtree( "wunderfizz" );

#namespace zm_perk_wunderfizz;

REGISTER_SYSTEM( "zm_perk_wunderfizz", &__init__, undefined )

// DER WUNDERFIZZ ( DER WUNDERFIZZ )

//-----------------------------------------------------------------------------------
// setup
//-----------------------------------------------------------------------------------
function __init__()
{
	level thread enable_wunderfizz_for_level();
}

function enable_wunderfizz_for_level()
{	
	level.wunderfizz_max_uses = 8;
	level.wunderfizz_min_uses = 3;
	level.fizz_cost = 1500;
	
	fizz_machines = struct::get_array( "harrybo21_wunderfizz", "targetname" );
	if ( isDefined( fizz_machines ) && fizz_machines.size > 0 )
	{
		for ( i = 0; i < fizz_machines.size; i++ )
			fizz_machines[ i ] wunderfizz_perk_machine_setup();
		
	}
	
	wait getAnimLength( WUNDERFIZZ_MACHINE_TURN_OFF );
	
	spawned_machines = wunderfizz_get_machine_triggers();
	spawned_machines[ randomInt( spawned_machines.size ) ] thread wunderfizz_arrive();
	
	level thread watch_for_power();
}

function watch_for_power()
{
	wait .05;
	while( 1 )
	{
		level flag::wait_till( "power_on" );
		spawned_machines = wunderfizz_get_machine_triggers();
		for ( i = 0; i < spawned_machines.size; i++ )
			spawned_machines[ i ] notify( "power_on" );
	
		level flag::wait_till_clear( "power_on" );
		spawned_machines = wunderfizz_get_machine_triggers();
		for ( i = 0; i < spawned_machines.size; i++ )
			spawned_machines[ i ] notify( "power_off" );
	
	}
}

function wunderfizz_get_machine_triggers()
{
	return getEntArray( "harrybo21_wunderfizz", "script_noteworthy" );
}

function get_free_wunderfizz_array()
{
	fizzs = wunderfizz_get_machine_triggers();
	if ( !isDefined( fizzs ) || fizzs.size < 1 )
		return undefined;
	
	array = [];
	for ( i = 0; i < fizzs.size; i++ )
	{
		if ( isDefined( fizzs[ i ].occupied ) && fizzs[ i ].occupied )
			continue;
			
		array[ array.size ] = fizzs[ i ];
		
	}
	if ( !isDefined( array ) || array.size < 1 )
		return undefined;
	
	return array;
}

function wunderfizz_perk_machine_setup()
{
	trigger = spawn( "trigger_radius_use", self.origin + ( 0, 0, 30 ), 0, 40, 80 );
	trigger.script_noteworthy = "harrybo21_wunderfizz";
	trigger.occupied = 1;
	trigger.active = 0;	
	trigger.used = 0;	
	
	trigger TriggerIgnoreTeam();
	trigger SetVisibleToAll();
	trigger SetTeamForTrigger( "none" );
	trigger UseTriggerRequireLookAt();
	trigger SetCursorHint( "HINT_NOICON" );
	trigger SetHintString( "You must turn the Power on first!" );
	
	machine = spawn( "script_model", self.origin );
	machine.angles = self.angles;
	machine setModel( WUNDERFIZZ_MACHINE_MODEL );
	machine useAnimTree( #animtree );
	
	machine.collision = spawn( "script_model", self.origin, 1 );
	machine.collision.angles = self.angles;
	machine.collision setModel( "zm_collision_perks1" );
	machine.collision.script_noteworthy = "clip";
	machine.collision disconnectPaths();
	
	trigger.linked_model = machine;
	
	trigger thread wunderfizz_leave();
	trigger thread wunderfizz_powerwatcher();
	trigger thread wunderfizz_trigger_think( machine );
}

function wunderfizz_powerwatcher()
{
	wait .05;
	while( 1 )
	{
		self waittill( "power_on" );
		if ( IS_TRUE( self.occupied ) )
			self wunderfizz_activate();
		
		self waittill( "power_off" );
		self wunderfizz_deactivate();
	}
}

function wunderfizz_arrive( activate )
{
	self setHintstring( "" );
	wait .05;
	self.linked_model showPart( "ball_jnt" );
	self.linked_model animScripted( WUNDERFIZZ_MACHINE_TURN_ON, self.linked_model.origin , self.linked_model.angles, WUNDERFIZZ_MACHINE_TURN_ON );
	wait getAnimLength( WUNDERFIZZ_MACHINE_TURN_ON );
	self.occupied = 1;
	self.used = 0;
	
	self setHintstring( "You must turn the Power on first!" );
	
	if ( IS_TRUE( activate ) )
		self wunderfizz_activate();
	
	self thread wunderfizz_marker_fx( self.linked_model.origin );
}

function wunderfizz_marker_fx( origin )
{
	if ( isDefined( self.fx_obj ) )
		return;
	
	self.fx_obj = spawn( "script_model", origin );
	self.fx_obj.angles = ( -90, 0, 0 );
	self.fx_obj setModel( "tag_origin" );
	playFxOnTag( WUNDERFIZZ_MARKER_FX, self.fx_obj, "tag_origin" );
	while( isDefined( self.fx_obj ) )
	{
		playSoundAtPosition( "zmb_rand_perk_impact", origin );
		playSoundAtPosition( "zmb_rand_perk_electric_strike", origin );
		wait 5;
	}
}

function wunderfizz_leave()
{
	if ( isDefined( self.fx_obj ) )
		self.fx_obj delete();
	
	if ( IS_TRUE( self.active ) )
		self wunderfizz_deactivate();
	
	self setHintstring( "" );
	self.linked_model animScripted( WUNDERFIZZ_MACHINE_TURN_OFF, self.linked_model.origin , self.linked_model.angles, WUNDERFIZZ_MACHINE_TURN_OFF );
	wait getAnimLength( WUNDERFIZZ_MACHINE_TURN_OFF );
	self.linked_model hidePart( "ball_jnt" );
	self.occupied = 0;
	self.used = 0;
	self setHintstring( "Der Wunderfizz is at another location" );
}

function wunderfizz_activate()
{	
	self.linked_model setModel( WUNDERFIZZ_MACHINE_MODEL_ON );
	self setHintstring( "" );
	self.linked_model animScripted( WUNDERFIZZ_MACHINE_IDLE, self.linked_model.origin , self.linked_model.angles, WUNDERFIZZ_MACHINE_IDLE );
	self.active = 1;
	self setHintstring( "Press & hold ^3&&1^7 to buy Der Wunderfizz [Cost: " + level.fizz_cost + "]" );
	self.linked_model set_light_state( "active" );
}

function set_light_state( state )
{
	if ( isDefined( self.green_light ) )
		self.green_light delete();
	if ( isDefined( self.red_light ) )
		self.red_light delete();
	if ( isDefined( self.bottom_light ) )
		self.bottom_light delete();
	if ( isDefined( self.spotlight_left ) )
		self.spotlight_left delete();
	if ( isDefined( self.spotlight_right ) )
		self.spotlight_right delete();
	
	self.green_light = spawn( "script_model", self getTagOrigin( "fx_light_green" ) );
	self.green_light setModel( "tag_origin" );
	self.red_light = spawn( "script_model", self getTagOrigin( "fx_light_red" ) );
	self.red_light setModel( "tag_origin" );
	self.bottom_light = spawn( "script_model", self getTagOrigin( "fx_light_bottom" ) );
	self.bottom_light setModel( "tag_origin" );
	self.spotlight_left = spawn( "script_model", self getTagOrigin( "fx_spotlight_left" ) );
	self.spotlight_left setModel( "tag_origin" );
	self.spotlight_right = spawn( "script_model", self getTagOrigin( "fx_spotlight_right" ) );
	self.spotlight_right setModel( "tag_origin" );
	
	if ( state == "active" )
	{
		playFxOnTag( WUNDERFIZZ_GREEN_LIGHT_FX, self.green_light, "tag_origin" );
		playFxOnTag( WUNDERFIZZ_GREEN_LIGHT_FX, self.bottom_light, "tag_origin" );
		playFxOnTag( WUNDERFIZZ_SPOTLIGHT_FX, self.spotlight_left, "tag_origin" );
		playFxOnTag( WUNDERFIZZ_SPOTLIGHT_FX, self.spotlight_right, "tag_origin" );
	}
	else if ( state == "in_use" )
	{
		playFxOnTag( WUNDERFIZZ_RED_LIGHT_FX, self.red_light, "tag_origin" );
		playFxOnTag( WUNDERFIZZ_GREEN_LIGHT_FX, self.bottom_light, "tag_origin" );
		playFxOnTag( WUNDERFIZZ_SPOTLIGHT_FX, self.spotlight_left, "tag_origin" );
		playFxOnTag( WUNDERFIZZ_SPOTLIGHT_FX, self.spotlight_right, "tag_origin" );
	}
	else if ( state == "inactive" )
	{
		playFxOnTag( WUNDERFIZZ_RED_LIGHT_FX, self.bottom_light, "tag_origin" );
	}
}

function wunderfizz_deactivate()
{
	self setHintstring( "" );
	self.linked_model setModel( WUNDERFIZZ_MACHINE_MODEL );
	self.linked_model stopAnimScripted();
	self.active = 0;
	self setHintstring( "You must turn the Power on first!" );
	self.linked_model set_light_state( "inactive" );
}

function wunderfizz_trigger_think( machine )
{
	self endon( "delete" );
	self.used = 0;
	while( 1 )
	{
		perk = undefined;
		
		self waittill( "trigger", player );
		
		if( !player zm_score::can_player_purchase( level.fizz_cost ) )
		{
			self playSound( "evt_perk_deny" );
			player zm_audio::create_and_play_dialog( "general", "outofmoney" );
			continue;
		}

		if ( !player zm_utility::can_player_purchase_perk() )
		{
			self playSound( "evt_perk_deny" );
			player zm_audio::create_and_play_dialog( "general", "sigh" );
			continue;
		}

		if ( !isDefined( self.active ) || !self.active )
			continue;
		if ( !isDefined( self.occupied ) || !self.occupied )
			continue;
		
		sound = "evt_bottle_dispense";
		playSoundAtPosition( sound, self.origin );
		player zm_score::minus_to_player_score( level.fizz_cost );
		self setHintstring( "" );
		machine set_light_state( "in_use" );
		machine animScripted( WUNDERFIZZ_MACHINE_VENDING, machine.origin , machine.angles, WUNDERFIZZ_MACHINE_VENDING );

		self thread wunderfizz_in_use_fx( machine getTagOrigin( "halo_right_jnt" ), machine getTagOrigin( "halo_left_jnt" ), machine.angles );
		perk = self randomize_perk_bottle( player );
		self notify( "kill_spark_fx" );
		
		machine animScripted( WUNDERFIZZ_MACHINE_IDLE, machine.origin , machine.angles, WUNDERFIZZ_MACHINE_IDLE );
		if ( self check_for_teddy() )
		{
			perk setModel( WUNDERFIZZ_BEAR_BOTTLE_MODEL );
			wait 2;
			perk moveZ( 500, 4, 3 );
			wait 3;
			if ( isDefined( perk.glow_fx ) )
				perk.glow_fx delete();
			
			perk delete();
			
			new_fizz = get_free_wunderfizz();
			activate_new_fizz_location_after_move( self, new_fizz );
			continue;
		}
		
		self.used++;
		
		self setHintstring( "Press & hold ^3&&1^7 to take Perk" );
		self thread wonderfizz_wait_for_timeout();
		self thread wonderfizz_wait_for_take( player, perk.perk );
		
		self util::waittill_either( "fizz_timeout", "fizz_taken" );
		self setHintstring( "" );
		
		if ( isDefined( perk.glow_fx ) )
			perk.glow_fx delete();
		
		perk delete();
			
		wait 2;
		machine set_light_state( "active" );
		self setHintstring( "Press & hold ^3&&1^7 to buy Der Wunderfizz [Cost: " + level.fizz_cost + "]" );
	}
}

function wunderfizz_in_use_fx( origin1, origin2, angles )
{
	fx_spark1 = spawn( "script_model", origin1 );
	fx_spark1.angles = angles;
	fx_spark1 setModel( "tag_origin" );
	
	fx_spark2 = spawn( "script_model", origin2 );
	fx_spark2.angles = angles + ( 0, 180, 0 );
	fx_spark2 setModel( "tag_origin" );
	
	playFxOnTag( WUNDERFIZZ_SPARK_FX, fx_spark1, "tag_origin" );
	playFxOnTag( WUNDERFIZZ_SPARK_FX, fx_spark2, "tag_origin" );
	
	self waittill( "kill_spark_fx" );
	
	fx_spark1 delete();
	fx_spark2 delete();
}

function wonderfizz_wait_for_timeout()
{
	self endon( "fizz_timeout" );
	self endon( "fizz_taken" );
	
	wait 15;
	
	self notify( "fizz_timeout" );
}

function wonderfizz_wait_for_take( player, perk )
{
	self endon( "fizz_taken" );
	self endon( "fizz_timeout" );
	while( 1 )
	{
		self waittill( "trigger", player_take );
		
		if ( player != player_take )
			continue;
		
		break;			
	}
	// player thread maps\_zombiemode_perks::give_perk_bottle( perk );
	
	player thread zm_perks::vending_trigger_post_think( player, perk );
	
	self notify( "fizz_taken" );
}

function activate_new_fizz_location_after_move( old_fizz, new_fizz )
{
	old_fizz wunderfizz_leave();
	new_fizz wunderfizz_arrive( 1 );
}

function get_free_wunderfizz()
{
	fizzs = get_free_wunderfizz_array();
	if ( !isDefined( fizzs ) || fizzs.size < 1 )
		return undefined;
	
	fizzs = array::randomize( fizzs );
	return fizzs[ 0 ];
}

function check_for_teddy()
{
	fizz_free = get_free_wunderfizz();
	if ( !isDefined( fizz_free ) )
		return 0;
	else if ( self.used > level.wunderfizz_max_uses )
		return 1;
	else if ( self.used > level.wunderfizz_min_uses && self.used < level.wunderfizz_max_uses )
	{
		remainder = level.wunderfizz_max_uses - self.used;
		teddy = randomInt( remainder );
		if ( teddy == 0 )
			return 1;
		
	}
	
	return 0;
}

function play_active_sounds( origin )
{
	self endon( "done_cycling" );
	while( 1 )
	{
		playSoundAtPosition( "zmb_rand_perk_spark", origin );
		wait randomfloat( 1 );
	}
}

function randomize_perk_bottle( player )
{
	model = spawn( "script_model", self.linked_model.origin );
	model.angles = self.linked_model.angles;
	model thread perk_bottle_motion();
	// model thread wunderfizz_wobble_object();
	model thread play_active_sounds( model.origin );
	
	model.glow_fx = spawn( "script_model", model.origin );
	model.glow_fx setModel( "tag_origin" );
	playFxOnTag( WUNDERFIZZ_BOTTLE_GLOW_FX, model.glow_fx, "tag_origin" );
	model.glow_fx playLoopSound( "zmb_rand_perk_vortex_loop" );
	
	options = player get_unowned_perks();
	previous = randomInt( options.size );
	
	for( i = 0; i < 40; i++ )
	{
		current = randomInt( options.size );
		if ( current == previous && options.size > 1 )
		{
			i--;
			continue;
		}
		
		if( i < 20 )
			wait .05; 
		else if( i < 30 )
			wait .1; 
		else if( i < 35 )
			wait .2; 
		else if( i < 38 )
			wait .3;
		
		previous = current;
		model.perk = options[ current ];
		
		model setModel( getWeaponWorldModel( level._custom_perks[ options[ current ] ].perk_bottle_weapon ) );
	}
	model notify( "done_cycling" );
	return model;
}

function wunderfizz_wobble_object()
{
	self endon( "delete" );

	while ( isdefined( self ) )
	{
		waittime = randomfloatrange( 2.5, 5 );
		yaw = RandomInt( 90 );
		if( yaw > 300 )
			yaw = 300;
		if( yaw < 60 )
			yaw = 60;
		
		yaw = self.angles[ 1 ] + yaw;
		self rotateto ( ( -60 + randomint( 120 ), yaw, -45 + randomint( 90 ) ), waittime, waittime * 0.5, waittime * 0.5 );
		wait randomfloat( waittime - 0.1 );
	}
}

function get_unowned_perks()
{
	perks = getArrayKeys( level._custom_perks );
	if ( !isDefined( perks ) || perks.size < 1 )
		return undefined;
	
	array = [];
	for ( i = 0; i < perks.size; i++ )
	{
		if ( !self hasPerk( perks[ i ] ) )
			array[ array.size ] = perks[ i ];
		
	}
	if ( !isDefined( array ) || array.size < 1 )
		return undefined;
	
	return array;
}

function perk_bottle_motion()
{
	putouttime = 3;
	putbacktime = 10;
	v_float = anglesToForward( self.angles - ( 0, 90, 0 ) ) * 10;
	self.origin = self.origin + ( 0, 0, 53 );
	self.angles = self.angles;
	self.origin -= v_float;
	self moveto( self.origin + v_float, putouttime, putouttime * 0.5 );
	self.angles += ( 0, 0, 10 );
	self rotateYaw( 720, putouttime, putouttime * 0,5 );
	self waittill( "done_cycling" );
	self.angles = self.angles;
	self moveTo( self.origin - v_float, putbacktime, putbacktime * 0.5 );
	self rotateyaw( 90, putbacktime, putbacktime * 0.5 );
}