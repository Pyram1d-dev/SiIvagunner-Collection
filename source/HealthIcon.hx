package;

import Character.CharacterData;
import lime.utils.Assets;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	/**
	 * Used for FreeplayState! If you use it elsewhere, prob gonna annoying
	 */
	public var sprTracker:FlxSprite;

	public function new(?char:String = "bf", ?isPlayer:Bool = false)
	{
		super();

		this.char = char;
		this.isPlayer = isPlayer;

		isPlayer = isOldIcon = false;

		antialiasing = FlxG.save.data.antialiasing;

		changeIcon(char);
		scrollFactor.set();
	}

	public function swapOldIcon()
	{
		(isOldIcon = !isOldIcon) ? changeIcon("bf-old") : changeIcon(char);
	}

	public function changeIcon(char:String)
	{
		var potentialData:CharacterData = Character.loadCharacterFromJSON(char);
		var aa = false;
		if (potentialData != null && potentialData.icon != null)
		{
			aa = potentialData.isPixel ? false : FlxG.save.data.antialiasing;
			char = potentialData.icon;
		}
		else
		{
			if (char.startsWith('bf-pixel') && !Assets.exists(Paths.image('icons/icon-$char')))
				char = 'bf-pixel';

			if (!Assets.exists(Paths.image('icons/icon-$char')) && !char.startsWith("gf"))
				char = char.split("-")[0];

			aa = !(char.endsWith('-pixel') || char.startsWith('senpai') || char.startsWith('spirit'));
		}

		loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);
		antialiasing = aa;
		animation.add(char, [0, 1], 0, false, isPlayer);
		animation.play(char);
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (sprTracker != null)
			setPosition(sprTracker.x + sprTracker.width + 10, sprTracker.y - 30);
	}
}
