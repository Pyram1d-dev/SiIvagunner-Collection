import sys.thread.Thread;
import Character;
import haxe.Json;
#if cpp
import flash.display.BitmapData;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxAxes;
import haxe.DynamicAccess;
import lime.app.Application;
import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;
import openfl.Lib;

using StringTools;

#if sys
import sys.FileSystem;
import sys.io.File;
#end

// completely yoinked from andromeda (thats what you get for stealing my callback inputs you fuckers /j)

typedef LuaProperty =
{
	var defaultValue:Any;
	var getter:(State, Any) -> Int;
	var setter:State->Int;
}

class LuaStorage
{
	public static var ListOfCameras:Array<LuaCamera> = [];
	public static var objectProperties:Map<String, Map<String, LuaProperty>> = [];
	public static var objects:Map<String, LuaClass> = [];
}

class LuaClass
{
	public var properties:Map<String, LuaProperty> = [];
	public var methods:Map<String, cpp.Callable<StatePointer->Int>> = [];
	public var className:String = "BaseClass";

	private static var state:State;

	public var addToGlobal:Bool = true;

	public function Register(l:State)
	{
		Lua.newtable(l);
		state = l;
		LuaStorage.objectProperties[className] = this.properties;

		var classIdx = Lua.gettop(l);
		Lua.pushvalue(l, classIdx);
		if (addToGlobal)
			Lua.setglobal(l, className);

		for (k in methods.keys())
		{
			Lua.pushcfunction(l, methods[k]);
			Lua.setfield(l, classIdx, k);
		}

		LuaL.newmetatable(l, className + "Metatable");
		var mtIdx = Lua.gettop(l);
		Lua.pushstring(l, "__index");
		Lua.pushcfunction(l, cpp.Callable.fromStaticFunction(index));
		Lua.settable(l, mtIdx);

		Lua.pushstring(l, "__newindex");
		Lua.pushcfunction(l, cpp.Callable.fromStaticFunction(newindex));
		Lua.settable(l, mtIdx);

		for (k in properties.keys())
		{
			Lua.pushstring(l, k + "PropertyData");
			Convert.toLua(l, properties[k].defaultValue);
			Lua.settable(l, mtIdx);
		}
		Lua.pushstring(l, "_CLASSNAME");
		Lua.pushstring(l, className);
		Lua.settable(l, mtIdx);

		Lua.pushstring(l, "__metatable");
		Lua.pushstring(l, "This metatable is locked.");
		Lua.settable(l, mtIdx);

		Lua.setmetatable(l, classIdx);
	};

	public static function index(l:StatePointer):Int
	{
		var l = state;
		var index = Lua.tostring(l, -1);
		if (Lua.getmetatable(l, -2) != 0)
		{
			var mtIdx = Lua.gettop(l);
			Lua.pushstring(l, index + "PropertyData");
			Lua.rawget(l, mtIdx);
			var data:Any = Convert.fromLua(l, -1);
			if (data != null)
			{
				Lua.pushstring(l, "_CLASSNAME");
				Lua.rawget(l, mtIdx);
				var clName = Lua.tostring(l, -1);
				if (LuaStorage.objectProperties[clName] != null && LuaStorage.objectProperties[clName][index] != null)
				{
					return LuaStorage.objectProperties[clName][index].getter(l, data);
				}
			};
		}
		else
		{
			// TODO: throw an error!
		};
		return 0;
	}

	public static function newindex(l:StatePointer):Int
	{
		var l = state;
		var index = Lua.tostring(l, 2);
		if (Lua.getmetatable(l, 1) != 0)
		{
			var mtIdx = Lua.gettop(l);
			Lua.pushstring(l, index + "PropertyData");
			Lua.rawget(l, mtIdx);
			var data:Any = Convert.fromLua(l, -1);
			if (data != null)
			{
				Lua.pushstring(l, "_CLASSNAME");
				Lua.rawget(l, mtIdx);
				var clName = Lua.tostring(l, -1);
				if (LuaStorage.objectProperties[clName] != null && LuaStorage.objectProperties[clName][index] != null)
				{
					Lua.pop(l, 2);
					return LuaStorage.objectProperties[clName][index].setter(l);
				}
			};
		}
		else
		{
			// TODO: throw an error!
		};
		return 0;
	}

	public static function SetProperty(l:State, tableIndex:Int, key:String, value:Any)
	{
		Lua.pushstring(l, key + "PropertyData");
		Convert.toLua(l, value);
		Lua.settable(l, tableIndex);

		Lua.pop(l, 2);
	}

	public static function DefaultSetter(l:State, ?customPropertyName:String)
	{
		var key = Lua.tostring(l, 2);

		if (customPropertyName != null)
			key = customPropertyName;

		Lua.pushstring(l, key + "PropertyData");
		Lua.pushvalue(l, 3);
		Lua.settable(l, 4);

		Lua.pop(l, 2);
	};

