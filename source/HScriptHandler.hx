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

class BlendMode
{
	public static var ADD = openfl.display.BlendMode.ADD;
	public static var ALPHA = openfl.display.BlendMode.ALPHA;
	public static var DARKEN = openfl.display.BlendMode.DARKEN;
	public static var DIFFERENCE = openfl.display.BlendMode.DIFFERENCE;
	public static var ERASE = openfl.display.BlendMode.ERASE;
	public static var HARDLIGHT = openfl.display.BlendMode.HARDLIGHT;
	public static var INVERT = openfl.display.BlendMode.INVERT;
	public static var LAYER = openfl.display.BlendMode.LAYER;
	public static var LIGHTEN = openfl.display.BlendMode.LIGHTEN;
	public static var MULTIPLY = openfl.display.BlendMode.MULTIPLY;
	public static var NORMAL = openfl.display.BlendMode.NORMAL;
	public static var OVERLAY = openfl.display.BlendMode.OVERLAY;
	public static var SCREEN = openfl.display.BlendMode.SCREEN;
	public static var SHADER = openfl.display.BlendMode.SHADER;
	public static var SUBTRACT = openfl.display.BlendMode.SUBTRACT;
}

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
		interp.variables.set("songLowercase", StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase());
		interp.variables.set("stageName", PlayState.SONG.stage);
		interp.variables.set("boyfriend", PlayState.boyfriend);
		interp.variables.set("gf", PlayState.gf);
		interp.variables.set("dad", PlayState.dad);
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
		interp.variables.set("BlendMode", BlendMode);
		@:privateAccess
		{
			interp.variables.set("camGame", PlayState.instance.camGame);
			interp.variables.set("camHUD", PlayState.instance.camHUD);
		}
		interp.variables.set("StringTools", StringTools);
		interp.variables.set("CoolUtil", CoolUtil);
        return interp;
    }
}