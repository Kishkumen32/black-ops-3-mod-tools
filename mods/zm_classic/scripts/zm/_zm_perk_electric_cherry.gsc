#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;

#using scripts\zm\_zm_perk_utility;

#using scripts\zm\_zm_kishkumen_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_electric_cherry.gsh;

#precache( "model", ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
#precache( "model", ELECTRIC_CHERRY_MACHINE_ACTIVE_MODEL );

#precache( "fx", "zombie/fx_perk_quick_revive_zmb" );
#precache( "fx", "zombie/fx_perk_quick_revive_factory_zmb" );
#precache( "fx", "dlc1/castle/fx_castle_electric_cherry_down" );

#namespace zm_perk_electric_cherry;

REGISTER_SYSTEM( "zm_perk_electric_cherry", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_electric_cherry_perk_for_level();
	place_perk();
}

function enable_electric_cherry_perk_for_level()
{	
	zm_perks::register_perk_basic_info( 			PERK_ELECTRIC_CHERRY, "electric_cherry", 						ELECTRIC_CHERRY_PERK_COST, 			"Hold ^3[{+activate}]^7 for Electric Cherry [Cost: &&1]", getWeapon( ELECTRIC_CHERRY_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_ELECTRIC_CHERRY, &electric_cherry_precache );
	zm_perks::register_perk_clientfields( 			PERK_ELECTRIC_CHERRY, &electric_cherry_register_clientfield, 	&electric_cherry_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_ELECTRIC_CHERRY, &electric_cherry_perk_machine_setup );
	zm_perks::register_perk_host_migration_params( 	PERK_ELECTRIC_CHERRY, ELECTRIC_CHERRY_RADIANT_MACHINE_NAME, 	ELECTRIC_CHERRY_MACHINE_LIGHT_FX );
	zm_perks::register_perk_threads( 				PERK_ELECTRIC_CHERRY, &electric_cherry_reload_attack , 			&electric_cherry_perk_lost );

	init_electric_cherry();
}

function place_perk()
{
	if ( level.script == "zm_factory" || level.script == "zm_zod" || zm_perk_utility::is_zc_map() )
		return;
		
	if(!isdefined(level.bgb_machine_spots))
	{
		zm_kishkumen_utility::initBGBMachines();
	}

	level.bgb_machine_spots = array::randomize( level.bgb_machine_spots );

	bgb_spot = level.bgb_machine_spots[0];

	if(isdefined(bgb_spot))
	{
		bgb_spot_orgin = bgb_spot.origin;
		bgb_spot_angles = bgb_spot.angles;

		bgb_spot delete();	

		ArrayRemoveIndex(level.bgb_machine_spots,0);

		zm_perk_utility::place_perk_machine( bgb_spot_orgin , bgb_spot_angles, PERK_ELECTRIC_CHERRY, ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL );
	}
}

function electric_cherry_precache()
{
	if ( zm_perk_utility::is_stock_map() && level.script != "zm_factory" )
		level._effect[ ELECTRIC_CHERRY_MACHINE_LIGHT_FX ] = "zombie/fx_perk_quick_revive_zmb";
	else
		level._effect[ ELECTRIC_CHERRY_MACHINE_LIGHT_FX ] = "zombie/fx_perk_quick_revive_factory_zmb";
	
	level.machine_assets[ PERK_ELECTRIC_CHERRY ] 			= spawnStruct();
	level.machine_assets[ PERK_ELECTRIC_CHERRY ].weapon 	= getWeapon( ELECTRIC_CHERRY_PERK_BOTTLE_WEAPON );
	level.machine_assets[ PERK_ELECTRIC_CHERRY ].off_model 	= ELECTRIC_CHERRY_MACHINE_DISABLED_MODEL;
	level.machine_assets[ PERK_ELECTRIC_CHERRY ].on_model 	= ELECTRIC_CHERRY_MACHINE_ACTIVE_MODEL;
}

function electric_cherry_register_clientfield() {}

function electric_cherry_set_clientfield( state ) {}

function electric_cherry_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_cherry_jingle";
	use_trigger.script_string = "electriccherry_perk";
	use_trigger.script_label = "mus_perks_cherry_sting";
	use_trigger.target = "vending_electriccherry";
	perk_machine.script_string = "electriccherry_perk";
	perk_machine.targetname = "vending_electriccherry";
	if( isDefined( bump_trigger ) )
		bump_trigger.script_string = "electriccherry_perk";
	
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function init_electric_cherry()
{	
	level._effect[ "electric_cherry_explode" ] = "dlc1/castle/fx_castle_electric_cherry_down";
	
	level.custom_laststand_func = &electric_cherry_laststand;
	
	zombie_utility::set_zombie_var( "tesla_head_gib_chance", 50 );
	
	clientfield::register( "allplayers", "electric_cherry_reload_fx", VERSION_SHIP, 2, "int" );
	clientfield::register( "actor", "tesla_death_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "vehicle", "tesla_death_fx_veh", VERSION_TU10, 1, "int" );
	clientfield::register( "actor", "tesla_shock_eyes_fx", VERSION_SHIP, 1, "int" );
	clientfield::register( "vehicle", "tesla_shock_eyes_fx_veh", VERSION_TU10, 1, "int" );
}

function electric_cherry_laststand()
{	
	visionSetLastStand( "zombie_last_stand", 1 );
	
	if ( isDefined( self ) )
	{
		playFX( level._effect[ "electric_cherry_explode" ], self.origin );
		self PlaySound( "zmb_cherry_explode" );
		self notify( "electric_cherry_start" );
		
		wait .05;
			
		a_zombies = zombie_utility::get_round_enemy_array();
		a_zombies = util::get_array_of_closest( self.origin, a_zombies, undefined, undefined, ELECTRIC_CHERRY_DOWNED_ATTACK_RADIUS );
		
		for ( i = 0; i < a_zombies.size; i++ )
		{
			if ( isAlive( self ) && isAlive( a_zombies[ i ] ) )
			{
				if ( a_zombies[ i ].health <= ELECTRIC_CHERRY_DOWNED_ATTACK_DAMAGE )
				{
					a_zombies[ i ] thread electric_cherry_death_fx();
					
					if( isDefined( self.cherry_kills ) )
						self.cherry_kills++;
					
					self zm_score::add_to_player_score( ELECTRIC_CHERRY_DOWNED_ATTACK_POINTS );
				}
				else
				{
					a_zombies[ i ] thread electric_cherry_stun();
					a_zombies[ i ] thread electric_cherry_shock_fx();
				}
				
				wait .1;
				
				a_zombies[ i ] DoDamage( ELECTRIC_CHERRY_DOWNED_ATTACK_DAMAGE, self.origin, self, self, "none" );
			}
		}
		self notify( "electric_cherry_end" );
	}
}

function electric_cherry_death_fx()
{
	self endon( "death" );
	
	self playSound( "zmb_elec_jib_zombie" );
	
	if ( !IS_TRUE( self.head_gibbed ) )
	{
		if( isVehicle( self ) )
			self clientfield::set( "tesla_shock_eyes_fx_veh", 1 );
		else
			self clientfield::set( "tesla_shock_eyes_fx", 1 );
	}
	else
	{
		if( isVehicle( self ) )
			self clientfield::set( "tesla_death_fx_veh", 1 );
		else
			self clientfield::set( "tesla_death_fx", 1 );
		
	}		
}

function electric_cherry_shock_fx()
{
	self endon( "death" );
	
	if( isVehicle( self ) )
		self clientfield::set( "tesla_shock_eyes_fx_veh", 1 );
	else
		self clientfield::set( "tesla_shock_eyes_fx", 1 );
	
	self playSound( "zmb_elec_jib_zombie" );
	
	self waittill( "stun_fx_end" );	

	if( isVehicle( self ) )
		self clientfield::set( "tesla_shock_eyes_fx_veh", 0 );
	else
		self clientfield::set( "tesla_shock_eyes_fx", 0 );
	
}

function electric_cherry_stun()
{
	self endon("death");

	self notify( "stun_zombie" );
	self endon( "stun_zombie" );

	if ( self.health <= 0 )
		return;
	
	if ( self.ai_state !== "zombie_think" )
		return;	
	
	self.zombie_tesla_hit = 1;		
	self.ignoreall = 1;

	wait ELECTRIC_CHERRY_STUN_CYCLES;

	if ( isDefined( self ) )
	{	
		self.zombie_tesla_hit = 0;		
		self.ignoreall = 0;
		self notify( "stun_fx_end" );	
	}
}

function electric_cherry_reload_attack()
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( PERK_ELECTRIC_CHERRY + "_stop" );

	self zm_perk_utility::create_perk_hud( PERK_ELECTRIC_CHERRY );
	
	self.wait_on_reload = [];
	self.consecutive_electric_cherry_attacks = 0;
	
	while( 1 )
	{
		self waittill( "reload_start" );
		
		current_weapon = self GetCurrentWeapon();
		
		if( isInArray( self.wait_on_reload, current_weapon ) )
			continue;	
		
		self.wait_on_reload[self.wait_on_reload.size] = current_weapon;
		
		self.consecutive_electric_cherry_attacks++;
		
		n_clip_current = 1;
		n_clip_max = 10;
		n_fraction = n_clip_current/n_clip_max;
	
		perk_radius = math::linear_map( n_fraction, 1.0, 0.0, RELOAD_ATTACK_MIN_RADIUS, RELOAD_ATTACK_MAX_RADIUS );
		perk_dmg = math::linear_map( n_fraction, 1.0, 0.0, RELOAD_ATTACK_MIN_DAMAGE, RELOAD_ATTACK_MAX_DAMAGE );
		
		self thread check_for_reload_complete( current_weapon );
		
		if ( isDefined( self ) )
		{			
			switch( self.consecutive_electric_cherry_attacks )
			{
				case 0:
				case 1:
					n_zombie_limit = undefined;
					break;
				case 2:
					n_zombie_limit = 8;
					break;
				case 3:
					n_zombie_limit = 4;
					break;
				case 4:
					n_zombie_limit = 2;
					break;
				default:
					n_zombie_limit = 0;
			
			}

			self thread electric_cherry_cooldown_timer( current_weapon );
			
			if( isDefined(n_zombie_limit) && (n_zombie_limit == 0) )
				continue;
			
			self thread electric_cherry_reload_fx( n_fraction );
			self notify( "electric_cherry_start" );
			self playSound( "zmb_cherry_explode" );
			
			a_zombies = zombie_utility::get_round_enemy_array();
			a_zombies = util::get_array_of_closest( self.origin, a_zombies, undefined, undefined, perk_radius );
			
			n_zombies_hit = 0;
			
			for ( i = 0; i < a_zombies.size; i++ )
			{
				if ( isAlive( self ) && isAlive( a_zombies[ i ] ) )
				{
					if ( isDefined( n_zombie_limit ) )
					{
						if ( n_zombies_hit < n_zombie_limit )
							n_zombies_hit++;							
						else
							break;
						
					}
					
					if ( a_zombies[ i ].health <= perk_dmg )
					{
						a_zombies[ i ] thread electric_cherry_death_fx();
						
						if( isDefined( self.cherry_kills ) )
							self.cherry_kills++;
					
						self zm_score::add_to_player_score( RELOAD_ATTACK_POINTS );
					}
					else
					{
						if( !isDefined( a_zombies[ i ].is_brutus ) )
							a_zombies[ i ] thread electric_cherry_stun();	
						
						a_zombies[ i ] thread electric_cherry_shock_fx();
					}
					
					wait .1;
					
					if ( isDefined( a_zombies[ i ] ) && isAlive( a_zombies[ i ] ) )
						a_zombies[ i ] doDamage( perk_dmg, self.origin, self, self, "none" );
					
				}
			}
			self notify( "electric_cherry_end" );	
		}
	}
}

function electric_cherry_perk_lost( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_ELECTRIC_CHERRY );
	self notify( PERK_ELECTRIC_CHERRY + "_stop" );
	self notify( "perk_lost", str_perk );
}

