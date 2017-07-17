#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\kishkumen\zm\perks\_zm_perk_juggernaut.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_util;

// #precache( "client_fx", "zombie/fx_perk_juggernaut_zmb" );
#precache( "client_fx", JUGGERNAUT_MACHINE_LIGHT_FX_FILE );

#namespace zm_perk_juggernaut;

REGISTER_SYSTEM( "zm_perk_juggernaut", &__init__, undefined )

// JUGGERNAUT

function __init__()
{
	// register custom functions for hud/lua
	zm_perks::register_perk_clientfields( PERK_JUGGERNOG, &juggernaut_client_field_func, &juggernaut_code_callback_func );
	zm_perks::register_perk_effects( PERK_JUGGERNOG, JUGGERNAUT_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( PERK_JUGGERNOG, &init_juggernaut );
}

function init_juggernaut()
{
	if( IS_TRUE(level.enable_magic) )
	{
		level._effect[JUGGERNAUT_MACHINE_LIGHT_FX]	= JUGGERNAUT_MACHINE_LIGHT_FX_FILE;
	}
}

function juggernaut_client_field_func()
{
	// clientfield::register( "clientuimodel", PERK_CLIENTFIELD_JUGGERNAUT, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function juggernaut_code_callback_func()
{
}
