// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\laststand_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\wardog\shared\wardog_shared.gsh; // This line is required so the below macro is valid
#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#using scripts\wardog\zm\perks\wardog_perk_hud;
#using scripts\wardog\zm\wardog_zm_load;
#using scripts\wardog\zm\wardog_zm_util;

// 3arc - Zombiemode
#using scripts\zm\_zm_perks;
#using scripts\zm\_zm_utility;

#insert scripts\zm\_zm_perks.gsh;
#insert scripts\zm\_zm_utility.gsh;

#namespace wardog_zm_util;

function is_stock_map()
{
	if (isdefined(level.CurrentMap) && (level.CurrentMap == "zm_factory" || level.CurrentMap == "zm_zod" || level.CurrentMap == "zm_castle" || level.CurrentMap == "zm_island" || level.CurrentMap == "zm_stalingrad" || level.CurrentMap == "zm_genesis"))
		return 1;
	
	return 0;
}

function is_zc_map()
{
	if (isdefined(level.CurrentMap) && (level.CurrentMap == "zm_prototype" || level.CurrentMap == "zm_asylum" || level.CurrentMap == "zm_sumpf" || level.CurrentMap == "zm_theater" || level.CurrentMap == "zm_cosmodrome" || level.CurrentMap == "zm_temple" || level.CurrentMap == "zm_moon" || level.CurrentMap == "zm_tomb"))
		return 1;
	
	return 0;
}

function is_waw_map()
{
	if(isdefined(level.CurrentMap) && (level.CurrentMap == "zm_prototype" || level.CurrentMap == "zm_asylum" || level.CurrentMap == "zm_sumpf"))
		return 1;

	return 0;
}

function place_perk_machine( origin, angles, perk, model, power_zone = undefined, script_notify = "", blocker_model = undefined, turn_on_notify = "")
{
	t_use = Spawn( "trigger_radius_use", origin + ( 0, 0, 60 ), 0, 40, 80 );
	t_use.targetname = "zombie_vending";			
	t_use.script_noteworthy = perk;

	if(isdefined(power_zone))
		t_use.script_int =  power_zone;

	t_use TriggerIgnoreTeam();

	if ( level.script == "zm_zod" || level.script == "zm_genesis" )
		t_use thread force_power();

	perk_machine = Spawn("script_model", origin);

	if ( !isdefined(angles))
		angles = ( 0, 0, 0 );
	
	perk_machine.angles = angles;
	perk_machine SetModel(model);

	bump_trigger = Spawn( "trigger_radius", origin + ( 0, 0, 30 ), 0, 40, 80 );
	bump_trigger.script_activated = 1;
	bump_trigger.script_sound = "zmb_perks_bump_bottle";
	bump_trigger.targetname = "audio_bump_trigger";
	
	collision = Spawn("script_model", origin, 1);
	collision.angles = angles;
	collision SetModel("zm_collision_perks1");
	collision.script_noteworthy = "clip";
	collision DisconnectPaths();
	
	t_use.clip = collision;
	t_use.machine = perk_machine;
	t_use.bump = bump_trigger;

	if(isdefined(script_notify))
		perk_machine.script_notify = script_notify;
	if(isdefined(blocker_model))
		t_use.blocker_model = blocker_model;
	if(isdefined(power_zone))
		perk_machine.script_int = power_zone;
	if(isdefined(turn_on_notify))
		perk_machine.turn_on_notify = turn_on_notify;
	
	[[ level._custom_perks[ perk ].perk_machine_set_kvps ]]( t_use, perk_machine, bump_trigger, collision );
}

function private force_power()
{
	wait 10;
	level notify( "divetonuke_on" );
}

function is_perk_in_map(perk)
{
	foreach(trigger in GetEntArray("zm_perk_machine", "targetname"))
	{
		if(isdefined(trigger.script_noteworthy) && trigger.script_noteworthy == perk)
			return true;
	}

	return false;
}

/@
"Name: waittill_round(<round>)"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Waits till specified round is reached"
"MandatoryArg: <round>: Round to wait till."
"Example: waittill_round(1);"
"SPMP: multiplayer"
@/
function waittill_round(round_number = level.round_number)
{
	Assert(isdefined(round_number), "round_number is a required argument for waittill_round!");

	while(level.round_number < round_number)
	{
		WAIT_SERVER_FRAME
	}
}