	public function new() {}
}

class LuaNote extends LuaClass
{ // again, stolen from andromeda but improved a lot for better thinking interoperability (I made that up)
	private static var state:State;

	public var note:Note;

	public function new(connectedNote:Note, index:Int)
	{
		super();
		className = "note_" + index;

		note = connectedNote;

		properties = [
			"alpha" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.alpha);
					return 1;
				},
				setter: SetNumProperty
			},

			"angle" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.modAngle);
					return 1;
				},
				setter: function(l:State):Int
				{
					// 1 = self
					// 2 = key
					// 3 = value
					// 4 = metatable
					if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
					{
						LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
						return 0;
					}

					var angle = Lua.tonumber(l, 3);
					connectedNote.modAngle = angle;

					LuaClass.DefaultSetter(l);
					return 0;
				}
			},

			"strumTime" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.strumTime);
					return 1;
				},
				setter: function(l:State):Int
				{
					// 1 = self
					// 2 = key
					// 3 = value
					// 4 = metatable
					// mf you can't modify this shit
					return 0;
				}
			},

			"data" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.noteData);
					return 1;
				},
				setter: SetNumProperty
			},

			"mustPress" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushboolean(l, connectedNote.mustPress);
					return 1;
				},
				setter: SetNumProperty
			},

			"beat" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.beat);
					return 1;
				},
				setter: SetNumProperty
			},

			"isSustain" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.rawNoteData);
					return 1;
				},
				setter: SetNumProperty
			},

			"isParent" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushboolean(l, connectedNote.isParent);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "isParent is read-only.");
					return 0;
				}
			},

			"getParent" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushstring(l, "note_" + connectedNote.parent.luaID);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "getParent is read-only.");
					return 0;
				}
			},

			"getChildren" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.newtable(l);

					for (i in 0...connectedNote.children.length)
					{
						var note = connectedNote.children[i];
						Lua.pushstring(l, "note_" + note.luaID);
						Lua.rawseti(l, -2, i);
					}

					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "getChildren is read-only.");
					return 0;
				}
			},

			"getSpotInline" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.spotInLine);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "spot in line is read-only.");
					return 0;
				}
			},

			"x" => {
				defaultValue: connectedNote.x,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.x);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenPos" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenPosC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenPos is read-only.");
					return 0;
				}
			},

			"tweenAlpha" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAlphaC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAlpha is read-only.");
					return 0;
				}
			},

			"tweenAngle" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAngleC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAngle is read-only.");
					return 0;
				}
			},

			"y" => {
				defaultValue: connectedNote.y,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedNote.y);
					return 1;
				},
				setter: SetNumProperty
			}

		];
	}

	private static function findNote(time:Float, data:Int)
	{
		for (i in PlayState.instance.notes)
		{
			if (i.strumTime == time && i.noteData == data)
			{
				return i;
			}
		}
		return null;
	}

	private static function tweenPos(l:StatePointer):Int
	{
		// 1 = self
		// 2 = x
		// 3 = y
		// 4 = time
		var xp = LuaL.checknumber(state, 2);
		var yp = LuaL.checknumber(state, 3);
		var time = LuaL.checknumber(state, 4);

		Lua.getfield(state, 1, "strumTime");
		var noteTime = Lua.tonumber(state, -1);
		Lua.getfield(state, 1, "data");
		var data = Lua.tonumber(state, -1);

		var note = findNote(noteTime, Math.floor(data));

		if (note == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find note " + noteTime + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 5) != -1)
			ease = LuaL.checkstring(state, 5);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(note, {x: xp, y: yp}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAngle(l:StatePointer):Int
	{
		// 1 = self
		// 2 = angle
		// 3 = time
		var nangle = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "strumTime");
		var noteTime = Lua.tonumber(state, -1);
		Lua.getfield(state, 1, "data");
		var data = Lua.tonumber(state, -1);

		var note = findNote(noteTime, Math.floor(data));

		if (note == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find note " + noteTime + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(note, {modAngle: nangle}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAlpha(l:StatePointer):Int
	{
		// 1 = self
		// 2 = alpha
		// 3 = time
		var nalpha = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "strumTime");
		var noteTime = Lua.tonumber(state, -1);
		Lua.getfield(state, 1, "data");
		var data = Lua.tonumber(state, -1);

		var note = findNote(noteTime, Math.floor(data));

		if (note == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find note " + noteTime + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(note, {alpha: nalpha}, time, {ease: easeThing});

		return 0;
	}

	private static var tweenPosC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenPos);
	private static var tweenAngleC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAngle);
	private static var tweenAlphaC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAlpha);

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}
		note.modifiedByLua = true;
		Reflect.setProperty(note, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
	}
}

