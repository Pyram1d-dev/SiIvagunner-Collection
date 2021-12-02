package;

import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.system.DisplayMode;
import openfl.Lib;
import openfl.display.FPS;

class OptionCategory
{
	private var _options:Array<Option> = new Array<Option>();

	public final function getOptions():Array<Option>
	{
		return _options;
	}

	public final function addOption(opt:Option)
	{
		_options.push(opt);
	}

	public final function removeOption(opt:Option)
	{
		_options.remove(opt);
	}

	private var _name:String = "New Category";

	private var quickOptionsAccess:Bool = true;

	public final function getName()
	{
		return _name;
	}

	public final function getSubAccess()
	{
		return quickOptionsAccess;
	}

	public function new(catName:String, options:Array<Option>, ?subAccess:Bool = true)
	{
		_name = catName;
		_options = options;
		quickOptionsAccess = subAccess;
	}
}

class Option
{
	public function new()
	{
		display = updateDisplay();
	}

	private var description:String = "";
	private var display:String;
	private var acceptValues:Bool = false;
	private var quickOptionsAccess:Bool = true;
	private var updateOption = false;

	public final function getDisplay():String
	{
		return display;
	}

	public function getAccept():Bool
	{
		return acceptValues;
	}

	public final function getupdateOption():Bool
	{
		return updateOption;
	}

	public final function getSubAccess():Bool
	{
		return quickOptionsAccess;
	}

	public final function getDescription():String
	{
		return description;
	}

	public function getValue():String
	{
		return throw "stub!";
	};

	// Returns whether the label is to be updated.
	public function press():Bool
	{
		return throw "stub!";
	}

	private function updateDisplay():String
	{
		return throw "stub!";
	}

	public function left():Bool
	{
		return throw "stub!";
	}

	public function right():Bool
	{
		return throw "stub!";
	}
}

class DFJKOption extends Option
{
	private var controls:Controls;

	public function new(controls:Controls)
	{
		super();
		this.controls = controls;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.state.openSubState(new KeyBindMenu());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Key Bindings";
	}
}

class CpuStrums extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.cpuStrums = !FlxG.save.data.cpuStrums;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.cpuStrums ? "CPU Strums: [Light]" : "CPU Strums: [Static]";
	}
}

class GraphicLoading extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.cacheImages = !FlxG.save.data.cacheImages;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return FlxG.save.data.cacheImages ? "My balls" : "My balls";
	}
}

class EditorRes extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.editorBG = !FlxG.save.data.editorBG;

		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Editor Grid: " + (FlxG.save.data.editorBG ? "[On]" : "[Off]");
	}
}

class DownscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.downscroll = !FlxG.save.data.downscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Scroll: " + (FlxG.save.data.downscroll ? "[Downscroll]" : "[Upscroll]");
	}
}

class MidscrollOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
		if (PlayStateChangeables.Optimize && PlayState.instance != null)
			quickOptionsAccess = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.midscroll = !FlxG.save.data.midscroll;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Midscroll: " + (FlxG.save.data.midscroll ? "[On]" : "[Off]");
	}
}

class AccuracyOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.accuracyDisplay = !FlxG.save.data.accuracyDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy: " + (!FlxG.save.data.accuracyDisplay ? "[Off]" : "[On]");
	}
}

class SongPositionOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.songPosition = !FlxG.save.data.songPosition;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Position: " + (!FlxG.save.data.songPosition ? "[Off]" : "[On]");
	}
}

class DistractionsAndEffectsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.distractions = !FlxG.save.data.distractions;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Distractions: " + (!FlxG.save.data.distractions ? "[Off]" : "[On]");
	}
}

class StepManiaOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.stepMania = !FlxG.save.data.stepMania;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Colors by Quantization: " + (!FlxG.save.data.stepMania ? "[Off]" : "[On]");
	}
}

class ResetButtonOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.resetButton = !FlxG.save.data.resetButton;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Reset Button: " + (!FlxG.save.data.resetButton ? "[Off]" : "[On]");
	}
}

class InstantRespawn extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.InstantRespawn = !FlxG.save.data.InstantRespawn;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Instant Respawn: " + (!FlxG.save.data.InstantRespawn ? "[Off]" : "[On]");
	}
}

class FlashingLightsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.flashing = !FlxG.save.data.flashing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Flashing Lights: " + (!FlxG.save.data.flashing ? "[Off]" : "[On]");
	}
}

class AntialiasingOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.antialiasing = !FlxG.save.data.antialiasing;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Antialiasing: " + (!FlxG.save.data.antialiasing ? "[Off]" : "[On]");
	}
}

class MissSoundsOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.missSounds = !FlxG.save.data.missSounds;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Miss Sounds: " + (!FlxG.save.data.missSounds ? "[Off]" : "[On]");
	}
}

class ShowInput extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.inputShow = !FlxG.save.data.inputShow;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Score Info: " + (FlxG.save.data.inputShow ? "[Extended]" : "[Minimalized]");
	}
}

class GhostTapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		updateOption = false; // sub options baby, this simply tells the options substate if an option requires a song to be restarted (if in play)
		// Ok it USED to force the song to restart but I'm making it not do that now. Also sub options are now just normal options with some data settings hidden while playing
	}

	public override function press():Bool
	{
		FlxG.save.data.ghost = !FlxG.save.data.ghost;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Ghost Tapping: " + (FlxG.save.data.ghost ? "[On] (Virgin)" : "[Off] (Chad)");
	}

	public override function getAccept():Bool
	{
		return !FlxG.save.data.ghost;
	}

	override function left():Bool
	{
		if (FlxG.save.data.missMs == 300)
			return false;

		FlxG.save.data.missMs -= 10;

		return false;
	}

	override function right():Bool
	{
		if (FlxG.save.data.missMs == 1010)
			return false;

		FlxG.save.data.missMs += 10;

		return true;
	}

	override function getValue():String
	{
		return " Miss Distance: < " + ((FlxG.save.data.missMs == 1010) ? "None" : (FlxG.save.data.missMs + " ms")) + " >";
	}
}

// Oh no
class HitSoundsOptions extends Option
{
	var sounds:Array<String>;
	var soundDisplay:Array<String>;
	var curIndex:Int = -1;

	public function new(desc:String)
	{
		super();
		var newSounds = CoolUtil.coolTextFile(Paths.txt('data/noteHitSoundList'));
		newSounds.shift();
		sounds = [];
		soundDisplay = [];
		for (i in newSounds)
		{
			var data = i.split(":");
			soundDisplay.push(data[0]);
			sounds.push(data[1]);
		}
		trace(soundDisplay, sounds);
		if (sounds.contains(FlxG.save.data.hitSound))
			curIndex = sounds.indexOf(FlxG.save.data.hitSound);
		description = desc;
		acceptValues = true;
		updateOption = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Note Hit Sounds: ";
	}

	override function left():Bool
	{
		curIndex -= 1;

		if (curIndex < -1)
			curIndex = sounds.length - 1;

		FlxG.save.data.hitSound = (curIndex > -1) ? sounds[curIndex] : null;

		return false;
	}

	override function right():Bool
	{
		curIndex += 1;

		if (curIndex > sounds.length - 1)
			curIndex = -1;

		FlxG.save.data.hitSound = (curIndex > -1) ? sounds[curIndex] : null;

		return true;
	}

	override function getValue():String
	{
		return "< " + ((FlxG.save.data.hitSound == null) ? "None" : soundDisplay[curIndex]) + " >";
	}
}

// Fun fact: this option used to be called "focus bar opacity" LMAOOOO imagine calling them focus bars I'm such a dumbass
class UnderlayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		updateOption = false;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Lane Underlay Opacity: ";
	}

	override function left():Bool
	{
		if (FlxG.save.data.focusAlpha < 0.1)
		{
			FlxG.save.data.focusAlpha = 0;
			return false;
		}

		FlxG.save.data.focusAlpha = HelperFunctions.truncateFloat(FlxG.save.data.focusAlpha - 0.1, 1);

		return false;
	}

	override function right():Bool
	{
		if (FlxG.save.data.focusAlpha > 0.9)
		{
			FlxG.save.data.focusAlpha = 1;
			return false;
		}

		FlxG.save.data.focusAlpha = HelperFunctions.truncateFloat(FlxG.save.data.focusAlpha + 0.1, 1);

		return true;
	}

	override function getValue():String
	{
		return "< " + ((FlxG.save.data.focusAlpha == 0) ? "Off" : FlxG.save.data.focusAlpha) + " >";
	}
}

