#using scripts\codescripts\struct;

#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;

#insert scripts\wardog\shared\wardog_shared.gsh; // This line is required so the below macro is valid
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;

#using scripts\zm\_zm_powerups;

#insert scripts\zm\_zm_powerups.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace zm_powerup_ww_grenade;

REGISTER_SYSTEM( "zm_powerup_ww_grenade", &__init__, undefined )
	
function __init__()
{
	if( level.CurrentMap == "zm_factory" || wardog_zm_util::is_zc_map() )
		return;
		
	zm_powerups::include_zombie_powerup( "ww_grenade" );
	zm_powerups::add_zombie_powerup( "ww_grenade" );
}
