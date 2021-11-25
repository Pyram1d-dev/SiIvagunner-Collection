package;

import flixel.util.FlxColor;
import flixel.FlxG;
import flixel.FlxSprite;

class LaneUnderlay extends FlxSprite // No one will probably use this lmaoooo I just wanted to add it
{
    var receptor:StaticArrow;

	public function new(receptor:StaticArrow)
    {
        this.receptor = receptor;
		super(receptor.x, FlxG.height * -0.5);
        makeGraphic(Math.floor(Note.swagWidth),FlxG.height*2,FlxColor.BLACK);
		alpha = FlxG.save.data.focusAlpha * receptor.alpha;
    }

    override function update(elapsed)
    {
		super.update(elapsed);
		alpha = FlxG.save.data.focusAlpha * receptor.alpha;
        x = receptor.x;
    }
}