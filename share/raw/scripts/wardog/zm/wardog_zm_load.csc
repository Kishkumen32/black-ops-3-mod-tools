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

#using scripts\wardog\zm\perks\wardog_perk_hud;

#using scripts\zm\_zm_score;

#namespace wardog_zm_load;

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::on_finalize_initialization(&__init__);
	callback::on_start_gametype(&__post_init__);
	callback::on_localclient_connect(&__player_connect__);
}

function __pre_init__()
{
	level.CurrentMap = tolower(GetDvarString("mapname"));
}

function __init__()
{
}

function __post_init__()
{
}

function __player_connect__(clientnum)
{
	player = GetLocalPlayer(clientnum);
}
