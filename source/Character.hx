package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;

using StringTools;

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var baseCharacter:String = 'bf';
	public var animationNotes:Array<Dynamic> = [];
	public var animationSound:FlxSound;

	public var biDirectional = false;

	public var holdTimer:Float = 0;

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		super(x, y);

		animOffsets = new Map<String, Array<Dynamic>>();
		curCharacter = character;
		baseCharacter = character;
		this.isPlayer = isPlayer;

		var hasUniqueOffsets = false;
		var exception = false;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			case 'gf':
				tex = Paths.getSparrowAtlas('GFs/GF_assets', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'gf-tankmen' | 'gf-homedepot' | 'gf-desync':
				var adder = (curCharacter == 'gf-homedepot') ? 'HD' : (curCharacter == 'gf-desync') ? 'Desync' : '';
				tex = Paths.getSparrowAtlas('GFs/gfTankmen$adder', 'shared', true);
				frames = tex;
				animation.addByPrefix('sad', 'GF Crying at Gunpoint', 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing at Gunpoint', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing at Gunpoint', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

				loadOffsetFile('gf-tankmen');

				playAnim('danceRight');

				exception = true;

			case 'gf-samsung':
				tex = Paths.getSparrowAtlas('GFs/GF_samsung', 'shared', true);
				frames = tex;

			case 'gf-curly':
				tex = Paths.getSparrowAtlas('GFs/GF_curly', 'shared', true);
				frames = tex;

			case 'gf-hk':
				tex = Paths.getSparrowAtlas('GFs/GF_hk', 'shared', true);
				frames = tex;

			case 'gf-cow':
				tex = Paths.getSparrowAtlas('GFs/GF_cow', 'shared', true);
				frames = tex;

			case 'gf-cowidle':
				tex = Paths.getSparrowAtlas('GFs/GF_cowidle', 'shared', true);
				frames = tex;

			case 'gf-whitty':
				tex = Paths.getSparrowAtlas('GFs/GF_Standing_Sway', 'shared', true);
				frames = tex;
				trace(tex.frames.length);
				// animation.addByPrefix('sad', 'Sad', 24, false);
				animation.addByPrefix('danceLeft', 'Idle Left', 24, false);
				animation.addByPrefix('danceRight', 'Idle Right', 24, false);
				animation.addByPrefix('scared', 'Scared', 24, true, false, false);

				loadOffsetFile(curCharacter);

				if (PlayState.SONG.song.toLowerCase() != 'Ballistic')
					playAnim('danceRight');
				else
					playAnim('scared');

				exception = true;

			case 'gf-monalisa':
				tex = Paths.getSparrowAtlas('GFs/GF_monalisa', 'shared', true);
				frames = tex;

			case 'gf-zelda':
				tex = Paths.getSparrowAtlas('GFs/GF_zelda', 'shared', true);
				frames = tex;

			case 'gf-mako':
				tex = Paths.getSparrowAtlas('GFs/GF_mako', 'shared', true);
				frames = tex;

			case 'gf-yankin':
				tex = Paths.getSparrowAtlas('GFs/GF_yankin', 'shared', true);
				frames = tex;

			case 'gf-pig':
				tex = Paths.getSparrowAtlas('GFs/GF_pig', 'shared', true);
				frames = tex;

			case 'gf-kapi':
				tex = Paths.getSparrowAtlas('GFs/GF_kapi', 'shared', true);
				frames = tex;

			case 'gf-marisa':
				tex = Paths.getSparrowAtlas('GFs/GF_marisa', 'shared', true);
				frames = tex;

			case 'gf-sus':
				tex = Paths.getSparrowAtlas('GFs/GF_sus', 'shared', true);
				frames = tex;

			case 'gf-amy':
				tex = Paths.getSparrowAtlas('GFs/GF_amy', 'shared', true);
				frames = tex;

			case 'gf-christmas':
				tex = Paths.getSparrowAtlas('GFs/gfChristmas', 'shared', true);
				frames = tex;

			case 'gf-car':
				tex = Paths.getSparrowAtlas('GFs/gfCar', 'shared', true);
				frames = tex;

			case 'gf-car-christmas':
				tex = Paths.getSparrowAtlas('GFs/gfCarChristmas', 'shared', true);
				frames = tex;

			case 'gf-car-dk':
				tex = Paths.getSparrowAtlas('GFs/gfCarDixie', 'shared', true);
				frames = tex;

			case 'gf-car-neko':
				tex = Paths.getSparrowAtlas('GFs/gfCarNeko', 'shared', true);
				frames = tex;

			case 'gf-pixel':
				tex = Paths.getSparrowAtlas('GFs/gfPixel', 'shared', true);
				frames = tex;

			case 'gf-pixel-guide':
				tex = Paths.getSparrowAtlas('GFs/gfPixelGuide', 'shared', true);
				frames = tex;

			case 'gf-pixel-eb':
				tex = Paths.getSparrowAtlas('GFs/gfPixelEB', 'shared', true);
				frames = tex;

			case 'gf-pixel-hippi':
				tex = Paths.getSparrowAtlas('GFs/gfPixelHippi', 'shared', true);
				frames = tex;

			case 'dad':
				// DAD ANIMATION LOADING CODE
				// ok
				tex = Paths.getSparrowAtlas('Dads/DADDY_DEAREST', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'kapi':
				tex = Paths.getSparrowAtlas('Kapi', 'shared', true);
				frames = tex;
				animation.addByIndices('idle', 'Dad idle dance', [2, 4, 6, 8, 10, 0], "", 12, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
				animation.addByPrefix('meow', 'Dad meow', 24, false);
				animation.addByPrefix('stare', 'Dad stare', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'remilia':
				tex = Paths.getSparrowAtlas('Remilia', 'shared', true);
				frames = tex;
				animation.addByIndices('idle', 'Dad idle dance', [2, 4, 6, 8, 10, 0], "", 12, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);
				animation.addByPrefix('meow', 'Dad meow', 24, false);
				animation.addByPrefix('stare', 'Dad stare', 24, false);

				loadOffsetFile('kapi');

				baseCharacter = 'kapi';

				playAnim('idle');

			case 'dad-king':
				tex = Paths.getSparrowAtlas('Dads/DADDY_DEAREST_king', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				loadOffsetFile('dad');

				playAnim('idle');

			case 'dads':
				tex = Paths.getSparrowAtlas('Dads/DADDY_DEARESTS', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				baseCharacter = 'dad';

				loadOffsetFile('dad');

				playAnim('idle');

			case 'big-chungus':
				baseCharacter = 'dad';
				tex = Paths.getSparrowAtlas('Dads/BIG_CHUNGUS_assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				loadOffsetFile('dad');

				playAnim('idle');

			case 'dad-amogus':
				tex = Paths.getSparrowAtlas('Dads/DADDY_DEAREST_amogus', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Dad idle dance', 24, false);
				animation.addByPrefix('singUP-alt', 'Drip', 24, false);
				animation.addByPrefix('singUP', 'Dad Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'Dad Sing Note RIGHT', 24, false);
				animation.addByPrefix('singDOWN', 'Dad Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Dad Sing Note LEFT', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'spooky':
				tex = Paths.getSparrowAtlas('Spooky/spooky_kids_assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'spooky-slam':
				tex = Paths.getSparrowAtlas('Spooky/spooky_kids_slam', 'shared', true);
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile('spooky');

				playAnim('danceRight');

			case 'spooky-tetris':
				tex = Paths.getSparrowAtlas('Spooky/spooky_kids_tetris', 'shared', true);
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile('spooky');

				playAnim('danceRight');

			case 'childishgambino':
				baseCharacter = 'spooky';
				tex = Paths.getSparrowAtlas('childish_gambino', 'shared', true);
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile('spooky');

				playAnim('danceRight');

			case 'bomberman':
				baseCharacter = 'spooky';
				tex = Paths.getSparrowAtlas('bomberman_assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile('spooky');

				playAnim('danceRight');

			case 'metalSonic':
				baseCharacter = 'spooky';
				tex = Paths.getSparrowAtlas('metal_sonic', 'shared', true);
				frames = tex;
				animation.addByPrefix('singUP', 'spooky UP NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'spooky DOWN note', 24, false);
				animation.addByPrefix('singLEFT', 'note sing left', 24, false);
				animation.addByPrefix('singRIGHT', 'spooky sing right', 24, false);
				animation.addByIndices('danceLeft', 'spooky dance idle', [0, 2, 6], "", 12, false);
				animation.addByIndices('danceRight', 'spooky dance idle', [8, 10, 12, 14], "", 12, false);

				loadOffsetFile(curCharacter);

				playAnim('danceRight');

			case 'mom':
				tex = Paths.getSparrowAtlas('Moms/Mom_Assets', 'shared', true);
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'mom-car':
				tex = Paths.getSparrowAtlas('Moms/momCar', 'shared', true);
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'mom-car-christmas':
				tex = Paths.getSparrowAtlas('Moms/momCarChristmas', 'shared', true);
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFile('mom-car');

				playAnim('idle');

			case 'mom-car-neko':
				tex = Paths.getSparrowAtlas('Moms/momCarNeko', 'shared', true);
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFile('mom-car');

				playAnim('idle');

			case 'mom-ragyo':
				tex = Paths.getSparrowAtlas('Moms/momRagyo', 'shared', true);
				frames = tex;

				animation.addByPrefix('idle', "Mom Idle", 24, false);
				animation.addByPrefix('singUP', "Mom Up Pose", 24, false);
				animation.addByPrefix('singDOWN', "MOM DOWN POSE", 24, false);
				animation.addByPrefix('singLEFT', 'Mom Left Pose', 24, false);
				// ANIMATION IS CALLED MOM LEFT POSE BUT ITS FOR THE RIGHT
				// CUZ DAVE IS DUMB!
				animation.addByPrefix('singRIGHT', 'Mom Pose Left', 24, false);

				loadOffsetFile('mom-car');

				playAnim('idle');

			case 'monster':
				tex = Paths.getSparrowAtlas('Monsters/Monster_Assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster left note', 24, false);
				animation.addByPrefix('singLEFT', 'Monster Right note', 24, false);

				loadOffsetFile(curCharacter);
				playAnim('idle');

			case 'monster-christmas':
				tex = Paths.getSparrowAtlas('Monsters/monsterChristmas', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFile(curCharacter);
				playAnim('idle');

			case 'monster-christmas-bean':
				tex = Paths.getSparrowAtlas('Monsters/monsterChristmas_bean', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'monster idle', 24, false);
				animation.addByPrefix('singUP', 'monster up note', 24, false);
				animation.addByPrefix('singDOWN', 'monster down', 24, false);
				animation.addByPrefix('singLEFT', 'Monster left note', 24, false);
				animation.addByPrefix('singRIGHT', 'Monster Right note', 24, false);

				loadOffsetFile('monster-christmas');
				playAnim('idle');

			case 'pico':
				tex = Paths.getSparrowAtlas('Picos/Pico_FNF_assetss', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down Note MISS', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				flipX = true;

			case 'pico-igor':
				tex = Paths.getSparrowAtlas('Picos/Pico_FNF_igor', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down note miss', 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'pico-cringe':
				tex = Paths.getSparrowAtlas('Picos/Pico_FNF_cringe', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down note miss', 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'pico-fw':
				tex = Paths.getSparrowAtlas('Picos/Pico_FNF_fw', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down note miss', 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'pico-gecs':
				tex = Paths.getSparrowAtlas('Picos/Pico_FNF_gecs', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down note miss', 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'juiceWRLD':
				baseCharacter = 'pico';
				tex = Paths.getSparrowAtlas('juiceWRLD', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down note miss', 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'pico-grandpa':
				tex = Paths.getSparrowAtlas('Picos/Pico_FNF_grandpa', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down note miss', 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'mario':
				baseCharacter = 'pico';
				tex = Paths.getSparrowAtlas('Mario_assets', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);
				animation.addByPrefix('singUP', 'pico Up note0', 24, false);
				animation.addByPrefix('singDOWN', 'Pico Down Note0', 24, false);
				if (isPlayer)
				{
					animation.addByPrefix('singLEFT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico Note Right Miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico NOTE LEFT miss', 24, false);
				}
				else
				{
					// Need to be flipped! REDO THIS LATER!
					animation.addByPrefix('singLEFT', 'Pico Note Right0', 24, false);
					animation.addByPrefix('singRIGHT', 'Pico NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'Pico NOTE LEFT miss', 24, false);
					animation.addByPrefix('singLEFTmiss', 'Pico Note Right Miss', 24, false);
				}

				animation.addByPrefix('singUPmiss', 'pico Up note miss', 24, false);
				animation.addByPrefix('singDOWNmiss', 'Pico Down note miss', 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'mario-ded':
				baseCharacter = 'pico';
				tex = Paths.getSparrowAtlas('mario_ded', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', "Pico Idle Dance", 24, false);

				loadOffsetFile('pico');

				playAnim('idle');

				flipX = true;

			case 'bf':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'bf-hk':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_hk', 'shared', true);
				frames = tex;

			case 'bf-desync':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_desync', 'shared', true);
				frames = tex;

			case 'bf-link':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_link', 'shared', true);
				frames = tex;

			case 'bf-dk':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_dk', 'shared', true);
				frames = tex;

			case 'bf-kapi':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_kapi', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'bf-gecs':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_gecs', 'shared', true);
				frames = tex;

			case 'bf-grandpa':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_grandpa', 'shared', true);
				frames = tex;

			case 'bf-slam':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_slam', 'shared', true);
				frames = tex;

			case 'bf-ryuko':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_ryuko', 'shared', true);
				frames = tex;

			case 'bf-samsung':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_samsung', 'shared', true);
				frames = tex;

			case 'bf-quote':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_quote', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'bf-smooth':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_smooth', 'shared', true);
				frames = tex;

			case 'bf-06':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_06', 'shared', true);
				frames = tex;

			case 'bf-igor':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_igor', 'shared', true);
				frames = tex;

			case 'bf-deez':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_deez', 'shared', true);
				frames = tex;

			case 'bf-amogus':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_amogus', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'bf-richter':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_richter', 'shared', true);
				frames = tex;

			case 'bf-pain':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_pain', 'shared', true);
				frames = tex;

			case 'bf-vitas':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_vitas', 'shared', true);
				frames = tex;

			case 'bf-sockdude':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_sockdude', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'bf-sonic':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_sonic', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'bf-reimu':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_reimu', 'shared', true);
				frames = tex;
				hasUniqueOffsets = true;

			case 'bf-neko':
				var tex = Paths.getSparrowAtlas('BFs/BOYFRIEND_neko', 'shared', true);
				frames = tex;

			case 'bf-christmas':
				var tex = Paths.getSparrowAtlas('BFs/bfChristmas', 'shared', true);
				frames = tex;

			case 'bf-car':
				var tex = Paths.getSparrowAtlas('BFs/bfCar', 'shared', true);
				frames = tex;

			case 'bf-car-christmas':
				var tex = Paths.getSparrowAtlas('BFs/bfCarChristmas', 'shared', true);
				frames = tex;

			case 'bf-car-dk':
				var tex = Paths.getSparrowAtlas('BFs/bfCarDiddy', 'shared', true);
				frames = tex;

			case 'bf-car-vitas':
				var tex = Paths.getSparrowAtlas('BFs/bfCarVitas', 'shared', true);
				frames = tex;

			case 'bf-car-neko':
				var tex = Paths.getSparrowAtlas('BFs/bfCarNeko', 'shared', true);
				frames = tex;

			case 'bf-pixel':
				frames = Paths.getSparrowAtlas('BFs/bfPixel', 'shared', true);

			case 'bf-pixel-dead':
				frames = Paths.getSparrowAtlas('BFs/bfPixelsDEAD', 'shared', true);

			case 'bf-pixel-dead-clp':
				frames = Paths.getSparrowAtlas('BFs/bfPixelsDEAD-clp', 'shared', true);

			case 'bf-pixel-squisherz':
				frames = Paths.getSparrowAtlas('BFs/bfPixelSquisherz', 'shared', true);
			case 'bf-pixel-squisherz-dead':
				frames = Paths.getSparrowAtlas('BFs/bfPixelSquisherzDEAD', 'shared', true);

			case 'bf-pixel-daft':
				frames = Paths.getSparrowAtlas('BFs/bfPixelDaft', 'shared', true);
			case 'bf-pixel-daft-dead':
				frames = Paths.getSparrowAtlas('BFs/bfPixelDaftDEAD', 'shared', true);

			case 'bf-pixel-terraria':
				frames = Paths.getSparrowAtlas('BFs/bfPixelTerraria', 'shared', true);
			case 'bf-pixel-terraria-dead':
				frames = Paths.getSparrowAtlas('BFs/bfPixelTerrariaDEAD', 'shared', true);

			case 'bf-pixel-ness':
				frames = Paths.getSparrowAtlas('BFs/bfPixelNess', 'shared', true);
			case 'bf-pixel-ness-dead':
				frames = Paths.getSparrowAtlas('BFs/bfPixelNessDEAD', 'shared', true);

			case 'signDeath':
				frames = PlayState.instance.songCache.fromSparrow("death", "characters/BFs/signDeath", "shared");
				//frames = Paths.getSparrowAtlas('BFs/signDeath', 'shared', true);
				animation.addByPrefix('firstDeath', 'BF dies', 24, false);
				animation.addByPrefix('deathLoop', 'BF Dead Loop', 24, false);
				animation.addByPrefix('deathConfirm', 'BF Dead confirm', 24, false);

				playAnim('firstDeath');

				loadOffsetFile(curCharacter);

				animation.pause();

				updateHitbox();
				antialiasing = FlxG.save.data.antialiasing;
				flipX = true;

			case 'senpai':
				frames = Paths.getSparrowAtlas('Senpais/senpai', 'shared', true);
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'senpai-helper':
				frames = Paths.getSparrowAtlas('Senpais/senpaiHelper', 'shared', true);
				animation.addByPrefix('idle', 'Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'SENPAI UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'SENPAI LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'SENPAI RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'SENPAI DOWN NOTE', 24, false);

				loadOffsetFile('senpai');

				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'senpai-angry':
				frames = Paths.getSparrowAtlas('Senpais/senpai', 'shared', true);
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFile(curCharacter);
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'senpai-punk':
				frames = Paths.getSparrowAtlas('Senpais/senpaiPunk', 'shared', true);
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFile('senpai-angry');
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'senpai-will':
				frames = Paths.getSparrowAtlas('Senpais/senpaiWill', 'shared', true);
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFile('senpai-angry');
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'senpai-skeletron':
				frames = Paths.getSparrowAtlas('Senpais/senpaiSkeletron', 'shared', true);
				animation.addByPrefix('idle', 'Angry Senpai Idle', 24, false);
				animation.addByPrefix('singUP', 'Angry Senpai UP NOTE', 24, false);
				animation.addByPrefix('singLEFT', 'Angry Senpai LEFT NOTE', 24, false);
				animation.addByPrefix('singRIGHT', 'Angry Senpai RIGHT NOTE', 24, false);
				animation.addByPrefix('singDOWN', 'Angry Senpai DOWN NOTE', 24, false);

				loadOffsetFile('senpai-angry');
				playAnim('idle');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				antialiasing = false;

			case 'spirit':
				frames = Paths.getPackerAtlas('Senpais/spirit', 'shared', true);
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				loadOffsetFile(curCharacter);

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'spirit-gariwald':
				frames = Paths.getPackerAtlas('Senpais/spiritGariwald', 'shared', true);
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				loadOffsetFile('spirit');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'spirit-giygas':
				frames = Paths.getPackerAtlas('Senpais/spiritGiygas', 'shared', true);
				animation.addByPrefix('idle', "idle spirit_", 24, false);
				animation.addByPrefix('singUP', "up_", 24, false);
				animation.addByPrefix('singRIGHT', "right_", 24, false);
				animation.addByPrefix('singLEFT', "left_", 24, false);
				animation.addByPrefix('singDOWN', "spirit down_", 24, false);

				loadOffsetFile('spirit');

				setGraphicSize(Std.int(width * 6));
				updateHitbox();

				playAnim('idle');

				antialiasing = false;

			case 'parents-christmas':
				frames = Paths.getSparrowAtlas('mom_dad_christmas_assets', 'shared', true);
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'parents-games':
				frames = Paths.getSparrowAtlas('mom_dad_games_assets', 'shared', true);
				animation.addByPrefix('idle', 'Parent Christmas Idle', 24, false);
				animation.addByPrefix('singUP', 'Parent Up Note Dad', 24, false);
				animation.addByPrefix('singDOWN', 'Parent Down Note Dad', 24, false);
				animation.addByPrefix('singLEFT', 'Parent Left Note Dad', 24, false);
				animation.addByPrefix('singRIGHT', 'Parent Right Note Dad', 24, false);

				animation.addByPrefix('singUP-alt', 'Parent Up Note Mom', 24, false);
				animation.addByPrefix('singDOWN-alt', 'Parent Down Note Mom', 24, false);
				animation.addByPrefix('singLEFT-alt', 'Parent Left Note Mom', 24, false);
				animation.addByPrefix('singRIGHT-alt', 'Parent Right Note Mom', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');

			case 'whitty': // whitty reg (lofight)
				tex = Paths.getSparrowAtlas('Whitty/WhittySprites', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singUP', 'Sing Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24, false);
				animation.addByPrefix('singDOWN', 'Sing Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sing Left', 24, false);

				loadOffsetFile(curCharacter);

			case 'whitty-mars': // whitty but he's bruno mars lol (overhead)
				tex = Paths.getSparrowAtlas('Whitty/WhittySprites_Mars', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singUP', 'Sing Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24, false);
				animation.addByPrefix('singDOWN', 'Sing Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sing Left', 24, false);

				loadOffsetFile('whitty');

			case 'whittyCrazy': // OH LAWD HE COMIN
				tex = Paths.getSparrowAtlas('Whitty/WhittyCrazy', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Whitty idle dance', 24, false);
				animation.addByPrefix('singUP', 'Whitty Sing Note UP', 24, false);
				animation.addByPrefix('singRIGHT', 'whitty sing note right', 24, false);
				animation.addByPrefix('singDOWN', 'Whitty Sing Note DOWN', 24, false);
				animation.addByPrefix('singLEFT', 'Whitty Sing Note LEFT', 24, false);

				loadOffsetFile(curCharacter);

			case 'tankman':
				tex = Paths.getSparrowAtlas('tankmanCaptain', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Tankman Idle Dance', 24, false);
				animation.addByPrefix('singUP', 'Tankman UP note', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Note Left', 24, false);
				animation.addByPrefix('singUP-alt', 'TANKMAN UGH', 24, false);
				animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman', 24, false);
				flipX = true;

				loadOffsetFile(curCharacter);

			case 'tankman-homedepot':
				tex = Paths.getSparrowAtlas('tankmanCaptainHomeDepot', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Tankman Idle Dance', 24, false);
				animation.addByPrefix('singUP', 'Tankman UP note', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Note Left', 24, false);
				animation.addByPrefix('singUP-alt', 'TANKMAN UGH', 24, false);
				animation.addByPrefix('singDOWN-alt', 'PRETTY GOOD tankman', 24, false);
				flipX = true;

				loadOffsetFile('tankman');

			case 'psy':
				baseCharacter = 'tankman';
				tex = Paths.getSparrowAtlas('psy', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Tankman Idle Dance', 24, false);
				animation.addByPrefix('singUP', 'Tankman UP note', 24, false);
				animation.addByPrefix('singLEFT', 'Tankman Right Note', 24, false);
				animation.addByPrefix('singDOWN', 'Tankman DOWN note', 24, false);
				animation.addByPrefix('singRIGHT', 'Tankman Note Left', 24, false);
				animation.addByPrefix('singUP-alt', 'TANKMAN UGH', 24, false);
				flipX = true;

				loadOffsetFile(curCharacter);

			case 'grimm':
				baseCharacter = 'tricky';
				tex = Paths.getSparrowAtlas('grimm', 'shared', true);
				frames = tex;
				animation.addByPrefix('idle', 'Idle', 24, false);
				animation.addByPrefix('singUP', 'Sing Up', 24, false);
				animation.addByPrefix('singRIGHT', 'Sing Right', 24, false);
				animation.addByPrefix('singDOWN', 'Sing Down', 24, false);
				animation.addByPrefix('singLEFT', 'Sing Left', 24, false);

				loadOffsetFile(curCharacter);

				playAnim('idle');
		}

		if (baseCharacter.split('-')[0] == 'spooky')
			biDirectional = true;

		var nameSplit:Array<String> = curCharacter.split('-');

		// Since this is a special case where I have a SHIT TON of character skins mostly of GF and BF, I had to type out this fucking code so that it sets up pretty much any BF sprite since they all have the same animations
		// Could do it for other characters but... NO
		if (curCharacter.startsWith('bf') && !exception)
		{
			if (!curCharacter.startsWith('bf-pixel') && !curCharacter.startsWith('bf-car') && !curCharacter.startsWith('bf-christmas'))
			{
				trace(frames.frames.length);

				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, false);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				loadOffsetFile((hasUniqueOffsets) ? curCharacter : 'bf');

				playAnim('idle');

				flipX = true;
			}
			else
			{
				if (nameSplit[nameSplit.length - 1] != 'dead'
					&& nameSplit[nameSplit.length - 2] + nameSplit[nameSplit.length - 1] != 'deadclp')
				{
					switch (nameSplit[1])
					{
						case 'christmas':
							{
								animation.addByPrefix('idle', 'BF idle dance', 24, false);
								animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
								animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
								animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
								animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
								animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
								animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
								animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
								animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
								animation.addByPrefix('hey', 'BF HEY', 24, false);

								loadOffsetFile((hasUniqueOffsets) ? curCharacter : (nameSplit[0] + '-' + nameSplit[1]));

								playAnim('idle');

								flipX = true;
							}

						case 'pixel':
							{
								animation.addByPrefix('idle', 'BF IDLE', 24, false);
								animation.addByPrefix('singUP', 'BF UP NOTE', 24, false);
								animation.addByPrefix('singLEFT', 'BF LEFT NOTE', 24, false);
								animation.addByPrefix('singRIGHT', 'BF RIGHT NOTE', 24, false);
								animation.addByPrefix('singDOWN', 'BF DOWN NOTE', 24, false);
								animation.addByPrefix('singUPmiss', 'BF UP MISS', 24, false);
								animation.addByPrefix('singLEFTmiss', 'BF LEFT MISS', 24, false);
								animation.addByPrefix('singRIGHTmiss', 'BF RIGHT MISS', 24, false);
								animation.addByPrefix('singDOWNmiss', 'BF DOWN MISS', 24, false);

								loadOffsetFile((hasUniqueOffsets) ? curCharacter : (nameSplit[0] + '-' + nameSplit[1]));

								setGraphicSize(Std.int(width * 6));
								updateHitbox();

								playAnim('idle');

								width -= 100;
								height -= 100;

								antialiasing = false;

								flipX = true;
							}
						case 'car':
							{
								animation.addByPrefix('idle', 'BF idle dance', 24, false);
								animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
								animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
								animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
								animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
								animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
								animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
								animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
								animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);

								loadOffsetFile((hasUniqueOffsets) ? curCharacter : (nameSplit[0] + '-' + nameSplit[1]));
								playAnim('idle');

								flipX = true;
							}
					}
				}
				else
				{
					animation.addByPrefix('singUP', "BF Dies pixel", 24, false);
					animation.addByPrefix('firstDeath', "BF Dies pixel", 24, false);
					animation.addByPrefix('deathLoop', "Retry Loop", 24, false);
					animation.addByPrefix('deathConfirm', "RETRY CONFIRM", 24, false);
					animation.play('firstDeath');

					loadOffsetFile((hasUniqueOffsets) ? curCharacter : 'bf-pixel-dead');
					playAnim('firstDeath');
					// pixel bullshit
					setGraphicSize(Std.int(width * 6));
					updateHitbox();
					antialiasing = false;
					flipX = true;
				}
			}
		}

		// Oh yeah also GF
		if (curCharacter.startsWith('gf') && !exception)
		{
			if (!curCharacter.startsWith('gf-pixel') && !curCharacter.startsWith('gf-car') && !curCharacter.startsWith('gf-christmas'))
			{
				animation.addByPrefix('cheer', 'GF Cheer', 24, false);
				animation.addByPrefix('singLEFT', 'GF left note', 24, false);
				animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
				animation.addByPrefix('singUP', 'GF Up Note', 24, false);
				animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
				animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
				animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
				animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
				animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
				animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
				animation.addByPrefix('scared', 'GF FEAR', 24);

				loadOffsetFile((hasUniqueOffsets) ? curCharacter : 'gf');

				playAnim('danceRight');
			}
			else
			{
				switch (nameSplit[1])
				{
					case 'christmas':
						{
							animation.addByPrefix('cheer', 'GF Cheer', 24, false);
							animation.addByPrefix('singLEFT', 'GF left note', 24, false);
							animation.addByPrefix('singRIGHT', 'GF Right Note', 24, false);
							animation.addByPrefix('singUP', 'GF Up Note', 24, false);
							animation.addByPrefix('singDOWN', 'GF Down Note', 24, false);
							animation.addByIndices('sad', 'gf sad', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12], "", 24, false);
							animation.addByIndices('danceLeft', 'GF Dancing Beat', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
							animation.addByIndices('danceRight', 'GF Dancing Beat', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24,
								false);
							animation.addByIndices('hairBlow', "GF Dancing Beat Hair blowing", [0, 1, 2, 3], "", 24);
							animation.addByIndices('hairFall', "GF Dancing Beat Hair Landing", [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11], "", 24, false);
							animation.addByPrefix('scared', 'GF FEAR', 24);

							loadOffsetFile((hasUniqueOffsets) ? curCharacter : (nameSplit[0] + '-' + nameSplit[1]));

							playAnim('danceRight');
						}

					case 'pixel':
						{
							animation.addByIndices('singUP', 'GF IDLE', [2], "", 24, false);
							animation.addByIndices('danceLeft', 'GF IDLE', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
							animation.addByIndices('danceRight', 'GF IDLE', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

							loadOffsetFile((hasUniqueOffsets) ? curCharacter : (nameSplit[0] + '-' + nameSplit[1]));

							playAnim('danceRight');

							setGraphicSize(Std.int(width * PlayState.daPixelZoom));
							updateHitbox();
							antialiasing = false;
						}
					case 'car':
						{
							animation.addByIndices('singUP', 'GF Dancing Beat Hair blowing CAR', [0], "", 24, false);
							animation.addByIndices('danceLeft', 'GF Dancing Beat Hair blowing CAR', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14],
								"", 24, false);
							animation.addByIndices('danceRight', 'GF Dancing Beat Hair blowing CAR',
								[15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);

							loadOffsetFile((hasUniqueOffsets) ? curCharacter : (nameSplit[0] + '-' + nameSplit[1]));

							playAnim('danceRight');
						}
				}
			}
		}

		if (curCharacter != 'gf-cow' && !(curCharacter == 'gf-whitty' && PlayState.SONG.song.toLowerCase() == 'Ballistic'))
			dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf') && curCharacter.toLowerCase().substr(curCharacter.length - 5) != 'death')
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	public function loadOffsetFile(character:String, library:String = 'shared')
	{
		if (PlayState.SONG != null && PlayState.SONG.song.toLowerCase() == 'guns short version')
			return;
		var offset:Array<String> = CoolUtil.coolTextFile(Paths.txt('images/characters/offsets/' + character + "Offsets", library));

		for (i in 0...offset.length)
		{
			var data:Array<String> = offset[i].split(' ');
			addOffset(data[0], Std.parseInt(data[1]), Std.parseInt(data[2]));
		}
	}

	override function update(elapsed:Float)
	{
		// trace(curCharacter);
		@:privateAccess
		if (!PlayState.inCutscene && PlayState.instance.songStarted)
		{
			if (PlayState.instance == null || PlayState.instance.currentEnemy == this)
			{
				if (animation.curAnim.name.startsWith('sing'))
					holdTimer += elapsed;

				var dadVar:Float = 4;

				if (curCharacter.startsWith('dad') || curCharacter == 'big-chungus')
					dadVar = 6.1;
				if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
				{
					// trace('dance');
					dance();
					holdTimer = 0;
				}
			}
			else
			{
				if (!debugMode)
				{
					if (animation.curAnim.name.startsWith('sing'))
					{
						holdTimer += elapsed;
					}
					else
						holdTimer = 0;

					if (animation.curAnim.name.endsWith('miss') && animation.curAnim.finished)
					{
						playAnim('idle', true, false, 10);
					}

					if (animation.curAnim.name == 'firstDeath' && animation.curAnim.finished)
					{
						playAnim('deathLoop');
					}
				}
			}
		}
		else
		{
			switch (curCharacter)
			{
				case 'psy' | 'tankman-homedepot':
					{
						if (animationNotes != null && animationSound != null)
						{
							if (0 < animationNotes.length && animationSound.time > animationNotes[0][0])
							{
								var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
								var num:Int = Math.floor(animationNotes[0][1]);
								var altAnim = (animationNotes[0][3]) ? '-alt' : '';
								num %= 4;
								playAnim("sing" + dataSuffix[num] + altAnim, true);
								animationNotes.shift();
							}
						}
					}
			}
		}

		if (curCharacter.startsWith('gf'))
			if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
				playAnim('danceRight');

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance(forced:Bool = false, altAnim:Bool = false)
	{
		if (!debugMode)
		{
			if (curCharacter.startsWith('gf'))
			{
				if (!animation.curAnim.name.startsWith('hair'))
				{
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				}
			}
			else
			{
				switch (biDirectional)
				{
					case true:
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					default:
						if (altAnim && animation.getByName('idle-alt') != null)
							playAnim('idle-alt', forced);
						else
							playAnim('idle', forced);
				}
			}
		}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		/*if (PlayState.instance.currentPlayer == this)
			trace((animation.curAnim != null) ? animation.curAnim.name : ""); */
		if (AnimName.endsWith('alt') && animation.getByName(AnimName) == null)
		{
			#if debug
			FlxG.log.warn(['Such alt animation doesnt exist: ' + AnimName]);
			#end
			AnimName = AnimName.split('-')[0];
		}

		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter.startsWith('gf'))
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}
}
