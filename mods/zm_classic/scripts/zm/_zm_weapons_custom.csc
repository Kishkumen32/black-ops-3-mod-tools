#using scripts\codescripts\struct;
#using scripts\shared\audio_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\zm\_zm_weapons;

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;

#namespace zm_weapons_custom;

function include_weapons()
{
	if(wardog_zm_util::is_waw_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_waw_weapons.csv", 1 );		
	}

	if(wardog_zm_util::is_zc_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_zc_blackop3.csv", 1 );
	}

	if(wardog_zm_util::is_stock_map())
	{
		zm_weapons::load_weapon_spec_from_table( "gamedata/weapons/zm/zm_vanilla_blackop3.csv", 1 );
	}
}

function ReplaceWallWeapons()
{
	if( !(level.CurrentMap == "zm_cosmodrome") && !(level.CurrentMap == "zm_tomb") && !(level.CurrentMap == "zm_prototype") && wardog_zm_util::is_zc_map() )
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

	if(level.CurrentMap == "zm_cosmodrome")
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

	if(level.CurrentMap == "zm_moon")
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

	if(level.CurrentMap == "zm_prototype")
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