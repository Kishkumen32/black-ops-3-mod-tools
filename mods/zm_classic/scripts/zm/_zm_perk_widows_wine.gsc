#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_util;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_bgb;
#using scripts\zm\_zm_laststand;
#using scripts\zm\_zm_melee_weapon;
#using scripts\zm\_zm_net;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_pers_upgrades;
#using scripts\zm\_zm_pers_upgrades_functions;
#using scripts\zm\_zm_pers_upgrades_system;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_spawner;
#using scripts\zm\_zm_stats;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_weapons;

#using scripts\zm\_zm_perk_utility;

#using scripts\zm\_zm_kishkumen_utility;

#using scripts\zm\_zm_powerup_ww_grenade;

#insert scripts\shared\archetype_shared\archetype_shared.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;
#insert scripts\zm\_zm_perk_widows_wine.gsh;

#namespace zm_perk_widows_wine;

#precache( "material", WIDOWS_WINE_SHADER );
#precache( "string", "ZOMBIE_PERK_WIDOWS_WINE" );
#precache( "fx", WIDOWS_WINE_FX_FILE_WRAP );
#precache( "fx", "zombie/fx_perk_juggernaut_factory_zmb" );
	
REGISTER_SYSTEM( "zm_perk_widows_wine", &__init__, undefined )	
	
//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( level.script == "zm_factory"  || level.script == "zm_prototype" || level.script == "zm_asylum" || level.script == "zm_sumpf" || level.script == "zm_theater" || level.script == "zm_cosmodrome" || level.script == "zm_temple" || level.script == "zm_moon" )
		return;
		
	enable_widows_wine_perk_for_level();
	place_perk();
}