class LuaReceptor extends LuaClass
{ // again, stolen from andromeda but improved a lot for better thinking interoperability (I made that up)
	private static var state:State;

	public var sprite:StaticArrow;

	public var defaultY:Float = 0;
	public var defaultX:Float = 0;

	public function new(connectedSprite:StaticArrow, name:String)
	{
		super();
		var defaultAngle = connectedSprite.angle;
		defaultX = connectedSprite.x;
		defaultY = connectedSprite.y;
		sprite = connectedSprite;

		className = name;

		properties = [
			"alpha" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.alpha);
					return 1;
				},
				setter: SetNumProperty
			},

			"id" => {
				defaultValue: name,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushstring(l, name);
					return 1;
				},
				setter: SetNumProperty
			},

			"angle" => {
				defaultValue: 0,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.modAngle);
					return 1;
				},
				setter: function(l:State):Int
				{
					// 1 = self
					// 2 = key
					// 3 = value
					// 4 = metatable
					if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
					{
						LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
						return 0;
					}

					var angle = Lua.tonumber(l, 3);
					connectedSprite.modAngle = angle;

					LuaClass.DefaultSetter(l, "modAngle");
					return 0;
				}
			},

			"x" => {
				defaultValue: connectedSprite.x,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.x);
					return 1;
				},
				setter: SetNumProperty
			},

			"y" => {
				defaultValue: connectedSprite.y,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.y);
					return 1;
				},
				setter: SetNumProperty
			},

			"defaultAngle" => {
				defaultValue: defaultAngle,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, defaultAngle);
					return 1;
				},
				setter: SetNumProperty
			},

			"defaultX" => {
				defaultValue: defaultX,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, defaultX);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenPos" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenPosC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenPos is read-only.");
					return 0;
				}
			},

			"tweenAlpha" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAlphaC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAlpha is read-only.");
					return 0;
				}
			},

			"tweenAngle" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAngleC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAngle is read-only.");
					return 0;
				}
			},

			"defaultY" => {
				defaultValue: defaultY,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, defaultY);
					return 1;
				},
				setter: function(l:State):Int
				{
					// 1 = self
					// 2 = key
					// 3 = value
					// 4 = metatable
					return 0;
				}
			}

		];
	}

	private static function findReceptor(index:Int)
	{
		for (i in 0...PlayState.strumLineNotes.length)
		{
			if (index == i)
			{
				return PlayState.strumLineNotes.members[i];
			}
		}
		return null;
	}

	private static function tweenPos(l:StatePointer):Int
	{
		// 1 = self
		// 2 = x
		// 3 = y
		// 4 = time
		var xp = LuaL.checknumber(state, 2);
		var yp = LuaL.checknumber(state, 3);
		var time = LuaL.checknumber(state, 4);

		Lua.getfield(state, 1, "id");
		var index = Std.parseInt(Lua.tostring(state, -1).split('_')[1]);

		var receptor = findReceptor(index);

		if (receptor == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find receptor " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 5) != -1)
			ease = LuaL.checkstring(state, 5);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(receptor, {x: xp, y: yp}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAngle(l:StatePointer):Int
	{
		// 1 = self
		// 2 = angle
		// 3 = time
		var nangle = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Std.parseInt(Lua.tostring(state, -1).split('_')[1]);

		var receptor = findReceptor(index);

		if (receptor == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find receptor " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(receptor, {modAngle: nangle}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAlpha(l:StatePointer):Int
	{
		// 1 = self
		// 2 = alpha
		// 3 = time
		var nalpha = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Std.parseInt(Lua.tostring(state, -1).split('_')[1]);

		var receptor = findReceptor(index);

		if (receptor == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find receptor " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(receptor, {alpha: nalpha}, time, {ease: easeThing});

		return 0;
	}

	private static var tweenPosC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenPos);
	private static var tweenAngleC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAngle);
	private static var tweenAlphaC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAlpha);

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}

		sprite.modifiedByLua = true;

		Reflect.setProperty(sprite, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
		trace("Registered " + className);
	}
}

class LuaCamera extends LuaClass
{ // again, stolen from andromeda but improved a lot for better thinking interoperability (I made that up)
	private static var state:State;

	public var cam:FlxCamera;

	public function new(connectedCamera:FlxCamera, name:String)
	{
		super();
		cam = connectedCamera;

		className = name;

		properties = [
			"visible" => {
				defaultValue: connectedCamera.visible,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushboolean(l, connectedCamera.visible);
					return 1;
				},
				setter: function(l:State):Int
				{
					if (Lua.type(l, 3) != Lua.LUA_TBOOLEAN)
					{
						LuaL.error(l, "invalid argument #3 (boolean expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
						return 0;
					}
					connectedCamera.visible = Lua.toboolean(l, 3);

					LuaClass.DefaultSetter(l);
					return 0;
				}
			},
			"alpha" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedCamera.alpha);
					return 1;
				},
				setter: SetNumProperty
			},

			"angle" => {
				defaultValue: 0,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedCamera.angle);
					return 1;
				},
				setter: SetNumProperty
			},

			"x" => {
				defaultValue: connectedCamera.x,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedCamera.x);
					return 1;
				},
				setter: SetNumProperty
			},

			"y" => {
				defaultValue: connectedCamera.y,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedCamera.y);
					return 1;
				},
				setter: SetNumProperty
			},

			"id" => {
				defaultValue: className,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushstring(l, className);
					return 1;
				},
				setter: SetNumProperty
			},

			"zoom" => {
				defaultValue: connectedCamera.zoom,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedCamera.zoom);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenZoom" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenZoomC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenZoom is read-only.");
					return 0;
				}
			},

			"tweenPos" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenPosC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenPos is read-only.");
					return 0;
				}
			},

			"tweenAlpha" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAlphaC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAlpha is read-only.");
					return 0;
				}
			},

			"tweenAngle" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAngleC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAngle is read-only.");
					return 0;
				}
			},
		];

		LuaStorage.ListOfCameras.push(this);
	}

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}
		Reflect.setProperty(cam, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	private static function tweenZoom(l:StatePointer):Int
	{
		// 1 = self
		// 2 = zoom
		// 3 = time
		var nzoom = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var camera:FlxCamera = null;

		for (i in LuaStorage.ListOfCameras)
		{
			if (i.className == index)
			{
				camera = i.cam;
			}
		}

		if (camera == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find camera " + index + ")");
			return 0;
		}

		var setDefZoom = false;
		var easeIndexThing = 4;
		if (Lua.typename(state, Lua.type(state, 4)) == "boolean")
		{
			setDefZoom = Lua.toboolean(state, 4);
			easeIndexThing = 5;
		}

		var ease:String = null;
		if (Lua.type(state, easeIndexThing) != -1)
			ease = LuaL.checkstring(state, easeIndexThing);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(camera, {zoom: nzoom}, time, {ease: easeThing});

		if (setDefZoom)
			PlayState.instance.targetCamZoom = nzoom;

		return 0;
	}

	private static var tweenZoomC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenZoom);

	private static function tweenPos(l:StatePointer):Int
	{
		// 1 = self
		// 2 = x
		// 3 = y
		// 4 = time
		var xp = LuaL.checknumber(state, 2);
		var yp = LuaL.checknumber(state, 3);
		var time = LuaL.checknumber(state, 4);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var camera:FlxCamera = null;

		for (i in LuaStorage.ListOfCameras)
		{
			if (i.className == index)
				camera = i.cam;
		}

		if (camera == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find camera " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 5) != -1)
			ease = LuaL.checkstring(state, 5);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(camera, {x: xp, y: yp}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAngle(l:StatePointer):Int
	{
		// 1 = self
		// 2 = angle
		// 3 = time
		var nangle = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var camera:FlxCamera = null;

		for (i in LuaStorage.ListOfCameras)
		{
			if (i.className == index)
				camera = i.cam;
		}

		if (camera == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find camera " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(camera, {modAngle: nangle}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAlpha(l:StatePointer):Int
	{
		// 1 = self
		// 2 = alpha
		// 3 = time
		var nalpha = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var camera:FlxCamera = null;

		for (i in LuaStorage.ListOfCameras)
		{
			if (i.className == index)
				camera = i.cam;
		}

		if (camera == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find camera " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(camera, {alpha: nalpha}, time, {ease: easeThing});

		return 0;
	}

	private static var tweenPosC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenPos);
	private static var tweenAngleC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAngle);
	private static var tweenAlphaC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAlpha);

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
		trace("Registered " + className);
	}
}

class LuaCharacter extends LuaClass
{ // again, stolen from andromeda but improved a lot for better thinking interoperability (I made that up)
	private static var state:State;

	public var char:Character;
	public var isPlayer:Bool = false;

	public static var ListOfCharacters:Array<LuaCharacter> = [];

	public function new(connectedCharacter:Character, name:String)
	{
		super();
		className = name;

		char = connectedCharacter;

		isPlayer = char.isPlayer;

		properties = [
			"alpha" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, char.alpha);
					return 1;
				},
				setter: SetNumProperty
			},

			"angle" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, char.angle);
					return 1;
				},
				setter: function(l:State):Int
				{
					// 1 = self
					// 2 = key
					// 3 = value
					// 4 = metatable
					if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
					{
						LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
						return 0;
					}

					var angle = Lua.tonumber(l, 3);
					char.angle = angle;

					LuaClass.DefaultSetter(l);
					return 0;
				}
			},

			"x" => {
				defaultValue: connectedCharacter.x,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, char.x);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenPos" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenPosC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenPos is read-only.");
					return 0;
				}
			},

			"id" => {
				defaultValue: name,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushstring(l, name);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenAlpha" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAlphaC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAlpha is read-only.");
					return 0;
				}
			},

			"tweenAngle" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAngleC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAngle is read-only.");
					return 0;
				}
			},

			"changeCharacter" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, changeCharacterC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "changeCharacter is read-only.");
					return 0;
				}
			},

			"playAnim" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, playAnimC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "playAnim is read-only.");
					return 0;
				}
			},

			"y" => {
				defaultValue: connectedCharacter.y,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, char.y);
					return 1;
				},
				setter: SetNumProperty
			}

		];

		ListOfCharacters.push(this);
	}

	private static function findNote(time:Float, data:Int)
	{
		for (i in PlayState.instance.notes)
		{
			if (i.strumTime == time && i.noteData == data)
			{
				return i;
			}
		}
		return null;
	}

	private static function tweenPos(l:StatePointer):Int
	{
		// 1 = self
		// 2 = x
		// 3 = y
		// 4 = time
		var xp = LuaL.checknumber(state, 2);
		var yp = LuaL.checknumber(state, 3);
		var time = LuaL.checknumber(state, 4);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var char:Character = null;

		for (i in ListOfCharacters)
		{
			if (i.className == index)
				char = i.char;
		}

		if (char == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find character " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 5) != -1)
			ease = LuaL.checkstring(state, 5);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(char, {x: xp, y: yp}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAngle(l:StatePointer):Int
	{
		// 1 = self
		// 2 = angle
		// 3 = time
		var nangle = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var char:Character = null;

		for (i in ListOfCharacters)
		{
			if (i.className == index)
				char = i.char;
		}

		if (char == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find character " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(char, {angle: nangle}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAlpha(l:StatePointer):Int
	{
		// 1 = self
		// 2 = alpha
		// 3 = time
		var nalpha = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var char:Character = null;

		for (i in ListOfCharacters)
		{
			if (i.className == index)
				char = i.char;
		}

		if (char == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find character " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(char, {alpha: nalpha}, time, {ease: easeThing});

		return 0;
	}

	private static function changeCharacter(l:StatePointer):Int
	{
		// 1 = self
		// 2 = newName
		// 3 = x
		// 4 = y
		var newName = LuaL.checkstring(state, 2);
		var x = LuaL.checknumber(state, 3);
		var y = LuaL.checknumber(state, 4);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var char:Character = null;
		var property:LuaCharacter = null;

		for (i in ListOfCharacters)
		{
			if (i.className == index)
			{
				char = i.char;
				property = i;
			}
		}

		trace("fuck " + char);

		if (char == null)
		{
			LuaL.error(state, "Failure to load (couldn't find character " + index + ")");
			return 0;
		}

		var pos = PlayState.instance.members.indexOf(Reflect.getProperty(PlayState, index));

		PlayState.instance.remove(Reflect.getProperty(PlayState, index));

		var newChar = (index == "boyfriend") ? new Boyfriend(x, y, newName) : new Character(x, y, newName, char.isPlayer);

		Reflect.setProperty(PlayState, index, newChar);

		property.char = Reflect.getProperty(PlayState, index);

		PlayState.instance.addAt(Reflect.getProperty(PlayState, index), pos);

		switch (index)
		{
			case "dad":
				PlayState.instance.iconP2.changeIcon(newName);
			case "boyfriend":
				PlayState.instance.iconP1.changeIcon(newName);
		}

		return 0;
	}

	private static function playAnim(l:StatePointer):Int
	{
		// 1 = self
		// 2 = animation
		var anim = LuaL.checkstring(state, 2);
		var force = false;
		if (Lua.type(state, 3) != -1)
			force = Lua.toboolean(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var char:Character = null;

		for (i in ListOfCharacters)
		{
			if (i.className == index)
			{
				char = i.char;
			}
		}

		if (char == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find character " + index + ")");
			return 0;
		}

		char.playAnim(anim, force);

		return 0;
	}

	private static var playAnimC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(playAnim);
	private static var changeCharacterC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(changeCharacter);
	private static var tweenPosC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenPos);
	private static var tweenAngleC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAngle);
	private static var tweenAlphaC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAlpha);

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}
		Reflect.setProperty(char, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
	}
}

class LuaSprite extends LuaClass
{ // again, stolen from andromeda but improved a lot for better thinking interoperability (I made that up)
	private static var state:State;

	public var sprite:FlxSprite;

	public static var ListOfSprites:Array<LuaSprite> = [];

	public function new(connectedSprite:FlxSprite, name:String)
	{
		super();
		className = name;
		sprite = connectedSprite;

		properties = [
			"visible" => {
				defaultValue: connectedSprite.visible,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushboolean(l, connectedSprite.visible);
					return 1;
				},
				setter: function(l:State):Int
				{
					if (Lua.type(l, 3) != Lua.LUA_TBOOLEAN)
					{
						LuaL.error(l, "invalid argument #3 (boolean expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
						return 0;
					}
					connectedSprite.visible = Lua.toboolean(l, 3);

					LuaClass.DefaultSetter(l);
					return 0;
				}
			},

			"alpha" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.alpha);
					return 1;
				},
				setter: SetNumProperty
			},

			"angle" => {
				defaultValue: 1,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.angle);
					return 1;
				},
				setter: function(l:State):Int
				{
					// 1 = self
					// 2 = key
					// 3 = value
					// 4 = metatable
					if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
					{
						LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
						return 0;
					}

					var angle = Lua.tonumber(l, 3);
					connectedSprite.angle = angle;

					LuaClass.DefaultSetter(l);
					return 0;
				}
			},

			"x" => {
				defaultValue: connectedSprite.x,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.x);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenPos" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenPosC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenPos is read-only.");
					return 0;
				}
			},

			"id" => {
				defaultValue: name,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushstring(l, name);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenAlpha" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAlphaC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAlpha is read-only.");
					return 0;
				}
			},

			"tweenAngle" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenAngleC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenAngle is read-only.");
					return 0;
				}
			},

			"destroy" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, destroyC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "destroy is read-only.");
					return 0;
				}
			},

			"y" => {
				defaultValue: connectedSprite.y,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, connectedSprite.y);
					return 1;
				},
				setter: SetNumProperty
			},

			"playAnim" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, playAnimC);
					return 1;
				},
				setter: function(l:State) 
				{
					LuaL.error(l, "playAnim is read-only");
					return 0;
				}
			}

		];

		ListOfSprites.push(this);
	}

	private static function findNote(time:Float, data:Int)
	{
		for (i in PlayState.instance.notes)
		{
			if (i.strumTime == time && i.noteData == data)
			{
				return i;
			}
		}
		return null;
	}

	private static function tweenPos(l:StatePointer):Int
	{
		// 1 = self
		// 2 = x
		// 3 = y
		// 4 = time
		var xp = LuaL.checknumber(state, 2);
		var yp = LuaL.checknumber(state, 3);
		var time = LuaL.checknumber(state, 4);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var sprite:FlxSprite = null;

		for (i in ListOfSprites)
		{
			if (i.className == index)
				sprite = i.sprite;
		}

		if (sprite == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find sprite " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 5) != -1)
			ease = LuaL.checkstring(state, 5);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(sprite, {x: xp, y: yp}, time, {ease: easeThing});

		return 0;
	}

	private static function playAnim(l:StatePointer):Int
	{
		// 1 = self
		// 2 = animation
		// 3 - force (optional)
		var anim = LuaL.checkstring(state, 2);
		var force = false;
		if (Lua.type(state, 3) != -1)
			force = Lua.toboolean(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var spr:FlxSprite = null;

		for (i in ListOfSprites)
		{
			if (i.className == index && i.sprite.animation != null)
			{
				spr = i.sprite;
			}
		}

		if (spr == null)
		{
			LuaL.error(state, "Failure to play animation (couldn't find sprite " + index + ")");
			return 0;
		}

		spr.animation.play(anim, force);

		return 0;
	}

	private static var playAnimC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(playAnim);

	private static function tweenAngle(l:StatePointer):Int
	{
		// 1 = self
		// 2 = angle
		// 3 = time
		var nangle = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var sprite:FlxSprite = null;

		for (i in ListOfSprites)
		{
			if (i.className == index)
				sprite = i.sprite;
		}

		if (sprite == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find sprite " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(sprite, {angle: nangle}, time, {ease: easeThing});

		return 0;
	}

	private static function tweenAlpha(l:StatePointer):Int
	{
		// 1 = self
		// 2 = alpha
		// 3 = time
		var nalpha = LuaL.checknumber(state, 2);
		var time = LuaL.checknumber(state, 3);

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var sprite:FlxSprite = null;

		for (i in ListOfSprites)
		{
			if (i.className == index)
				sprite = i.sprite;
		}

		if (sprite == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find sprite " + index + ")");
			return 0;
		}

		var ease:String = null;
		if (Lua.type(state, 4) != -1)
			ease = LuaL.checkstring(state, 4);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(sprite, {alpha: nalpha}, time, {ease: easeThing});

		return 0;
	}

	private static function destroy(l:StatePointer):Int
	{
		// 1 = self

		Lua.getfield(state, 1, "id");
		var index = Lua.tostring(state, -1);

		var sprite:FlxSprite = null;

		for (i in ListOfSprites)
		{
			if (i.className == index)
				sprite = i.sprite;
		}

		if (sprite == null)
		{
			LuaL.error(state, "Failure to tween (couldn't find sprite " + index + ")");
			return 0;
		}

		PlayState.instance.remove(sprite);
		sprite.destroy();

		return 0;
	}

	private static var destroyC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(destroy);
	private static var tweenPosC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenPos);
	private static var tweenAngleC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAngle);
	private static var tweenAlphaC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenAlpha);

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}
		Reflect.setProperty(sprite, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
		trace("Registered " + className);
	}
}

