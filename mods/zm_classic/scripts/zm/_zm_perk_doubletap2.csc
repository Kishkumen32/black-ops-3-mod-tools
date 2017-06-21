#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_doubletap2.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", "zombie/fx_perk_doubletap2_factory_zmb" );

#namespace zm_perk_doubletap2;

REGISTER_SYSTEM( "zm_perk_doubletap2", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	if ( level.script == "zm_cosmodrome" || level.script == "zm_prototype" )
		return;
		
	enable_doubletap2_perk_for_level();
}

function enable_doubletap2_perk_for_level()
{
	zm_perks::register_perk_clientfields( 	PERK_DOUBLETAP2, &doubletap2_client_field_func, &doubletap2_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_DOUBLETAP2, DOUBLETAP2_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_DOUBLETAP2, &init_doubletap2 );
}

function init_doubletap2()
{
	level._effect[ DOUBLETAP2_MACHINE_LIGHT_FX ]						= "zombie/fx_perk_doubletap2_factory_zmb";
}

function doubletap2_client_field_func() {}

function doubletap2_code_callback_func() {}