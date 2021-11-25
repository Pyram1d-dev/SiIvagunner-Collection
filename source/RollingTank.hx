import flixel.math.FlxAngle;
import flixel.math.FlxMath;
import flixel.FlxG;
import flixel.FlxSprite;

class RollingTank extends FlxSprite
{
	var counter = FlxG.random.float(-90, 45);
	var speed = FlxG.random.float(5, 7);

    public function new(x:Float, y:Float, ?adder:String)
    {
		super(x, y);
        if (adder != null)
		    frames = Paths.getSparrowAtlas('${adder}tankRolling', 'week7');
		else
			frames = Paths.getSparrowAtlas('tankRolling', 'week7');
		animation.addByPrefix('idle', "BG tank w lighting", 24, true);
		visible = false;
		animation.play('idle', true);
    }

    override function update(elapsed:Float)
    {
	    super.update(elapsed);
        if (!PlayState.inCutscene)
		{
			counter += elapsed * speed;
			angle = counter - 90 + 15;
			x = 400 + 1400 * FlxMath.fastCos(FlxAngle.asRadians(counter + 180));
			y = 1300 + 1100 * FlxMath.fastSin(FlxAngle.asRadians(counter + 180));
        }
    }
} 