function electric_cherry_cooldown_timer( current_weapon )
{
	self notify( "electric_cherry_cooldown_started" );
	self endon( "electric_cherry_cooldown_started" );
	self endon( "death" );
	self endon( "disconnect" );
	
	n_reload_time = 0.25;
	if ( self hasPerk( "specialty_fastreload" ) )
		n_reload_time *= GetDvarFloat( "perk_weapReloadMultiplier" );
	
	n_cooldown_time = ( n_reload_time + RELOAD_ATTACK_COOLDOWN_TIMER );
	
	wait n_cooldown_time;
	
	self.consecutive_electric_cherry_attacks = 0;
}

function check_for_reload_complete( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "player_lost_weapon_" + weapon.name );
	
	self thread weapon_replaced_monitor( weapon );
	
	while( 1 )
	{
		self waittill( "reload" );
		
		current_weapon = self getCurrentWeapon();
		if( current_weapon == weapon )
		{
			arrayRemoveValue( self.wait_on_reload, weapon );
			self notify( "weapon_reload_complete_" + weapon.name );
			break;
		}
	}
}

function weapon_replaced_monitor( weapon )
{
	self endon( "death" );
	self endon( "disconnect" );
	self endon( "weapon_reload_complete_" + weapon.name );
	
	while( 1 )
	{
		self waittill( "weapon_change" );

		primaryWeapons = self getWeaponsListPrimaries();
		if( !IsInArray( primaryWeapons, weapon ) )
		{
			self notify( "player_lost_weapon_" + weapon.name );
			arrayRemoveValue( self.wait_on_reload, weapon );
			break;
		}
	}
}

function electric_cherry_reload_fx( n_fraction )
{
	if( n_fraction >= 0.67 )
	{
		CodeSetClientField( self, "electric_cherry_reload_fx", 1 );	
	}
	else if( (n_fraction >= 0.33) && (n_fraction < 0.67) )
	{
		CodeSetClientField( self, "electric_cherry_reload_fx", 2 );	
	}
	else
	{
		CodeSetClientField( self, "electric_cherry_reload_fx", 3 );	
	}
	
	wait ( 1.0 );
	
	CodeSetClientField( self, "electric_cherry_reload_fx", 0 );
}