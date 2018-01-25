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

#precache( "client_fx", PHDFLOPPER_MACHINE_FACTORY_LIGHT_FX_PATH );
#precache( "client_fx", PHDFLOPPER_MACHINE_LIGHT_FX_PATH );

#namespace zm_perk_phdflopper;

REGISTER_SYSTEM( "zm_perk_phdflopper", &__init__, undefined )

//-----------------------------------------------------------------------------------
// SETUP
//-----------------------------------------------------------------------------------
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
			zm_perks::register_perk_clientfields( 	PERK_PHDFLOPPER, &phdflopper_client_field_func, &phdflopper_code_callback_func );
			zm_perks::register_perk_effects( 		PERK_PHDFLOPPER, PERK_PHDFLOPPER );
			zm_perks::register_perk_init_thread( 	PERK_PHDFLOPPER, &phdflopper_init );
			break;
		}
	}
}

function phdflopper_init()
{
	if( IS_TRUE(level.enable_magic) )
	{
		script = toLower( getDvarString( "mapname" ) );
		if ( script != "zm_factory" )
			level._effect[ PHDFLOPPER_MACHINE_LIGHT_FX ]		= PHDFLOPPER_MACHINE_LIGHT_FX_PATH;
		else
			level._effect[ PHDFLOPPER_MACHINE_LIGHT_FX ]		= PHDFLOPPER_MACHINE_FACTORY_LIGHT_FX_PATH;
	}
}

function phdflopper_client_field_func() 
{
	clientfield::register( "clientuimodel", "hudItems.perks.dive_to_nuke", VERSION_SHIP, 2, "int", undefined, !CF_HOST_ONLY, CF_CALLBACK_ZERO_ON_NEW_ENT );
}

function phdflopper_code_callback_func() 
{
}