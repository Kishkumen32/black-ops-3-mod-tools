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

#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_random;

#namespace zm_injector;

function autoexec main()
{
	LuiLoad( "ui.uieditor.menus.hud.remove_bubblegum_pack_hud" );
	
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::on_finalize_initialization(&__init__);
	callback::on_start_gametype(&__post_init__);
	callback::on_localclient_connect(&__player_connect__);
}

function __pre_init__()
{
	script = ToLower( GetDvarString( "mapname" ) );
}

function __init__()
{
}

function __post_init__()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );
}

function __player_connect__(clientnum)
{
	player = GetLocalPlayer(clientnum);
}