function enable_widows_wine_perk_for_level()
{	
	zm_perks::register_perk_basic_info( 			PERK_WIDOWS_WINE, WIDOWS_WINE_NAME, 					WIDOWS_WINE_PERK_COST, 			&"ZOMBIE_PERK_WIDOWSWINE", getWeapon( WIDOWS_WINE_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_WIDOWS_WINE, &widows_wine_precache );
	zm_perks::register_perk_clientfields( 			PERK_WIDOWS_WINE, &widows_wine_register_clientfield, 	&widows_wine_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_WIDOWS_WINE, &widows_wine_perk_machine_setup );
	zm_perks::register_perk_host_migration_params( 	PERK_WIDOWS_WINE, WIDOWS_WINE_RADIANT_MACHINE_NAME, 	WIDOWS_WINE_FX_MACHINE_LIGHT );
	zm_perks::register_perk_threads( 				PERK_WIDOWS_WINE, &widows_wine_perk_activate, 			&widows_wine_perk_lost );

	clientfield::register( "toplayer", "widows_wine_1p_contact_explosion", VERSION_SHIP, 1, "counter" );
	
	init_widows_wine();	
}

function place_perk()
{
	if( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_island" || zm_perk_utility::is_zc_map() )
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

		zm_perk_utility::place_perk_machine( bgb_spot_orgin , bgb_spot_angles, PERK_WIDOWS_WINE, WIDOWS_WINE_MACHINE_DISABLED_MODEL );
	}
}

function widows_wine_precache()
{
	level._effect[ WIDOWS_WINE_FX_MACHINE_LIGHT ]	= WIDOWS_WINE_FX_FILE_MACHINE_LIGHT;
	level._effect[ WIDOWS_WINE_FX_WRAP ]				= WIDOWS_WINE_FX_FILE_WRAP;
		
	level.machine_assets[PERK_WIDOWS_WINE] 				= spawnStruct();
	level.machine_assets[PERK_WIDOWS_WINE].weapon 		= getWeapon( WIDOWS_WINE_PERK_BOTTLE_WEAPON );
	level.machine_assets[PERK_WIDOWS_WINE].off_model 	= WIDOWS_WINE_MACHINE_DISABLED_MODEL;
	level.machine_assets[PERK_WIDOWS_WINE].on_model 	= WIDOWS_WINE_MACHINE_ACTIVE_MODEL;
}

function widows_wine_register_clientfield()
{
	clientfield::register( "actor", CF_WIDOWS_WINE_WRAP, VERSION_SHIP, 1, "int" );
	clientfield::register( "vehicle", CF_WIDOWS_WINE_WRAP, VERSION_SHIP, 1, "int" );
}

function widows_wine_set_clientfield( state ) {}

function widows_wine_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound	= "mus_perks_widow_jingle";
	use_trigger.script_string	= "widowswine_perk";
	use_trigger.script_label	= "mus_perks_widow_sting";
	use_trigger.target			= "vending_widowswine";
	perk_machine.script_string	= "widowswine_perk";
	perk_machine.targetname		= "vending_widowswine";
	if( isDefined( bump_trigger ) )
		bump_trigger.script_string = "widowswine_perk";
	
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function init_widows_wine()
{	
	zm_utility::register_lethal_grenade_for_level( WIDOWS_WINE_GRENADE );
	zm_spawner::register_zombie_damage_callback( &widows_wine_zombie_damage_response );
	zm_spawner::register_zombie_death_event_callback( &widows_wine_zombie_death_watch );
	zm::register_vehicle_damage_callback( &widows_wine_vehicle_damage_response );
	zm_perks::register_perk_damage_override_func( &widows_wine_damage_callback );
	level.w_widows_wine_grenade = GetWeapon( WIDOWS_WINE_GRENADE );

	zm_utility::register_melee_weapon_for_level( WIDOWS_WINE_KNIFE );
	level.w_widows_wine_knife = GetWeapon( WIDOWS_WINE_KNIFE );

	zm_utility::register_melee_weapon_for_level( WIDOWS_WINE_BOWIE_KNIFE );
	level.w_widows_wine_bowie_knife = GetWeapon( WIDOWS_WINE_BOWIE_KNIFE );
}

function widows_wine_perk_activate()
{
	self zm_perk_utility::create_perk_hud( PERK_WIDOWS_WINE );
	if ( level.w_widows_wine_grenade == self zm_utility::get_player_lethal_grenade() )
		return;

	self.w_widows_wine_prev_grenade = self zm_utility::get_player_lethal_grenade();
	self takeWeapon( self.w_widows_wine_prev_grenade );

	self giveWeapon( level.w_widows_wine_grenade );
	self zm_utility::set_player_lethal_grenade( level.w_widows_wine_grenade );

	self.w_widows_wine_prev_knife = self zm_utility::get_player_melee_weapon();
	
	if ( isDefined( self.widows_wine_knife_override ) )
		self [[self.widows_wine_knife_override]]();
	else
	{
		self takeWeapon( self.w_widows_wine_prev_knife );
		
		if ( self.w_widows_wine_prev_knife.name == "bowie_knife" )
		{
			self giveWeapon( level.w_widows_wine_bowie_knife );
			self zm_utility::set_player_melee_weapon( level.w_widows_wine_bowie_knife );
		}
		else
		{
			self giveWeapon( level.w_widows_wine_knife );
			self zm_utility::set_player_melee_weapon( level.w_widows_wine_knife );
		}
	}

	assert( !isDefined( self.check_override_wallbuy_purchase ) || self.check_override_wallbuy_purchase == &widows_wine_override_wallbuy_purchase );
	assert( !isDefined( self.check_override_melee_wallbuy_purchase ) || self.check_override_melee_wallbuy_purchase == &widows_wine_override_melee_wallbuy_purchase );
	self.check_override_wallbuy_purchase = &widows_wine_override_wallbuy_purchase;
	self.check_override_melee_wallbuy_purchase = &widows_wine_override_melee_wallbuy_purchase;
	
	self thread grenade_bounce_monitor();
}

function widows_wine_contact_explosion()
{
	self magicGrenadeType( self.current_lethal_grenade, self.origin + ( 0, 0, 48 ), ( 0, 0, 0 ), 0.0 );
	self setWeaponAmmoClip( self.current_lethal_grenade, self getWeaponAmmoClip( self.current_lethal_grenade ) - 1 );
	self clientfield::increment_to_player( "widows_wine_1p_contact_explosion", 1 );
}

function widows_wine_zombie_damage_response( str_mod, str_hit_location, v_hit_origin, e_player, n_amount, w_weapon, direction_vec, tagName, modelName, partName, dFlags, inflictor, chargeLevel )
{
	if ( ( isDefined( self.damageweapon ) && self.damageweapon == level.w_widows_wine_grenade ) || ( IS_EQUAL( str_mod, "MOD_MELEE" ) && isDefined( e_player ) && isPlayer( e_player ) && e_player hasPerk( PERK_WIDOWS_WINE ) && RandomFloat( 1.0 ) <= WW_MELEE_COCOON_CHANCE ) )
	{
		if ( !IS_TRUE( self.no_widows_wine ) )
		{
			self thread zm_powerups::check_for_instakill( e_player, str_mod, str_hit_location );
		
			n_dist_sq = distanceSquared( self.origin, v_hit_origin );
	
			if ( n_dist_sq <= WIDOWS_WINE_COCOON_RADIUS_SQ )
				self thread widows_wine_cocoon_zombie( e_player );
			else
				self thread widows_wine_slow_zombie( e_player );
			
			if ( !IS_TRUE( self.no_damage_points ) && isDefined( e_player ) )
			{
				damage_type = "damage";
				e_player zm_score::player_add_points( damage_type, str_mod, str_hit_location, 0, undefined, w_weapon );
			}
			
			return 1;
		}
	}

	return 0;
}

function widows_wine_vehicle_damage_response( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, vDamageOrigin, psOffsetTime, damageFromUnderneath, modelIndex, partName, vSurfaceNormal )
{
	if ( isDefined( weapon ) && weapon == level.w_widows_wine_grenade && !IS_TRUE( self.b_widows_wine_cocoon ) )
	{
		if ( self.archetype === ARCHETYPE_PARASITE )
			self thread vehicle_stuck_grenade_monitor();
		
		self thread widows_wine_vehicle_behavior( eAttacker, weapon );

		if ( !IS_TRUE( self.no_damage_points ) && isDefined( eAttacker ) )
		{
			damage_type = "damage";
			eAttacker zm_score::player_add_points( damage_type, sMeansOfDeath, sHitLoc, 0, undefined, weapon );
		}

		return 0;
	}
	return iDamage;
}

function widows_wine_damage_callback( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, sWeapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( sWeapon == level.w_widows_wine_grenade )
		return 0;

	if (	self.current_lethal_grenade == level.w_widows_wine_grenade && self getWeaponAmmoClip( self.current_lethal_grenade ) > WIDOWS_WINE_CONTACT_EXPLOSION_COUNT && !self bgb::is_enabled( "zm_bgb_burned_out" ) )
	{
		if ( ( sMeansOfDeath == "MOD_MELEE" && IsAI(eAttacker) ) || ( sMeansOfDeath == "MOD_EXPLOSIVE" && isVehicle( eAttacker ) ) )
		{
			self thread widows_wine_contact_explosion();
			return iDamage;
		}
	}
}

function widows_wine_zombie_death_watch( attacker )
{
	if ( ( IS_TRUE( self.b_widows_wine_cocoon ) || IS_TRUE( self.b_widows_wine_slow ) ) && !IS_TRUE( self.b_widows_wine_no_powerup ) )
	{
		if ( isDefined( self.attacker ) && isPlayer( self.attacker ) && self.attacker hasPerk( PERK_WIDOWS_WINE ) )
		{
			chance = WW_POWERUP_DROP_CHANCE_NORMAL;			
			if ( isDefined( self.damageweapon ) && self.damageweapon == level.w_widows_wine_grenade )
				chance = WW_POWERUP_DROP_CHANCE_WEBBING;
			else if ( isdefined( self.damageweapon ) && ( self.damageweapon == level.w_widows_wine_knife || self.damageweapon == level.w_widows_wine_bowie_knife ) )
				chance = WW_POWERUP_DROP_CHANCE_MELEE;
			if ( randomFloat( 1.0 ) <= chance )
			{
				self.no_powerups = 1;
				level._powerup_timeout_override = &powerup_widows_wine_timeout;
				level thread zm_powerups::specific_powerup_drop( "ww_grenade", self.origin, undefined, undefined, undefined, self.attacker );
				level._powerup_timeout_override = undefined;
			}
		}
	}
}

function powerup_widows_wine_timeout()
{
	self endon( "powerup_grabbed" );
	self endon( "death" );
	self endon("powerup_reset");
	
	self zm_powerups::powerup_show( 1 );
	
	wait_time = 1;
	if ( isDefined( level._powerup_timeout_custom_time ) )
	{
		time = [[ level._powerup_timeout_custom_time ]]( self );
		if ( time == 0 )
			return;
		
		wait_time = time;
	}
	
	wait wait_time;

	for ( i = 20; i > 0; i-- )
	{
		if ( i % 2 )
			self zm_powerups::powerup_show( 0 );
		else
			self zm_powerups::powerup_show( 1 );

		if( i > 15 )
			wait( .3 );
		if ( i > 10 )
			wait( .25 );
		else if ( i > 5 )
			wait( .15 );
		else
			wait( .1 );			
		
	}
	
	self notify( "powerup_timedout" );
	self zm_powerups::powerup_delete();
}
	
function widows_wine_cocoon_zombie_score( e_player, duration, max_score )
{
	self notify( "widows_wine_cocoon_zombie_score" );
	self endon( "widows_wine_cocoon_zombie_score" );
	self endon( "death" );
	
	DEFAULT( self.ww_points_given, 0 ); 
	start_time = getTime();
	end_time = start_time + ( duration * 1000 );
	while( getTime() < end_time && self.ww_points_given < max_score )
	{
		e_player zm_score::add_to_player_score( 10 );
		wait duration / max_score;		
	}
}

function widows_wine_cocoon_zombie( e_player )
{
	self notify( "widows_wine_cocoon" );
	self endon( "widows_wine_cocoon" );
	
	if ( IS_TRUE( self.kill_on_wine_coccon ) )
		self kill();
	
	if ( !IS_TRUE( self.b_widows_wine_cocoon ) )
	{
		self.b_widows_wine_cocoon = 1;
		self.e_widows_wine_player = e_player;
		
		if( isDefined( self.widows_wine_cocoon_fraction_rate ) )
			widows_wine_cocoon_fraction_rate = self.widows_wine_cocoon_fraction_rate;
		else
			widows_wine_cocoon_fraction_rate = WIDOWS_WINE_COCOON_FRACTION;
		
		self asmSetAnimationRate( widows_wine_cocoon_fraction_rate );

		self clientfield::set( CF_WIDOWS_WINE_WRAP, 1 );
	}
	
	if ( isDefined( e_player ) )
		self thread widows_wine_cocoon_zombie_score( e_player, WIDOWS_WINE_COCOON_DURATION, WIDOWS_WINE_COCOON_MAX_SCORE );
	
	self util::waittill_any_timeout( WIDOWS_WINE_COCOON_DURATION, "death" );

	if ( !isDefined( self ))
		return; 
	
	self asmSetAnimationRate( 1 );
	self clientfield::set( CF_WIDOWS_WINE_WRAP, 0 );
	
	if ( isAlive( self ) )
		self.b_widows_wine_cocoon = 0;
	
}

function widows_wine_slow_zombie( e_player )
{
	self notify( "widows_wine_slow" );
	self endon( "widows_wine_slow" );
	
	if ( IS_TRUE( self.b_widows_wine_cocoon ) )
	{
		self thread widows_wine_cocoon_zombie( e_player );
		return;
	}

	if ( isDefined(e_player) )
		self thread widows_wine_cocoon_zombie_score( e_player, WIDOWS_WINE_SLOW_DURATION, WIDOWS_WINE_SLOW_MAX_SCORE );
	
	if ( !IS_TRUE( self.b_widows_wine_slow ) )
	{
		if ( isDefined(self.widows_wine_slow_fraction_rate) )
			widows_wine_slow_fraction_rate = self.widows_wine_slow_fraction_rate;
		else
			widows_wine_slow_fraction_rate = WIDOWS_WINE_SLOW_FRACTION;
		
		self.b_widows_wine_slow = 1;
		self ASMSetAnimationRate( widows_wine_slow_fraction_rate );
		self clientfield::set( CF_WIDOWS_WINE_WRAP, 1 );
	}
	self util::waittill_any_timeout( WIDOWS_WINE_SLOW_DURATION, "death" );

	if ( !isDefined( self ) )
		return; 
	
	self asmSetAnimationRate( 1 );
	self clientfield::set( CF_WIDOWS_WINE_WRAP, 0 );
	
	if ( isAlive( self ) )
		self.b_widows_wine_slow = 0;
	
}

function vehicle_stuck_grenade_monitor()
{
	self endon( "death" );
	
	self waittill( "grenade_stuck", e_grenade );
	
	e_grenade detonate(); 
}

function grenade_bounce_monitor()
{
	self endon( "disconnect" );
	self endon( "stop_widows_wine" );
	
	while ( 1 )
	{
		self waittill( "grenade_fire", e_grenade );
		e_grenade thread grenade_bounces();
	}
}
	
function grenade_bounces()
{
	self endon( "explode" );
	
	self waittill( "grenade_bounce", pos, normal, e_target );
	
	if ( isDefined( e_target ) )
	{
		if ( e_target.archetype === ARCHETYPE_PARASITE || e_target.archetype === ARCHETYPE_RAPS )
			self detonate(); 
		
	}
}

function widows_wine_vehicle_behavior( attacker, weapon )
{
	self endon( "death" );
	
	self.b_widows_wine_cocoon = 1;
	
	if ( isDefined( self.archetype ) )
	{
		if ( self.archetype == ARCHETYPE_RAPS )
		{
			self clientfield::set( CF_WIDOWS_WINE_WRAP, 1 );
			self._override_raps_combat_speed = WIDOWS_WINE_ELEMENTAL_SPEED_OVERRIDE;
			
			wait( .5 * WIDOWS_WINE_SLOW_DURATION );
	
			self doDamage( self.health + 1000, self.origin, attacker, undefined, "none", "MOD_EXPLOSIVE", 0, weapon );		
		}
		else if( self.archetype == ARCHETYPE_PARASITE )
		{
			wait SERVER_FRAME;
			self doDamage( self.maxhealth, self.origin );
		}
	}
}

function widows_wine_perk_lost( b_pause, str_perk, str_result )
{
	self notify( "stop_widows_wine" );
	self endon( "death" );
	
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_WIDOWS_WINE );
	
	if ( self laststand::player_is_in_laststand() )
	{
		self waittill( "player_revived" );

		if ( self hasPerk( PERK_WIDOWS_WINE ) )
			return;
		
	}

	self.check_override_wallbuy_purchase = undefined;
	
	self TakeWeapon( level.w_widows_wine_grenade );
	if ( isdefined( self.w_widows_wine_prev_grenade ) )
	{
		self.lsgsar_lethal = self.w_widows_wine_prev_grenade;
		self giveWeapon( self.w_widows_wine_prev_grenade );
		self zm_utility::set_player_lethal_grenade( self.w_widows_wine_prev_grenade );
	}
	else
		self zm_utility::init_player_lethal_grenade(); 	
	
	grenade = self zm_utility::get_player_lethal_grenade(); 
	self giveStartAmmo( grenade );
	
	if( self.w_widows_wine_prev_knife.name == "bowie_knife" )
		self takeWeapon( level.w_widows_wine_bowie_knife );
	else
		self takeWeapon( level.w_widows_wine_knife );

	if ( isDefined( self.w_widows_wine_prev_knife ) )
	{
		self GiveWeapon( self.w_widows_wine_prev_knife );
		self zm_utility::set_player_melee_weapon( self.w_widows_wine_prev_knife );
	}
	else
		self zm_utility::init_player_melee_weapon(); 	
	
	self notify( "perk_lost", str_perk );
}