class LuaWindow extends LuaClass
{ // again, stolen from andromeda but improved a lot for better thinking interoperability (I made that up)
	private static var state:State;

	public function new()
	{
		super();
		className = "Window";

		properties = [
			"x" => {
				defaultValue: Application.current.window.x,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, Application.current.window.x);
					return 1;
				},
				setter: SetNumProperty
			},

			"y" => {
				defaultValue: Application.current.window.y,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, Application.current.window.y);
					return 1;
				},
				setter: SetNumProperty
			},

			"width" => {
				defaultValue: Application.current.window.width,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, Application.current.window.width);
					return 1;
				},
				setter: SetNumProperty
			},

			"height" => {
				defaultValue: Application.current.window.height,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, Application.current.window.height);
					return 1;
				},
				setter: SetNumProperty
			},

			"tweenPos" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, tweenPosC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "tweenPos is read-only.");
					return 0;
				},
			},
		];
	}

	private static function tweenPos(l:StatePointer):Int
	{
		// 1 = self
		// 2 = x
		// 3 = y
		// 4 = time
		var xp = LuaL.checknumber(state, 2);
		var yp = LuaL.checknumber(state, 3);
		var time = LuaL.checknumber(state, 4);

		var ease:String = null;
		if (Lua.type(state, 5) != -1)
			ease = LuaL.checkstring(state, 5);

		var easeThing:(t:Float) -> Float = FlxEase.linear;

		if (ease != null)
			easeThing = Reflect.getProperty(FlxEase, ease);

		FlxTween.tween(Application.current.window, {x: xp, y: yp}, time, {ease: easeThing});

		return 0;
	}

	private static var tweenPosC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(tweenPos);

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}
		Reflect.setProperty(Application.current.window, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
	}
}

