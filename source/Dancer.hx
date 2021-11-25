package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

using StringTools;

class Dancer extends FlxSprite // There's like 200000000 different classes for dancers so I'm making this one for simplicity's sake
{
	var danceLeft = true;
	var biDirectional:Bool;
	var mod:Array<Int>;
	var originalY:Float;
	var frameTick:Float;
	var moving:Bool = true;

	public var lerpAnim:Bool;

	/**
	 * A background dancer that bops to the beat as part of the current stage
	 * @param x 
	 * @param y 
	 * @param biDirectional Whether or not the dancer has a danceLeft and danceRight animation
	 * @param mod Mod format: [division, remainder], uses a mod function to instruct the dancer which beat to dance on
	 * @param lerpAnim If the dancer doesn't have a dance animation and just bops to the beat using lerps and simple movement
	 */
	public function new(x:Float, y:Float, biDirectional:Bool = false, ?mod:Array<Int>, lerpAnim:Bool = false)
	{
		super(x, y);
		originalY = y;
		this.biDirectional = biDirectional;
		this.lerpAnim = lerpAnim;
		this.mod = mod; // Mod format: [division, remainder]
		// Mod example: I want the dancer to bop every other beat, so my mod array would be [2, 0]
		// EX 2: I want the dancer to bop every 8th beat, so my mod array would be [8, 7]
		// Remember the first number is non-inclusive and it starts counting from 0 because coding make the brain go *windows xp shutdown noise*
		// Tbf idk if anyone would use any mod other than [2, 0] but whatever I thought it would be neat
	}

	public function dance(beat:Int):Void
	{
		var exec = function()
		{
			if (mod == null || beat % mod[0] == mod[1])
			{
				if (!lerpAnim)
				{
					danceLeft = !danceLeft;
					if (!biDirectional)
					{
						animation.play("idle", true);
					}
					else if (danceLeft)
					{
						animation.play("danceLeft", true);
					}
					else
					{
						animation.play("danceRight", true);
					}
				}
				else
				{
					// Move down for 2 frames (at 24 fps) because moving instantly looks dumb
					moving = true;
					new FlxTimer().start(1 / 24, function(tmr:FlxTimer)
					{
						y = originalY + 15 * tmr.elapsedLoops;
						if (tmr.elapsedLoops == 2)
							moving = false;
					}, 2);
				}
			}
		}
		if (PlayState.SONG.song.toLowerCase() == 'guns short version')
			new FlxTimer().start(FlxG.random.float(.01, .2), function(tmr:FlxTimer)
			{
				exec();
			});
		else
			exec();
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		frameTick += elapsed;
		while (lerpAnim && frameTick > 1 / 24 && !moving)
		{
			frameTick -= 1 / 24;
			y = FlxMath.lerp(y, originalY, 0.2);
		}
	}
}