class Judgement extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		updateOption = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Safe Frames: ";
	}

	override function left():Bool
	{
		if (Conductor.safeFrames == 1)
			return false;

		Conductor.safeFrames -= 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return false;
	}

	override function getValue():String
	{
		return "< " + Conductor.safeFrames + " >";
	}

	override function right():Bool
	{
		if (Conductor.safeFrames == 20)
			return false;

		Conductor.safeFrames += 1;
		FlxG.save.data.frames = Conductor.safeFrames;

		Conductor.recalculateTimings();
		return true;
	}
}

class FPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.fps = !FlxG.save.data.fps;
		(cast(Lib.current.getChildAt(0), Main)).toggleFPS(FlxG.save.data.fps);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Counter: " + (!FlxG.save.data.fps ? "[Off]" : "[On]");
	}
}

class ScoreScreen extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool 
	{
		FlxG.save.data.scoreScreen = !FlxG.save.data.scoreScreen;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Score Screen: " + (FlxG.save.data.scoreScreen ? "[On]" : "[Off]");
	}
}

class SkipIntroOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.skipIntro = !FlxG.save.data.skipIntro;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Skip Intro Text: " + (FlxG.save.data.skipIntro ? "[On]" : "[Off]");
	}
}

class FPSCapOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		updateOption = false;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "FPS Cap: ";
	}

	override function right():Bool
	{
		if (FlxG.save.data.fpsCap >= 290)
		{
			FlxG.save.data.fpsCap = 290;
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);
		}
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap + 10;
		(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);

		return true;
	}

	override function left():Bool
	{
		if (FlxG.save.data.fpsCap > 290)
			FlxG.save.data.fpsCap = 290;
		else if (FlxG.save.data.fpsCap < 60)
			FlxG.save.data.fpsCap = Application.current.window.displayMode.refreshRate;
		else
			FlxG.save.data.fpsCap = FlxG.save.data.fpsCap - 10;
				(cast(Lib.current.getChildAt(0), Main)).setFPSCap(FlxG.save.data.fpsCap);
		return true;
	}

	override function getValue():String
	{
		return "< "
			+ FlxG.save.data.fpsCap
			+ (FlxG.save.data.fpsCap == Application.current.window.displayMode.refreshRate ? "Hz (Refresh Rate)" : "") + " >";
	}
}

class ScrollSpeedOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
		updateOption = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Scroll Speed: ";
	}

	override function right():Bool
	{
		FlxG.save.data.scrollSpeed += 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;
		return true;
	}

	override function getValue():String
	{
		return "< "
			+ ((FlxG.save.data.scrollSpeed == 1) ? "Chart Dependent" : Std.string(HelperFunctions.truncateFloat(FlxG.save.data.scrollSpeed, 1))) + " >";
	}

	override function left():Bool
	{
		FlxG.save.data.scrollSpeed -= 0.1;

		if (FlxG.save.data.scrollSpeed < 1)
			FlxG.save.data.scrollSpeed = 1;

		if (FlxG.save.data.scrollSpeed > 4)
			FlxG.save.data.scrollSpeed = 4;

		return true;
	}
}

class RainbowFPSOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.fpsRain = !FlxG.save.data.fpsRain;
		(cast(Lib.current.getChildAt(0), Main)).changeFPSColor(FlxColor.WHITE);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "FPS Rainbow: " + (!FlxG.save.data.fpsRain ? "[Off]" : "[On]");
	}
}

class Optimization extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		quickOptionsAccess = false;
		//updateOption = true;
		// fuck that
	}

	public override function press():Bool
	{
		FlxG.save.data.optimize = !FlxG.save.data.optimize;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Optimization: " + (FlxG.save.data.optimize ? "[On]" : "[Off]");
	}
}

class NPSDisplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.npsDisplay = !FlxG.save.data.npsDisplay;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "NPS Display: " + (!FlxG.save.data.npsDisplay ? "[Off]" : "[On]");
	}
}

class ReplayOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		quickOptionsAccess = false;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new LoadReplayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Load replays";
	}
}

class AccuracyDOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.accuracyMod = FlxG.save.data.accuracyMod == 1 ? 0 : 1;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Accuracy Mode: " + (FlxG.save.data.accuracyMod == 0 ? "[Accurate]" : "[Complex]");
	}
}

class CustomizeGameplay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		quickOptionsAccess = false;
	}

	public override function press():Bool
	{
		trace("switch");
		FlxG.switchState(new GameplayCustomizeState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Customize Gameplay";
	}
}

class WatermarkOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		Main.watermarks = !Main.watermarks;
		FlxG.save.data.watermark = Main.watermarks;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Watermarks: " + (Main.watermarks ? "[On]" : "[Off]");
	}
}

class OffsetMenu extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		trace("switch");
		var poop:String = Highscore.formatSong("Tutorial", 1);

		PlayState.SONG = Song.loadFromJson(poop, "Tutorial");
		PlayState.isStoryMode = false;
		PlayState.storyDifficulty = 0;
		PlayState.storyWeek = 0;
		PlayState.offsetTesting = true;
		trace('CUR WEEK' + PlayState.storyWeek);
		LoadingState.loadAndSwitchState(new PlayState());
		return false;
	}

	private override function updateDisplay():String
	{
		return "Time your offset";
	}
}

class BotPlay extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.botplay = !FlxG.save.data.botplay;
		trace('BotPlay : ' + FlxG.save.data.botplay);
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
		return "BotPlay: " + (FlxG.save.data.botplay ? "[On]" : "[Off]");
}

class CamZoomOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		FlxG.save.data.camzoom = !FlxG.save.data.camzoom;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Camera Zoom: " + (!FlxG.save.data.camzoom ? "[Off]" : "[On]");
	}
}

class LockWeeksOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = 1;
		StoryMenuState.weekUnlocked = [true, true];
		confirm = false;
		trace('Weeks Locked');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Story Reset" : "Reset Story Progress";
	}
}

class ResetScoreOption extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.songScores = null;
		for (key in Highscore.songScores.keys())
		{
			Highscore.songScores[key] = 0;
		}
		FlxG.save.data.songCombos = null;
		for (key in Highscore.songCombos.keys())
		{
			Highscore.songCombos[key] = '';
		}
		confirm = false;
		trace('Highscores Wiped');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Score Reset" : "Reset Score";
	}
}

class Color extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
	}

	public override function press():Bool
	{
		FlxG.save.data.color = !FlxG.save.data.color;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Color Health Bar By Character: " + (!FlxG.save.data.color ? "[Off]" : "[On]");
	}
}

class ResetSettings extends Option
{
	var confirm:Bool = false;

	public function new(desc:String)
	{
		super();
		description = desc;
	}

	public override function press():Bool
	{
		if (!confirm)
		{
			confirm = true;
			display = updateDisplay();
			return true;
		}
		FlxG.save.data.weekUnlocked = null;
		FlxG.save.data.newInput = null;
		FlxG.save.data.downscroll = null;
		FlxG.save.data.midscroll = null;
		FlxG.save.data.antialiasing = null;
		FlxG.save.data.missSounds = null;
		FlxG.save.data.dfjk = null;
		FlxG.save.data.accuracyDisplay = null;
		FlxG.save.data.offset = null;
		FlxG.save.data.songPosition = null;
		FlxG.save.data.fps = null;
		FlxG.save.data.changedHit = null;
		FlxG.save.data.fpsRain = null;
		FlxG.save.data.fpsCap = null;
		FlxG.save.data.scrollSpeed = null;
		FlxG.save.data.npsDisplay = null;
		FlxG.save.data.frames = null;
		FlxG.save.data.accuracyMod = null;
		FlxG.save.data.watermark = null;
		FlxG.save.data.ghost = null;
		FlxG.save.data.distractions = null;
		FlxG.save.data.stepMania = null;
		FlxG.save.data.flashing = null;
		FlxG.save.data.resetButton = null;
		FlxG.save.data.botplay = null;
		FlxG.save.data.cpuStrums = null;
		FlxG.save.data.strumline = null;
		FlxG.save.data.customStrumLine = null;
		FlxG.save.data.camzoom = null;
		FlxG.save.data.scoreScreen = null;
		FlxG.save.data.inputShow = null;
		FlxG.save.data.optimize = null;
		FlxG.save.data.cacheImages = null;
		FlxG.save.data.editor = null;
		FlxG.save.data.shortenNames = null;
		FlxG.save.data.color = null;
		FlxG.save.data.missMs = null;
		FlxG.save.data.playEnemy = null;
		FlxG.save.data.focusAlpha = null;
		FlxG.save.data.freeplayCutscenes = null;
		FlxG.save.data.firstTime = null;
		FlxG.save.data.hitSound = null;

		KadeEngineData.initSave();
		confirm = false;
		trace('All settings have been reset');
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return confirm ? "Confirm Settings Reset" : "Reset Settings";
	}
}