class LuaGame extends LuaClass
{ // again, stolen from andromeda but improved a lot for better thinking interoperability (I made that up)
	private static var state:State;

	public function new()
	{
		super();
		className = "Game";

		properties = [

			"health" => {
				defaultValue: PlayState.instance.health,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, PlayState.instance.health);
					return 1;
				},
				setter: function(l:State):Int
				{
					PlayState.instance.health = Lua.tonumber(l, 3);
					return 0;
				},
			},

			"camZoom" => {
				defaultValue: PlayState.instance.targetCamZoom,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, PlayState.instance.targetCamZoom);
					return 1;
				},
				setter: function(l:State):Int
				{
					PlayState.instance.targetCamZoom = Lua.tonumber(l, 3);
					return 0;
				},
			},

			"allowZooming" => {
				defaultValue: PlayState.instance.camZooming,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushboolean(l, PlayState.instance.camZooming);
					return 1;
				},
				setter: function(l:State):Int
				{
					PlayState.instance.camZooming = Lua.toboolean(l, 3);
					return 0;
				},
			},

			"accuracy" => {
				defaultValue: PlayState.instance.accuracy,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushnumber(l, PlayState.instance.accuracy);
					return 1;
				},
				setter: SetNumProperty
			},

			"cacheCharacter" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, cacheCharacterC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "cacheCharacter is read-only.");
					return 0;
				},
			},

			"setCamFollow" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, setCamFollowC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "setCamFollow is read-only.");
					return 0;
				},
			},

			"setZoom" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, setZoomC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "setZoom is read-only.");
					return 0;
				},
			},

			"setZoomInterval" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, setZoomIntervalC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "setZoomInterval is read-only.");
					return 0;
				},
			}
		];
	}

	private static function cacheCharacter(l:StatePointer):Int
	{
		// 1 = self
		// 2 = character
		var char = LuaL.checkstring(state, 2);

		var characterData:CharacterData = Character.loadCharacterFromJSON(char);
		var path = characterData.texturePath;
		var key = path.split('/')[path.split('/').length - 1];

		PlayState.instance.songCache.loadFrames([key => ['characters/${path}', "shared"]]);

		return 0;
	}

	private static var cacheCharacterC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(cacheCharacter);

	private static function setZoomInterval(l:StatePointer):Int
	{
		// 1 - self
		// 2 - mod
		// 3 - game zoom
		// 4 - hud zoom
		var backToDefault = false;
		var mod = 4;
		if (Lua.type(state, 2) != 1)
			mod = LuaL.checkint(state, 2);
		else
			backToDefault = true;

		@:privateAccess
		{
			var gameZoom = PlayState.instance.bumpZooms[0];
			var camZoom = PlayState.instance.bumpZooms[1];
			if (Lua.type(state, 3) != -1)
				gameZoom = LuaL.checknumber(state, 3);
			if (Lua.type(state, 4) != -1)
				camZoom = LuaL.checknumber(state, 4);
			if (backToDefault)
			{
				gameZoom = 0.015;
				camZoom = 0.03;
				mod = 4;
			}
			PlayState.instance.bumpEvery = mod;
			PlayState.instance.bumpZooms = [gameZoom, camZoom];
		}

		return 0;
	}

	private static var setZoomIntervalC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setZoomInterval);

	private static function setZoom(l:StatePointer):Int
	{
		// 1 - self
		// 2 - zoom
		// 3 - snap
		var zoom = LuaL.checknumber(state, 2);
		var snap = false;
		if (Lua.type(state, 3) != -1)
			snap = Lua.toboolean(state, 3);

		@:privateAccess
		{
			PlayState.instance.targetCamZoom = zoom;
			if (snap)
				PlayState.instance.camGame.zoom = zoom;
		}

		return 0;
	}

	private static var setZoomC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setZoom);

	private static function setCamFollow(l:StatePointer):Int
	{
		// 1 - self
		// 2 - x
		// 3 - y
		// 4 - focusOn (OPTIONAL)
		var x = LuaL.checknumber(state, 2);
		var y = LuaL.checknumber(state, 3);
		var focusOn = false;
		if (Lua.type(state, 4) != -1)
			focusOn = Lua.toboolean(state, 4);

		@:privateAccess
		{
			PlayState.instance.camFollow.setPosition(x, y);
			if (focusOn)
				PlayState.instance.camGame.focusOn(PlayState.instance.camFollow.getPosition());
		}

		return 0;
	}

	private static var setCamFollowC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(setCamFollow);

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}
		Reflect.setProperty(Application.current.window, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
	}
}

