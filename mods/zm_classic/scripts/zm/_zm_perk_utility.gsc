#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_kishkumen_utility;

#insert scripts\zm\_zm_utility.gsh;

#insert scripts\zm\_zm_perk_quick_revive.gsh;
#insert scripts\zm\_zm_perk_juggernaut.gsh;
#insert scripts\zm\_zm_perk_sleight_of_hand.gsh;
#insert scripts\zm\_zm_perk_doubletap2.gsh;
#insert scripts\zm\_zm_perk_deadshot.gsh;
#insert scripts\zm\_zm_perk_phdflopper.gsh;
#insert scripts\zm\_zm_perk_staminup.gsh;
#insert scripts\zm\_zm_perk_additionalprimaryweapon.gsh;
#insert scripts\zm\_zm_perk_electric_cherry.gsh;
#insert scripts\zm\_zm_perk_widows_wine.gsh;

#precache( "material", QUICK_REVIVE_SHADER );
#precache( "material", JUGGERNAUT_SHADER );
#precache( "material", SLEIGHT_OF_HAND_SHADER );
#precache( "material", DOUBLETAP2_SHADER );
#precache( "material", STAMINUP_SHADER );
#precache( "material", PHDFLOPPER_SHADER );
#precache( "material", DEADSHOT_SHADER );
#precache( "material", ADDITIONAL_PRIMARY_WEAPON_SHADER );
#precache( "material", ELECTRIC_CHERRY_SHADER );
#precache( "material", WIDOWS_WINE_SHADER );

#namespace zm_perk_utility;

function autoexec init()
{
	level.perk_shaders = [];
	level.perk_shaders[ "specialty_quickrevive" ] 				= QUICK_REVIVE_SHADER;
	level.perk_shaders[ "specialty_armorvest" ] 				= JUGGERNAUT_SHADER;
	level.perk_shaders[ "specialty_fastreload" ] 				= SLEIGHT_OF_HAND_SHADER;
	level.perk_shaders[ "specialty_doubletap2" ] 				= DOUBLETAP2_SHADER;
	level.perk_shaders[ "specialty_staminup" ] 					= STAMINUP_SHADER;
	level.perk_shaders[ "specialty_phdflopper" ] 				= PHDFLOPPER_SHADER;
	level.perk_shaders[ "specialty_deadshot" ] 					= DEADSHOT_SHADER;
	level.perk_shaders[ "specialty_additionalprimaryweapon" ] 	= ADDITIONAL_PRIMARY_WEAPON_SHADER;
	level.perk_shaders[ "specialty_electriccherry" ] 			= ELECTRIC_CHERRY_SHADER;
	level.perk_shaders[ "specialty_widowswine" ] 				= WIDOWS_WINE_SHADER;

	level.perk_lost_func = &update_perk_hud;
}

function is_stock_map()
{
	if ( level.script == "zm_factory" || level.script == "zm_zod" || level.script == "zm_castle" || level.script == "zm_island" || level.script == "zm_stalingrad" || level.script == "zm_genesis" )
		return 1;
	
	return 0;
}

function is_zc_map()
{
	if ( level.script == "zm_prototype" || level.script == "zm_asylum" || level.script == "zm_sumpf" || level.script == "zm_theater" || level.script == "zm_cosmodrome" || level.script == "zm_temple" || level.script == "zm_moon" || level.script == "zm_tomb" )
		return 1;
	
	return 0;
}

function is_waw_map()
{
	if( level.script == "zm_prototype" || level.script == "zm_asylum" || level.script == "zm_sumpf" || level.script == "zm_factory" )
		return 1;

	return 0;
}

function create_perk_hud( perk )
{
	if ( !isDefined( self.perk_hud ) )
		self.perk_hud = [];
	
	hud = NewClientHudElem( self );
	hud.alignX = "left";
	hud.alignY = "bottom";
	hud.horzAlign = "left";
	hud.vertAlign = "bottom";
	hud.foreground = true;
	hud.sort = 1;
	hud.hidewheninmenu = true;
	hud.x = 76 + (self.perk_hud.size * 30);
	hud.y = -22;
	hud.alpha = 1;
	hud SetShader( level.perk_shaders[ perk ], 25, 25);
		
	self.perk_hud[ perk ] = hud;
}

function harrybo21_perks_hud_remove( perk )
{
	if(!isdefined(self.perk_hud))
		self.perk_hud = [];

	if(isdefined(self.perk_hud[ perk ]))
	{
		self zm_perks::perk_hud_destroy(perk);
	}

	if ( isdefined( self.perk_hud ) )
	{
		keys = getarraykeys( self.perk_hud );
		for ( i = 0; i < self.perk_hud.size; i++ )
		{
			self.perk_hud[ keys[i] ].x = 76 + (i * 30);
		}
	}
}

function fade_hud( time, alpha )
{
	self fadeOverTime( time );
	self.alpha = alpha;
	wait time;
	self destroy();
}

function move_hud( time, x, y )
{
	self moveOverTime( time );
	self.x = x;
	self.y = y;
}

function place_perk_machine( origin, angles, perk, model )
{
	t_use = spawn( "trigger_radius_use", origin + ( 0, 0, 60 ), 0, 40, 80 );
	t_use.targetname = "zombie_vending";			
	t_use.script_noteworthy = perk;	
	t_use TriggerIgnoreTeam();
	if ( level.script == "zm_zod" || level.script == "zm_genesis" || level.script == "zm_tomb" )
		t_use thread force_power();
	
	perk_machine = spawn( "script_model", origin );
	if ( !isDefined( angles ) )
		angles = ( 0, 0, 0 );
	
	perk_machine.angles = angles;
	perk_machine setModel( model );

	bump_trigger = spawn( "trigger_radius", origin + ( 0, 0, 30 ), 0, 40, 80 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	
	collision = spawn( "script_model", origin, 1 );
	collision.angles = angles;
	collision setModel( "zm_collision_perks1" );
	collision.script_noteworthy = "clip";
	collision disconnectPaths();
	
	t_use.clip = collision;
	t_use.machine = perk_machine;
	t_use.bump = bump_trigger;
	
	[[ level._custom_perks[ perk ].perk_machine_set_kvps ]]( t_use, perk_machine, bump_trigger, collision );
}	

function force_power()
{
	wait 10;
	level notify( "phdflopper_on" );
	level notify( "electric_cherry_on" );
	level notify( "deadshot_on" );
}

function update_perk_hud()
{
	if ( isdefined( self.perk_hud ) )
	{
		keys = getarraykeys( self.perk_hud );
		for ( i = 0; i < self.perk_hud.size; i++ )
		{
			self.perk_hud[ keys[i] ].x = 76 + (i * 30);
		}
	}
}