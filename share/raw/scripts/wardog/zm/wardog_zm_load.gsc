// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// 3arc - Zombiemode
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#insert scripts\wardog\shared\wardog_shared.gsh; // This line is required so the below macro is valid
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;

#namespace wardog_zm_load;

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::add_callback(#"on_finalize_initialization", &__init__);
	callback::add_callback(#"on_start_gametype", &__post_init__);
	callback::on_connect(&__player_connect__);
}

function __pre_init__()
{
	level.CurrentMap = tolower(GetDvarString("mapname"));

	level.bgb_machine_spots = GetEntArray( "bgb_machine_use", "targetname" );
	level.wunderfizz_machine_spots = GetEntArray( "perk_random_machine", "targetname" );
}

function __init__()
{
	wardog_perk_hud::perk_hud_init();
}

function __post_init__()
{	
	perk_lights();

	if(isdefined(level.debug) && level.debug)
	{
		dev_mode();
	}
}

function __player_connect__()
{
}

function dev_mode()
{
	wait 10;
	iPrintLn( "GIVE POINTS" );
	players = getPlayers();
	for ( i = 0; i < players.size; i++ )
	{
		players[ i ] zm_score::add_to_player_score( 500000 );
	}

	level.perk_purchase_limit = 13;

	iPrintLn(level.script);

	a_keys = GetArrayKeys( level._custom_perks );
		
	for ( i = 0; i < a_keys.size; i++ )
	{
		iPrintLn(a_keys[ i ]);
	}
}

// Perk Lights
function private perk_lights()
{
	register_perk_light(PERK_JUGGERNOG, "juggernaut_lgts");
	register_perk_light(PERK_QUICK_REVIVE, "quick_revive_lgts");
	register_perk_light(PERK_SLEIGHT_OF_HAND, "sleight_of_hand_lgts");
	register_perk_light(PERK_DOUBLETAP2, "doubletap2_lgts");
	register_perk_light(PERK_PHDFLOPPER, "divetonuke_lgts");
	register_perk_light(PERK_STAMINUP, "marathon_lgts");
	register_perk_light(PERK_DEAD_SHOT, "dead_shot_lgts");
	register_perk_light(PERK_ADDITIONAL_PRIMARY_WEAPON, "additional_primary_weapon_lgts");
	register_perk_light(PERK_ELECTRIC_CHERRY, "electric_cherry_lgts");
	register_perk_light(PERK_WIDOWS_WINE, "widows_wine_lgts");
	register_perk_light("Pack_A_Punch", "packapunch_lgts");

	foreach(perk in GetArrayKeys(level._custom_perks))
	{
		str_notify = perk;

		if(isdefined(level._custom_perks[perk].alias))
			str_notify = level._custom_perks[perk].alias;

		level thread perk_lights_flag_think(perk, str_notify + "_on", str_notify + "_off");
	}

	level thread perk_lights_flag_think("Pack_A_Punch", "Pack_A_Punch_on", "Pack_A_Punch_off");
}

function register_perk_light(perk, light)
{
	MAKE_ARRAY(level.wardog_perk_lights)

	level.wardog_perk_lights[perk] = light;
}

function activate_perk_lights(perk)
{
	if(!isdefined(level.wardog_perk_lights))
		return;
	if(!isdefined(level.wardog_perk_lights[perk]))
		return;
	if(!level flag::exists("wardog_power_lights_" + perk))
		level flag::init("wardog_power_lights_" + perk);
	if(level flag::get("wardog_power_lights_" + perk))
		return;

	level flag::set("wardog_power_lights_" + perk);
	exploder::exploder(level.wardog_perk_lights[perk]);
}

function deactivate_perk_lights(perk)
{
	if(!isdefined(level.wardog_perk_lights))
		return;
	if(!isdefined(level.wardog_perk_lights[perk]))
		return;
	if(!level flag::exists("wardog_power_lights_" + perk))
		level flag::init("wardog_power_lights_" + perk);
	if(!level flag::get("wardog_power_lights_" + perk))
		return;

	level flag::clear("wardog_power_lights_" + perk);
	exploder::stop_exploder(level.wardog_perk_lights[perk]);
}

function private perk_lights_flag_think(perk, power_on_notify, power_off_notify)
{
	level endon("pre_end_game");
	level endon("end_game");

	for(;;)
	{
		level waittill(power_on_notify);
		activate_perk_lights(perk);

		level waittill(power_off_notify);
		deactivate_perk_lights(perk);
	}
}