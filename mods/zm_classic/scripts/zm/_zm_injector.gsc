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

#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm;
#using scripts\zm\_zm_audio;
#using scripts\zm\_zm_powerups;
#using scripts\zm\_zm_weapons;
#using scripts\zm\_zm_utility;
#using scripts\zm\_zm_zonemgr;

//Perks
#using scripts\zm\_zm_perk_phdflopper;

//Powerups
#using scripts\zm\_zm_powerup_free_perk;

// AI
#using scripts\shared\ai\zombie;
#using scripts\shared\ai\behavior_zombie_dog;
#using scripts\shared\ai\zombie_utility;

#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_kishkumen_utility;

#insert scripts\zm\_zm_perk_phdflopper.gsh;

#precache( "fx", "weapon/fx_muz_sm_pistol_1p" );
#precache( "fx", "weapon/fx_muz_sm_pistol_3p" );
#precache( "fx", "weapon/fx_shellejects_pistol" );
#precache( "fx", "explosions/fx_exp_molotov_lotus" );
#precache( "fx", "weapon/fx_trail_fake_bullet" );
#precache( "model", "t7_props_dlc/zm/dlc0/der_riese/p7_zm_der2_teleporter_control_panel/p7_zm_der2_teleporter_control_panel_lod0" );

#precache( "fx", "weapon/fx_trail_crossbow");
#precache( "fx", "zombie/fx_muz_rocket_xm_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_rocket_xm_1p_ug_zmb");
#precache( "fx", "explosions/fx_exp_rocket_default_sm");
#precache( "fx", "zombie/fx_muz_lg_mg_3p_ug_zm");
#precache( "fx", "zombie/fx_muz_lg_mg_1p_ug_zm");
#precache( "fx", "zombie/fx_muz_md_rifle_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_md_rifle_1p_ug_zmb");
#precache( "fx", "zombie/fx_muz_lg_shotgun_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_lg_shotgun_1p_ug_zmb");
#precache( "fx", "zombie/fx_muz_sm_pistol_3p_ug_zmb");
#precache( "fx", "zombie/fx_muz_sm_pistol_1p_ug_zmb");
#precache( "fx", "dlc3/stalingrad/fx_raygun_r_3p_red_zmb");
#precache( "fx", "dlc3/stalingrad/fx_raygun_r_1p_red_zmb");

#namespace zm_injector;

REGISTER_SYSTEM( "zm_injector", &__init__, undefined )

function __init__()
{
	callback::on_start_gametype( &init );
}	

function init()
{
	zm_injector::main();
}

function main()
{
	level._uses_default_wallbuy_fx = 1;

	zm::init_fx();

	//Custom
	level thread zm_kishkumen_utility::initBGBMachines();	
	level thread zm_kishkumen_utility::RemoveAllBGBMachines();

	initCharacterStartIndex();

	if( !zm_perk_utility::is_zc_map() )
	{
		level.pack_a_punch_camo_index = 42;

	 	level.pack_a_punch_camo_index_number_variants = 1;		
	}

	if(!(level.script == "zm_zod" || level.script == "zm_tomb"))
	{
		level.start_weapon = getWeapon("bo3_m1911");

		//playing coop
		level.default_laststandpistol = GetWeapon("bo3_m1911");

		//playing solo
		level.default_solo_laststandpistol = GetWeapon("bo3_m1911_upgraded");
	};

	include_weapons();
	MapSpecific();

	//zm_kishkumen_utility::anti_cheat();
	zm_kishkumen_utility::debug();
}

function include_weapons()
{
	zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_levelcommon_weapons.csv", 1 );
}

function initCharacterStartIndex()
{
	level.characterStartIndex = RandomInt( 4 );
}

function giveCustomLoadout( takeAllWeapons, alreadySpawned )
{
	self giveWeapon( level.weaponBaseMelee );
	self zm_utility::give_start_weapon( true );
}

#define JUGGERNAUT_MACHINE_LIGHT_FX						"jugger_light"		
#define QUICK_REVIVE_MACHINE_LIGHT_FX					"revive_light"		
#define STAMINUP_MACHINE_LIGHT_FX						"marathon_light"	
#define WIDOWS_WINE_FX_MACHINE_LIGHT					"widow_light"
#define SLEIGHT_OF_HAND_MACHINE_LIGHT_FX				"sleight_light"		
#define DOUBLETAP2_MACHINE_LIGHT_FX						"doubletap2_light"		
#define DEADSHOT_MACHINE_LIGHT_FX						"deadshot_light"		
#define ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX		"additionalprimaryweapon_light"

function perk_init()
{
	level._effect[JUGGERNAUT_MACHINE_LIGHT_FX] = "zombie/fx_perk_juggernaut_factory_zmb";
	level._effect[QUICK_REVIVE_MACHINE_LIGHT_FX] = "zombie/fx_perk_quick_revive_factory_zmb";
	level._effect[SLEIGHT_OF_HAND_MACHINE_LIGHT_FX] = "zombie/fx_perk_sleight_of_hand_factory_zmb";
	level._effect[DOUBLETAP2_MACHINE_LIGHT_FX] = "zombie/fx_perk_doubletap2_factory_zmb";	
	level._effect[DEADSHOT_MACHINE_LIGHT_FX] = "zombie/fx_perk_daiquiri_factory_zmb";
	level._effect[STAMINUP_MACHINE_LIGHT_FX] = "zombie/fx_perk_stamin_up_factory_zmb";
	level._effect[ADDITIONAL_PRIMARY_WEAPON_MACHINE_LIGHT_FX] = "zombie/fx_perk_mule_kick_factory_zmb";
}

function MapSpecific()
{
	mapname = level.script;

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
		case "zm_prototype":
		case "zm_asylum":
		case "zm_sumpf":
		case "zm_theater":
		case "zm_cosmodrome":
		case "zm_temple":
		case "zm_moon":
		{
			zm_kishkumen_utility::initWunderfizzMachines();
			zm_kishkumen_utility::RemoveAllWunderfizz();			
		}
	};
}
