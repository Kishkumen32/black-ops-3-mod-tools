#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\util_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\callbacks_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_utility.gsh;

#insert scripts\zm\_zm_perk_doubletap2.gsh;
#insert scripts\zm\_zm_perk_deadshot.gsh;
#insert scripts\zm\_zm_perk_phdflopper.gsh;
#insert scripts\zm\_zm_perk_electric_cherry.gsh;
#insert scripts\zm\_zm_perk_widows_wine.gsh;

#precache( "material", DOUBLETAP2_SHADER );
#precache( "material", PHDFLOPPER_SHADER );
#precache( "material", DEADSHOT_SHADER );
#precache( "material", ELECTRIC_CHERRY_SHADER );
#precache( "material", WIDOWS_WINE_SHADER );

#namespace zm_perk_utility;

function autoexec init()
{
	level.perk_shaders = [];
	level.perk_shaders[ "specialty_doubletap2" ] 				= DOUBLETAP2_SHADER;
	level.perk_shaders[ "specialty_phdflopper" ] 				= PHDFLOPPER_SHADER;
	level.perk_shaders[ "specialty_deadshot" ] 					= DEADSHOT_SHADER;
	level.perk_shaders[ "specialty_electriccherry" ] 			= ELECTRIC_CHERRY_SHADER;
	level.perk_shaders[ "specialty_widowswine" ] 				= WIDOWS_WINE_SHADER;
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
	
	hud = newClientHudElem( self );
	hud.perk = perk;
	hud.foreground = 1;
	hud.sort = 1;
	hud.hidewheninmenu = 1;
	hud.alignX = "left";
	hud.alignY = "bottom";
	hud.horzAlign = "left";
	hud.vertAlign = "bottom";
	hud.x = 76 + (self.perk_hud.size * 30);
	hud.y = -22;
	hud.alpha = 0;
	hud setShader( level.perk_shaders[ perk ], 48, 48 );
	hud scaleOverTime( .5, 24, 24 );
	hud fadeOverTime( .5 );
	hud.alpha = 1;
		
	self.perk_hud[ self.perk_hud.size ] = hud;
}

function harrybo21_perks_hud_remove( perk )
{
	new_array = [];
	for ( i = 0; i < self.perk_hud.size; i++ )
	{
		if ( self.perk_hud[ i ].perk == perk )
			self.perk_hud[ i ] thread fade_hud( .5, 0 );
		else
			new_array[ new_array.size ] = self.perk_hud[ i ];
		
	}
	self.perk_hud = new_array;
	for ( i = 0; i < self.perk_hud.size; i++ )
		self.perk_hud[ i ] move_hud( .5, 0 + ( i * 30 ), self.perk_hud[ i ].y );
	
}

function fade_hud( time, alpha )
{
	if ( isDefined( self.hud_mist ) )
		self.mist_hud delete();
	if ( isDefined( self.hud_glow ) )
		self.glow_hud delete();
		
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