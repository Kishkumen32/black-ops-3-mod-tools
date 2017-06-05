#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\callbacks_shared;
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

#insert scripts\zm\_zm_perk_phdflopper.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "fx", "explosions/fx_exp_rocket_default_sm" );
#precache( "fx", "zombie/fx_perk_doubletap2_factory_zmb" );

#precache( "model", PHDFLOPPER_MACHINE_DISABLED_MODEL );
#precache( "model", PHDFLOPPER_MACHINE_ACTIVE_MODEL );

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM( "zm_perk_phdflopper", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	enable_phdflopper_perk_for_level();
	place_perk();
}

function enable_phdflopper_perk_for_level()
{	
	zm_perks::register_perk_basic_info( 			PERK_PHDFLOPPER, "phdflopper", 						PHDFLOPPER_PERK_COST, 			"Hold ^3[{+activate}]^7 for P.H.D Flopper [Cost: &&1]", getWeapon( PHDFLOPPER_PERK_BOTTLE_WEAPON ) );
	zm_perks::register_perk_precache_func( 			PERK_PHDFLOPPER, &phdflopper_precache );
	zm_perks::register_perk_clientfields( 			PERK_PHDFLOPPER, &phdflopper_register_clientfield, 	&phdflopper_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_PHDFLOPPER, &phdflopper_perk_machine_setup );
	zm_perks::register_perk_host_migration_params( 	PERK_PHDFLOPPER, PHDFLOPPER_RADIANT_MACHINE_NAME, 	PHDFLOPPER_MACHINE_LIGHT_FX );
	zm_perks::register_perk_threads( 				PERK_PHDFLOPPER, &phdflopper_perk_give, 			&phdflopper_perk_lost  );
	
	callback::on_spawned( &on_player_spawned );
	zm_perks::register_perk_damage_override_func( &damage_override );
}

function place_perk()
{
	if(!isDefined(level.bgb_machine_spots))
	{
		zm_kishkumen_utility::initBGBMachines();
	}

	level.bgb_machine_spots = array::randomize( level.bgb_machine_spots );

	bgb_spot = level.bgb_machine_spots[0];

	bgb_spot_orgin = bgb_spot.origin;
	bgb_spot_angles = bgb_spot.angles;

	bgb_spot delete();	

	ArrayRemoveIndex(level.bgb_machine_spots,0);

	zm_perk_utility::place_perk_machine( bgb_spot_orgin , bgb_spot_angles, PERK_PHDFLOPPER, PHDFLOPPER_MACHINE_DISABLED_MODEL );
}

function phdflopper_precache()
{	
	level._effect[ PHDFLOPPER_MACHINE_LIGHT_FX ] 		= "zombie/fx_perk_doubletap2_factory_zmb";
	
	level.machine_assets[ PERK_PHDFLOPPER ] 			= spawnStruct();
	
	level.machine_assets[ PERK_PHDFLOPPER ].weapon 		= getWeapon( PHDFLOPPER_PERK_BOTTLE_WEAPON );
		
	level.machine_assets[ PERK_PHDFLOPPER ].off_model 	= PHDFLOPPER_MACHINE_DISABLED_MODEL;
	
	level.machine_assets[ PERK_PHDFLOPPER ].on_model 	= PHDFLOPPER_MACHINE_ACTIVE_MODEL;
}

function phdflopper_register_clientfield() {}

function phdflopper_set_clientfield( state ) {}

function phdflopper_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = "mus_perks_phdflopper_jingle";
	
	use_trigger.script_string = "phdflopper_perk";
	use_trigger.script_label = "mus_perks_phdflopper_sting";
	
	use_trigger.target = "vending_phdflopper";
	perk_machine.script_string = "phdflopper_perk";
	perk_machine.targetname = "vending_phdflopper";
	if( isDefined( bump_trigger ) )
		bump_trigger.script_string = "phdflopper_perk";
	
}

function phdflopper_perk_lost( b_pause, str_perk, str_result )
{
	self zm_perk_utility::harrybo21_perks_hud_remove( PERK_PHDFLOPPER );
	self notify( PERK_PHDFLOPPER + "_stop" );
	self notify( "perk_lost", str_perk );
}

function phdflopper_perk_give( b_pause, str_perk, str_result )
{
	self zm_perk_utility::create_perk_hud( PERK_PHDFLOPPER );
	self notify( PERK_PHDFLOPPER + "_start" );
	
	
	
	// self setPerk( "specialty_detectexplosive" );
}

//-----------------------------------------------------------------------------------
// FUNCTIONALITY
//-----------------------------------------------------------------------------------
function damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if ( !self hasPerk( PERK_PHDFLOPPER ) )
		return undefined;

	if(sMeansOfDeath == PHD_PERK_EXPLODE_DAMAGE_MOD)
	{
		iDamage = 0;
		return 0;
	}
	
	switch( sMeansOfDeath )
	{
		case "MOD_FALLING":
		case "MOD_BURNED":
		case "MOD_GRENADE":
		case "MOD_GRENADE_SPLASH":
		case "MOD_EXPLOSIVE":
		case "MOD_EXPLOSIVE_SPLASH":
		case "MOD_ELECTOCUTED":
		case "MOD_IMPACT":
			iDamage = 0;
			return 0;

		default:
			break;
	}

	if(!isdefined(weapon))
		return undefined;

	switch(weapon.name)
	{
		case "bouncingbetty":
		case "cymbal_monkey":
		case "frag_grenade":
		case "launcher_multi":
		case "launcher_multi_upgraded":
		case "launcher_standard":
		case "launcher_standard_upgraded":
		case "octobomb":
		case "octobomb_upgraded":
		case "pistol_standard_upgraded":
		case "pistol_standardlh_upgraded":
		case "ray_gun":
		case "ray_gun_upgraded":
		case "raygun_mark3":
		case "raygun_mark3lh":
		case "raygun_mark3_upgraded":
		case "raygun_mark3lh_upgraded":
		case "tesla_gun":
		case "tesla_gun_upgraded":
			iDamage = 0;
			return 0;

		default:
			break;
	}

	return undefined;
}

