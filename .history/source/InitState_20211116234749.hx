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

		if (FlxG.save.data.firstTime || true)
		{
			setupInitScreen();
			super.create();
		}
		else
			FlxG.switchState(new TitleState());
	}

	function setupInitScreen()
	{
		add(new Alphabet(10, 10, "Friday Night Funkin", true, false));
		add(new Alphabet(10, 300, "SiIvagunner Collection", true, false));
	}

	function poopyballs()
	{
		var shittyText = new FlxText(0, 0, FlxG.width * 0.8);
		shittyText.autoSize = false;
		shittyText.setFormat("VCR OSD Mono", 35, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		shittyText.text = "This mod contains some copyrighted content! (which should be under fair use but, y'know)\n\nPress ENTER to continue\nPress SPACE to enable copyright covers\n\nBe warned, not all of the covers are finished yet. If you're worried about a strike, you can skip the song via the pause menu.";
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
