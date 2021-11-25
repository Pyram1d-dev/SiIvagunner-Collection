package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import openfl.filters.ColorMatrixFilter;
import openfl.geom.Point;

class NoteSplat extends FlxSprite // Just couldn't not add this. This shit makes hitting a note so much more satisfying. It's like the note busted a fat nut because of your sick accuracy.
{
	var receptor:FlxSprite; // I think code here is pretty obvious. Spawn splat at receptor, play animation for note color, follow receptor until animation finishes, kill splat.

	// ...Except there are note styles which I THEN had to make sure the colors matched up for those. Also I made sprites for pixel notes and by "made" I really mean I threw a mosaic filter on it in Photoshop.
	// OH ALSO remember Step Mania mode? Yeah, I had to implement that as well ;)
	// I mean technically speaking I didn't have to implement that but I did anyway because it looked stupid if I didn't.

	/**
		Generates a new note splat at a receptor. It then follows that receptor until the animation ends.
		* @param receptor The receptor which the splat will spawn at and follow
		* @param number The receptor number from 0-3. Determines color IF not in Step Mania mode
		* @param originColor Step Mania color shit
	*/
	public function new(receptor:FlxSprite, number:Int, ?originColor:Int)
	{
		this.receptor = receptor;
		var noteStyle = PlayState.SONG.noteStyle;

		setPos();
		super(x, y);

		if (originColor != null)
			number = originColor;

		// NOW WITH CACHES! Fr tho that was really required or there would be random lag
		if (noteStyle == 'pixel' || (noteStyle == 'clubpenguin' && number != 2))
		{
			#if sys
			frames = GameCache.globalCache.fromSparrow('pixelNoteSplashes', 'weeb/pixelUI/noteSplashes-pixel', 'week6');
			#else
			frames = Paths.getSparrowAtlas('weeb/pixelUI/noteSplashes-pixel', 'week6');
			#end
		}
		else if (noteStyle == 'clubpenguin' && number == 2)
		{
			// Listen man, FlxColor is fucking stupid and hues don't work the way I want them to. I'll be as inefficient as I want >:(
			#if sys
			frames = GameCache.globalCache.fromSparrow('yellowNoteSplashes', 'weeb/clubpenguin/pixelUI/yellowsplashlmao', 'week6');
			#else
			frames = Paths.getSparrowAtlas('weeb/clubpenguin/pixelUI/yellowsplashlmao', 'week6');
			#end
		}
		else
		{
			#if sys
			frames = GameCache.globalCache.fromSparrow('noteSplashes', 'noteSplashes', 'shared');
			#else
			frames = Paths.getSparrowAtlas('noteSplashes', 'shared');
			#end
		}

		if (noteStyle == 'kapi')
			switch (number)
			{
				case 2:
					number = 1;
				case 3:
					number = 0;
			}
		if (noteStyle == 'clubpenguin')
			switch (number)
			{
				case 0:
					number = 3;
				case 1:
					number = 2;
				case 3:
					number = 1;
			}

		for (color in 0...4)
		{
			for (i in 0...2)
			{
				// Renamed frames in the XML file to make this a lot easier and less cluttered
				animation.addByPrefix('hit$color-variation$i', 'note impact ${i + 1} $color', 24, false);
			}
		}

		antialiasing = (noteStyle == 'clubpenguin' || noteStyle == 'pixel') ? false : FlxG.save.data.antialiasing;

		animation.play("hit" + number + "-variation" + FlxG.random.int(0, 1), true);
		animation.curAnim.frameRate += FlxG.random.int(-2, 2);
		updateHitbox();
		offset.set(0.3 * frameWidth, 0.3 * frameHeight);
		visible = receptor.visible;
	}

	function setPos()
	{
		x = receptor.x;
		y = receptor.y;
		alpha = receptor.alpha * 0.6;
		visible = receptor.visible;
	}

	override function update(elapsed)
	{
		setPos();
		super.update(elapsed);
		if (animation.curAnim.finished)
		{
			kill();
			destroy();
		}
	}
}
