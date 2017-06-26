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

#using scripts\zm\_zm_weapons;

//Weapons
#using scripts\zm\_zm_weap_ammo_counter;
#using scripts\zm\zm_flamethrower;

#using scripts\zm\_zm_perk_utility;
#using scripts\zm\_zm_kishkumen_utility;

#insert scripts\zm\_zm_weap_ammo_counter.gsh;

#namespace zm_weapons_custom;

REGISTER_SYSTEM( "zm_weapons_custom", &__init__, undefined )

function __init__()
{
	callback::on_start_gametype( &init );
}	

function init()
{

}

function include_weapons()
{
	if(zm_perk_utility::is_waw_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_waw_weapons.csv", 1 );		
	}

	if(zm_perk_utility::is_zc_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_zc_blackop3.csv", 1 );
	}

	if(zm_perk_utility::is_stock_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_vanilla_blackop3.csv", 1 );
	}
}

function ReplaceWallWeapons()
{
	AscensionWallWeapons();	
}

function AscensionWallWeapons()
{
	if( !(level.script == "zm_cosmodrome") && !(level.script == "zm_tomb") && !(level.script == "zm_prototype") && zm_perk_utility::is_zc_map() )
	{
		spawnable_weapon_spawns = struct::get_array( "weapon_upgrade", "targetname" );

		for(i = 0; i < spawnable_weapon_spawns.size; i++)
		{
			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "ar_marksman")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "ar_m14";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "pistol_burst")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "shotgun_rottweil72";
			}
		}
	}

	if(level.script == "zm_cosmodrome")
	{
		pistol_burst_found = false;

		spawnable_weapon_spawns = struct::get_array( "weapon_upgrade", "targetname" );

		for(i = 0; i < spawnable_weapon_spawns.size; i++)
		{
			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "ar_marksman")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "ar_m14";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "pistol_burst")
			{
				if( !pistol_burst_found )
				{
					spawnable_weapon_spawns[i].zombie_weapon_upgrade = "shotgun_rottweil72";

					pistol_burst_found = true;
				}
				else
				{				
					spawnable_weapon_spawns[i].zombie_weapon_upgrade = "smg_mp5k";
				}
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "smg_fastfire")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "smg_ak74u";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "shotgun_precision")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "bo1_stakeout";
			}
		}
	}

	if(level.script == "zm_moon")
	{
		spawnable_weapon_spawns = struct::get_array( "weapon_upgrade", "targetname" );

		for(i = 0; i < spawnable_weapon_spawns.size; i++)
		{
			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "smg_versatile")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "smg_mp5k";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "smg_burst")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "bo1_kiparis";
			}			

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "ar_standard")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "smg_ak74u";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "shotgun_precision")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "bo1_stakeout";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "pistol_fullauto")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "bo1_mpl";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "smg_standard")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "ar_m16";
			}
		}
	}

	if(level.script == "zm_prototype")
	{
		spawnable_weapon_spawns = struct::get_array( "weapon_upgrade", "targetname" );

		for(i = 0; i < spawnable_weapon_spawns.size; i++)
		{
			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "smg_standard")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "thompson";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "ar_marksman")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "ar_m14";
			}

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "pistol_burst")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "m1garand";
			}			

			if(spawnable_weapon_spawns[i].zombie_weapon_upgrade == "ar_standard")
			{
				spawnable_weapon_spawns[i].zombie_weapon_upgrade = "ar_stg44";
			}
		}
	}
}