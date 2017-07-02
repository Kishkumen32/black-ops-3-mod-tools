#using scripts\codescripts\struct;

#using scripts\shared\array_shared;
#using scripts\shared\callbacks_shared;
#using scripts\shared\system_shared;
#using scripts\shared\trigger_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#insert scripts\zm\_zm_utility.gsh;

/*
#####################
by: ZeRoY - 2017
#####################
Script:

Add to main in mapname.gsc
zm_flamethrower::init();

Add to top of mapname.gsc
#using scripts\zm\zm_flamethrower;

Add to zone file
scriptparsetree,scripts/zm/zm_flamethrower.gsc

###############################################################################
*/


#namespace zm_flamethrower;

#precache( "model", "gear_flametank");

function init()
{
	level._swap_flametank_model = "gear_flametank";
	callback::on_spawned( &flamethrower_swap );

}

function flamethrower_swap()
{
    self endon( "death" ); 
    self endon( "disconnect" ); 

    while(1)
    {
        self waittill("weapon_change");

        weapons = self GetWeaponsList(); 

        self.has_flame_thrower = false; 

        for( i = 0; i < weapons.size; i++ )
        {
            if( weapons[i].name == "m2_flamethrower" && !self.hasRiotShield)
            {
                self.has_flame_thrower = true; 
            }
        }
            
        if( self.has_flame_thrower )
        {
            if( !isdefined( self.flamethrower_attached ) || !self.flamethrower_attached )
            {
                self attach( level._swap_flametank_model, "j_spine4" ); 
                self.flamethrower_attached = true; 
            }
        }

        else if( !self.has_flame_thrower )
        {
            if( isdefined( self.flamethrower_attached ) && self.flamethrower_attached )
            {
                self detach( level._swap_flametank_model, "j_spine4" ); 
                self.flamethrower_attached = false; 
            }
        }

        util::wait_network_frame();
    }
}