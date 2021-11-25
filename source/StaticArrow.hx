package;
import flixel.FlxG;
import flixel.FlxSprite;

using StringTools;

class StaticArrow extends FlxSprite // Stolen from KE 1.7 LMAOOOOOOOOOOO
{
	public var modifiedByLua:Bool = false;
	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside here

	public function new(x:Float, y:Float)
	{
		super(x, y);
		updateHitbox();
	}

	override function update(elapsed:Float)
	{
		if (!modifiedByLua)
			angle = localAngle + modAngle;
		else
			angle = modAngle;
		
		super.update(elapsed);

		#if debug
		if (FlxG.keys.justPressed.THREE)
			modAngle += 10;
		#end
	}

	public function playAnim(AnimName:String, ?force:Bool = false, ?debug:Bool = false):Void
	{
		animation.play(AnimName, force);

		if (!AnimName.startsWith('dirCon'))
		{
			localAngle = 0;
		}

		updateHitbox();

		// Dunno why Kade didn't exclude the pixel notes from this like I did, they don't require an offset and this just made them move around in 1.7
		if ((AnimName == 'confirm' || AnimName.startsWith('dirCon')) && PlayState.SONG.noteStyle != 'pixel' && PlayState.SONG.noteStyle != 'clubpenguin')
		{
			offset.set(frameWidth / 2, frameHeight / 2);

			offset.x -= 54;
			offset.y -= 56;
		}
		else
		{
			centerOffsets();
		}

		// Kung pow penis
		angle = localAngle + modAngle;
	}
}