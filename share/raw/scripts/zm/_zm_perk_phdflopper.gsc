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

#insert scripts\zm\_zm_perk_phdflopper.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "material", 	PERK_PHDFLOPPER_SHADER );
#precache( "fx", 		PHDFLOPPER_EXPLODE_FX_PATH);
#precache( "fx", 		PHDFLOPPER_MACHINE_LIGHT_FX_PATH );
#precache( "fx", 		PHDFLOPPER_MACHINE_FACTORY_LIGHT_FX_PATH );

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM( "zm_perk_phdflopper", &__init__, undefined )

function __init__()
{	
	mapname = ToLower( GetDvarString( "mapname" ) );

	switch(mapname)
	{
		case "zm_zod":
		case "zm_castle":
		case "zm_island":
		case "zm_stalingrad":
		case "zm_genesis":
		{
			break;
		}		
		default:
		{
			if ( IS_TRUE( PHDFLOPPER_LEVEL_USE_PERK ) )
				enable_phdflopper_perk_for_level();
			break;
		}
	}
}

function enable_phdflopper_perk_for_level()
{		
	perk_machine_location = struct::get("specialty_widowswine", "script_noteworthy");

	if(isdefined(perk_machine_location))
	{
		perk_machine_location.script_noteworthy = "specialty_phdflopper";
	}

	zm_perks::register_perk_basic_info(				PERK_PHDFLOPPER, PHDFLOPPER_ALIAS, 					PHDFLOPPER_PERK_COST, 		&PHDFLOPPER_HINT, GetWeapon(PHDFLOPPER_PERK_BOTTLE_WEAPON) );
	zm_perks::register_perk_precache_func(			PERK_PHDFLOPPER, &phdflopper_precache);
	zm_perks::register_perk_clientfields(			PERK_PHDFLOPPER, &phdflopper_register_clientfield, &phdflopper_set_clientfield );
	zm_perks::register_perk_machine(				PERK_PHDFLOPPER, &phdflopper_perk_machine_setup, &phd_init );
	zm_perks::register_perk_host_migration_params(	PERK_PHDFLOPPER, PHDFLOPPER_RADIANT_MACHINE_NAME, 	PHDFLOPPER_MACHINE_LIGHT_FX);
	
	callback::on_spawned( &flopper_think );
	zm_perks::register_perk_damage_override_func( &phdflopper_damage_override );
}

function phd_init()
{
	level.zombiemode_divetonuke_perk_func = &divetonuke_explode;
}

function phdflopper_precache()
{	
	script = toLower( getDvarString( "mapname" ) );
	
	if ( script != "zm_factory" )
		level._effect[ PHDFLOPPER_MACHINE_LIGHT_FX ]				= PHDFLOPPER_MACHINE_LIGHT_FX_PATH;
	else
		level._effect[ PHDFLOPPER_MACHINE_LIGHT_FX ]				= PHDFLOPPER_MACHINE_FACTORY_LIGHT_FX_PATH;
	
	level._effect[PHDFLOPPER_EXPLODE_FX] 				= PHDFLOPPER_EXPLODE_FX_PATH;

	level.machine_assets[ PERK_PHDFLOPPER ] 			= SpawnStruct();
	
	level.machine_assets[ PERK_PHDFLOPPER ].weapon 		= GetWeapon( PHDFLOPPER_PERK_BOTTLE_WEAPON );	
	level.machine_assets[ PERK_PHDFLOPPER ].off_model 	= PHDFLOPPER_MACHINE_DISABLED_MODEL;	
	level.machine_assets[ PERK_PHDFLOPPER ].on_model 	= PHDFLOPPER_MACHINE_ACTIVE_MODEL;
}

function phdflopper_register_clientfield() 
{
	clientfield::register( "clientuimodel", "hudItems.perks.dive_to_nuke", VERSION_SHIP, 2, "int" );
}

function phdflopper_set_clientfield( state ) 
{
	self clientfield::set_player_uimodel( "hudItems.perks.dive_to_nuke", state );
}

