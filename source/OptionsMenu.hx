package;

import Controls.Control;
import Options;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import lime.utils.Assets;
import openfl.Lib;

class OptionsMenu extends MusicBeatState
{
	public static var instance:OptionsMenu;

	var selector:FlxText;
	var curSelected:Int = 0;

	public var acceptInput:Bool = true;

	private var currentDescription:String = "";
	private var grpControls:FlxTypedGroup<Alphabet>;

	public static var versionShit:FlxText;

	var currentSelectedCat:OptionCategory;
	var blackBorder:FlxSprite;
	
	public function new()
	{
		super();
	}

	override function create()
	{
		clean();
		instance = this;
		var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));

		menuBG.color = 0xFFea71fd;
		menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
		menuBG.updateHitbox();
		menuBG.screenCenter();
		menuBG.antialiasing = FlxG.save.data.antialiasing;
		add(menuBG);

		openSubState(new OptionsSubState());

		super.create();
	}

	override function closeSubState()
	{
		FlxG.switchState(new MainMenuState());
		super.closeSubState();
	}
}
