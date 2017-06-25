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

#namespace zm_weapons_custom;

function autoexec init()
{
	zm_weapons_custom::main();
}

function main()
{	

}

function ReplaceWallWeapons()
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
	}
}