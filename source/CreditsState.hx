import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxSpriteGroup.FlxTypedSpriteGroup;
import flixel.group.FlxSpriteGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import haxe.Json;
import openfl.Assets;

using StringTools;

class CreditText extends FlxSpriteGroup
{
	var title:FlxText;
	var subtitle:FlxText;

    public var link:String;
	public var menuIndex:Int = 0;

	public function new(creditData:CreditData, i:Int)
	{
		super();
		menuIndex = i;
        link = creditData.link;
		title = new FlxText(0, 0, 0, creditData.name);
		subtitle = new FlxText(0, 0, 0, creditData.description);
		title.setFormat(Paths.font("vcr.ttf"), 35, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		subtitle.setFormat(Paths.font("vcr.ttf"), 20, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		title.borderSize = 2;
		subtitle.borderSize = 2;
		title.offset.set(0, title.height);
		title.screenCenter(X);
		subtitle.screenCenter(X);
		add(title);
		add(subtitle);
		if (creditData.icons.length > 0)
		{
            var grpIcons = new FlxSpriteGroup();
			for (i in 0...creditData.icons.length)
			{
				var spr = new HealthIcon(creditData.icons[i]);
				spr.setGraphicSize(Std.int(spr.width * 0.5));
				spr.updateHitbox();
				spr.offset.set(spr.width / 2, spr.height * 0.3);
                spr.x = 80 * i;
				spr.y = subtitle.y;
				grpIcons.add(spr);
            }
            grpIcons.screenCenter(X);
            add(grpIcons);
		}
	}

	override public function update(elapsed:Float)
	{
        x = 250;
		y = CoolUtil.coolLerp(y, (FlxG.height * 0.5) + (menuIndex * 150), 0.1);
        if (menuIndex == 0)
			alpha = CoolUtil.coolLerp(alpha, 1, 0.1);
        else
			alpha = CoolUtil.coolLerp(alpha, 0.5, 0.1);
		super.update(elapsed);
	}
}

typedef CreditData = 
{
	var name:String;
	var description:String;
	var link:String;
	var icons:Array<String>;
}

class CreditsState extends MusicBeatState
{
	var credits:Array<CreditData>;

	var curSelected:Int = 0;

	var text:Array<CreditText> = [];

	override function create()
	{
		var bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'), false);
		bg.screenCenter();
        bg.color = FlxColor.PURPLE;
		add(bg);

		var rawJson = Assets.getText(Paths.json("credits", "shared")).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		credits = cast Json.parse(rawJson).credits;

		for (index => data in credits)
		{
			var bruh = new CreditText(data, index);
			add(bruh);
			text.push(bruh);
		}
		var title = new FlxText(80, 150, FlxG.width / 2, "CREDITS");
		title.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		title.borderSize = 2;

		var subtitle = new FlxText(80, 220, FlxG.width / 3, "Be sure to support all the people here who made this mod possible! (buttons are links, hit ENTER)");
		subtitle.setFormat(Paths.font("vcr.ttf"), 25, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
		subtitle.borderSize = 2;

		add(title);
		add(subtitle);
	}

    function changeSelection(change:Int)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'));
		curSelected = ((curSelected + change) % credits.length + credits.length) % credits.length;
		for (index => data in text)
			data.menuIndex = index - curSelected;
    }

	override public function update(elapsed:Float)
	{
		if (controls.BACK)
			FlxG.switchState(new MainMenuState());
		if (FlxG.keys.justPressed.UP)
			changeSelection(-1);
		if (FlxG.keys.justPressed.DOWN)
			changeSelection(1);
        if (controls.ACCEPT)
			fancyOpenURL(text[curSelected].link);
        for (data in text)
            data.update(elapsed);
	}
}
