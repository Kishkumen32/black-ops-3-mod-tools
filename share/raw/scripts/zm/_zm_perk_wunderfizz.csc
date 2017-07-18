#using scripts\codescripts\struct;
#using scripts\shared\system_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\exploder_shared;
#using scripts\shared\scene_shared;
#using scripts\shared\util_shared;
#using scripts\shared\system_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;
#insert scripts\zm\_zm_perk_wunderfizz.gsh;

#using scripts\zm\_load;
#using scripts\zm\_zm_weapons;

#namespace zm_perk_wunderfizz; 

REGISTER_SYSTEM( "zm_perk_wunderfizz", &__init__, undefined )

function __init__()
{
}