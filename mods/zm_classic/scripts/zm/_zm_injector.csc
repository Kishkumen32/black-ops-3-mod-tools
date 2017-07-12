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

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\zm\wardog_zm_util;
#using scripts\wardog\zm\wardog_zm_load;

#using scripts\zm\_zm_perk_phdflopper;

#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_weapons_custom;

#insert scripts\zm\_zm_perk_phdflopper.gsh;

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

#namespace zm_injector;

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::on_finalize_initialization(&__init__);
	callback::on_start_gametype(&__post_init__);
	callback::on_localclient_connect(&__player_connect__);
}

function __pre_init__()
{
	zm_weapons_custom::include_weapons();
	zm_weapons_custom::ReplaceWallWeapons();
}

function __init__()
{
}

function __post_init__()
{
	if(wardog_zm_util::is_zc_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );
	}
}

function __player_connect__(clientnum)
{
}