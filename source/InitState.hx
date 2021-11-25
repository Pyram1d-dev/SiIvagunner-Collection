import flixel.FlxG;
import flixel.FlxState;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class InitState extends FlxState
{
	var transitioning = false;

	override function create()
	{
		FlxG.save.bind('funkin', 'ninjamuffin99');

		PlayerSettings.init();

		KadeEngineData.initSave();

		if (FlxG.save.data.firstTime)
		{
			setupInitScreen();
			super.create();
		}
		else
			FlxG.switchState(new TitleState());
	}

	function setupInitScreen()
	{
		var shittyText = new FlxText(0, 0, FlxG.width * 0.8);
		shittyText.autoSize = false;
		shittyText.setFormat("VCR OSD Mono", 35, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		shittyText.text = "This mod contains some copyrighted content! (which should be under fair use but, y'know)\n\nThere will be copyright covers in the future. If you're worried about a strike, you can skip the song via the pause menu.\n\nPress ENTER to continue";
		shittyText.alignment = LEFT;
		shittyText.updateHitbox();
		shittyText.screenCenter(XY);
		shittyText.antialiasing = FlxG.save.data.antialiasing;
		add(shittyText);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);
		if (!transitioning)
		{
			if (FlxG.keys.justPressed.ENTER)
			{
				FlxG.switchState(new TitleState());
				transitioning = true;
			}
			if (FlxG.keys.justPressed.SPACE)
			{
				FlxG.save.data.noCopyright = 1;
				FlxG.switchState(new TitleState());
				transitioning = true;
			}
		}
	}
}
