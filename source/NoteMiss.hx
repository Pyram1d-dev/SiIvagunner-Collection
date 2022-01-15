import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

// The players gotta know when they're bad at the game tbh
class NoteMiss extends FlxSprite
{
	public function init(x:Float, data:Int)
	{
		setPosition(x, (PlayStateChangeables.useDownscroll) ? FlxG.height - 100 : 0);
		scale.set(1, 1);
		data = Math.floor(Math.abs(data));

		var num2color:Map<Int, FlxColor> = [
			0 => 0xFFCF4BDE, // Thanks for nothing FlxColor grape juice purple looking headass
			1 => FlxColor.CYAN,
			2 => FlxColor.LIME,
			3 => FlxColor.RED
		];
		switch (PlayState.SONG.noteStyle)
		{
			case 'pixel':
				num2color.set(3, 0xFFFC7F03);
			case 'clubpenguin':
				num2color = [0 => 0xFFFC7F03, 1 => FlxColor.LIME, 2 => FlxColor.YELLOW, 3 => FlxColor.BLUE];
			case 'kapi':
				num2color.set(2, num2color[1]);
				num2color.set(3, num2color[0]);
			case 'monika':
				num2color.set(3, FlxColor.MAGENTA);
		}
		var col = num2color[data];
		pixels = FlxGradient.createGradientBitmapData(Math.floor(Note.swagWidth), 100, [col, FlxColor.TRANSPARENT], 1,
			(PlayStateChangeables.useDownscroll) ? -90 : 90);
		updateHitbox();
		scrollFactor.set();
		cameras = [FlxG.cameras.list[1]];
		alpha = (FlxG.save.data.missGFX) ? 1 : 0;
		FlxTween.tween(this, {
			alpha: 0,
			'scale.x': .6,
			'scale.y': 2,
			y: y + (FlxMath.signOf(FlxG.height / 2 - y) * (height / 2))
		}, .8, {
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				kill();
			}
		});
	}
}
