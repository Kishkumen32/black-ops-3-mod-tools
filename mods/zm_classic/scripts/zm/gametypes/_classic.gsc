#using scripts\codescripts\struct;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\array_shared;
#using scripts\shared\flag_shared;

#using scripts\zm\_load;
#using scripts\zm\_zm_score;
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_bgb_machine;

#using scripts\zm\gametypes\_dev;

// BO2 WEAPON STUFF
//#using scripts\zm\_zm_t6_weapons;

#namespace classic;	

function init()
{
	callback::on_connect( &on_player_connect );
	callback::on_spawned( &on_player_spawned );

	dev::init();

	//level.start_weapon = getWeapon("pistol_m1911");

	//playing coop

	//level.default_laststandpistol = GetWeapon("pistol_m1911_upgraded");

	//playing solo

	//level.default_solo_laststandpistol = GetWeapon("pistol_m1911_upgraded");
}

function on_player_connect()
{	
	thread RemoveBGBMachines();
}

function on_player_spawned()
{
	//level flag::wait_till( "initial_blackscreen_passed" );
}

function RemoveBGBMachines()
{
	bgbMachines = GetEntArray("bgb_machine_use","targetname");

	foreach(machine in bgbMachines)
	{
		machine delete();
	}
}