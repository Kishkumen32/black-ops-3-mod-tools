#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\compass;
#using scripts\shared\exploder_shared;
#using scripts\shared\system_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

// T7 Script Suite - Include everything
#insert scripts\m_shared\utility.gsh;
T7_SCRIPT_SUITE_INCLUDES

#using scripts\zm\_zm_weapons;

//Perks
#using scripts\zm\_zm_perk_phdflopper;
#using scripts\zm\_zm_perk_random;

//Custom
#using scripts\zm\kishkumen\_zm_kishkumen_utility;

#using scripts\zm\_zm_perks_ss;

#namespace zm_injector;

REGISTER_SYSTEM( "zm_injector", &__init__, undefined )

function autoexec main()
{
	callback::add_callback(#"on_pre_initialization", &__pre_init__);
	callback::add_callback(#"on_start_gametype", &__post_init__);
	callback::on_connect(&__player_connect__);
}

function __pre_init__()
{
	level.debug = true;
	level.debug_coord = false;

	zm_kishkumen_utility::RemoveAllBGBMachines();	

	remove_random_perk_machine();		

	modify_3arc_maps();
}

function __init__()
{
}

function __post_init__()
{	
	zm_kishkumen_utility::dev_mode();

	remove_perks_from_random_machine();

	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );

	level.start_weapon = getWeapon("bo1_m1911");

	//playing coop
	level.default_laststandpistol = GetWeapon("bo1_m1911_upgraded");

	//playing solo
	level.default_solo_laststandpistol = GetWeapon("bo1_m1911_upgraded");
}

function __player_connect__()
{
	level thread zm_kishkumen_utility::origin_angle_print();
}

function remove_perks_from_random_machine()
{
	mapname = ToLower( GetDvarString( "mapname" ) );

	switch(mapname)
	{
		case "zm_prototype":
		case "zm_asylum":
		case "zm_sumpf":
		case "zm_theater":
		{
			m_zm_perks::remove_perk_from_random_rotation("specialty_widowswine");
			m_zm_perks::remove_perk_from_random_rotation("specialty_staminup");		
			m_zm_perks::remove_perk_from_random_rotation("specialty_deadshot");	
			m_zm_perks::remove_perk_from_random_rotation("specialty_electriccherry");		
			break;
		}
		case "zm_cosmodrome":
		{		
			m_zm_perks::remove_perk_from_random_rotation("specialty_widowswine");	
			m_zm_perks::remove_perk_from_random_rotation("specialty_deadshot");	
			m_zm_perks::remove_perk_from_random_rotation("specialty_electriccherry");
			break;
		}		
		case "zm_temple":
		case "zm_moon":
		case "zm_tomb":
		{
			m_zm_perks::remove_perk_from_random_rotation("specialty_widowswine");

			zm_perk_random::include_perk_in_random_rotation("specialty_phdflopper");
			break;
		}
		default:
		{
			break;
		}
	};
}

function remove_random_perk_machine()
{
	mapname = ToLower( GetDvarString( "mapname" ) );

	switch(mapname)
	{
		case "zm_island": 
		case "zm_prototype":
		case "zm_asylum":
		case "zm_sumpf":
		case "zm_theater":
		case "zm_cosmodrome":
		case "zm_temple":
		case "zm_moon":
		{
			zm_kishkumen_utility::RemoveAllWunderfizz();
			break;
		}
		default:
		{
			break;
		}
	};
}

function modify_3arc_maps()
{
	mapname = ToLower( GetDvarString( "mapname" ) );

	switch(mapname)
	{
		case "zm_island": 
		{
			origin = (-176.359,2410.86,-383.875);
			angles = (0,176,0);

			origin_dragon = (-1924.52,800.659,276.125);
			angles_dragon = (0, -71.7902, 0);

			t_use = spawn( "trigger_radius_use", origin + ( 0, 0, 30), 0, 40, 80 );
			t_use.targetname = "dragon_room_teleport";
			t_use UseTriggerRequireLookAt();
			t_use TriggerIgnoreTeam();

			control_panel = spawn("script_model", origin + ( 0, 0, 30) );
			control_panel.angles = angles + (0, 270, 0);
			control_panel setModel("p7_zm_der2_teleporter_control_panel");

			collision = spawn("script_model", origin, 1 );
			collision.angles = angles;
			collision setModel("zm_collision_perks1");
			collision.script_noteworthy = "clip";
			collision disconnectPaths();

			t_use.clip = collision;
			t_use.machine = control_panel;

			while(1)
			{
				t_use SetHintString( "Press ^3&&1^7 to Teleport to Dragon Room" );
				t_use SetCursorHint( "HINT_NOICON" );

				t_use waittill( "trigger", player);
				t_use SetHintString( "" );

				player SetOrigin(origin_dragon);
				player SetPlayerAngles(angles_dragon);
				wait(2);
			}

			break;
		}
		default:
		{
			break;
		}
	};
}