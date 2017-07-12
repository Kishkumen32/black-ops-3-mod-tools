// 3arc - Core
#using scripts\codescripts\struct;

// 3arc - Shared
#using scripts\shared\callbacks_shared;
#using scripts\shared\clientfield_shared;
#using scripts\shared\flag_shared;
#using scripts\shared\math_shared;
#using scripts\shared\util_shared;

#insert scripts\shared\shared.gsh;
#insert scripts\shared\version.gsh;

#using scripts\wardog\shared\wardog_load;
#using scripts\wardog\shared\wardog_menu;
#using scripts\wardog\shared\wardog_shared_util;

#namespace wardog_shared_util;

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
	Assert(isdefined(vector) && IsVec(vector), "vector is a required argument for vector_to_string!");

	str_vector = "" + vector[0] + splitter;
	str_vector += "" + vector[1] + splitter;
	str_vector += "" + vector[2];

	return str_vector;
}
