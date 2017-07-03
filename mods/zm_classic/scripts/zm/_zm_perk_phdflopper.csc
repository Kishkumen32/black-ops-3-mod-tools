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

#insert scripts\zm\_zm_perk_phdflopper.gsh;
#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#precache("client_fx", PERK_PHDFLOPPER_LIGHT_FX);
#precache("client_fx", PERK_PHDFLOPPER_EXPLODE_FX);

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM( "zm_perk_phdflopper", &__init__, undefined )

function __init__()
{
	if(level.CurrentMap == "zm_tomb")
		return;
		
	zm_perks::register_perk_clientfields( 	PERK_PHDFLOPPER, &phdflopper_client_field_func, &phdflopper_code_callback_func );
	zm_perks::register_perk_effects( 		PERK_PHDFLOPPER, PERK_PHDFLOPPER_LIGHT_EXPLODE_FX );
	zm_perks::register_perk_init_thread( 	PERK_PHDFLOPPER, &init_phdflopper );
}

function init_phdflopper()
{
	level._effect[PERK_PHDFLOPPER_LIGHT_EXPLODE_FX] = PERK_PHDFLOPPER_LIGHT_FX;
	level._effect[PERK_PHDFLOPPER_EXPLODE_FX_PATH] = PERK_PHDFLOPPER_EXPLODE_FX;
}
function phdflopper_client_field_func() 
{
	//clientfield::register("clientuimodel", PERK_CLIENTFIELD_PHDFLOPPER, VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT);
}

function phdflopper_code_callback_func() 
{
}