/@
"Name: waittill_round_range(<start_round>, <end_round>)"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Waits till specified round is reached in range"
"MandatoryArg: <start_round>: Start round to wait till."
"MandatoryArg: <end_round>: End round to wait till."
"Example: waittill_round_range(1, 5);"
"SPMP: multiplayer"
@/
function waittill_round_range(start_round, end_round)
{
	Assert(isdefined(start_round), "start_round is a required argument for waittill_round_range!");
	Assert(isdefined(end_round), "end_round is a required argument for waittill_round_range!");

	waittill_round(RandomIntRange(start_round, end_round));
}

/@
"Name: replace_perk_machines(<from_perk>, <to_perk>)"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Replaces all triggers for perk A with a trigger for perk B"
"MandatoryArg: <from_perk>: All perk triggers with this script_noteworthy will be replaced."
"MandatoryArg: <to_perk>: The perk to change to."
"Example: replace_perk_machines("specialty_widowswine", "specialty_phdflopper");"
"SPMP: multiplayer"
@/
function replace_perk_machines(from_perk, to_perk)
{
	Assert(isdefined(from_perk), "from_perk is a required argument for replace_perk_machines!");
	Assert(isdefined(to_perk), "to_perk is a required argument for replace_perk_machines!");

	foreach(trigger in GetEntArray("zombie_vending", "targetname"))
	{
		if(isdefined(trigger.script_noteworthy) && trigger.script_noteworthy == from_perk)
			replace_perk_machine(trigger, to_perk);
	}
}

/@
"Name: replace_perk_machine(<trigger>)"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Replaces this trigger with a trigger for perk A"
"MandatoryArg: <trigger>: Trigger to replace."
"MandatoryArg: <to_perk>: The perk to change to."
"Example: replace_perk_machine(trigger, "specialty_phdflopper");"
"SPMP: multiplayer"
@/
function replace_perk_machine(trigger, to_perk)
{
	Assert(isdefined(trigger), "trigger is a required argument for replace_perk_machine!");
	Assert(isdefined(to_perk), "to_perk is a required argument for replace_perk_machine!");

	trigger.script_noteworthy = to_perk;

	perk_machine = trigger.machine;
	bump_trigger = trigger.bump;
	collision = trigger.clip;

	if(!isdefined(perk_machine))
		perk_machine = Spawn("script_model", trigger.origin - (0, 0, 60));
	if(isdefined(level.machine_assets) && isdefined(level.machine_assets[to_perk]) && isdefined(level.machine_assets[to_perk].off_model))
		perk_machine SetModel(level.machine_assets[to_perk].off_model);

	if(!isdefined(bump_trigger))
	{
		if(!IS_TRUE(level._no_vending_machine_bump_trigs))
		{
			bump_trigger = Spawn("trigger_radius", perk_machine.origin + (0, 0, 30), 0, 40, 80);
			bump_trigger.script_activated = 1;
			bump_trigger.script_sound = "zmb_perks_bump_bottle";
			bump_trigger.targetname = "audio_bump_trigger";
		}
	}

	if(!isdefined(collision))
	{
		if(!IS_TRUE(level._no_vending_machine_auto_collision))
		{
			collision = Spawn("script_model", perk_machine.origin, 1);
			collision.angles = perk_machine.angles;
			collision SetModel("zm_collision_perks1");
			collision.script_noteworthy = "clip";
			collision DisconnectPaths();
		}
	}

	trigger.clip = collision;
	trigger.machine = perk_machine;
	trigger.bump = bump_trigger;

	if(is_perk(to_perk) && isdefined(level._custom_perks[to_perk].perk_machine_set_kvps))
		util::single_func(level, level._custom_perks[to_perk].perk_machine_set_kvps, trigger, perk_machine, bump_trigger, collision);

	return trigger;
}

function delete_perk_machine(perk)
{
	//zm_perk_machine
	//zombie_vending
	foreach(trigger in GetEntArray("zm_perk_machine", "targetname"))
	{
		if(isdefined(trigger.script_noteworthy) && trigger.script_noteworthy == perk)
		{
			trigger Delete();
		}
	}
}

