import flixel.FlxG;

// Setting the fps cap doesn't change elapsed time for some fucking reason lmao Haxeflixel momento
// the 144 is just the fps I was using to test the game
class FPSScalingShit
{
  public static function scaledFPS():Float
  {
    return 144 * ((1 / FlxG.save.data.fpsCap > FlxG.elapsed) ? (1 / FlxG.save.data.fpsCap) : FlxG.elapsed);
  }
}