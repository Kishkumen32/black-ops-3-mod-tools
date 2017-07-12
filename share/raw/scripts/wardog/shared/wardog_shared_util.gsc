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

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#namespace wardog_shared_util;

function trigger_on()
{
	if(isdefined(self.realOrigin))
		self.origin = self.realOrigin;
	self.trigger_off = undefined;
}

function trigger_off()
{
	if(!isdefined(self.realOrigin))
		self.realOrigin = self.origin;
	if(self.origin == self.realOrigin)
		self.origin += (0, 0, -10000);
	self.trigger_off = true;
}

function string_to_vector(str_vector, splitter = ",")
{
	Assert(isdefined(str_vector), "str_vector is a required argument for string_to_vector!");

	if(IsVec(str_vector))
		return str_vector;

	Assert(IsString(str_vector), "str_vector must be a string");

	tokens = StrTok(str_vector, splitter);
	str_x = tokens[0];
	str_y = tokens[1];
	str_z = tokens[2];

	Assert(StrIsNumber(str_x), "str_vector must contain only numbers");
	Assert(StrIsNumber(str_y), "str_vector must contain only numbers");
	Assert(StrIsNumber(str_z), "str_vector must contain only numbers");

	if(StrIsInt(str_x))
		x = Int(str_x);
	else
		x = Float(str_x);

	if(StrIsInt(str_y))
		y = Int(str_y);
	else
		y = Float(str_y);

	if(StrIsInt(str_z))
		z = Int(str_z);
	else
		z = Float(str_z);

	Assert(IsInt(x) || IsFloat(x), "number was not parsed from str_vector successfully");
	Assert(IsInt(y) || IsFloat(y), "number was not parsed from str_vector successfully");
	Assert(IsInt(z) || IsFloat(z), "number was not parsed from str_vector successfully");

	return (x, y, z);
}

function vector_to_string(vector, splitter = ",")
{
	Assert(isdefined(vector), "vector is a required argument for vector_to_string!");

	str_x = "0";
	str_y = "0";
	str_z = "0";

	if(IsVec(vector))
	{
		if(isdefined(vector[0]))
			str_x = STR(vector[0]);
		if(isdefined(vector[1]))
			str_y = STR(vector[1]);
		if(isdefined(vector[2]))
			str_z = STR(vector[2]);
	}

	str_vector = STR(str_x + splitter + str_y + splitter + str_z);

	return str_vector;
}

function is_facing(facee, requiredDot = .9)
{
	Assert(isdefined(facee), "facee is a required argument for is_facing!");
	Assert(isdefined(self), "is_facing must be called on a entity");

	orientation = self.angles;

	if(IsPlayer(self))
		orientation = self GetPlayerAngles();

	forwardVec = AnglesToForward(orientation);
	forwardVec2D = (forwardVec[0], forwardVec[1], 0);
	unitForwardVec2D = VectorNormalize(forwardVec2D);
	toFaceeVec = facee.origin - self.origin;
	toFaceeVec2D = (toFaceeVec[0], toFaceeVec[1], 0);
	unitToFaceeVec2D = VectorNormalize(toFaceeVec2D);
	dotProduct = VectorDot(unitForwardVec2D, unitToFaceeVec2D);

	return dotProduct > requiredDot;
}
