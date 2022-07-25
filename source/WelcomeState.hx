import flixel.FlxG;
import flixel.FlxSprite;
import flixel.text.FlxText;
import flixel.util.FlxColor;

class WelcomeState extends MusicBeatState
{
    var txt:FlxText;

    override function create()
    {
        var bg = new FlxSprite().loadGraphic(Paths.image('bababooey'));
        bg.screenCenter(XY);
        bg.alpha = 0.6;
        add(bg);
		txt = new FlxText(0, 0, FlxG.width * 0.8);
		txt.autoSize = false;
		txt.setFormat("VCR OSD Mono", 35, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
        txt.text = "Thanks for playing the SiIvagunner Collection!\n\n
        This mod has a lot of content and jokes packed in, including blueball screens, death dialogue, and extra freeplay difficulties. There is also a joke explainer in the pause menu! ";
        txt.text += "Make sure to set up your options and keybinds.\n\nPlease support the original Friday Night Funkin' and the SiIvagunner YouTube channel!";
        txt.alignment = LEFT;
        txt.updateHitbox();
		txt.screenCenter(XY);
		txt.antialiasing = FlxG.save.data.antialiasing;
        add(txt);
        FlxG.save.data.firstTime = false;
        super.create();
    }

    override function update(elapsed:Float)
    {
        if (controls.ACCEPT)
        {
            FlxG.switchState(new MainMenuState());
            clean();
        }
        super.update(elapsed);
    }
}