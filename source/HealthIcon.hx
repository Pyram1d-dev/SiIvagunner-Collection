package;

import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class HealthIcon extends FlxSprite
{
	public var char:String = 'bf';
	public var isPlayer:Bool = false;
	public var isOldIcon:Bool = false;

	// There's probably a more automated and/or efficient way to do this. Too bad!
	// Ok this is getting worryingly large, I think I do have to change how this works after all. I'll do it next update lol
	static var exceptions:Array<String> = [
		'bf-pixel', 'bf-old', 'bf-amogus', 'big-chungus', 'dad-amogus', 'dad-king', 'spooky-slam', 'bf-slam', 'bf-ryuko', 'mom-ragyo', 'spooky-tetris',
		'pico-grandpa', 'pico-igor', 'bf-igor', 'bf-richter', 'pico-cringe', 'pico-fw', 'bf-pixel-squisherz', 'bf-pixel-daft', 'senpai-punk',
		'senpai-punk-full', 'senpai-will', 'senpai-skeletron', 'spirit-gariwald', 'spirit-giygas', 'mario-ded', 'bf-pixel-terraria', 'tankman-homedepot',
		'bf-sockdude', 'parents-games', 'bf-sonic', 'bf-reimu', 'bf-hk', 'mom-car-neko', 'bf-lady', 'bf-pixel-knuck', 'bf-christmas-aloe'
	];

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
		if (char.startsWith('bf-pixel') && !exceptions.contains(char))
			char = 'bf-pixel';

		if (!exceptions.contains(char) && !char.startsWith("gf"))
			char = char.split("-")[0];

		loadGraphic(Paths.image('icons/icon-' + char), true, 150, 150);
		if (char.endsWith('-pixel') || char.startsWith('senpai') || char.startsWith('spirit'))
			antialiasing = false
		else
			antialiasing = FlxG.save.data.antialiasing;
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
