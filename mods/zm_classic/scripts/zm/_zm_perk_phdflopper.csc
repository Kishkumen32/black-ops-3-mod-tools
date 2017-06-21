#using scripts\codescripts\struct;

#using scripts\shared\clientfield_shared;
#using scripts\shared\system_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_perks;

#insert scripts\zm\_zm_perk_phdflopper.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache( "client_fx", "zombie/fx_perk_doubletap2_factory_zmb" );

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM( "zm_perk_phdflopper", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
function __init__()
{
	level.script = GetDvarString( "mapname" );
	
	if( level.script == "zm_tomb")
		return;

	zm_perks::register_perk_clientfields( 	PERK_PHDFLOPPER, &phdflopper_client_field_func, &phdflopper_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_PHDFLOPPER, PHDFLOPPER_MACHINE_LIGHT_FX );
	zm_perks::register_perk_init_thread( 	PERK_PHDFLOPPER, &init_phdflopper );
}

function init_phdflopper()
{
	level._effect[ PHDFLOPPER_MACHINE_LIGHT_FX ]	= "zombie/fx_perk_doubletap2_factory_zmb";
}

function phdflopper_client_field_func() {}

function phdflopper_code_callback_func() {}