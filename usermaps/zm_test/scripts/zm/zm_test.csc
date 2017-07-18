#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

// Wardog Scripts
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;
#using scripts\wardog\zm\perks\wardog_perk_hud;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_pack_a_punch;
#using scripts\zm\_zm_perk_additionalprimaryweapon;
#using scripts\zm\_zm_perk_doubletap2;
#using scripts\zm\_zm_perk_deadshot;
#using scripts\zm\_zm_perk_juggernaut;
#using scripts\zm\_zm_perk_quick_revive;
#using scripts\zm\_zm_perk_sleight_of_hand;
#using scripts\zm\_zm_perk_staminup;
#using scripts\zm\_zm_perk_electric_cherry;
#using scripts\zm\_zm_perk_widows_wine;
#using scripts\zm\_zm_perk_phdflopper;

//Powerups
#using scripts\zm\_zm_powerup_double_points;
#using scripts\zm\_zm_powerup_carpenter;
#using scripts\zm\_zm_powerup_fire_sale;
#using scripts\zm\_zm_powerup_free_perk;
#using scripts\zm\_zm_powerup_full_ammo;
#using scripts\zm\_zm_powerup_insta_kill;
#using scripts\zm\_zm_powerup_nuke;

//Traps
#using scripts\zm\_zm_trap_electric;

#using scripts\zm\zm_usermap;

//Frost Iceforge's custom eye color
#define RED_EYE_FX    "frost_iceforge/red_zombie_eyes"
#define ORANGE_EYE_FX    "frost_iceforge/orange_zombie_eyes"
#define GREEN_EYE_FX    "frost_iceforge/green_zombie_eyes"
#define BLUE_EYE_FX    "frost_iceforge/blue_zombie_eyes"
#define PURPLE_EYE_FX    "frost_iceforge/purple_zombie_eyes"
#define PINK_EYE_FX    "frost_iceforge/pink_zombie_eyes"
#define WHITE_EYE_FX    "frost_iceforge/white_zombie_eyes"
#precache( "client_fx", RED_EYE_FX );
#precache( "client_fx", ORANGE_EYE_FX );
#precache( "client_fx", GREEN_EYE_FX );
#precache( "client_fx", BLUE_EYE_FX );
#precache( "client_fx", PURPLE_EYE_FX );
#precache( "client_fx", PINK_EYE_FX );
#precache( "client_fx", WHITE_EYE_FX );

function main()
{
	zm_usermap::main();

	set_eye_color();

	include_weapons();
	
	util::waitforclient( 0 );
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table("gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1);
}

function set_eye_color()
{
	level._override_eye_fx = BLUE_EYE_FX;
}