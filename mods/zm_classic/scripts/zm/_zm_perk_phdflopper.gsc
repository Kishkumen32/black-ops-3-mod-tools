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
		case "MOD_GRENADE_SPLASH":
		case "MOD_GRENADE":
		case "MOD_EXPLOSIVE":
		case "MOD_PROJECTILE":
		case "MOD_PROJECTILE_SPLASH":
		case "MOD_BURNED":
		case "MOD_FALLING":
			iDamage = 0;
			return 0;

		default:
			break;
	}

	return undefined;
}

function on_player_spawned()
{
	
}