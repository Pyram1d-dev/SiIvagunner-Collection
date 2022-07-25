package;

import haxe.Exception;
import openfl.utils.AssetType;
import lime.utils.AssetType;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;

using StringTools;

typedef AnimationData = {
	name:String,
	identifier:String,
	indicies:Array<Int>,
	framerate:Int,
	looped:Bool
}

typedef CharacterData = {
	texturePath:String,
	usePackerAtlas:Bool,
	hasUniqueOffsets:Bool,
	biDirectional:Bool,
	hasTrail:Bool,
	scale:Int,
	positionOffset:Array<Int>,
	cameraOffset:Array<Int>,
	sizeOffset:Array<Int>,
	isPixel:Bool,
	animationData:Array<AnimationData>,
	flipX:Bool,
	characterColor:String,
	baseCharacter:String,
	toCopyFromBase:Array<String>,
	copyAllFromBase:Bool,
	dontCopy:Array<String>,
	overrideConflictingProperties:Bool,
	mergeProperties:Bool,
	icon:String
}

class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var baseCharacter:String = 'bf';
	public var animationNotes:Array<Dynamic> = [];
	public var animationSound:FlxSound;
	public var charColor:Null<FlxColor>;
	public var characterData:CharacterData;

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

		var tex:FlxAtlasFrames;

		trace(curCharacter);

		characterData = loadCharacterFromJSON(character);
		var baseCharacterData:CharacterData;

		if (characterData.baseCharacter != null)
			baseCharacter = characterData.baseCharacter;

		if (baseCharacter != character)
		{
			baseCharacterData = loadCharacterFromJSON(baseCharacter);

			if (characterData.toCopyFromBase != null || characterData.copyAllFromBase)
			{
				if (characterData.dontCopy == null)
					characterData.dontCopy = [];
				
				var toCopyTemp = [
					"usePackerAtlas",
					"biDirectional",
					"scale",
					"sizeOffset",
					"positionOffset",
					"cameraOffset",
					"isPixel",
					"animationData",
					"flipX",
					"characterColor"
				];
				if (!(characterData.toCopyFromBase != null && characterData.toCopyFromBase[0].toLowerCase().trim() == "all") && !characterData.copyAllFromBase)
					toCopyTemp = characterData.toCopyFromBase;

				for (str in characterData.dontCopy)
					if (toCopyTemp.contains(str))
						toCopyTemp.remove(str);
				
				// Reflect my beloved
				for (fieldName in toCopyTemp)
				{
					var fieldExists = Reflect.hasField(characterData, fieldName);
					var baseFieldExists = Reflect.hasField(baseCharacterData, fieldName);
					
					if (!baseFieldExists)
						continue;

					if (fieldExists)
					{
						if (!characterData.overrideConflictingProperties && !characterData.mergeProperties)
							continue;
						if (characterData.mergeProperties)
						{
							switch (fieldName)
							{
								case "animationData":
									var charAnims:Array<AnimationData> = cast Reflect.field(characterData, fieldName);
									var baseCharAnims:Array<AnimationData> = cast Reflect.field(baseCharacterData, fieldName);
									for (anim in baseCharAnims)
									{
										var alreadyExists:Bool = false;
										for (check in charAnims)
										{
											if (check.name == anim.name)
											{
												trace('${check.name} matches ${anim.name}! Skipping.');
												alreadyExists = true;
												break;
											}
										}
										if (alreadyExists)
											continue;
										charAnims.push(anim);
									}
									Reflect.setField(characterData, fieldName, charAnims);
								default:
									Reflect.setField(characterData, fieldName, Reflect.field(baseCharacterData, fieldName));
							}
							continue;
						}
					}

					Reflect.setField(characterData, fieldName, Reflect.field(baseCharacterData, fieldName));
				}
			}
		}

		hasUniqueOffsets = characterData.hasUniqueOffsets;

		biDirectional = characterData.biDirectional;
		antialiasing = characterData.isPixel ? false : FlxG.save.data.antialiasing;

		if (characterData.characterColor != null)
			charColor = Std.parseInt(characterData.characterColor);

		if (!characterData.usePackerAtlas)
		{
			#if sys
			var charName = characterData.texturePath.split('/')[characterData.texturePath.split('/').length - 1];
			if (PlayState.instance != null
				&& PlayState.instance.songCache != null
				&& PlayState.instance.songCache.cachedGraphics.exists(charName))
			{
				trace('Loaded $charName from the cache!');
				tex = PlayState.instance.songCache.fromSparrow(charName, 'characters/${characterData.texturePath}', "shared");
			}
			else
				tex = Paths.getSparrowAtlas(characterData.texturePath, 'shared', true);
			#else
			tex = Paths.getSparrowAtlas(characterData.texturePath, 'shared', true);
			#end
		}
		else
			tex = Paths.getPackerAtlas(characterData.texturePath, 'shared', true);
		frames = tex;
		for (data in characterData.animationData)
		{
			if (data.indicies != null)
				animation.addByIndices(data.name, data.identifier, data.indicies, "", data.framerate, data.looped);
			else
				animation.addByPrefix(data.name, data.identifier, data.framerate, data.looped);
		}

		if (characterData.scale != 1)
		{
			setGraphicSize(Std.int(width * characterData.scale));
			updateHitbox();
		}

		if (characterData.sizeOffset != null)
		{
			width += characterData.sizeOffset[0];
			height += characterData.sizeOffset[1];
		}

		flipX = characterData.flipX;

		if (characterData.hasUniqueOffsets)
			loadOffsetFile(character);
		else
			loadOffsetFile(baseCharacter);

		playAnim(characterData.animationData[0].name);
		
		if (PlayState.instance != null && PlayState.SONG.song.toLowerCase().startsWith('ballistic') && curCharacter.startsWith('gf'))
			playAnim('scared');

		if (charColor == null)
			charColor = (character.startsWith('bf')) ? 0xFF0097C4 : 0xFFFA0000;
		
		if (curCharacter != 'gf-cow'
			&& !(curCharacter == 'gf-whitty' && PlayState.SONG != null && PlayState.SONG.song.toLowerCase().startsWith('ballistic')))
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

	public static function loadCharacterFromJSON(character:String):CharacterData
	{
		if (!Assets.exists(Paths.json("characters/" + character, "shared"), TEXT))
			return null;
		var rawJson = Assets.getText(Paths.json("characters/" + character, "shared")).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		return cast Json.parse(rawJson);
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
		if (PlayState.instance == null || (!PlayState.inCutscene && PlayState.instance.songStarted))
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

		if (PlayState.instance != null && curCharacter == 'bf-christmas-aloe'
			&& (FlxG.save.data.playEnemy ? PlayState.instance.health > 1 : PlayState.instance.health < 1)
			&& !AnimName.endsWith('alt')
			&& !AnimName.endsWith('miss') && (AnimName.startsWith('sing') || AnimName.startsWith('idle')))
		{
			AnimName += '-fard';
		}

		if (animation.curAnim != null
			&& AnimName == "idle"
			&& (animation.curAnim.name.startsWith('pog') || animation.curAnim.name.startsWith('bruh')))
			return;

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
