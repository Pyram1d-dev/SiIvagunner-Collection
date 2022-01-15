import flixel.system.FlxSound;
import flixel.group.FlxGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import hscript.InterpEx;
import hscript.ParserEx;
import lime.utils.Assets;
import Stage.StageData;
import flixel.FlxG;
import flixel.FlxSprite;

typedef DancerGroup = FlxTypedGroup<Dancer>;

class HScriptHandler // Imma be honest fam I can't take hardcoding anymore
{
	public static function loadStageFromHScript(stageName:String):StageData
    {
		// Was having a stroke until I discovered HScript EX
		var parser = new ParserEx();
		var rawScript = Assets.getText(Paths.hscript('data/STAGES/$stageName'));
        var script = parser.parseString(rawScript);
		var interp = defaultVarBS(stageName);
		var defaultData = new StageData();
		defaultData.curStage = stageName;
		interp.variables.set("data", defaultData);
		interp.variables.set("RollingTank", RollingTank);
		interp.variables.set("DancerGroup", DancerGroup);
		interp.variables.set("Dancer", Dancer);
        interp.execute(script);
		return interp.variables.get("data");
	}


	static function defaultVarBS(?stageName:String):InterpEx
	{
		var interp = new InterpEx();
		interp.variables.set("FlxSprite", FlxSprite);
		interp.variables.set("FlxGroup", FlxGroup);
		interp.variables.set("FlxSound", FlxSound);
		interp.variables.set("Paths", Paths);
		interp.variables.set("FlxG", FlxG);
		interp.variables.set("PlayState", PlayState);
		if (PlayState.SONG != null)
		{
			interp.variables.set("songLowercase", StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase());
			interp.variables.set("stageName", PlayState.SONG.stage);
		}
		else
		{
			interp.variables.set("songLowercase", "");
			interp.variables.set("stageName", stageName);
		}
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("CoolUtil", CoolUtil);
        return interp;
    }
}