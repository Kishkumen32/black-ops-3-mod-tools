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

// 3arc - Zombiemode
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#using scripts\zm\_zm_score;

#namespace zm_kishkumen_utility; 

function RemoveAllBGBMachines()
{
	for( i = 0; i < level.bgb_machine_spots.size; i++)
	{
		spot = level.bgb_machine_spots[i];

		spot Delete();
	}	
}

function RemoveAllWunderfizz()
{
	for( i = 0; i < level.wunderfizz_machine_spots.size; i++)
	{
		spot = level.wunderfizz_machine_spots[i];

		spot Delete();
	}	
}

function is_perk(perk)
{
	Assert(isdefined(perk), "perk is a required argument for is_perk!");

	if(isdefined(level._custom_perks) && isdefined(level._custom_perks[perk]))
		return true;
		
	return false;
}