class ShortenNamesOption extends Option // Some names would go off screen so I decided to add this because why tf not
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.shortenNames = !FlxG.save.data.shortenNames;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Song Names: " + (FlxG.save.data.shortenNames ? "[Short]" : "[Full]");
	}
}

class FreeplayCutscenesOption extends Option // I mostly used this for testing purposes lmao
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
		quickOptionsAccess = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.freeplayCutscenes = !FlxG.save.data.freeplayCutscenes;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Cutscenes in Freeplay: " + (FlxG.save.data.freeplayCutscenes ? "[On]" : "[Off]");
	}
}

class NoteSplatsOption extends Option // sexy note schplats (P.S. isn't splat such a weird word when you say it over and over? splat splat splat splat splat splat splat splat splat splat splat splat splat)
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.noteSplats = !FlxG.save.data.noteSplats;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Note Splats: " + (FlxG.save.data.noteSplats ? "[On]" : "[Off]");
	}
}

class MissGFXOption extends Option // balls
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		FlxG.save.data.missGFX = !FlxG.save.data.missGFX;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Miss GFX: " + (FlxG.save.data.missGFX ? "[On]" : "[Off]");
	}
}

class DisableCopyrightOption extends Option
{
	public function new(desc:String)
	{
		super();
		description = desc;
		acceptValues = true;
	}

	public override function press():Bool
	{
		return false;
	}

	private override function updateDisplay():String
	{
		return "Copyright Protection: ";
	}

	override function left():Bool
	{
		FlxG.save.data.noCopyright -= 1;

		if (FlxG.save.data.noCopyright < 0)
			FlxG.save.data.noCopyright = 2;

		return false;
	}

	override function right():Bool
	{
		FlxG.save.data.noCopyright += 1;
		FlxG.save.data.noCopyright %= 3;

		return true;
	}

	override function getValue():String
	{
		var textlol = "";
		switch (FlxG.save.data.noCopyright)
		{
			case 0:
				textlol = "None";
			case 1:
				textlol = "Covers";
			case 2:
				textlol = "Completely Remove";
		}
		return "< " + textlol + " >";
	}
}

class PlayEnemyOption extends Option // Some enemies in this game look like they have more interesting parts so it would be a waste to NOT add this lol
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = true;
		if (PlayStateChangeables.Optimize && PlayState.instance != null)
			quickOptionsAccess = false;
		// fuck that
	}

	public override function press():Bool
	{
		FlxG.save.data.playEnemy = !FlxG.save.data.playEnemy;
		display = updateDisplay();
		return true;
	}

	private override function updateDisplay():String
	{
		return "Play as: " + (FlxG.save.data.playEnemy ? "[Enemy]" : "[BF]");
	}
}



class SupportSiIvagunnerButton extends Option // Do it. Support SiIva.
{
	public function new(desc:String)
	{
		super();
		description = desc;
		updateOption = false;
	}

	public override function press():Bool
	{
		var link:String = "https://www.youtube.com/channel/UC9ecwl3FTG66jIKA9JRDtmg";
		#if linux
		Sys.command('/usr/bin/xdg-open', [link, "&"]);
		#else
		FlxG.openURL(link);
		#end
		return true;
	}

	private override function updateDisplay():String
	{
		return "Support SiIvagunner";
	}
}