function on_player_spawned()
{
	self thread grenade_multispawn();
}

function grenade_multispawn()
{
	while( 1 )
	{
		self waittill( "grenade_fire", grenade, weapon );
		
		if ( !self hasPerk( PERK_PHDFLOPPER ) )
			continue;
		
		if ( IS_TRUE( grenade.additional ) ) 
			continue;
		
		current_lethal = self zm_utility::get_player_lethal_grenade();
		if ( weapon != current_lethal )
			continue;
		
		self thread spawn_grenade( grenade, weapon );
	}
}

function spawn_grenade( grenade, weapon )
{
	if ( isDefined( grenade ) )
		grenade grenade_waittill_still_or_bounce();
	
	fraction = 360 / 5;
	for ( i = 0; i < 4; i++ )
	{
		wait .3;
		self playSound( "dig_sites_grenade" );
		
		if ( !isDefined( grenade ) )
			origin = self getTagOrigin( "j_spineupper" );
		else
			origin = grenade.origin;
		
		grenade2 = self magicGrenadeType( weapon, origin, ( 0, 0, 300 ), 3 );
		grenade2.additional = 1;
		
		if ( i == 0 )
			playFxOnTag( "harry/multigrenade/fx_multigrenade_blue", grenade2, "tag_origin" );
		else if ( i == 1 )
			playFxOnTag( "harry/multigrenade/fx_multigrenade_green", grenade2, "tag_origin" );
		else if ( i == 2 )
			playFxOnTag( "harry/multigrenade/fx_multigrenade_red", grenade2, "tag_origin" );
		else
			playFxOnTag( "harry/multigrenade/fx_multigrenade_yellow", grenade2, "tag_origin" );
		
	}
}

function grenade_waittill_still_or_bounce()
{
	self endon( "death" );
	self endon( "grenade_bounce" );
	prev_origin = self.origin;
	while( 1 )
	{
		wait .05;
		if ( prev_origin == self.origin )
			break;
		
		prev_origin = self.origin;
	}
}

/*
function playerDiveMonitor()
{
    self endon( "disconnect" );
    useDive = 1;
    while( 1 )
    {
        wait .05;
       
        if ( !isDefined( self.diving ) && self isSprinting() && !self isMeleeing() && !isDefined( self.grabbed ) && self useButtonPressed() && self isOnGround() )
        {
            vec = anglesToForward( self getPlayerAngles() );
            end = vectorScale( vec, 50 );
           
            self.diving = 1;
            self disableWeaponCycling();
            self disableOffHandWeapons();
           
            self playSound( "sfx_dive_in" );

            self allowStand( 0 );
            
            self setStance( "crouch" );
           
            self setOrigin( self.origin + ( 0, 0, 5 ) );
            wait .05;
           
            self setVelocity( self getVelocity() + end + ( 0, 0, 350 ) );
           
            wait .3;
			self.dive_height = self.origin[ 2 ];
			self allowCrouch( 0 );
            self allowMelee( 0 );
			self setStance( "prone" );
			self.divetoprone = 1;
        }
       
        if ( isDefined( self.diving ) && ( self isOnGround() || isDefined( self.grabbed ) ) ) // Diving Land
        {
            self setStance( "prone" );
            self enableWeaponCycling();
            self enableOffHandWeapons();
           
            if ( self.dive_height - self.origin[ 2 ] > 100 && self hasPerk( PERK_PHDFLOPPER ) )
                self thread phdExplosion();
               
            self playSound( "sfx_dive_out" );
            self.divetoprone = 0; 
            wait .45;
 
            self allowStand( 1 );
            self allowCrouch( 1 );
            self allowMelee( 1 );
            
            self notify( "Dive Over" );
            self.diving = undefined;
        }
    }
}
function phdExplosion()
{
    earthquake( 1, 1, self.origin, 50 );
    self playSound( "zmb_perks_phdflopper_explode" );
     
    ai = getAiSpeciesArray( "axis","all" );
    for(i = 0; i < ai.size; i++)
    {
        if ( distance( ai[ i ].origin, self.origin ) < 300 )
        {
            shouldGib = randomIntRange( 0, 100 ) > 42;
            headGib = randomIntRange( 0, 100 ) > 88;
            if ( headGib )
                ai[ i ] thread zombie_utility::zombie_head_gib();
            else if ( shouldGib )
                ai[ i ] thread zombie_utility::gib_random_parts();
               
            if ( level.round_number < 15 )
                ai[ i ] doDamage( ai[ i ].health + 666, ai[ i ].origin, undefined, undefined, "riflebullet" );
            else
                ai[ i ] doDamage( ai[ i ].maxhealth / 2, ai[ i ].origin, undefined, undefined, "riflebullet" );
               
            wait .05;
               
            if ( ai[ i ].health <= 0 )
                self zm_score::add_to_player_score( 50 );
        }
    }
     
    visionSetNaked( "zm_flopper_explosion" );
    playFx( "explosions/fx_exp_rocket_default_sm", self.origin );
     
    wait 2;
     
    VisionSetNaked( "zm_factory", 1 );
}

function playFxOnMultipleTags( effect, ent, tags )
{
    for( t = 0; t < tags.size; t++ )
        playFxOnTag( level._effect[ effect ], ent, tags[ t ] );
	
}
*/