#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_weapons_custom;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_kishkumen_utility;

//Perks
#using scripts\zm\_zm_perk_phdflopper;

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

REGISTER_SYSTEM( "zm_injector", &__init__, undefined )

function __init__()
{
	zm_weapons_custom::include_weapons();
	zm_weapons_custom::ReplaceWallWeapons();

	callback::on_start_gametype( &init );
}	

function init()
{
	zm_injector::main();
}

function main()
{
	zm_weapons_custom::include_weapons();
	
	//If enabled then the zombies will get a keyline round them so we can see them through walls
	level.debug_keyline_zombies = false;
}