/@
"Name: replace_perk_spawn_struct(<from_perk>, <to_perk>)"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Replaces all perk spawn structs from perk A to perk B"
"MandatoryArg: <from_perk>: All perk spawn structs with this script_noteworthy will be replaced."
"MandatoryArg: <to_perk>: The perk to change to."
"Example: replace_perk_spawn_struct("specialty_widowswine", "specialty_phdflopper");"
"SPMP: multiplayer"
@/
function replace_perk_spawn_struct(from_perk, to_perk)
{
	Assert(isdefined(from_perk), "from_perk is a required argument for replace_perk_spawn_struct!");
	Assert(isdefined(to_perk), "to_perk is a required argument for replace_perk_spawn_struct!");

	if(isdefined(level.override_perk_targetname))
		targetname = level.override_perk_targetname;
	else
		targetname = "zm_perk_machine";

	structs = struct::get_array(targetname, "targetname");

	for(i = 0; i < structs.size; i++)
	{
		if(isdefined(structs[i].script_noteworthy) && structs[i].script_noteworthy == from_perk)
			structs[i].script_noteworthy = to_perk;
	}
}

/@
"Name: create_perk_spawn_struct(<perk>, <origin>, [angles], [power_zone], [script_notify], [blocker_model], [turn_on_notify])"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Attempts to spawn a struct that can be used to spawn a perk machine"
"MandatoryArg: <perk>: The perk that this struct will spawn."
"MandatoryArg: <origin>: The origin this perk will spawn at."
"OptionalArg: [angles]: The angles this perk will spawn at"
"OptionalArg: [power_zone]: The power zone this perk will use for power"
"OptionalArg: [script_notify]: Not 100% sure what this is for but zm_perks uses it"
"OptionalArg: [blocker_model]: Not 100% sure what this is for but zm_perks uses it"
"OptionalArg: [turn_on_notify]: Not 100% sure what this is for but zm_perks uses it"
"Example: create_perk_spawn_struct("specialty_vultureaid", (0, 0, 0));"
"SPMP: multiplayer"
@/
function create_perk_spawn_struct(perk, origin, angles = (0, 0, 0), power_zone = undefined, script_notify = "", blocker_model = undefined, turn_on_notify = "")
{
	Assert(isdefined(perk), "perk is a required argument for create_perk_spawn_struct!");
	Assert(isdefined(origin), "origin is a required argument for create_perk_spawn_struct!");

	struct = struct::spawn(origin, angles);

	/*
	if(!isdefined(struct))
	{
		struct = SpawnStruct();
		struct.origin = origin;
		struct.angles = angles;
	}
	*/

	if(isdefined(level.override_perk_targetname))
		struct.targetname = level.override_perk_targetname;
	else
		struct.targetname = "zm_perk_machine";

	struct.model = "p7_zm_vending_sleight";
	struct.script_noteworthy = perk;
	struct.script_int = power_zone;
	struct.script_notify = script_notify;
	struct.blocker_model = blocker_model;
	struct.turn_on_notify = turn_on_notify;

	struct struct::init();

	return struct;
}

