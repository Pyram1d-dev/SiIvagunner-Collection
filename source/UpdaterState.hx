import flixel.FlxState;
import flixel.input.gamepad.FlxGamepad;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxSprite;
#if cpp
import sys.thread.Thread;
#end
import flixel.util.FlxTimer;
import flixel.FlxG;

using StringTools;

class UpdaterState extends FlxState
{

    var skip:Bool = false;
    var infoText:FlxText;
    var controlText:String = "ENTER";

    override public function create()
	{
		super.create();

		var bf:FlxSprite = new FlxSprite(FlxG.width * 0.75, FlxG.height * 0.6);
		bf.frames = Paths.getSparrowAtlas('pauseAlt/bfLol', 'shared');
		bf.animation.addByPrefix('lol', "funnyThing", 13);
		bf.animation.play('lol');
		bf.antialiasing = FlxG.save.data.antialiasing;
		add(bf);

        infoText = new FlxText(0,0,0,"Checking for updates... \nPress ENTER to skip", 50);
        infoText.autoSize = false;
		infoText.setFormat("VCR OSD Mono", 50, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        infoText.screenCenter(XY);
        add(infoText);

        var ctr:Int = 0;

		new FlxTimer().start(.25, function(tmr:FlxTimer)
		{
            ctr++;
            ctr%=3;
            var adder = '.';
            for (v in 0...ctr)
                adder += '.';
			infoText.text = "Checking for updates"+adder+" \nPress " + controlText + " to skip";
		}, 0);

		#if cpp
		Thread.create(requestUpdateInfo);
		#end
    }

    function requestUpdateInfo()
	{
		// Get current version of Kade Engine
		// No lmao

		var http = new haxe.Http("https://raw.githubusercontent.com/Pyram1d-dev/SiIvagunner-Collection/main/version.downloadMe");
		var returnedData:Array<String> = [];

		http.onData = function(data:String)
		{
            if (skip)
                return;
			returnedData[0] = data.substring(0, data.indexOf(';'));
			returnedData[1] = data.substring(data.indexOf('-'), data.length);
			if (!MainMenuState.gameVer.contains(returnedData[0].trim()) && !OutdatedSubState.leftState)
			{
				trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.gameVer);
				OutdatedSubState.needVer = returnedData[0];
				OutdatedSubState.currChanges = returnedData[1];
				FlxG.switchState(new OutdatedSubState());
			}
			else
			{
				FlxG.switchState(new MainMenuState());
			}
		}

		http.onError = function(error)
		{
			if (skip)
				return;
			trace('error: $error');
			FlxG.switchState(new MainMenuState()); // fail but we go anyway
		}

		http.request();
    }
    
    override function update(elapsed:Float)
	{
		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;
		controlText = (gamepad != null ? "[A]" : "ENTER");
		// infoText.text = "Checking for updates... \nPress " + (gamepad != null ? "[A]" : "ENTER") + " to skip";
		if ((FlxG.keys.justPressed.ENTER || (gamepad != null && gamepad.justPressed.START)) && !skip)
		{
			skip = true;
			FlxG.switchState(new MainMenuState()); // skip this shit in case there's no intertnet
            // I just noticed I spelled "internet" wrong but I'm keeping it because it funny
        }
        super.update(elapsed);
    }
}