class LuaStage extends LuaClass
{
	private static var state:State;

	public function new()
	{
		super();
		className = "Stage";

		properties = [

			"isPixel" => {
				defaultValue: PlayState.instance.stage.isPixel,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushboolean(l, PlayState.instance.stage.isPixel);
					return 1;
				},
				setter: function(l:State):Int
				{
					LuaL.error(l, "isPixel is read-only.");
					return 0;
				},
			},

			"name" => {
				defaultValue: PlayState.SONG.stage,
				getter: function(l:State, data:Any):Int
				{
					Lua.pushstring(l, PlayState.SONG.stage);
					return 1;
				},
				setter: function(l:State):Int
				{
					LuaL.error(l, "name is read-only.");
					return 0;
				},
			},

			"changeStage" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, changeStageC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "changeStage is read-only.");
					return 0;
				},
			},
			"getSprite" => {
				defaultValue: 0,
				getter: function(l:State, data:Any)
				{
					Lua.pushcfunction(l, getSpriteC);
					return 1;
				},
				setter: function(l:State)
				{
					LuaL.error(l, "getSprite is read-only.");
					return 0;
				},
			}
		];
	}

	private static function changeStage(l:StatePointer):Int
	{
		// 1 = self
		// 2 = stage
		var stageName = LuaL.checkstring(state, 2);

		PlayState.instance.removeStage();

		PlayState.instance.setupStage(stageName);

		return 0;
	}

	private static var changeStageC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(changeStage);

	private static function getSprite(l:StatePointer):Int
	{
		// 1 = self
		// 2 = sprite name
		var sprName = LuaL.checkstring(state, 2);
		if (!PlayState.instance.stage.swagBacks.exists(sprName))
		{
			LuaL.error(state, '$sprName is not a valid key in swagBacks!');
			return 0;
		}
		var toBeNamed = sprName;
		if (Lua.type(state, 3) != -1)
			toBeNamed = LuaL.checkstring(state, 3);

		toBeNamed.trim().replace(' ', '_');

		var back:FlxSprite = cast PlayState.instance.stage.swagBacks[sprName];

		trace('loaded $back');

		ModchartState.luaSprites.set(toBeNamed, back);

		new LuaSprite(back, toBeNamed).Register(ModchartState.lua);

		return 0;
	}

	private static var getSpriteC:cpp.Callable<StatePointer->Int> = cpp.Callable.fromStaticFunction(getSprite);

	private function SetNumProperty(l:State)
	{
		// 1 = self
		// 2 = key
		// 3 = value
		// 4 = metatable
		if (Lua.type(l, 3) != Lua.LUA_TNUMBER)
		{
			LuaL.error(l, "invalid argument #3 (number expected, got " + Lua.typename(l, Lua.type(l, 3)) + ")");
			return 0;
		}
		Reflect.setProperty(Application.current.window, Lua.tostring(l, 2), Lua.tonumber(l, 3));
		return 0;
	}

	override function Register(l:State)
	{
		state = l;
		super.Register(l);
	}
}
#end