function phdflopper_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound 							= PHDFLOPPER_JINGLE;	
	use_trigger.script_string 							= PHDFLOPPER_SCRIPT_STRING;
	use_trigger.script_label 							= PHDFLOPPER_STING;	
	use_trigger.target 									= PHDFLOPPER_RADIANT_MACHINE_NAME;
	perk_machine.script_string 							= PHDFLOPPER_SCRIPT_STRING;
	perk_machine.targetname 							= PHDFLOPPER_RADIANT_MACHINE_NAME;

	if ( isDefined( bump_trigger ) )
		bump_trigger.script_string 						= PHDFLOPPER_SCRIPT_STRING;
}

function phdflopper_damage_override( eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime )
{
	if ( !self hasPerk( PERK_PHDFLOPPER ) )
		return undefined;
	
	switch ( sMeansOfDeath )
	{
		case "MOD_FALLING":
		case "MOD_BURNED":
		case "MOD_GRENADE":
		case "MOD_GRENADE_SPLASH":
		case "MOD_PROJECTILE":
		case "MOD_PROJECTILE_SPLASH":
		case "MOD_EXPLOSIVE":
		case "MOD_EXPLOSIVE_SPLASH":
		case "MOD_ELECTOCUTED":
		case "MOD_IMPACT":
			iDamage = 0;
			return 0;

		default:
			break;
			
	}
	return undefined;
}

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
                ai[ i ] doDamage( ai[ i ].health + 777, ai[ i ].origin, undefined, undefined, "riflebullet" );
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

function private flopper_think()
{
	self endon("disconnect");

	self notify("kill_flopper");
	self endon("kill_flopper");

	for(;;)
	{
		wait .01;

		if(self IsOnGround())
			continue;

		velocity = self GetVelocity();

		while(!self IsOnGround())
		{
			velocity = self GetVelocity();
			wait .01;
		}

		wait .01;

		if(!self IsSliding())
			continue;
		if(velocity[2] > -300)
			continue;

		self notify("flopp_start");

		WAIT_SERVER_FRAME
		waittillframeend;

		if(self HasPerk(PERK_PHDFLOPPER))
		{
			self notify("divetonuke");

			if(isdefined(level.zombiemode_divetonuke_perk_func))
				thread [[level.zombiemode_divetonuke_perk_func]](self, self.origin);
		}

		WAIT_SERVER_FRAME
		waittillframeend;

		self notify("flopp_end");
	}
}

function divetonuke_explode(attacker, origin)
{
	if(!attacker HasPerk(PERK_PHDFLOPPER))
		return;

	if(IS_TRUE(PHDFLOPPER_EXPLODE_NETWORK_OPTIMIZED))
		attacker thread divetonuke_explode_network_optimized(origin);
	else
	{
		SetPlayerIgnoreRadiusDamage(true);

		RadiusDamage(origin, PHDFLOPPER_EXPLODE_RADIUS, PHDFLOPPER_EXPLODE_MAX_DAMAGE, PHDFLOPPER_EXPLODE_MIN_DAMAGE, attacker, PHDFLOPPER_EXPLODE_DAMAGE_MOD);

		SetPlayerIgnoreRadiusDamage(false);
	}

	PlayFX(level._effect[PHDFLOPPER_EXPLODE_FX], origin);
	attacker PlaySound("zmb_perks_phdflopper_explode");
}

function private divetonuke_explode_network_optimized(origin)
{
	self endon("disconnect");

	zombies = util::get_array_of_closest(origin, zombie_utility::get_round_enemy_array(), undefined, undefined, PHDFLOPPER_EXPLODE_RADIUS);
	count = 0;

	foreach(zombie in zombies)
	{
		if(!isdefined(zombie) || !IsAlive(zombie))
			continue;

		damage = PHDFLOPPER_EXPLODE_MIN_DAMAGE + ((PHDFLOPPER_EXPLODE_MAX_DAMAGE - PHDFLOPPER_EXPLODE_MIN_DAMAGE) * (1 - (Distance(zombie.origin, origin) / PHDFLOPPER_EXPLODE_RADIUS)));

		zombie DoDamage(damage, zombie.origin, self, self, 0, PHDFLOPPER_EXPLODE_DAMAGE_MOD);

		count--;

		if(count <= 0)
		{
			util::wait_network_frame();

			count = RandomIntRange(1, 3);
		}
	}
}