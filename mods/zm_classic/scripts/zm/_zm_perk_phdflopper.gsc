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

#insert scripts\wardog\shared\wardog_shared.gsh; // This line is required so the below macro is valid
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;

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

#using scripts\zm\_zm_kishkumen_utility;

#insert scripts\zm\_zm_perk_phdflopper.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache("material", PERK_PHDFLOPPER_SHADER);
#precache("string", PERK_PHDFLOPPER_HINT);
#precache("fx", PERK_PHDFLOPPER_LIGHT_FX);
#precache("fx", PERK_PHDFLOPPER_EXPLODE_FX);
#precache( "model", PERK_PHDFLOPPER_MACHINE_OFF );
#precache( "model", PERK_PHDFLOPPER_MACHINE_ON );

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM( "zm_perk_phdflopper", &__init__, undefined )

function __init__()
{
	enable_phdflopper_perk_for_level();
}

function enable_phdflopper_perk_for_level()
{	
	zm_perks::register_perk_basic_info( 			PERK_PHDFLOPPER, PERK_PHDFLOPPER_ALIAS, PERK_PHDFLOPPER_COST, &PERK_PHDFLOPPER_HINT, GetWeapon( PERK_PHDFLOPPER_BOTTLE ) );
	zm_perks::register_perk_precache_func( 			PERK_PHDFLOPPER, &phdflopper_precache );
	zm_perks::register_perk_clientfields( 			PERK_PHDFLOPPER, &phdflopper_register_clientfield, 	&phdflopper_set_clientfield );
	zm_perks::register_perk_machine( 				PERK_PHDFLOPPER, &phdflopper_perk_machine_setup, &phd_init );
	zm_perks::register_perk_host_migration_params( 	PERK_PHDFLOPPER, PERK_PHDFLOPPER_MACHINE_NAME, 	PERK_PHDFLOPPER_LIGHT_FX );	
	zm_perks::register_perk_damage_override_func( &damage_override );
	
	callback::on_spawned( &flopper_think );

	visionset_mgr::register_info("visionset", PERK_PHDFLOPPER_VISIONSET_NAME, VERSION_SHIP, 27, 1, true, &visionset_mgr::ramp_in_out_thread_per_player, true);
}

function phd_init()
{
	level.zombiemode_divetonuke_perk_func = &divetonuke_explode;

	wardog_perk_hud::register_perk_shader(PERK_PHDFLOPPER, PERK_PHDFLOPPER_SHADER);
}

function phdflopper_precache()
{	
	level._effect[PERK_PHDFLOPPER_EXPLODE_FX_PATH] = PERK_PHDFLOPPER_EXPLODE_FX;
	level._effect[PERK_PHDFLOPPER_LIGHT_EXPLODE_FX]	= PERK_PHDFLOPPER_LIGHT_FX;
	
	level.machine_assets[ PERK_PHDFLOPPER ] 			= SpawnStruct();	
	level.machine_assets[ PERK_PHDFLOPPER ].weapon 		= GetWeapon( PERK_PHDFLOPPER_BOTTLE );		
	level.machine_assets[ PERK_PHDFLOPPER ].off_model 	= PERK_PHDFLOPPER_MACHINE_OFF;	
	level.machine_assets[ PERK_PHDFLOPPER ].on_model 	= PERK_PHDFLOPPER_MACHINE_ON;
}

function phdflopper_register_clientfield() 
{
	//clientfield::register("clientuimodel", PERK_CLIENTFIELD_PHDFLOPPER, VERSION_SHIP, 2, "int");
}

function phdflopper_set_clientfield( state ) 
{
	//self clientfield::set_player_uimodel(PERK_CLIENTFIELD_PHDFLOPPER, state);
}

function phdflopper_perk_machine_setup( use_trigger, perk_machine, bump_trigger, collision )
{
	use_trigger.script_sound = PERK_PHDFLOPPER_JINGLE;	
	use_trigger.script_string = PERK_PHDFLOPPER_MACHINE_STRING;
	use_trigger.script_label = PERK_PHDFLOPPER_STING;
	use_trigger.longJingleWait = true;
	use_trigger.target = PERK_PHDFLOPPER_MACHINE_NAME;

	perk_machine.script_string = PERK_PHDFLOPPER_MACHINE_STRING;
	perk_machine.targetname = PERK_PHDFLOPPER_MACHINE_NAME;
	
	if(IsDefined( bump_trigger ))
	{
		bump_trigger.script_string = PERK_PHDFLOPPER_MACHINE_STRING;
	}	
}

function damage_override(eInflictor, eAttacker, iDamage, iDFlags, sMeansOfDeath, weapon, vPoint, vDir, sHitLoc, psOffsetTime)
{
	if (!self HasPerk(PERK_PHDFLOPPER))
		return undefined;
	
	switch( sMeansOfDeath )
	{
		case "MOD_GRENADE":
		case "MOD_GRENADE_SPLASH":
		case "MOD_EXPLOSIVE":
		case "MOD_EXPLOSIVE_SPLASH":
		case "MOD_PROJECTILE":
		case "MOD_PROJECTILE_SPLASH":
		case "MOD_BURNED":
		case "MOD_ELECTOCUTED":
		case "MOD_FALLING":
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
    playFx( PERK_PHDFLOPPER_EXPLODE_FX, self.origin );
     
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

	visionset_mgr::activate("visionset", PERK_PHDFLOPPER_VISIONSET_NAME, attacker);

	PlayFX(level._effect[PERK_PHDFLOPPER_EXPLODE_FX_PATH], origin);
	attacker PlaySound(PERK_PHDFLOPPER_EXPLODE_SOUND);

	if(IS_TRUE(PERK_PHDFLOPPER_EXPLODE_NETWORK_OPTIMIZED))
		attacker thread divetonuke_explode_network_optimized(origin);
	else
	{
		SetPlayerIgnoreRadiusDamage(true);

		RadiusDamage(origin, PERK_PHDFLOPPER_EXPLODE_RADIUS, PERK_PHDFLOPPER_EXPLODE_MAX_DAMAGE, PERK_PHDFLOPPER_EXPLODE_MIN_DAMAGE, attacker, PERK_PHDFLOPPER_EXPLODE_DAMAGE_MOD);

		SetPlayerIgnoreRadiusDamage(false);
	}

	visionset_mgr::deactivate("visionset", PERK_PHDFLOPPER_VISIONSET_NAME, attacker);
}

function private divetonuke_explode_network_optimized(origin)
{
	self endon("disconnect");

	zombies = util::get_array_of_closest(origin, zombie_utility::get_round_enemy_array(), undefined, undefined, PERK_PHDFLOPPER_EXPLODE_RADIUS);
	count = 0;

	foreach(zombie in zombies)
	{
		if(!isdefined(zombie) || !IsAlive(zombie))
			continue;

		damage = PERK_PHDFLOPPER_EXPLODE_MIN_DAMAGE + ((PERK_PHDFLOPPER_EXPLODE_MAX_DAMAGE - PERK_PHDFLOPPER_EXPLODE_MIN_DAMAGE) * (1 - (Distance(zombie.origin, origin) / PERK_PHDFLOPPER_EXPLODE_RADIUS)));

		zombie DoDamage(damage, zombie.origin, self, self, 0, PERK_PHDFLOPPER_EXPLODE_DAMAGE_MOD);

		count--;

		if(count <= 0)
		{
			util::wait_network_frame();

			count = RandomIntRange(1, 3);
		}
	}
}