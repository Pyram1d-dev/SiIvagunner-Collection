package;

import flixel.math.FlxMath;
import lime.utils.Assets;

using StringTools;

class CoolUtil
{
	public static var difficultyArray:Array<String> = ['Easy', "Normal", "Hard", "Extra"];

	public static function difficultyFromInt(difficulty:Int):String
	{
		return difficultyArray[difficulty];
	}

	public static function intFromDifficulty(difficulty:String):Int
	{
		return difficultyArray.indexOf(difficulty);
	}

	public static function lowerCaseSong(song:String):String
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
		switch (songLowercase)
		{
			case 'dad-battle':
				songLowercase = 'dadbattle';
			case 'philly-nice':
				songLowercase = 'philly';
		}
		return songLowercase;
	}

	public static function coolTextFile(path:String):Array<String>
	{
		var daList:Array<String> = Assets.getText(path).trim().split('\n');
		var toRemove:Array<String> = [];

		while (daList.contains(""))
			daList.remove("");

		for (i in 0...daList.length)
		{
			daList[i] = daList[i].trim();
			if (daList[i].startsWith("//"))
				toRemove.push(daList[i]);
		}
		
		for (i in toRemove)
			daList.remove(i);

		return daList;
	}

	public static function coolLerp(n1:Float, n2:Float, alpha:Float):Float
	{
		var scaledFps = FPSScalingShit.scaledFPS();
		var a = alpha * scaledFps;
		if (a < 0.011)
			a = 0.011;
		else if (a > 0.95)
			a = 0.95;
		return FlxMath.lerp(n1, n2, a);
	}
	
	public static function coolStringFile(path:String):Array<String>
		{
			var daList:Array<String> = path.trim().split('\n');
	
			for (i in 0...daList.length)
			{
				daList[i] = daList[i].trim();
			}
	
			return daList;
		}

	public static function numberArray(max:Int, ?min = 0):Array<Int>
	{
		var dumbArray:Array<Int> = [];
		for (i in min...max)
		{
			dumbArray.push(i);
		}
		return dumbArray;
	}
}