/@
"Name: spawn_perk_from_struct()"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Attempts to spawn a perk machine from the struct"
"Example: spawn_perk_from_struct();"
"CallOn: script_struct"
"SPMP: multiplayer"
@/
function spawn_perk_from_struct()
{
	t_use = Spawn("trigger_radius_use", self.origin + (0, 0, 60), 0, 40, 80);
	t_use.targetname = "zombie_vending";
	t_use.script_noteworthy = self.script_noteworthy;

	if(isdefined(self.script_int))
		t_use.script_int = self.script_int;

	t_use TriggerIgnoreTeam();

	perk_machine = Spawn("script_model", self.origin);

	if(!isdefined(self.angles))
		self.angles = (0, 0, 0);

	perk_machine.angles = self.angles;
	perk_machine SetModel(self.model);

	if(IS_TRUE(level._no_vending_machine_bump_trigs))
		bump_trigger = undefined;
	else
	{
		bump_trigger = Spawn("trigger_radius", self.origin + (0, 0, 30), 0, 40, 80);
		bump_trigger.script_activated = 1;
		bump_trigger.script_sound = "zmb_perks_bump_bottle";
		bump_trigger.targetname = "audio_bump_trigger";
	}

	if(IS_TRUE(level._no_vending_machine_auto_collision))
		collision = undefined;
	else
	{
		collision = Spawn("script_model", self.origin, 1);
		collision.angles = self.angles;
		collision SetModel("zm_collision_perks1");
		collision.script_noteworthy = "clip";
		collision DisconnectPaths();
	}

	t_use.clip = collision;
	t_use.machine = perk_machine;
	t_use.bump = bump_trigger;

	if(isdefined(self.script_notify))
		perk_machine.script_notify = self.script_notify;
	if(isdefined(self.blocker_model))
		t_use.blocker_model = self.blocker_model;
	if(isdefined(self.script_int))
		perk_machine.script_int = self.script_int;
	if(isdefined(self.turn_on_notify))
		perk_machine.turn_on_notify = self.turn_on_notify;

	t_use.script_sound = "mus_perks_speed_jingle";
	t_use.script_string = "speedcola_perk";
	t_use.script_label = "mus_perks_speed_sting";
	t_use.target = "vending_sleight";
	perk_machine.script_string = "speedcola_perk";
	perk_machine.targetname = "vending_sleight";

	if(isdefined(bump_trigger))
		bump_trigger.script_string = "speedcola_perk";

	if(is_perk(self.script_noteworthy) && isdefined(level._custom_perks[self.script_noteworthy].perk_machine_set_kvps))
		util::single_func(level, level._custom_perks[self.script_noteworthy].perk_machine_set_kvps, t_use, perk_machine, bump_trigger, collision);

	return t_use;
}

/@
"Name: is_perk(<perk>)"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Returns true if this is a valid perk"
"MandatoryArg: <perk>: The perk string engine name."
"Example: is_perk("specialty_vultureaid");"
"SPMP: multiplayer"
@/
function is_perk(perk)
{
	Assert(isdefined(perk), "perk is a required argument for is_perk!");

	if(isdefined(level._custom_perks) && isdefined(level._custom_perks[perk]))
		return true;
	return false;
}

/@
"Name: pause_perk(<perk>, [give])"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Pauses a specified perk"
"MandatoryArg: <perk>: The perk to be unpaused."
"OptionalArg: [give]: set to true to give the player the perk if they dont have it, defaults to 'false'"
"CallOn: An player"
"Example: pause_perk("specialty_vultureaid");"
"SPMP: multiplayer"
@/
function pause_perk(perk, give = FALSE)
{
	Assert(isdefined(perk), "perk is a required argument for pause_perk!");
	Assert(isdefined(self) && IsPlayer(self), "pause_perk must be called on a valid player entity!");

	if(!is_perk(perk))
		return;

	if(!self HasPerk(perk))
	{
		if(IS_TRUE(give))
		{
			self zm_perks::give_perk(perk, false);
			wait .1;
		}
		else
			return;
	}

	MAKE_ARRAY(self.disabled_perks)

	if(self zm_perks::has_perk_paused(perk))
		return;

	self.disabled_perks[perk] = true;
	self UnSetPerk(perk);
	self zm_perks::set_perk_clientfield(perk, PERK_STATE_PAUSED);

	if(isdefined(level._custom_perks[perk].player_thread_take))
		util::single_thread(self, level._custom_perks[perk].player_thread_take, true);
}

/@
"Name: unpause_perk(<perk>)"
"Module: WARDOGSK93 - Zombiemode: Util"
"Summary: Unpauses a specified perk"
"MandatoryArg: <perk>: The perk to be unpaused."
"CallOn: An player"
"Example: unpause_perk("specialty_vultureaid");"
"SPMP: multiplayer"
@/
function unpause_perk(perk)
{
	Assert(isdefined(perk), "perk is a required argument for unpause_perk!");
	Assert(isdefined(self) && IsPlayer(self), "unpause_perk must be called on a valid player entity!");

	if(!is_perk(perk))
		return;

	MAKE_ARRAY(self.disabled_perks)

	if(self HasPerk(perk) || !self zm_perks::has_perk_paused(perk))
		return;

	self.disabled_perks[perk] = false;
	self zm_perks::set_perk_clientfield(perk, PERK_STATE_OWNED);

	self SetPerk(perk);

	self zm_perks::perk_set_max_health_if_jugg(perk, false, false);

	if(isdefined(level._custom_perks[perk].player_thread_give))
		util::single_thread(self, level._custom_perks[perk].player_thread_give);
}
