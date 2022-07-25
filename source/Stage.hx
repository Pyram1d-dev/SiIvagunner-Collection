package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

using StringTools;

// For da scripts
class StageData
{
	public var curStage:String = '';
	public var halloweenLevel:Bool = false;
	public var camZoom:Float = 1.05;
	public var hideLastBG:Bool = false; // True = hide last BG and show ones from slowBacks on certain step, False = Toggle Visibility of BGs from SlowBacks on certain step
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String, Dynamic> = []; // Store BGs here to use them later in PlayState or when slowBacks activate
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var swagDancerGroup:Array<FlxTypedGroup<Dancer>> = []; // Store Dancer Groups
	public var swagSounds:Map<String, FlxSound> = []; // Store sounds
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup)
	public var layInFront:Array<Array<Dynamic>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and techincally also opponent since Haxe layering moment)
	public var slowBacks:Map<Int, Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"
	public var swagDancers:Map<String, Dynamic> = []; // Group for objects with a dance() function so that doesn't have to be manually added to beatHit in PlayState. (This is something that wasn't in KE 1.7 that I added)
	public var distractions:Array<Dynamic> = []; // Why have I complicated this whole thing
	public var isPixel:Bool = false; // PIXEL STAGES (for AA settings)
	public var charPositions:Array<Array<Int>> = [[0, 0], [0, 0], [0, 0]]; // [0] - BF, [1] - GF, [2] - Opponent
	public var stageCamOffsets:Array<Array<Int>> = [[0, 0], [0, 0]]; // [0] - BF, [1] - Opponent
	public function new() {}
}

class Stage // Stolen from KE 1.7 :troll: (this was true like 5 updates ago but then I made it load from a script so it's not the same at all anymore lmao)
{
	public var data:StageData;

	public function new(stageCheck:String, rootSong:String, songLowercase:String, daPixelZoom:Float)
	{
		switch (stageCheck)
		{
			case 'ballisticAlley':
				stageCheck = 'alley';
		}
		data = HScriptHandler.loadStageFromHScript(stageCheck);

		if (songLowercase == 'test')
			data.layInFront[2].push(new AscendedPixelBF(15, 15));

		for (i in data.swagDancers)
			data.distractions.push(i);

		trace(data.curStage);
		PlayState.curStage = data.curStage;
    }
}