function widows_wine_override_wallbuy_purchase( weapon, wallbuy ) 
{
	if ( zm_utility::is_lethal_grenade( weapon ) )
	{
		ammo_cost = zm_weapons::get_ammo_cost( weapon );
		cost = zm_weapons::get_weapon_cost( weapon );
		
		if ( self zm_score::can_player_purchase( ammo_cost ) )
		{
			if ( wallbuy.first_time_triggered == 0 )
				wallbuy zm_weapons::show_all_weapon_buys( self, cost, ammo_cost, 1 );
			
			if ( self getAmmoCount( self.current_lethal_grenade ) < self.current_lethal_grenade.maxAmmo )
			{
				self zm_score::minus_to_player_score( ammo_cost ); 
				self zm_utility::play_sound_on_ent( "purchase" ); 
				self giveMaxAmmo( self.current_lethal_grenade );
			}
		}
		else
		{
			wallbuy zm_utility::play_sound_on_ent( "no_purchase" );
			if ( isDefined( level.custom_generic_deny_vo_func ) )
				self [[ level.custom_generic_deny_vo_func ]]();
			else
				self zm_audio::create_and_play_dialog( "general", "outofmoney" );
			
		}

		return 1; 
	}
	return 0; 
}

function widows_wine_override_melee_wallbuy_purchase( vo_dialog_id, flourish_weapon, weapon, ballistic_weapon, ballistic_upgraded_weapon, flourish_fn, wallbuy ) 
{	
	if ( zm_utility::is_melee_weapon( weapon ) )
	{
		if ( self.w_widows_wine_prev_knife != weapon )
		{
			cost = wallbuy.stub.cost;
			
			if ( self zm_score::can_player_purchase( cost ) )
			{
				if ( wallbuy.first_time_triggered == 0 )
				{
					model = getEnt( wallbuy.target, "targetname" ); 
					
					if ( isDefined( model ) )
						model thread zm_melee_weapon::melee_weapon_show( self );
					else if ( isDefined( wallbuy.clientFieldName ) )
						level clientfield::set( wallbuy.clientFieldName, 1 );
					
					wallbuy.first_time_triggered = 1; 
					if ( isDefined( wallbuy.stub ) )
						wallbuy.stub.first_time_triggered = 1;

				}

				self zm_score::minus_to_player_score( cost ); 
				
				assert( weapon.name == "bowie_knife" ); 
				self.w_widows_wine_prev_knife = weapon;
				if ( self.w_widows_wine_prev_knife.name == "bowie_knife" )
					self thread zm_melee_weapon::give_melee_weapon( vo_dialog_id, flourish_weapon, weapon, ballistic_weapon, ballistic_upgraded_weapon, flourish_fn, wallbuy );
				
			}
			else
			{
				zm_utility::play_sound_on_ent( "no_purchase" );
				self zm_audio::create_and_play_dialog( "general", "outofmoney", 1 );
			}
		}
		return 1; 
	}
	return 0; 
}