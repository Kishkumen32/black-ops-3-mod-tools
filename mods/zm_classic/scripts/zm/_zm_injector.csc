#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_perk_phdflopper;

//Powerups
#using scripts\zm\_zm_powerup_free_perk;

// Weapons
#using scripts\zm\_zm_weap_ammo_counter;

#insert scripts\zm\_zm_weap_ammo_counter.gsh;

#namespace zm_injector;

#precache( "client_fx", "weapon/fx_muz_sm_pistol_1p" );
#precache( "client_fx", "weapon/fx_muz_sm_pistol_3p" );
#precache( "client_fx", "weapon/fx_shellejects_pistol" );
#precache( "client_fx", "explosions/fx_exp_molotov_lotus" );
#precache( "client_fx", "zombie/fx_blood_torso_explo_zmb" );
#precache( "client_fx", "weapon/fx_trail_fake_bullet" );

#precache( "client_fx", "weapon/fx_trail_crossbow");
#precache( "client_fx", "zombie/fx_muz_rocket_xm_3p_ug_zmb");
#precache( "client_fx", "zombie/fx_muz_rocket_xm_1p_ug_zmb");
#precache( "client_fx", "explosions/fx_exp_rocket_default_sm");
#precache( "client_fx", "zombie/fx_muz_lg_mg_3p_ug_zm");
#precache( "client_fx", "zombie/fx_muz_lg_mg_1p_ug_zm");
#precache( "client_fx", "zombie/fx_muz_md_rifle_3p_ug_zmb");
#precache( "client_fx", "zombie/fx_muz_md_rifle_1p_ug_zmb");
#precache( "client_fx", "zombie/fx_muz_lg_shotgun_3p_ug_zmb");
#precache( "client_fx", "zombie/fx_muz_lg_shotgun_1p_ug_zmb");
#precache( "client_fx", "zombie/fx_muz_sm_pistol_3p_ug_zmb");
#precache( "client_fx", "zombie/fx_muz_sm_pistol_1p_ug_zmb");
#precache( "client_fx", "dlc3/stalingrad/fx_raygun_r_3p_red_zmb");
#precache( "client_fx", "dlc3/stalingrad/fx_raygun_r_1p_red_zmb");


function autoexec init()
{
	zm_injector::main();
}

function main()
{
	//If enabled then the zombies will get a keyline round them so we can see them through walls
	level.debug_keyline_zombies = false;

	include_perks();
	include_weapons();
}

#define JUGGERNAUT_MACHINE_LIGHT_FX				"jugger_light"		
#define QUICK_REVIVE_MACHINE_LIGHT_FX			"revive_light"		
#define STAMINUP_MACHINE_LIGHT_FX				"marathon_light"	
#define WIDOWS_WINE_FX_MACHINE_LIGHT				"widow_light"
#define SLEIGHT_OF_HAND_MACHINE_LIGHT_FX				"sleight_light"		
#define DOUBLETAP2_MACHINE_LIGHT_FX				"doubletap2_light"		
#define DEADSHOT_MACHINE_LIGHT_FX				"deadshot_light"		
#define ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX					"additionalprimaryweapon_light"

function include_perks()
{
	level._effect[JUGGERNAUT_MACHINE_LIGHT_FX] = "zombie/fx_perk_juggernaut_factory_zmb";
	level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX] = "zombie/fx_perk_quick_revive_factory_zmb";
	level._effect[SLEIGHT_OF_HAND_MACHINE_LIGHT_FX] = "zombie/fx_perk_sleight_of_hand_factory_zmb";
	level._effect[DOUBLETAP2_MACHINE_LIGHT_FX] = "zombie/fx_perk_doubletap2_factory_zmb";
	level._effect[DEADSHOT_MACHINE_LIGHT_FX] = "zombie/fx_perk_daiquiri_factory_zmb";
	level._effect[STAMINUP_MACHINE_LIGHT_FX] = "zombie/fx_perk_stamin_up_factory_zmb";
	level._effect[ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX] = "zombie/fx_perk_mule_kick_factory_zmb";	
}

function include_weapons()
{
	level.script = GetDvarString( "mapname" );
	
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );

	if (( level.script == "zm_prototype" || level.script == "zm_asylum" || level.script == "zm_sumpf" || level.script == "zm_factory" ))
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_waw_weapons.csv", 1 );		
	}

	if ( level.script == "zm_prototype" || level.script == "zm_asylum" || level.script == "zm_sumpf" || level.script == "zm_theater" || level.script == "zm_cosmodrome" || level.script == "zm_moon" || level.script == "zm_tomb" )
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_zc_blackop3.csv", 1 );
	}

	if ( level.script == "zm_factory" || level.script == "zm_zod" || level.script == "zm_castle" || level.script == "zm_island" || level.script == "zm_stalingrad" || level.script == "zm_genesis" )
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_vanilla_blackop3.csv", 1 );
	}
}