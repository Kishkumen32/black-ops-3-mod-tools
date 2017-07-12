// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\filter_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;
#using scripts\shared\visionset_mgr_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\wardog_zm_load;

// 3arc - Zombiemode
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace wardog_zm_util;

function is_stock_map()
{
	if (isdefined(level.CurrentMap) && (level.CurrentMap == "zm_factory" || level.CurrentMap == "zm_zod" || level.CurrentMap == "zm_castle" || level.CurrentMap == "zm_island" || level.CurrentMap == "zm_stalingrad" || level.CurrentMap == "zm_genesis"))
		return 1;
	
	return 0;
}

function is_zc_map()
{
	if (isdefined(level.CurrentMap) && (level.CurrentMap == "zm_prototype" || level.CurrentMap == "zm_asylum" || level.CurrentMap == "zm_sumpf" || level.CurrentMap == "zm_theater" || level.CurrentMap == "zm_cosmodrome" || level.CurrentMap == "zm_temple" || level.CurrentMap == "zm_moon" || level.CurrentMap == "zm_tomb"))
		return 1;
	
	return 0;
}

function is_waw_map()
{
	if(isdefined(level.CurrentMap) && (level.CurrentMap == "zm_prototype" || level.CurrentMap == "zm_asylum" || level.CurrentMap == "zm_sumpf"))
		return 1;

	return 0;
}

function is_perk(perk)
{
	Assert(isdefined(perk), "perk is a required argument for is_perk!");

	if(isdefined(level._custom_perks) && isdefined(level._custom_perks[perk]))
		return true;
	return false;
}
