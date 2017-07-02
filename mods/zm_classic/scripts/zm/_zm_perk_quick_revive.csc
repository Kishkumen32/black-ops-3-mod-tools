#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
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

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_quick_revive.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

// s#precache( "client_fx", "zombie/fx_perk_quick_revive_zmb" );
#precache( "client_fx", QUICK_REVIVE_MACHINE_LIGHT_FX_FILE );
#namespace zm_perk_quick_revive;

REGISTER_SYSTEM( "zm_perk_quick_revive", &__init__, undefined )

// QUICK REVIVE ( QUICK REVIVE )

function __init__()
{
	enable_quick_revive_perk_for_level();
}

function enable_quick_revive_perk_for_level()
{
	// register custom functions for hud/lua
	zm_perks::register_perk_clientfields( PERK_QUICK_REVIVE, &quick_revive_client_field_func, &quick_revive_callback_func );
	zm_perks::register_perk_effects( PERK_QUICK_REVIVE, QUICK_REVIVE_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( PERK_QUICK_REVIVE, &init_quick_revive );
}

function init_quick_revive()
{
	if( IS_TRUE(level.enable_magic) )
	{
		// level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX]	= "zombie/fx_perk_quick_revive_zmb";
		level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX]	= QUICK_REVIVE_MACHINE_LIGHT_FX_FILE;
	}
}

function quick_revive_client_field_func()
{
	// WARDOGSK93 - Code Start
	// clientfield::register( "clientuimodel", PERK_CLIENTFIELD_QUICK_REVIVE, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
	// WARDOGSK93 - Code End
}

function quick_revive_callback_func()
{
}
