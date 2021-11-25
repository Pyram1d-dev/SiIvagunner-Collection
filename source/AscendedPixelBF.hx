package;
import flixel.FlxG;
import flixel.math.FlxMath;
import flixel.FlxSprite;

class AscendedPixelBF extends FlxSprite // Best class in the game
{
    var shittyCounter:Float = 0;
    var originalY:Float;

	/**
        * HEY MOM LOOK I WROTE A DESCRIPTION
        * @param x Tf do you think this is
        * @param y I really don't need to explain this right
        * @param z what
        * @param RTX YOOOOOOOO
	 */
	public function new(x:Float, y:Float, z:Float = 0, RTX:Bool = false)
	{
        super(x, y);
        originalY = y;
        if (z != 0) // I decided to make z do something because it's funny lol
		{
			z += 1;
			setGraphicSize(Math.floor(width * z), Math.floor(height * z));
			scrollFactor.set(z, z);
            updateHitbox();
        }

        if (RTX) // AYO RTX LET'S GO
            loadGraphic(Paths.image("bababooey"));
        else
			loadGraphic(Paths.image("test/bfAscend", 'week1'));

        antialiasing = FlxG.save.data.antialiasing;
    }

    override public function update(elapsed:Float)
    {
		shittyCounter += elapsed * 1.2;
		// Yes I did take advanced algebra/trig honors how did you know
		y = originalY + FlxMath.fastSin(shittyCounter) * 12; // Sien wav :D but fast >:D
        updateHitbox();
    }
}