package;

import Character.CharacterData;
import LuaClass;
import Note.MineData;
import Note.NoteSkinData;
import Replay.Ana;
import Replay.Analysis;
import Section.SwagSection;
import Song.SwagSong;
import Stage.StageData;
import StoryMenuState;
import Type.ValueType;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxGlitchEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxTimer;
import haxe.Exception;
import haxe.Json;
import lime.utils.Assets;
import openfl.Lib;
import openfl.events.KeyboardEvent;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.ui.Keyboard;

using StringTools;

#if sys
import smTools.SMFile;
import sys.io.File;
#end
#if cpp
import webm.WebmPlayer;
#end
#if cpp
import Discord.DiscordClient;
import Sys;
import sys.FileSystem;
#end

class PlayState extends MusicBeatState
{
	public static var instance:PlayState = null;

	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var storyWeek:Dynamic = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyLength:Int = 0;
	public static var storyDifficulty:Int = 1;
	public static var weekSong:Int = 0;
	public static var weekScore:Int = 0;
	public static var shits:Int = 0;
	public static var bads:Int = 0;
	public static var goods:Int = 0;
	public static var sicks:Int = 0;

	public var rootSong:String;

	public var noteSkinData:NoteSkinData = null;

	public static var songPosBG:FlxSprite;

	public var visibleCombos:Array<FlxSprite> = [];

	public static var songPosBar:FlxBar;

	public static var rep:Replay;
	public static var loadRep:Bool = false;
	public static var inResults:Bool = false;

	public var inOptions = false;
	public var resetPauseMenu = false;

	public static var noteBools:Array<Bool> = [false, false, false, false];

	var songLength:Float = 0;
	var kadeEngineWatermark:FlxText;

	var skipIntroText:FlxText;
	var skipTime:Float;

	#if cpp
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	private var vocals:FlxSound;

	public static var isSM:Bool = false;
	#if sys
	public static var sm:SMFile;
	public static var pathToSm:String;
	#end

	public var originalX:Float;

	public static var dad(default, set):Character;
	public static var gf:Character;
	public static var boyfriend(default, set):Boyfriend;

	public var currentPlayer:Character;
	public var currentEnemy:Character;

	var blueBallsLMAO:Character;

	public var notes:FlxTypedGroup<Note>;

	private var unspawnNotes:Array<Note> = [];

	public var strumLine:FlxSprite;

	private var underlays:Array<FlxSprite> = [];

	private var curSection:Int = 0;

	private var camFollow:FlxObject;

	private static var prevCamFollow:FlxObject;

	public static var strumLineNotes:FlxTypedGroup<StaticArrow> = null;
	public static var playerStrums:FlxTypedGroup<StaticArrow> = null;
	public static var cpuStrums:FlxTypedGroup<StaticArrow> = null;

	public var camZooming:Bool = false;

	private var curSong:String = "";

	private var gfSpeed:Int = 1;

	public var health:Float = 1; // making public because sethealth doesnt work without it

	private var combo:Int = 0;

	public static var misses:Int = 0;
	public static var campaignMisses:Int = 0;
	public static var campaignSicks:Int = 0;
	public static var campaignGoods:Int = 0;
	public static var campaignBads:Int = 0;
	public static var campaignShits:Int = 0;

	public var accuracy:Float = 0.00;

	private var accuracyDefault:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalNotesHitDefault:Float = 0;
	private var totalPlayed:Int = 0;
	private var ss:Bool = false;

	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;
	private var songPositionBar:Float = 0;

	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	public var iconP1:HealthIcon; // making these public again because i may be stupid
	public var iconP2:HealthIcon; // what could go wrong?
	public var camHUD:FlxCamera;
	public var camSustains:FlxCamera;
	public var camNotes:FlxCamera;

	private var camGame:FlxCamera;

	public var cannotDie = false;

	public static var offsetTesting:Bool = false;

	public var isSMFile:Bool = false;

	var notesHitArray:Array<Date> = [];
	var currentFrames:Int = 0;
	var idleToBeat:Bool = true; // change if bf and dad would idle to the beat of the song
	var idleBeat:Int = 2; // how frequently bf and dad would play their idle animation(1 - every beat, 2 - every 2 beats and so on)

	public var dialogue:Array<String> = ['dad:blah blah blah', 'bf:coolswag'];

	public var trainSound:FlxSound;

	public static var fromDeath:Bool = false;

	var noteHitSound:FlxSound;

	var restarted:Bool = false;

	var timeRemaining:FlxText;

	public var stage:StageData;

	var fc:Bool = true;

	public var wiggleShit:WiggleEffect = new WiggleEffect();

	var rumble:FlxSound;

	var talking:Bool = true;

	public var songScore:Int = 0;

	var songScoreDef:Int = 0;
	var scoreTxt:FlxText;
	var replayTxt:FlxText;

	public static var campaignScore:Int = 0;

	public var targetCamZoom:Float = 1.05;

	public static var daPixelZoom:Float = 6;

	public static var theFunne:Bool = true;

	public static var inCutscene:Bool = false;

	var usedTimeTravel:Bool = false;

	public static var repPresses:Int = 0;
	public static var repReleases:Int = 0;

	public static var timeCurrently:Float = 0;
	public static var timeCurrentlyR:Float = 0;

	// Will fire once to prevent debug spam messages and broken animations
	private var triggeredAlready:Bool = false;

	// Will decide if she's even allowed to headbang at all depending on the song
	private var allowedToHeadbang:Bool = false;

	// Per song additive offset
	public static var songOffset:Float = 0;

	// BotPlay text
	private var botPlayState:FlxText;
	// Replay shit
	private var saveNotes:Array<Dynamic> = [];
	private var saveJudge:Array<String> = [];
	private var replayAna:Analysis = new Analysis(); // replay analysis

	public static var highestCombo:Int = 0;

	public var executeModchart = false;

	// Animation common suffixes
	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];
	private var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];

	public static var startTime = 0.0;

	// I'm going green
	var splatFXGroup:FlxTypedSpriteGroup<NoteSplat> = new FlxTypedSpriteGroup<NoteSplat>();
	var missFXGroup:FlxTypedSpriteGroup<NoteMiss> = new FlxTypedSpriteGroup<NoteMiss>();

	// Not used too often but still useful
	#if sys
	public var songCache:GameCache;
	#end

	// API stuff

	public function addObject(object:FlxBasic)
	{
		add(object);
	}

	public function removeObject(object:FlxBasic)
	{
		remove(object);
	}

	public static function set_dad(newDad:Character):Character
	{
		if (instance != null)
		{
			if (instance.currentPlayer == dad)
			{
				instance.currentPlayer = newDad;
				trace('Setting PLAYER to ${newDad.curCharacter}');
			}
			else if (instance.currentEnemy == dad)
			{
				instance.currentEnemy = newDad;
				trace('Setting ENEMY to ${newDad.curCharacter}');
			}
		}
		return dad = newDad;
	}

	public static function set_boyfriend(newBoyfriend:Boyfriend):Boyfriend
	{
		if (instance != null)
		{
			if (instance.currentPlayer == boyfriend)
			{
				instance.currentPlayer = newBoyfriend;
				trace('Setting PLAYER to ${newBoyfriend.curCharacter}');
			}
			else if (instance.currentEnemy == boyfriend)
			{
				instance.currentEnemy = newBoyfriend;
				trace('Setting ENEMY to ${newBoyfriend.curCharacter}');
			}
		}
		return boyfriend = cast newBoyfriend;
	}

	public function addAt(Object:FlxBasic, index:Int):FlxBasic
	{
		if (Object == null)
		{
			FlxG.log.warn("Cannot add a `null` object to a FlxGroup.");
			return null;
		}

		// Don't bother adding an object twice.
		if (members.indexOf(Object) >= 0)
			return Object;

		// If the group is full, return the Object
		if (maxSize > 0 && length >= maxSize)
			return Object;

		var push = false;

		if (index >= members.length || index < 0)
			push = true;

		// If we made it this far, we need to add the object to the group.
		if (push)
			members.push(Object);
		else
			members.insert(index, Object);
		length++;

		if (_memberAdded != null)
			_memberAdded.dispatch(Object);

		return Object;
	}

	public function addBehind(Object:FlxBasic, behind:FlxBasic):FlxBasic
	{
		if (!members.contains(behind))
		{
			FlxG.log.warn('Object is not added!');
			return null;
		}
		if (Object == null)
		{
			FlxG.log.warn("Cannot add a `null` object to a FlxGroup.");
			return null;
		}

		// Don't bother adding an object twice.
		if (members.indexOf(Object) >= 0)
			return Object;

		// If the group is full, return the Object
		if (maxSize > 0 && length >= maxSize)
			return Object;

		// If we made it this far, we need to add the object to the group.
		members.insert(members.indexOf(behind), Object);
		length++;

		if (_memberAdded != null)
			_memberAdded.dispatch(Object);

		return Object;
	}

	function createHitSound()
	{
		if (noteHitSound != null)
		{
			FlxG.sound.list.remove(noteHitSound);
			noteHitSound.destroy();
			noteHitSound = null;
		}
		if (FlxG.save.data.hitSound != null)
		{
			noteHitSound = new FlxSound().loadEmbedded(Paths.sound('noteHit/${FlxG.save.data.hitSound}', "shared"));
			noteHitSound.volume = 0.9;
			FlxG.sound.list.add(noteHitSound);
		}
	}

	override public function create()
	{
		FlxG.mouse.visible = false;
		instance = this;
		restarted = fromDeath;
		fromDeath = false;
		createHitSound();

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(800);

		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		sicks = 0;
		bads = 0;
		shits = 0;
		goods = 0;

		misses = 0;

		highestCombo = 0;
		repPresses = 0;
		repReleases = 0;
		inResults = false;

		PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
		PlayStateChangeables.safeFrames = FlxG.save.data.frames;
		PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
		PlayStateChangeables.botPlay = FlxG.save.data.botplay;
		PlayStateChangeables.usedBotPlay = PlayStateChangeables.botPlay;
		PlayStateChangeables.Optimize = FlxG.save.data.optimize;
		PlayStateChangeables.zoom = FlxG.save.data.zoom;

		// pre lowercasing the song name (create)
		var songLowercase = CoolUtil.lowerCaseSong(PlayState.SONG.song);

		removedVideo = false;

		#if cpp
		if (!PlayStateChangeables.Optimize)
		{
			executeModchart = FileSystem.exists(Paths.lua("SONGS/" + songLowercase + "/lua/modchart"));
			if (executeModchart)
				PlayStateChangeables.Optimize = false;
		}
		#end
		#if !cpp
		executeModchart = false; // FORCE disable for non cpp targets
		#end

		trace('Mod chart: ' + executeModchart + " - " + Paths.lua("SONGS/" + songLowercase + "/lua/modchart"));

		#if cpp
		// Making difficulty text for Discord Rich Presence.
		storyDifficultyText = CoolUtil.difficultyFromInt(storyDifficulty);

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;

		curStage = "";

		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
		camSustains = new FlxCamera();
		camSustains.bgColor.alpha = 0;
		camNotes = new FlxCamera();
		camNotes.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD);
		FlxG.cameras.add(camSustains);
		FlxG.cameras.add(camNotes);

		camHUD.zoom = PlayStateChangeables.zoom;

		FlxCamera.defaultCameras = [camGame];

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial', 'tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		if (SONG.eventObjects == null)
		{
			SONG.eventObjects = [new Song.Event("Init BPM", 0, SONG.bpm, "BPM Change")];
		}

		TimingStruct.clearTimings();

		var currentIndex = 0;
		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change")
			{
				var beat:Float = i.position;

				var endBeat:Float = Math.POSITIVE_INFINITY;

				TimingStruct.addTiming(beat, i.value, endBeat, 0); // offset in this case = start time since we don't have a offset

				if (currentIndex != 0)
				{
					var data = TimingStruct.AllTimings[currentIndex - 1];
					data.endBeat = beat;
					data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
					TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
				}

				currentIndex++;
			}
		}

		trace('INFORMATION ABOUT WHAT U PLAYIN WIT:\nFRAMES: ' + PlayStateChangeables.safeFrames + '\nZONE: ' + Conductor.safeZoneOffset + '\nTS: '
			+ Conductor.timeScale + '\nBotPlay : ' + PlayStateChangeables.botPlay);

		var rootExceptions = ['lo-fight', 'winter-horrorland', 'high-school-conflict'];

		rootSong = (!rootExceptions.contains(songLowercase)) ? songLowercase.split('-')[0] : songLowercase;

		for (i in rootExceptions)
			if (songLowercase.startsWith(i))
				rootSong = i;

		var songsWithDialogue = [
			'senpai',
			'roses',
			'thorns',
			'lo-fight',
			'overhead',
			'ballistic',
			'wocky',
			'beathoven',
			'high-school-conflict'
		];
		var ignoreThisShit = ['ballistic-beta-mix'];

		if (Assets.exists(Paths.txt('data/SONGS/' + songLowercase + '/dialogue'), TEXT))
		{
			// if the song has dialogue, so we don't accidentally try to load a nonexistant file and crash the game
			dialogue = CoolUtil.coolTextFile(Paths.txt('data/SONGS/' + songLowercase + '/dialogue'));
		}

		// defaults if no stage was found in chart
		var stageCheck:String = 'stage';

		if (SONG.stage == null)
		{
			switch (storyWeek)
			{
				case 2:
					stageCheck = 'halloween';
				case 3:
					stageCheck = 'philly';
				case 4:
					stageCheck = 'limo';
				case 5:
					if (rootSong == 'winter-horrorland')
						stageCheck = 'mallEvil';
					else
						stageCheck = 'mall';
				case 6:
					if (songLowercase == 'thorns')
						stageCheck = 'schoolEvil';
					else
						stageCheck = 'school';
				// i should check if its stage (but this is when none is found in chart anyway)
				case 7:
					stageCheck = 'militaryzone';
			}
		}
		else
		{
			stageCheck = SONG.stage;
		}

		// defaults if no gf was found in chart
		var gfCheck:String = 'gf';

		if (SONG.gfVersion == null)
		{
			switch (storyWeek)
			{
				case 4:
					gfCheck = 'gf-car';
				case 5:
					gfCheck = 'gf-christmas';
				case 6:
					gfCheck = 'gf-pixel';
				case 7:
					gfCheck = 'gf-tankmen';
			}
		}
		else
		{
			gfCheck = SONG.gfVersion;
		}

		#if sys
		songCache = new GameCache();
		if (songLowercase == 'philly' && gfCheck == 'gf-cow')
		{
			gfCheck = 'gf-cowidle';
			songCache.loadFrames([
				'gf-cow' => ['characters/GFs/GF_cow', 'shared'],
				'gf-cowidle' => ['characters/GFs/GF_cowidle', 'shared']
			]);
		}
		if (songLowercase == 'winter-horrorland-short-version')
			songCache.loadFrames(['BEANED' => ['characters/Monsters/monsterChristmas_bean', 'shared']]);
		cacheDeathVariant(SONG.player1);
		#end

		var curGf:String = gfCheck;

		if ((SONG.player1 == 'bf' || SONG.player1 == 'bf-06' || SONG.player1 == 'bf-grandpa')
			&& curGf == 'gf'
			&& SONG.player2 != 'gf'
			&& FlxG.random.bool(10)) // Oh shit RNG
		{
			if (FlxG.random.bool(50))
			{
				SONG.player1 = 'bf-samsung';
				SONG.gfVersion = 'gf-samsung';
			}
			else
			{
				SONG.player1 = 'bf-quote';
				SONG.gfVersion = 'gf-curly';
			}
			curGf = SONG.gfVersion;
		}

		gf = new Character(400, 130, curGf);
		gf.scrollFactor.set(0.9, 0.9);
		gf.visible = SONG.song != "Bad Piggies";
		dad = new Character(100, 100, (SONG.player2 == 'gf') ? curGf : SONG.player2);
		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		trace('curGf = $curGf');

		var exceptions:Array<String> = ['monster-christmas', 'mario-pixel', 'luigi-pixel'];

		var exceptionCheck:Bool = false;

		var vibeCheck:String = SONG.player2;

		if (exceptions.contains(SONG.player2))
		{
			exceptionCheck = true;
			for (i in exceptions)
			{
				if (SONG.player2.startsWith(i))
				{
					vibeCheck = i;
					break;
				}
			}
		}

		vibeCheck = (!exceptionCheck) ? dad.baseCharacter.split('-')[0] : vibeCheck;

		dad.visible = (SONG.song != 'Fresh Itch io Build' && SONG.song != 'Test' && SONG.song != 'Bad Piggies');
		switch (vibeCheck)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode || FlxG.save.data.freeplayCutscenes)
				{
					// camPos.x += 600;
					tweenCamIn();
				}
		}
		boyfriend = new Boyfriend(770, 450, SONG.player1);

		for (char in [dad, gf, boyfriend])
		{
			if (char.characterData.positionOffset != null)
			{
				char.x += char.characterData.positionOffset[0];
				char.y += char.characterData.positionOffset[1];
			}
			if (char.characterData.hasTrail)
			{
				var trail = new FlxTrail(char, null, 4, 24, 0.3, 0.069);
				add(trail);
			}
		}

		if (songLowercase == 'dadbattle')
		{
			blueBallsLMAO = new Boyfriend(770, 450, SONG.player1);
			blueBallsLMAO.x = boyfriend.x;
			blueBallsLMAO.y = boyfriend.y;
		}

		setupStage(stageCheck);

		if (dad.characterData.cameraOffset == null)
			camPos.set(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
		else
			camPos.set(dad.getMidpoint().x + dad.characterData.cameraOffset[0], dad.getMidpoint().y + dad.characterData.cameraOffset[1]);

		if (loadRep)
		{
			FlxG.watch.addQuick('rep rpesses', repPresses);
			FlxG.watch.addQuick('rep releases', repReleases);
			// FlxG.watch.addQuick('Queued',inputsQueued);
			PlayStateChangeables.useDownscroll = rep.replay.isDownscroll;
			PlayStateChangeables.safeFrames = rep.replay.sf;
			PlayStateChangeables.botPlay = true;
		}
		trace('uh ' + PlayStateChangeables.safeFrames);
		trace("SF CALC: " + Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
		Conductor.songPosition = -5000;
		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		strumLine.scrollFactor.set();
		if (PlayStateChangeables.useDownscroll)
			strumLine.y = FlxG.height - 165;
		strumLineNotes = new FlxTypedGroup<StaticArrow>();
		playerStrums = new FlxTypedGroup<StaticArrow>();
		cpuStrums = new FlxTypedGroup<StaticArrow>();

		var noteTypeCheck:String = 'normal';

		if (SONG.noteStyle == null)
		{
			switch (storyWeek)
			{
				case 6:
					SONG.noteStyle = 'pixel';
					noteTypeCheck = 'pixel';
			}
		}
		else
		{
			noteTypeCheck = SONG.noteStyle;
		}

		var rawJson = Assets.getText(Paths.file("images/noteskins/skinData.json", "shared", TEXT)).trim();

		while (!rawJson.endsWith("}"))
			rawJson = rawJson.substr(0, rawJson.length - 1);

		var rawNoteSkinData:Array<NoteSkinData> = Json.parse(rawJson).skins;

		for (i in rawNoteSkinData)
		{
			if (i.name == noteTypeCheck.trim())
			{
				noteSkinData = i;
				break;
			}
		}

		if (noteSkinData == null)
			noteSkinData = rawNoteSkinData[0];

		if (noteSkinData.skinOverride != null)
			noteSkinData.name = noteSkinData.skinOverride;

		if (noteSkinData.mineSkin != null)
		{
			var rawJson = Assets.getText(Paths.file("images/mines/mineData.json", "shared", TEXT)).trim();

			while (!rawJson.endsWith("}"))
				rawJson = rawJson.substr(0, rawJson.length - 1);

			var rawMineData:Array<MineData> = cast Json.parse(rawJson).skins;

			for (i in rawMineData)
			{
				if (i.name == noteSkinData.mineSkin)
				{
					noteSkinData.mineData = i;
					break;
				}
			}
		}

		if (!FlxG.save.data.playEnemy)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		else
		{
			generateStaticArrows(1);
			generateStaticArrows(0);
		}

		if (songLowercase == 'test')
		{
			cpuStrums.visible = false;
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				spr.visible = false;
			});
		}
		for (box in underlays)
		{
			add(box);
		}
		add(strumLineNotes);
		// startCountdown();
		if (SONG.song == null)
			trace('song is null???');
		else
			trace('song looks gucci');

		generateSong(SONG.song);

		#if cpp
		if (executeModchart)
		{
			luaModchart = ModchartState.createModchartState(isStoryMode);
			luaModchart.executeState('start', [songLowercase]);
			new LuaCamera(camGame, "camGame").Register(ModchartState.lua);
			new LuaCamera(camHUD, "camHUD").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camSustains").Register(ModchartState.lua);
			new LuaCamera(camSustains, "camNotes").Register(ModchartState.lua);
			new LuaCharacter(dad, "dad").Register(ModchartState.lua);
			new LuaCharacter(gf, "gf").Register(ModchartState.lua);
			new LuaCharacter(boyfriend, "boyfriend").Register(ModchartState.lua);
		}
		#end

		if (startTime != 0)
		{
			var toBeRemoved = [];
			for (i in 0...notes.members.length)
			{
				var dunceNote:Note = notes.members[i];

				if (dunceNote.strumTime - startTime <= 0)
					toBeRemoved.push(dunceNote);
				else
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (dunceNote.mustPress)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								+
								0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- dunceNote.noteYOff;
						else
							dunceNote.y = (cpuStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								+
								0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- dunceNote.noteYOff;
					}
					else
					{
						if (dunceNote.mustPress)
							dunceNote.y = (playerStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ dunceNote.noteYOff;
						else
							dunceNote.y = (cpuStrums.members[Math.floor(Math.abs(dunceNote.noteData))].y
								- 0.45 * (startTime - dunceNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ dunceNote.noteYOff;
					}
				}
			}
			for (i in toBeRemoved)
				notes.members.remove(i);
		}
		trace('generated');
		// add(strumLine);
		camFollow = new FlxObject(0, 0, 1, 1);
		camFollow.setPosition(camPos.x, camPos.y);
		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}
		add(camFollow);
		FlxG.camera.follow(camFollow, LOCKON, 0.04 * (30 / (cast(Lib.current.getChildAt(0), Main)).getFPS()));
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = targetCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());
		if (songLowercase == "high-in-game-version")
			FlxG.camera.focusOn(FlxPoint.get(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100));
		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);
		FlxG.fixedTimestep = false;
		createHudObjects();
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;
		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;
		trace('starting');
		if ((isStoryMode || FlxG.save.data.freeplayCutscenes) && !restarted && !PlayStateChangeables.Optimize)
		{
			var doof:DialogueBox = null;
			if (songsWithDialogue.contains(rootSong) && !ignoreThisShit.contains(songLowercase))
			{
				doof = new DialogueBox(false, dialogue);
				doof.scrollFactor.set();
				doof.finishThing = startCountdown;
				doof.cameras = [camHUD];
			}
			if (storyWeek == "fanchannels" && storyLength - storyPlaylist.length == 0)
				fanchannelIntro(doof, songLowercase);
			else
				checkCutscene(doof, songLowercase);
		}
		else
		{
			switch (curSong.toLowerCase().split(" ")[0])
			{
				case 'ballistic':
					gf.playAnim('scared', true);
					startCountdown();
				default:
					startCountdown();
			}
		}
		if (!loadRep)
			rep = new Replay("na");
		FlxG.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.addEventListener(KeyboardEvent.KEY_UP, releaseInput);
		trace(storyWeek);
		super.create();
	}

	public function cacheDeathVariant(char:String)
	{
		#if cpp
		var p1DeathSprite = GameOverSubstate.getDeathVariant(char);
		if (p1DeathSprite != char)
		{
			var p1DeathShit:CharacterData = Character.loadCharacterFromJSON(char);
			var texName = p1DeathShit.texturePath.split('/')[p1DeathShit.texturePath.split('/').length - 1];
			songCache.loadFrames([texName => ['characters/${p1DeathShit.texturePath}', 'shared']]);
		}
		#end
	}

	public function removeStage()
	{
		for (i in stage.toAdd)
			remove(i);
		for (arr in stage.layInFront)
			for (i in arr)
				remove(i);
		for (i in stage.swagBacks)
			remove(i);
		for (i in stage.distractions)
			remove(i);
		for (i in stage.swagDancers)
			remove(i);
		for (i in stage.swagDancerGroup)
			remove(i);
		for (char => pos in [boyfriend => [770, 450], gf => [400, 130], dad => [100, 100]])
			char.setPosition(pos[0], pos[1]);

		for (char in [dad, gf, boyfriend])
		{
			if (char.characterData.positionOffset != null)
			{
				char.x += char.characterData.positionOffset[0];
				char.y += char.characterData.positionOffset[1];
			}
		}
	}

	public function setupStage(stageCheck:String)
	{
		stage = new Stage(stageCheck, rootSong, CoolUtil.lowerCaseSong(PlayState.SONG.song), daPixelZoom).data; // sex
		if (!PlayStateChangeables.Optimize)
		{
			for (i in stage.toAdd)
				add(i);
			for (index => array in stage.layInFront)
			{
				switch (index)
				{
					case 0:
						add(gf);
						gf.scrollFactor.set(0.95, 0.95);
						for (bg in array)
							add(bg);
					case 1:
						add(dad);
						for (bg in array)
							add(bg);
					case 2:
						add(boyfriend);
						for (bg in array)
							add(bg);
				}
			}
			if (!FlxG.save.data.distractions)
				for (i in stage.distractions)
					remove(i);
			targetCamZoom = stage.camZoom;
		}

		// REPOSITIONING PER STAGE

		for (index => data in stage.charPositions)
		{
			switch (index)
			{
				case 0:
					boyfriend.x += data[0];
					boyfriend.y += data[1];
				case 1:
					gf.x += data[0];
					gf.y += data[1];
				case 2:
					dad.x += data[0];
					dad.y += data[1];
			}
		}
	}

	function checkCutscene(doof:DialogueBox, songLowercase:String)
	{
		switch (songLowercase)
		{
			case 'fresh':
				OHGODNO();
			case 'philly-nice-in-game-version':
				ladyIntro();
			case 'ballistic':
				whittyAnimation(doof);
			default:
				switch (rootSong)
				{
					case "winter-horrorland":
						var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
						blackScreen.screenCenter();
						add(blackScreen);
						blackScreen.scrollFactor.set();
						camHUD.visible = false;
						new FlxTimer().start(0.1, function(tmr:FlxTimer)
						{
							remove(blackScreen);
							camZooming = false;
							inCutscene = true;
							FlxG.sound.play(Paths.sound('Lights_Turn_On'));
							camFollow.x = 400;
							camFollow.y = -2050;
							FlxG.camera.focusOn(camFollow.getPosition());
							FlxG.camera.zoom = 1.5;
							new FlxTimer().start(0.8, function(tmr:FlxTimer)
							{
								// inCutscene = false;
								camHUD.visible = true;
								remove(blackScreen);
								FlxTween.tween(FlxG.camera, {zoom: targetCamZoom}, 2.5, {
									ease: FlxEase.quadInOut,
									onComplete: function(twn:FlxTween)
									{
										var offsetX = stage.stageCamOffsets[0][0];
										var offsetY = stage.stageCamOffsets[0][1];
										if (boyfriend.characterData.cameraOffset != null)
										{
											offsetX += boyfriend.characterData.cameraOffset[0];
											offsetY += boyfriend.characterData.cameraOffset[1];
										}
										camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);
										inCutscene = false;
										camZooming = true;
										startCountdown();
									}
								});
							});
						});
					case 'wocky' | 'beathoven':
						kapiIntro(doof);
					case 'senpai' | 'thorns' | 'high-school-conflict':
						schoolIntro(doof);
					case 'roses':
						FlxG.sound.play(Paths.sound('ANGRY'));
						schoolIntro(doof);
					case 'lo-fight' | 'overhead':
						whittyAnimation(doof);
					case 'ugh' | 'guns':
						tankmanIntro();
					default:
						startCountdown();
				}
		}
	}

	function fanchannelIntro(doof:DialogueBox, songLowercase:String)
	{
		var blacc = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blacc.cameras = [camGame];
		blacc.scrollFactor.set();
		blacc.updateHitbox();
		camZooming = false;
		camHUD.visible = false;
		inCutscene = true;
		add(blacc);
		var info:FlxText = new FlxText(0, 0, Math.floor(FlxG.width * 0.95),
			"This week consists of rips produced by the fan channels \"Nafun\" and \"YoshiGunner.\"\n\nPlease support their channels!\n(They can be found on the credits screen)",
			28);
		info.font = Paths.font("vcr.ttf");
		info.antialiasing = FlxG.save.data.antialiasing;
		info.autoSize = false;
		info.alignment = CENTER;
		info.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
		info.updateHitbox();
		info.screenCenter();
		info.scrollFactor.set();
		add(info);
		new FlxTimer().start(4, function(tmr:FlxTimer)
		{
			FlxTween.tween(blacc, {alpha: 0}, 2, {
				ease: FlxEase.sineIn,
				onUpdate: function(twn:FlxTween)
				{
					info.alpha = blacc.alpha;
				},
				onComplete: function(twn:FlxTween)
				{
					blacc.destroy();
					info.destroy();
					camHUD.visible = true;
					checkCutscene(doof, songLowercase);
				}
			});
		});
	}

	function ladyIntro()
	{
		var blacc = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blacc.cameras = [camGame];
		blacc.scrollFactor.set();
		blacc.updateHitbox();
		var ladyFinish = function()
		{
			inCutscene = false;
			FlxTween.tween(blacc, {alpha: 0}, 1.5, {
				onComplete: function(twn:FlxTween)
				{
					remove(blacc);
					camHUD.visible = true;
					startCountdown();
				}
			});
		}
		#if cpp
		camZooming = false;
		camHUD.visible = false;
		inCutscene = true;
		add(blacc);
		var video:MP4Handler = new MP4Handler();
		video.finishCallback = ladyFinish;
		video.playMP4(Paths.video('phillyCutscene'));
		#else
			ladyFinish();
		#end
	}

	function OHGODNO()
	{
		var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
		blackScreen.screenCenter(XY);
		add(blackScreen);
		blackScreen.scrollFactor.set();
		camHUD.visible = false;
		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			remove(blackScreen);
			camZooming = false;
			inCutscene = true;
			FlxG.sound.play(Paths.sound('vineboom', 'week1'));
			FlxG.sound.play(Paths.sound('ohmygod', 'week1'), 0.8);
			FlxG.sound.play(Paths.sound('Lights_Turn_On'));
			camFollow.setPosition(dad.getMidpoint().x, dad.getMidpoint().y - 100);
			FlxG.camera.focusOn(camFollow.getPosition());
			FlxG.camera.zoom = 2.2;
			new FlxTimer().start(0.5, function(tmr:FlxTimer)
			{
				FlxG.sound.play(Paths.sound('SUS', 'week1'));
				camHUD.visible = true;
				remove(blackScreen);
				FlxTween.tween(FlxG.camera, {zoom: targetCamZoom}, 4, {
					ease: FlxEase.quadInOut,
					onComplete: function(twn:FlxTween)
					{
						inCutscene = false;
						camZooming = true;
						startCountdown();
					}
				});
			});
		});
	}

	function createHudObjects(updatePos:Bool = false)
	{
		if (!updatePos) // I dont wanna talk about this code :(   (Jarvis, insert spongebob crying image with vine boom sound effect bass boosted)
		{
			songPosBG = new FlxSprite(0, 20).makeGraphic(400, 20, FlxColor.BLACK);
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBG.screenCenter(X);
			songPosBG.scrollFactor.set();
			add(songPosBG);
			songPosBar = new FlxBar(songPosBG.x + 4, songPosBG.y + 4, LEFT_TO_RIGHT, Std.int(songPosBG.width - 8), Std.int(songPosBG.height - 8), this,
				'songPositionBar', 0, songLength);
			songPosBar.scrollFactor.set();
			songPosBar.createFilledBar(FlxColor.BLACK, FlxColor.WHITE);
			add(songPosBar);
			var remainingSeconds = (FlxG.sound.music.length - Conductor.songPosition) / 1000;
			var remainingMinutes = Math.floor(remainingSeconds / 60);
			remainingSeconds = Math.floor(Math.max(remainingSeconds % 60, 0));
			timeRemaining = new FlxText(songPosBG.x
				+ (songPosBG.width * 0.47), songPosBG.y
				+ (songPosBG.height / 2), 0,
				Math.max(remainingMinutes, 0)
				+ ":"
				+ (remainingSeconds < 10 ? "0" : "")
				+ remainingSeconds);

			// if (PlayStateChangeables.useDownscroll)
			// 	timeRemaining.y -= 3;
			timeRemaining.setFormat(Paths.font("vcr.ttf"), 28, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			timeRemaining.offset.set(timeRemaining.width / 2, timeRemaining.height / 2);
			timeRemaining.scrollFactor.set();
			add(timeRemaining);
			timeRemaining.cameras = [camHUD];
			songPosBG.visible = FlxG.save.data.songPosition;
			songPosBar.visible = FlxG.save.data.songPosition;
			timeRemaining.visible = FlxG.save.data.songPosition;
			healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
			if (PlayStateChangeables.useDownscroll)
				healthBarBG.y = 50;
			healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			add(healthBarBG);
			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, (FlxG.save.data.playEnemy ? LEFT_TO_RIGHT : RIGHT_TO_LEFT),
				Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
			healthBar.scrollFactor.set();

			var HPcolors = healthBarColors();
			var bfColor:FlxColor = HPcolors[0];
			var dadColor:FlxColor = HPcolors[1];

			if (!FlxG.save.data.playEnemy || !FlxG.save.data.color)
				healthBar.createFilledBar(dadColor, bfColor);
			else
				healthBar.createFilledBar(bfColor, dadColor);
			// healthBar
			add(healthBar);
			// Add Kade Engine watermark
			var difftext = CoolUtil.difficultyFromInt(storyDifficulty);
			if (difftext.toLowerCase() == "extra")
				if (SONG.extraDiffDisplay != null)
					difftext = SONG.extraDiffDisplay;
			kadeEngineWatermark = new FlxText(4, healthBarBG.y + 50, 0,
				SONG.song + " - " + difftext + (Main.watermarks ? " | KE " + MainMenuState.kadeEngineVer : ""), 16);
			kadeEngineWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			kadeEngineWatermark.scrollFactor.set();
			add(kadeEngineWatermark);
			if (PlayStateChangeables.useDownscroll)
				kadeEngineWatermark.y = FlxG.height * 0.9 + 45;
			scoreTxt = new FlxText(FlxG.width / 2 - 235, healthBarBG.y + 50, 0, "", 20);
			scoreTxt.screenCenter(X);
			originalX = scoreTxt.x;
			scoreTxt.scrollFactor.set();
			scoreTxt.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, FlxTextAlign.CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			add(scoreTxt);
			replayTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
				"REPLAY", 20);
			replayTxt.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			replayTxt.borderSize = 4;
			replayTxt.borderQuality = 2;
			replayTxt.scrollFactor.set();
			if (loadRep)
				add(replayTxt);
			// Literally copy-paste of the above, fu
			botPlayState = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100), 0,
				"BOTPLAY", 20);
			botPlayState.setFormat(Paths.font("vcr.ttf"), 42, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			botPlayState.scrollFactor.set();
			botPlayState.borderSize = 4;
			botPlayState.borderQuality = 2;
			if (PlayStateChangeables.botPlay && !loadRep)
				add(botPlayState);
			iconP1 = new HealthIcon(SONG.player1, true);
			iconP1.y = healthBar.y - (iconP1.height / 2);
			add(iconP1);
			iconP2 = new HealthIcon((SONG.player2 == 'gf') ? gf.curCharacter : (SONG.song == 'Fresh Itch io Build') ? 'crazybus' : (SONG.song == 'Test') ? 'bf-pixel' : SONG.player2,
				false);
			iconP2.visible = SONG.player2 != "mario-ded" && SONG.song != "Bad Piggies";
			iconP2.y = healthBar.y - (iconP2.height / 2);
			add(iconP2);
			strumLineNotes.cameras = [camHUD];
			notes.cameras = [camHUD];
			healthBar.cameras = [camHUD];
			healthBarBG.cameras = [camHUD];
			iconP1.cameras = [camHUD];
			iconP2.cameras = [camHUD];
			scoreTxt.cameras = [camHUD];
			if (FlxG.save.data.songPosition)
			{
				songPosBG.cameras = [camHUD];
				songPosBar.cameras = [camHUD];
			}
			kadeEngineWatermark.cameras = [camHUD];
			if (loadRep)
				replayTxt.cameras = [camHUD];
		}
		else
		{
			// songPosBar.updateHitbox();
			songPosBG.y = 20;
			if (PlayStateChangeables.useDownscroll)
				songPosBG.y = FlxG.height * 0.9 + 45;
			songPosBar.y = songPosBG.y + 4;
			timeRemaining.y = songPosBG.y + songPosBG.height / 2;
			// if (PlayStateChangeables.useDownscroll)
			// 	timeRemaining.y -= 3;
			songPosBG.visible = FlxG.save.data.songPosition;
			songPosBar.visible = FlxG.save.data.songPosition;
			timeRemaining.visible = FlxG.save.data.songPosition;
			healthBar.updateHitbox();
			healthBarBG.y = FlxG.height * 0.9;
			if (PlayStateChangeables.useDownscroll)
				healthBarBG.y = 50;
			healthBarBG.scrollFactor.set();
			healthBar.y = healthBarBG.y + 4;
			healthBar.scrollFactor.set();
			kadeEngineWatermark.y = healthBarBG.y + 50;
			kadeEngineWatermark.scrollFactor.set();
			if (PlayStateChangeables.useDownscroll)
				kadeEngineWatermark.y = FlxG.height * 0.9 + 45;
			scoreTxt.y = healthBarBG.y + 50;
			scoreTxt.scrollFactor.set();
			replayTxt.y = healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100);
			replayTxt.scrollFactor.set();
			if (loadRep && !assets.contains(replayTxt))
				add(replayTxt);
			else if (!loadRep && assets.contains(replayTxt))
				remove(replayTxt);
			botPlayState.y = healthBarBG.y + (PlayStateChangeables.useDownscroll ? 100 : -100);
			botPlayState.scrollFactor.set();
			if (PlayStateChangeables.botPlay && !loadRep && !assets.contains(botPlayState))
				add(botPlayState);
			else if ((!PlayStateChangeables.botPlay || loadRep) && assets.contains(botPlayState))
				remove(botPlayState);
			iconP1.y = healthBar.y - (iconP1.height / 2);
			iconP2.y = healthBar.y - (iconP2.height / 2);
			updateNotes();
		}
	}

	function tankmanIntro()
	{
		var blacc = new FlxSprite().makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		blacc.cameras = [camGame];
		blacc.scrollFactor.set();
		blacc.updateHitbox();
		var tankmanFinish = function()
		{
			remove(blacc);
			camHUD.visible = true;
			startCountdown();
			FlxTween.tween(camFollow, {x: (dad.getMidpoint().x + 150), y: (dad.getMidpoint().y - 100)}, 1, {ease: FlxEase.cubeInOut});
			FlxTween.tween(camGame, {zoom: targetCamZoom}, 1, {
				ease: FlxEase.quadInOut
			});
		}
		camZooming = false;
		inCutscene = true;
		camHUD.visible = false;
		switch (StringTools.replace(curSong.toLowerCase(), ' ', '-'))
		{
			case 'ugh':
				{
					camGame.zoom = 1.05;
					camFollow.setPosition(dad.getMidpoint().x + 50, dad.getMidpoint().y - 100);
					camGame.focusOn(FlxPoint.get(camFollow.getPosition().x, camFollow.getPosition().y - 50));
					#if cpp
					if (FlxG.random.bool(65))
					{
						add(blacc);
						var video:MP4Handler = new MP4Handler();
						video.finishCallback = tankmanFinish;
						video.playMP4(Paths.video('ughCutscene'));
						new FlxTimer().start(5, function(tmr:FlxTimer)
						{
							remove(blacc);
						});
					}
					else
					{
					#end
						var bgm:FlxSound = new FlxSound().loadEmbedded(Paths.music('DISTORTO', 'week7'));
						var nicepubes:FlxSound = new FlxSound().loadEmbedded(Paths.sound('homedepot/toughguy', 'week7'));
						FlxG.sound.list.add(bgm);
						FlxG.sound.list.add(nicepubes);
						nicepubes.onComplete = function()
						{
							bgm.fadeOut(1);
							tankmanFinish();
						}
						nicepubes.volume = 1.2;
						bgm.fadeIn(1, 0, 0.6);
						new FlxTimer().start(0.5, function(tmr:FlxTimer)
						{
							nicepubes.play();
							dad.animationSound = nicepubes;
							var toLoad = Song.loadFromJson('nicepubes', 'ugh').notes;
							for (section in toLoad)
								for (data in section.sectionNotes)
									dad.animationNotes.push(data);
							dad.animationNotes.sort((a, b) -> a[0] - b[0]);
						});
					#if cpp
					}
					#end
				}
			case 'ugh-alterneeyyytive-mix':
				{
					camGame.zoom = 1.05;
					camFollow.setPosition(dad.getMidpoint().x + 50, dad.getMidpoint().y - 50);
					var subtitles:FlxText = new FlxText(0, 0, Math.floor(FlxG.width * 0.95), "Well, well, well. What do we got here?", 28);
					subtitles.font = Paths.font("vcr.ttf");
					subtitles.antialiasing = FlxG.save.data.antialiasing;
					subtitles.autoSize = false;
					subtitles.alignment = CENTER;
					subtitles.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 1, 1);
					subtitles.updateHitbox();
					subtitles.screenCenter(X);
					subtitles.y = FlxG.height - 125;
					subtitles.scrollFactor.set();
					subtitles.alpha = 0;
					add(subtitles);
					var psy1:FlxSound = new FlxSound().loadEmbedded(Paths.sound('psy/wellWellWell', 'week7'));
					var beep:FlxSound = new FlxSound().loadEmbedded(Paths.sound('psy/bfBeep', 'week7'));
					var psy2:FlxSound = new FlxSound().loadEmbedded(Paths.sound('psy/killYou', 'week7'));
					var bgm:FlxSound = new FlxSound().loadEmbedded(Paths.music('DISTORTO', 'week7'));
					FlxG.sound.list.add(psy1);
					FlxG.sound.list.add(psy2);
					FlxG.sound.list.add(bgm);
					FlxG.sound.list.add(beep);
					beep.onComplete = function()
					{
						boyfriend.playAnim('idle', true);
					}
					var talking = true;
					var ended = false;
					var part2 = function()
					{
						var loop = 1;
						talking = false;
						dad.playAnim('idle', true);
						camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);
						FlxTween.tween(subtitles, {alpha: 0}, 0.5);
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							switch (loop)
							{
								case 1:
									boyfriend.playAnim('singUP', true);
									beep.play();
									loop++;
									tmr.reset(1);
								case 2:
									subtitles.text = "We should just kill you, but what the hell, it's been a boring day.\nLet's see what you got!";
									subtitles.updateHitbox();
									subtitles.screenCenter(X);
									FlxTween.tween(subtitles, {alpha: 1}, 0.5);
									camFollow.setPosition(dad.getMidpoint().x + 50, dad.getMidpoint().y - 50);
									psy2.play();
									dad.animationSound = psy2;
									var toLoad = Song.loadFromJson('psy2', 'ugh-alterneeyyytive-mix').notes;
									for (section in toLoad)
										for (data in section.sectionNotes)
											dad.animationNotes.push(data);
									dad.animationNotes.sort((a, b) -> a[0] - b[0]);
									talking = true;
							}
						});
					}
					var fadeMusic = function()
					{
						ended = true;
						talking = false;
						dad.playAnim('idle', true);
						bgm.fadeOut(1);
						FlxTween.tween(subtitles, {alpha: 0}, 0.5, {
							onComplete: function(twn:FlxTween)
							{
								remove(subtitles);
								subtitles.kill();
								subtitles.destroy();
							}
						});
						tankmanFinish();
					}
					bgm.fadeIn(1, 0, 0.6);
					psy1.onComplete = part2;
					psy2.onComplete = fadeMusic;
					psy1.play();
					dad.animationSound = psy1;
					var toLoad = Song.loadFromJson('psy1', 'ugh-alterneeyyytive-mix').notes;
					for (section in toLoad)
						for (data in section.sectionNotes)
							dad.animationNotes.push(data);
					FlxTween.tween(subtitles, {alpha: 1}, 0.5);
				}
			case 'guns-short-version':
				{
					#if cpp
					add(blacc);
					camGame.zoom = 1.2;
					camFollow.setPosition(dad.getMidpoint().x + 50, dad.getMidpoint().y - 100);
					camGame.focusOn(camFollow.getPosition());
					var video:MP4Handler = new MP4Handler();
					video.finishCallback = tankmanFinish;
					video.playMP4(Paths.video('gunsCutscene'));
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						remove(blacc);
					});
					#else
					tankmanFinish();
					#end
				}
			default:
				tankmanFinish();
		}
	}

	function turnToCrazyWhitty()
	{
		// var pos = members.indexOf(dad);

		// remove(dad);

		// var newChar = new Character(100, 100, 'whittyCrazy');

		// dad = newChar;

		// addAt(dad, pos);

		// PlayState.instance.iconP2.changeIcon('whittyCrazy');

		dad.visible = true;

		if (isStoryMode || FlxG.save.data.freeplayCutscenes && !restarted)
		{
			iconP1.visible = false;
			iconP2.visible = false;
		}
	}

	function whittyAnimation(?dialogueBox:DialogueBox):Void // Mfw I steal Whitty code :troll:
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.fromRGB(19, 0, 0));
		black.scrollFactor.set();
		var black2:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black2.scrollFactor.set();
		black2.alpha = 0;
		var black3:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black3.scrollFactor.set();
		if (curSong.toLowerCase() != 'ballistic')
			add(black);

		var epic:Bool = false;
		var white:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.WHITE);
		white.scrollFactor.set();
		white.alpha = 0;

		var whittyCutsceneOver = function()
		{
			healthBar.visible = true;
			healthBarBG.visible = true;
			scoreTxt.visible = true;
			iconP1.visible = true;
			iconP2.visible = true;
			camHUD.visible = true;
			rumble.fadeOut();
			startCountdown();
		};

		trace('what animation to play, hmmmm');

		var wat:Bool = true;

		trace('cur song: ' + curSong);

		switch (curSong.toLowerCase()) // WHITTY ANIMATION CODE LMAOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOOO
		{
			case 'ballistic':
				trace('funny ballistic!!!');
				trace(white);
				var noMore:Bool = false;
				inCutscene = true;
				dialogueBox.finishThing = whittyCutsceneOver;

				var wind:FlxSound = new FlxSound().loadEmbedded(Paths.sound('windLmao', 'shared'), true);
				var mBreak:FlxSound = new FlxSound().loadEmbedded(Paths.sound('micBreak', 'shared'));
				var mThrow:FlxSound = new FlxSound().loadEmbedded(Paths.sound('micThrow', 'shared'));
				var mSlam:FlxSound = new FlxSound().loadEmbedded(Paths.sound('slammin', 'shared'));
				var TOE:FlxSound = new FlxSound().loadEmbedded(Paths.sound('ouchMyToe', 'shared'));
				var soljaBOY:FlxSound = new FlxSound().loadEmbedded(Paths.sound('souljaboyCrank', 'shared'));
				rumble = new FlxSound().loadEmbedded(Paths.sound('rumb', 'shared'));

				var sounds = [wind, mBreak, mThrow, mSlam, TOE, soljaBOY, rumble];

				for (i in sounds)
					FlxG.sound.list.add(i);

				gf.playAnim('scared');

				dad.visible = false;
				var animation:FlxSprite = new FlxSprite(-630, -100);
				animation.frames = Paths.getSparrowAtlas('cuttinDeezeBalls', 'bonusWeek');
				animation.animation.addByPrefix('startup', 'Whitty Ballistic Cutscene', 24, false);
				animation.antialiasing = true;
				add(animation);
				add(white);

				var nwBg = cast(stage.swagBacks.get('nwBg'), FlxSprite);
				var wBg = cast(stage.swagBacks.get('wBg'), FlxSprite);
				var wstageFront = cast(stage.swagBacks.get('wstageFront'), FlxSprite);

				wBg.alpha = 1;
				nwBg.alpha = 1;

				trace(animation);

				camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);

				wind.fadeIn();
				camHUD.visible = false;

				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					// animation

					if (!wat)
					{
						tmr.reset(1.5);
						wat = true;
					}
					else
					{
						if (animation.animation.curAnim == null) // check thingy go BEE BOOP
						{
							animation.animation.play('startup'); // if beopoe then make go BEP
							trace('start ' + animation.animation.curAnim.name);
						}
						if (!animation.animation.finished && animation.animation.curAnim.name == 'startup') // beep?
						{
							tmr.reset(0.01); // fuck
							noMore = true; // fuck outta here animation
							// trace(animation.animation.frameIndex);
							switch (animation.animation.frameIndex)
							{
								case 87:
									if (!mThrow.playing)
										mThrow.play();
								case 86:
									if (!mSlam.playing)
										mSlam.play();
								case 128:
									if (!soljaBOY.playing)
									{
										soljaBOY.play();
										remove(wstageFront);
										nwBg.alpha = 1;
										wBg.alpha = 0;
										nwBg.animation.play('gaming');
										camFollow.camera.shake(0.01, 3);
									}
								case 123:
									if (!rumble.playing)
										rumble.play();
								case 135:
									camFollow.camera.stopFX();
								case 158:
									if (!TOE.playing)
									{
										TOE.play();
										camFollow.camera.stopFX();
										camFollow.camera.shake(0.03, 6);
									}
								case 52:
									if (!mBreak.playing)
									{
										mBreak.play();
									}
							}
						}
						else
						{
							// white screen thingy

							camFollow.camera.stopFX();

							if (white.alpha < 1 && !epic)
							{
								white.alpha += 0.4;
								tmr.reset(0.1);
							}
							else
							{
								if (!epic)
								{
									epic = true;
									trace('epic ' + epic);
									turnToCrazyWhitty();
									remove(animation);
									TOE.fadeOut();
									tmr.reset(0.1);
									nwBg.animation.play("gameButMove");
								}
								else
								{
									if (white.alpha != 0)
									{
										white.alpha -= 0.1;
										tmr.reset(0.1);
									}
									else
									{
										if (dialogueBox != null)
										{
											camHUD.visible = true;
											wind.fadeOut();
											healthBar.visible = false;
											healthBarBG.visible = false;
											scoreTxt.visible = false;
											iconP1.visible = false;
											iconP2.visible = false;
											add(dialogueBox);
											trace('ended');
										}
										else
										{
											whittyCutsceneOver();
										}
										remove(white);
									}
								}
							}
						}
					}
				});

			case 'lo-fight':
				trace('funny lo-fight!!!');
				inCutscene = true;
				remove(dad);
				var animation:FlxSprite = new FlxSprite(-290, -100);
				animation.frames = Paths.getSparrowAtlas('whittyCutscene', 'bonusWeek');
				animation.animation.addByPrefix('startup', 'Whitty Cutscene Startup ', 24, false);
				animation.antialiasing = true;
				gf.visible = false;
				add(animation);
				black2.visible = true;
				black3.visible = true;
				add(black2);
				add(black3);
				black2.alpha = 0;
				black3.alpha = 0;
				trace(black2);
				trace(black3);

				var city:FlxSound = new FlxSound().loadEmbedded(Paths.sound('city', 'shared'), true);
				var rip:FlxSound = new FlxSound().loadEmbedded(Paths.sound('rip', 'shared'));
				var fire:FlxSound = new FlxSound().loadEmbedded(Paths.sound('fire', 'shared'));
				var BEEP:FlxSound = new FlxSound().loadEmbedded(Paths.sound('beepboop', 'shared'));

				var sounds = [city, rip, fire, BEEP];

				for (i in sounds)
					FlxG.sound.list.add(i);

				city.fadeIn();
				camFollow.setPosition(dad.getMidpoint().x + 120, dad.getMidpoint().y - 180);

				camHUD.visible = false;
				boyfriend.x += 314;

				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					if (!wat)
					{
						tmr.reset(3);
						wat = true;
					}
					else
					{
						// animation

						black.alpha -= 0.15;

						if (black.alpha > 0)
						{
							tmr.reset(0.3);
						}
						else
						{
							if (animation.animation.curAnim == null)
								animation.animation.play('startup');

							if (!animation.animation.finished)
							{
								tmr.reset(0.01);
								trace('animation at frame ' + animation.animation.frameIndex);

								switch (animation.animation.frameIndex)
								{
									case 0:
										trace('play city sounds');
									case 41:
										trace('fire');
										if (!fire.playing)
											fire.play();
									case 34:
										trace('paper rip');
										if (!rip.playing)
											rip.play();
									case 147:
										trace('BEEP');
										if (!BEEP.playing)
										{
											camFollow.setPosition(dad.getMidpoint().x + 600, dad.getMidpoint().y - 100);
											BEEP.play();
											boyfriend.playAnim('singLEFT', true);
										}
									case 154:
										if (boyfriend.animation.curAnim.name != 'idle')
											boyfriend.playAnim('idle');
								}
							}
							else
							{
								// CODE LOL!!!!
								if (black2.alpha != 1)
								{
									black2.alpha += 0.4;
									tmr.reset(0.1);
									trace('increase blackness lmao!!!');
								}
								else
								{
									if (black2.alpha == 1 && black2.visible)
									{
										black2.visible = false;
										black3.alpha = 1;
										trace('transision ' + black2.visible + ' ' + black3.alpha);
										remove(animation);
										add(dad);
										gf.visible = true;
										boyfriend.x -= 314;
										camHUD.visible = true;
										tmr.reset(0.3);
									}
									else if (black3.alpha != 0)
									{
										black3.alpha -= 0.1;
										tmr.reset(0.3);
										trace('decrease blackness lmao!!!');
									}
									else
									{
										if (dialogueBox != null)
										{
											add(dialogueBox);
											city.fadeOut();
										}
										else
										{
											trace('waait what');
											startCountdown();
										}
										remove(black);
									}
								}
							}
						}
					}
				});
			default:
				trace('funny *goat looking at camera*!!!');
				new FlxTimer().start(0.3, function(tmr:FlxTimer)
				{
					if (!wat)
					{
						tmr.reset(3);
						wat = true;
					}

					black.alpha -= 0.15;

					if (black.alpha > 0)
					{
						tmr.reset(0.3);
					}
					else
					{
						if (dialogueBox != null)
						{
							inCutscene = true;
							add(dialogueBox);
						}
						remove(black);
					}
				});
		}
	}

	function kapiIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		new FlxTimer().start(0.2, function(tmr:FlxTimer)
		{
			black.alpha -= 0.1;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;
					add(dialogueBox);
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var howManyMoreFuckingAddersDoIHaveToMake = (SONG.song.toLowerCase() == 'thorns') ? '/clubpenguin' : '';

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb$howManyMoreFuckingAddersDoIHaveToMake/senpaiCrazy', 'week6');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * 6));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();

		trace(rootSong);

		if (rootSong == 'roses' || rootSong == 'thorns')
		{
			remove(black);

			if (rootSong == 'thorns')
			{
				add(red);
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (rootSong == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer;
	var perfectMode:Bool = false;
	var luaWiggles:Array<WiggleEffect> = [];

	#if cpp
	public static var luaModchart:ModchartState = null;
	#end

	function startCountdown():Void
	{
		inCutscene = false;

		currentPlayer = (FlxG.save.data.playEnemy) ? dad : boyfriend;
		currentEnemy = (!FlxG.save.data.playEnemy) ? dad : boyfriend;

		trace('counting down baybee');

		appearStaticArrows();
		// generateStaticArrows(0);
		// generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		var timerSpeed = Conductor.crochet / 1000;

		startTimer = new FlxTimer().start(timerSpeed, function(tmr:FlxTimer)
		{
			if (dad.animation.curAnim.name.startsWith('idle') || dad.animation.curAnim.name.startsWith('dance'))
				dad.dance();
			if (!PlayStateChangeables.Optimize && FlxG.save.data.distractions)
				for (i in stage.swagDancers)
					i.dance();
			if (!(gf.curCharacter == 'gf-whitty' && curSong.startsWith('Ballistic')))
				gf.dance();
			boyfriend.playAnim('idle');

			var altSuffix:String = "";

			if (noteSkinData.type == 'pixel')
				altSuffix = '-pixel';

			switch (swagCounter)
			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image('uiskins/' + noteSkinData.uiSkin + '/' + 'ready', 'shared'));
					ready.scrollFactor.set();
					ready.updateHitbox();

					if (noteSkinData.type == 'pixel')
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image('uiskins/' + noteSkinData.uiSkin + '/' + 'set', 'shared'));
					set.scrollFactor.set();

					if (noteSkinData.type == 'pixel')
						set.setGraphicSize(Std.int(set.width * daPixelZoom));

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var filepath = 'uiskins/' + noteSkinData.uiSkin + '/' + 'go';
					if (SONG.song == "Spookeez In-Game Version" || SONG.song == "Ballistic Beta Mix")
						filepath = 'slam';
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image('uiskins/' + noteSkinData.uiSkin + '/' + 'go', 'shared'));
					go.scrollFactor.set();

					if (noteSkinData.type == 'pixel')
						go.setGraphicSize(Std.int(go.width * daPixelZoom));

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 5);

		if (SONG.song == "The Fab Fairies Dance")
		{
			startTimer.cancel();
		}
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	private function getKey(charCode:Int):String
	{
		for (key => value in FlxKey.fromStringMap)
		{
			if (charCode == value)
				return key;
		}
		return null;
	}

	var keys = [false, false, false, false];

	private function releaseInput(evt:KeyboardEvent):Void // handles releases
	{
		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}

		if (data == -1)
			return;

		keys[data] = false;
	}

	public var closestNotes:Array<Note> = [];

	private function handleInput(evt:KeyboardEvent):Void
	{ // this actually handles press inputs

		if (PlayStateChangeables.botPlay || loadRep || paused || (SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))
			return;

		// first convert it from openfl to a flixel key code
		// then use FlxKey to get the key's name based off of the FlxKey dictionary
		// this makes it work for special characters

		@:privateAccess
		var key = FlxKey.toStringMap.get(Keyboard.__convertKeyCode(evt.keyCode));

		var binds:Array<String> = [
			FlxG.save.data.leftBind,
			FlxG.save.data.downBind,
			FlxG.save.data.upBind,
			FlxG.save.data.rightBind
		];

		var data = -1;

		switch (evt.keyCode) // arrow keys
		{
			case 37:
				data = 0;
			case 40:
				data = 1;
			case 38:
				data = 2;
			case 39:
				data = 3;
		}

		for (i in 0...binds.length) // binds
		{
			if (binds[i].toLowerCase() == key.toLowerCase())
				data = i;
		}
		if (data == -1)
		{
			// trace("couldn't find a keybind with the code " + key);
			return;
		}
		if (keys[data])
		{
			// trace("ur already holding " + key);
			return;
		}

		keys[data] = true;

		var ana = new Ana(Conductor.songPosition, null, false, "miss", data);

		var dataNotes = [];
		for (i in closestNotes)
			if (i.noteData == data)
				dataNotes.push(i);

		if (dataNotes.length != 0)
		{
			var coolNote = null;

			for (i in dataNotes)
				if (!i.isSustainNote)
				{
					coolNote = i;
					break;
				}

			if (coolNote == null) // Note is null, which means it's probably a sustain note. Update will handle this (HOPEFULLY???)
			{
				return;
			}

			if (dataNotes.length > 1) // stacked notes or really close ones
			{
				for (i in 0...dataNotes.length)
				{
					if (i == 0) // skip the first note
						continue;

					var note = dataNotes[i];

					if (!note.isSustainNote && (note.strumTime - coolNote.strumTime) < 2)
					{
						trace('found a stacked/really close note ' + (note.strumTime - coolNote.strumTime));
						// just fuckin remove it since it's a stacked note and shouldn't be there
						note.kill();
						notes.remove(note, true);
						note.destroy();
					}
				}
			}

			if (!coolNote.isMine)
			{
				goodNoteHit(coolNote);
				var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
				ana.hit = true;
				ana.hitJudge = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
				ana.nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
			}
			else
			{
				mineHit(coolNote);
			}
		}
		else if (!FlxG.save.data.ghost && songStarted && notes.length != 0)
		{
			checkBadInput(null, data, ana);
			// noteMiss(data, null);
		}
	}

	// Stolen from tiky :troll:
	// Really only needed this for Madness but now that it's here I might as well have fun with it
	// Also renamed them to mines because StepMania
	function mineHit(coolNote:Note)
	{
		trace('mine hit');
		health -= 0.45;
		var data = noteSkinData.mineData;
		coolNote.wasGoodHit = true;
		coolNote.canBeHit = false;
		coolNote.kill();
		notes.remove(coolNote, true);
		coolNote.destroy();
		if (data.effectAnimation.sound != null)
			FlxG.sound.play(Paths.sound('mineSounds/' + data.effectAnimation.sound, 'shared'));

		var spr = playerStrums.members[coolNote.noteData];
		var hitFX:FlxSprite = new FlxSprite(spr.x, spr.y);
		#if sys
		hitFX.frames = GameCache.globalCache.fromSparrow(data.effect, "splats/" + data.effect, 'shared');
		#else
		hitFX.frames = Paths.getSparrowAtlas("splats/" + data.effect, 'shared');
		#end
		var variation = '';
		if (data.effectAnimation.variation > 0)
			variation = " " + Std.string(FlxG.random.int(1, data.effectAnimation.variation));
		if (data.effectAnimation.directional)
			hitFX.animation.addByPrefix('boom', data.effectAnimation.prefix + dataColor[coolNote.noteData] + variation, data.effectAnimation.frameRate, false);
		else
			hitFX.animation.addByPrefix('boom', data.effectAnimation.prefix + variation, data.effectAnimation.frameRate, false);

		hitFX.animation.play('boom');
		hitFX.setGraphicSize(Std.int(hitFX.width * data.effectAnimation.scale));
		// trace(data.effectAnimation.offset);
		hitFX.updateHitbox();
		// Why must Haxe sprite placement shit be so painful
		hitFX.x = spr.x - (spr.width / 2) - data.effectAnimation.offset[0];
		hitFX.y = spr.y - (spr.height / 2) - data.effectAnimation.offset[1];
		hitFX.cameras = [camHUD];
		if (data.effect == "haatoSplash")
		{
			var AAAAAAA = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 5, FlxG.height * 5, FlxColor.BLACK);
			healthBar.color = FlxColor.RED;
			iconP1.color = FlxColor.RED;
			iconP2.color = FlxColor.RED;
			add(AAAAAAA);
			FlxTween.tween(AAAAAAA, {alpha: 0}, 5, {
				onComplete: function(twn:FlxTween)
				{
					remove(AAAAAAA);
					AAAAAAA.kill();
					AAAAAAA.destroy();
				},
				onUpdate: function(twn:FlxTween)
				{
					var newColor = FlxColor.interpolate(FlxColor.RED, FlxColor.WHITE, twn.scale);
					iconP1.color = newColor;
					iconP2.color = newColor;
					healthBar.color = newColor;
				}
			});
		}
		add(hitFX);
		hitFX.animation.finishCallback = function(name:String)
		{
			remove(hitFX);
		}
	}

	public var songStarted = false;

	function startSong():Void
	{
		startingSong = false;
		songStarted = true;
		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		FlxG.sound.music.play();
		vocals.play();

		// Song check real quick
		var songCheck = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase().split("-")[0];
		switch (songCheck)
		{
			case 'bopeebo' | 'philly' | 'blammed' | 'cocoa' | 'eggnog':
				allowedToHeadbang = true;
			default:
				allowedToHeadbang = false;
		}

		#if cpp
		if (executeModchart)
			luaModchart.executeState("songStart", [null]);
		#end

		if (useVideo)
			GlobalVideo.get().resume();

		#if cpp
		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end

		FlxG.sound.music.time = startTime;
		vocals.time = startTime;
		Conductor.songPosition = startTime;
		startTime = 0;

		if ((notes.members.length > 0 && notes.members[0].strumTime > 4500)
			|| (unspawnNotes.length > 0 && unspawnNotes[0].strumTime > 4500))
		{
			var firstNote = (notes.members.length > 0) ? notes.members[0] : unspawnNotes[0];
			skipIntroText = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 75, healthBarBG.y + (PlayStateChangeables.useDownscroll ? 150 : -150), 0,
				"Press SPACE to skip intro");
			skipIntroText.setFormat(Paths.font("vcr.ttf"), 36, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
			skipIntroText.borderSize = 4;
			skipIntroText.borderQuality = 2;
			skipIntroText.scrollFactor.set();
			skipIntroText.screenCenter(X);
			skipIntroText.updateHitbox();
			skipIntroText.antialiasing = false;
			if (FlxG.save.data.skipIntro)
				add(skipIntroText);
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				FlxTween.tween(skipIntroText, {alpha: 0}, 1, {
					onComplete: function(twn:FlxTween)
					{
						remove(skipIntroText);
					}
				});
			});
			skipTime = firstNote.strumTime - 1500;
		}
		for (i in 0...unspawnNotes.length)
			if (unspawnNotes[i].strumTime < startTime)
				unspawnNotes.remove(unspawnNotes[i]);
	}

	var debugNum:Int = 0;

	public function generateSong(dataPath:String):Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);
		curSong = songData.altSong != null ? songData.altSong : songData.song;

		var copyrightList = CoolUtil.coolTextFile(Paths.txt("data/copyrightedSonglist"));
		var copyrighted = "";
		var coverVoices:Bool = false;
		var coverInst:Bool = false;
		if (FlxG.save.data.noCopyright == 1) // TODO: GET GOOD AT FL LMAO
		{
			for (i in copyrightList)
			{
				var data = i.split(":");
				if (SONG.song == data[0])
					copyrighted = data[1];
			}
			copyrighted = copyrighted.trim().toLowerCase();
			coverVoices = (copyrighted == "vocals" || copyrighted == "both");
			coverInst = (copyrighted == "inst" || copyrighted == "both");
			trace(copyrighted, coverVoices, coverInst);
		}

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(curSong, coverVoices));
		else
			vocals = new FlxSound();

		vocals.looped = false;

		trace('loaded vocals');

		trace('loading song ' + songData.song);

		FlxG.sound.list.add(vocals);

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(curSong, coverInst), 1, false);

		FlxG.sound.music.onComplete = endSong;
		FlxG.sound.music.pause();
		FlxG.sound.pause();

		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		#if cpp
		// pre lowercasing the song name (generateSong)
		var songLowercase = CoolUtil.lowerCaseSong(SONG.song);

		var songPath = Paths.songPath + songLowercase + '/';

		#if sys
		if (isSM && !isStoryMode)
			songPath = pathToSm;
		#end

		trace(songPath);

		for (file in sys.FileSystem.readDirectory(songPath))
		{
			var path = haxe.io.Path.join([songPath, file]);
			if (!sys.FileSystem.isDirectory(path))
			{
				if (path.endsWith('.offset'))
				{
					trace('Found offset file: ' + path);
					songOffset = Std.parseFloat(file.substring(0, file.indexOf('.off')));
					break;
				}
				else
				{
					trace('Offset file not found. Creating one @: ' + songPath);
					sys.io.File.saveContent(songPath + songOffset + '.offset', '');
				}
			}
		}
		#end

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped

		var bpmChanges:Array<String> = [];

		for (i in SONG.eventObjects)
		{
			if (i.type == "BPM Change" && i.position != 0)
				bpmChanges.push(Std.string(i.position + ";" + i.value));
		}

		trace(bpmChanges);

		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset + songOffset;
				if (daStrumTime < 0)
					daStrumTime = 0;

				var timing = TimingStruct.getTimingAtBeat(daStrumTime);

				// I'M SO FUCKIN SMART UGHHH I'M LIKE A REGULAR MEGAMIND OVER HERE
				// I don't even know why I wanted to fix this lol barely anyone uses quantization. I suppose it was just for the challenge.
				// Basically just adds the beat at which the BPM changed last and recounts the beats using the new BPM. If that makes sense.
				// TODO: Still kinda fucky sometimes. Solution: cry about it for now
				var daNoteBeatStrum = timing.startBeat + (timing.bpm / 60) * (daStrumTime - timing.startTime) / 1000;

				// Technically speaking with all this effort I put into BPM changes I could just calculate the strumTime changes in-game rather than in the chart editor
				// but that's already how FNF notes work and I don't wanna change that for the sake of modding

				var daNoteData:Int = Std.int(songNotes[1]);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] % 8 > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				// Shitty inclusion of Haato notes from Holofunk but let's be honest here, they're just mines and I already have mines programmed in. Not doing that shit again, especially because the devs refuse to release the source code.
				// Thanks, guys.
				// I also still don't want to change how FNF notes work because there are like 70 songs (210 charts for each difficulty) in this fucking mod and
				// I'm not gonna go back and convert every damn chart or spend hours writing a script that would probably break them (and me) anyway
				if (songNotes.length > 3)
				{
					switch (Type.typeof(songNotes[3]))
					{
						case ValueType.TClass(String):
							if (songNotes[3] == "haato")
								daNoteData += 8;
						default:
					}
				}

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote, false, false, false, daNoteBeatStrum);

				if (PlayStateChangeables.Optimize && (FlxG.save.data.playEnemy ? gottaHitNote : !gottaHitNote))
					continue;

				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				swagNote.isAlt = songNotes[3] || (section.altAnim && !gottaHitNote);

				if (susLength > 0)
					swagNote.isParent = true;

				var type = 0;

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);
					sustainNote.isAlt = songNotes[3];

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
						sustainNote.x += FlxG.width / 2; // general offset

					sustainNote.parent = swagNote;
					swagNote.children.push(sustainNote);
					sustainNote.spotInLine = type;
					type++;
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}

	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return FlxSort.byValues(FlxSort.ASCENDING, Obj1.strumTime, Obj2.strumTime);
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:StaticArrow = new StaticArrow(0, strumLine.y);

			// defaults if no noteStyle was found in chart
			var noteTypeCheck:String = 'normal';

			var playerCheck = (FlxG.save.data.playEnemy) ? (player + 1) % 2 : player;

			if (PlayStateChangeables.Optimize && playerCheck == 0)
				continue;

			if (SONG.noteStyle == null)
			{
				switch (storyWeek)
				{
					case 6:
						SONG.noteStyle = 'pixel';
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = SONG.noteStyle;
			}

			switch (noteSkinData.type)
			{
				case 'pixel':
					babyArrow.loadGraphic(Paths.image('noteskins/' + noteSkinData.name, 'shared'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;

					babyArrow.x += Note.swagWidth * i;
					babyArrow.animation.add('static', [i]);
					babyArrow.animation.add('pressed', [4 + i, 8 + i], 12, false);
					babyArrow.animation.add('confirm', [12 + i, 16 + i], 24, false);

					for (j in 0...4)
					{
						babyArrow.animation.add('dirCon' + j, [12 + j, 16 + j], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('noteskins/' + noteSkinData.name, 'shared');
					for (j in 0...4)
					{
						babyArrow.animation.addByPrefix(dataColor[j], 'arrow' + dataSuffix[j]);
						babyArrow.animation.addByPrefix('dirCon' + j, dataSuffix[j].toLowerCase() + ' confirm', 24, false);
					}

					var lowerDir:String = dataSuffix[i].toLowerCase();

					babyArrow.animation.addByPrefix('static', 'arrow' + dataSuffix[i]);
					babyArrow.animation.addByPrefix('pressed', lowerDir + ' press', 24, false);
					babyArrow.animation.addByPrefix('confirm', lowerDir + ' confirm', 24, false);

					babyArrow.x += Note.swagWidth * i;

					babyArrow.antialiasing = FlxG.save.data.antialiasing;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			babyArrow.alpha = (songStarted) ? 1 : 0;
			if (!isStoryMode && !FlxG.save.data.freeplayCutscenes && !restarted && !songStarted)
			{
				babyArrow.y -= 10;
				// babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			switch (playerCheck)
			{
				case 0:
					cpuStrums.add(babyArrow);
				case 1:
					playerStrums.add(babyArrow);
			}

			babyArrow.playAnim('static');
			babyArrow.x += 92;
			babyArrow.x += ((FlxG.width / 2) * player);

			if (PlayStateChangeables.Optimize || FlxG.save.data.midscroll)
				babyArrow.x += ((player == 0) ? 320 : -320);

			cpuStrums.forEach(function(spr:StaticArrow)
			{
				spr.centerOffsets(); // CPU arrows start out slightly off-center
			});

			playerStrums.forEach(function(spr:StaticArrow)
			{
				spr.centerOffsets(); // for good measure lol
			});

			strumLineNotes.add(babyArrow);

			if (playerCheck == 0 && FlxG.save.data.midscroll)
				babyArrow.visible = false;

			if (!PlayStateChangeables.Optimize)
			{
				var underlay = new LaneUnderlay(babyArrow);
				underlay.cameras = [camHUD];
				underlays.push(underlay);
			}
		}
	}

	private function appearStaticArrows():Void
	{
		strumLineNotes.forEach(function(babyArrow:FlxSprite)
		{
			babyArrow.alpha = 1;
		});
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	function updateAA()
	{
		for (i in members)
		{
			var obj = null;
			try
			{
				obj = cast(i);
				obj.antialiasing = FlxG.save.data.antialiasing;
			}
			catch (e:Exception)
				trace('what');
		}
		if (noteSkinData.type != "pixel")
		{
			for (obj in strumLineNotes)
				obj.antialiasing = FlxG.save.data.antialiasing;
			notes.forEachAlive(function(daNote:Note)
			{
				daNote.antialiasing = FlxG.save.data.antialiasing;
			});
			for (i in unspawnNotes)
				i.antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			for (i in strumLineNotes)
				i.antialiasing = false;

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.graphic != null)
					daNote.antialiasing = false;
			});
			for (i in unspawnNotes)
				i.antialiasing = false;
		}
		if (stage.isPixel)
		{
			boyfriend.antialiasing = false;
			gf.antialiasing = false;
			dad.antialiasing = false;
			iconP1.antialiasing = false;
			iconP2.antialiasing = false;
			for (obj in stage.toAdd)
			{
				try
				{
					obj.antialiasing = false;
				}
				catch (e:Exception)
					trace('what');
			}
		}
	}

	function updateNotes(switchDownscroll:Bool = false)
	{
		notes.members.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.animation.curAnim != null)
			{
				daNote.setupNote(false, switchDownscroll);
			}
		});
		unspawnNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		for (daNote in unspawnNotes)
		{
			if (daNote.animation.curAnim != null)
			{
				daNote.setupNote(false, switchDownscroll);
			}
		}
	}

	function refreshArrows()
	{
		remove(notes);
		for (box in underlays)
		{
			remove(box, true);
			box.kill();
			box.destroy();
		}
		underlays = [];
		remove(strumLineNotes);
		for (i in strumLineNotes)
		{
			remove(i, true);
			i.kill();
			i.destroy();
		}
		strumLineNotes.clear();
		cpuStrums.clear();
		playerStrums.clear();
		if (!FlxG.save.data.playEnemy)
		{
			generateStaticArrows(0);
			generateStaticArrows(1);
		}
		else
		{
			generateStaticArrows(1);
			generateStaticArrows(0);
		}
		for (box in underlays)
		{
			add(box);
		}
		add(strumLineNotes);
		add(notes);
	}

	function healthBarColors():Array<FlxColor>
	{
		var bfColor:FlxColor = boyfriend.charColor;
		var dadColor:FlxColor = dad.charColor;

		if (!FlxG.save.data.color)
		{
			dadColor = 0xFFFA0000;
			bfColor = 0xFF66FF33;
		}

		return [bfColor, dadColor];
	}

	function updateHealthBar()
	{
		healthBar.kill();
		healthBar.destroy();
		healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, (FlxG.save.data.playEnemy ? LEFT_TO_RIGHT : RIGHT_TO_LEFT),
			Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this, 'health', 0, 2);
		healthBar.scrollFactor.set();

		var HPcolors = healthBarColors();
		var bfColor:FlxColor = HPcolors[0];
		var dadColor:FlxColor = HPcolors[1];

		remove(iconP1);
		remove(iconP2);
		notes.forEachAlive(function(daNote:Note)
		{
			remove(daNote);
		});

		add(healthBar);
		healthBar.cameras = [camHUD];

		add(iconP1);
		add(iconP2);
		notes.forEachAlive(function(daNote:Note)
		{
			add(daNote);
		});

		if (!FlxG.save.data.playEnemy || !FlxG.save.data.color)
			healthBar.createFilledBar(dadColor, bfColor);
		else
			healthBar.createFilledBar(bfColor, dadColor);

		healthBar.fillDirection = FlxG.save.data.playEnemy ? LEFT_TO_RIGHT : RIGHT_TO_LEFT;
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused && !inOptions)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			#if cpp
			DiscordClient.changePresence("PAUSED on "
				+ SONG.song
				+ " ("
				+ storyDifficultyText
				+ ") "
				+ Ratings.GenerateLetterRank(accuracy),
				"Acc: "
				+ HelperFunctions.truncateFloat(accuracy, 2)
				+ "% | Score: "
				+ songScore
				+ " | Misses: "
				+ misses, iconRPC);
			#end
			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	public function updateOption(option:String)
	{
		switch (option)
		{
			case 'scroll' | 'song position':
				{
					PlayStateChangeables.useDownscroll = FlxG.save.data.downscroll;
					strumLine.y = 50;
					if (PlayStateChangeables.useDownscroll)
						strumLine.y = FlxG.height - 165;
					strumLineNotes.forEach(function(spr:StaticArrow)
					{
						spr.y = strumLine.y;
					});
					// Flip over center of screen lol (not perfect but good enough)
					notes.forEachAlive(function(spr:Note)
					{
						var offset = spr.y - FlxG.height / 2;
						spr.y = FlxG.height / 2 - offset;
					});
					createHudObjects(true);
					updateNotes(true);
					#if cpp
					if (executeModchart)
						luaModchart.setDefaultStrumPos();
					#end
				}
			case 'antialiasing':
				{
					updateAA();
				}
			case 'colors by quantization':
				{
					updateNotes();
				}
			case 'scroll speed':
				{
					PlayStateChangeables.scrollSpeed = FlxG.save.data.scrollSpeed;
					updateNotes();
				}

			case 'safe frames':
				{
					PlayStateChangeables.safeFrames = FlxG.save.data.frames;
				}
			case 'botplay':
				{
					PlayStateChangeables.botPlay = FlxG.save.data.botplay;
					PlayStateChangeables.usedBotPlay = true;
					createHudObjects(true);
				}
			case 'color health bar by character':
				{
					updateHealthBar();
				}
			case 'cpu strums':
				{
					cpuStrums.forEach(function(spr:StaticArrow)
					{
						if (spr.animation.curAnim.name != 'static')
							spr.playAnim('static');
					});
				}
			case 'distractions':
				{
					if (FlxG.save.data.distractions && !PlayStateChangeables.Optimize)
					{
						for (i in stage.toAdd)
						{
							remove(i);
						}
						for (array in stage.layInFront)
						{
							remove(gf);
							remove(dad);
							remove(boyfriend);
							for (bg in array)
								remove(bg);
						}
						for (i in stage.toAdd)
						{
							add(i);
						}
						for (index => array in stage.layInFront)
						{
							switch (index)
							{
								case 0:
									add(gf);
									gf.scrollFactor.set(0.95, 0.95);
									for (bg in array)
										add(bg);
								case 1:
									add(dad);
									for (bg in array)
										add(bg);
								case 2:
									add(boyfriend);
									for (bg in array)
										add(bg);
							}
						}
					}
					else
						for (obj in stage.distractions)
							remove(obj);
				}
			case 'play as':
				{
					currentPlayer = (FlxG.save.data.playEnemy) ? dad : boyfriend;
					currentEnemy = (!FlxG.save.data.playEnemy) ? dad : boyfriend;
					for (i in notes)
						i.mustPress = !i.mustPress;
					refreshArrows();
					updateHealthBar();
					#if cpp
					if (executeModchart)
						luaModchart.setDefaultStrumPos();
					#end
				}
			case 'midscroll':
				{
					refreshArrows();
					notes.forEachAlive(function(daNote:Note)
					{
						if (!daNote.mustPress)
							daNote.visible = !FlxG.save.data.midscroll;
					});
					#if cpp
					if (executeModchart)
						luaModchart.setDefaultStrumPos();
					#end
				}
			case 'skip intro text':
				{
					if (skipTime != 0)
						if (FlxG.save.data.skipIntro)
							add(skipIntroText);
						else
							remove(skipIntroText);
				}
			case 'note hit sounds':
				createHitSound();
		}
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (inOptions)
			{
				openSubState(new PauseSubState(currentPlayer.getScreenPosition().x, currentPlayer.getScreenPosition().y));
				inOptions = false;
				return;
			}
			else
			{
				if (FlxG.sound.music != null && !startingSong)
				{
					resyncVocals();
				}

				if (!startTimer.finished)
					startTimer.active = true;
				paused = false;

				#if cpp
				if (startTimer.finished)
				{
					DiscordClient.changePresence(detailsText
						+ " "
						+ SONG.song
						+ " ("
						+ storyDifficultyText
						+ ") "
						+ Ratings.GenerateLetterRank(accuracy),
						"\nAcc: "
						+ HelperFunctions.truncateFloat(accuracy, 2)
						+ "% | Score: "
						+ songScore
						+ " | Misses: "
						+ misses, iconRPC, true,
						songLength
						- Conductor.songPosition);
				}
				else
				{
					DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ") " + Ratings.GenerateLetterRank(accuracy), iconRPC);
				}
				#end
			}
		}

		super.closeSubState();
	}

	function resyncVocals():Void
	{
		vocals.pause();

		FlxG.sound.music.play();
		Conductor.songPosition = FlxG.sound.music.time;
		vocals.time = Conductor.songPosition;
		vocals.play();

		#if cpp
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"\nAcc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC);
		#end
	}

	function noteMissFX(x:Float, data:Int)
	{
		var noteMiss:NoteMiss = missFXGroup.recycle(NoteMiss);
		noteMiss.init(x, data);
		add(noteMiss);
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var nps:Int = 0;
	var maxNPS:Int = 0;

	public static var songRate = 1.5;

	public var stopUpdate = false;
	public var removedVideo = false;
	public var currentBPM = 0;
	public var updateFrame = 0;
	public var pastScrollChanges:Array<Song.Event> = [];

	var currentLuaIndex = 0;

	var camOnBf = false;

	override public function update(elapsed:Float)
	{
		#if !debug
		perfectMode = false;
		#end

		if (!PlayStateChangeables.Optimize && FlxG.save.data.distractions)
			for (i in stage.swagDancers)
				if (i.lerpAnim)
					i.update(elapsed);

		var toFuckingKill:Array<Note> = [];
		for (note in unspawnNotes)
		{
			if (note.strumTime - Conductor.songPosition < 10000 / SONG.speed)
			{
				if (note.strumTime - Conductor.songPosition < 0)
				{
					toFuckingKill.push(note);
					continue;
				}
				var dunceNote:Note = note;
				if (FlxG.save.data.playEnemy)
					dunceNote.mustPress = !dunceNote.mustPress;
				notes.add(dunceNote);

				#if cpp
				if (executeModchart)
				{
					new LuaNote(dunceNote, currentLuaIndex);
					dunceNote.luaID = currentLuaIndex;
				}
				#end

				if (executeModchart)
				{
					#if cpp
					if (!dunceNote.isSustainNote)
						dunceNote.cameras = [camNotes];
					else
						dunceNote.cameras = [camSustains];
					#end
				}
				else
				{
					dunceNote.cameras = [camHUD];
				}

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.splice(index, 1);
				currentLuaIndex++;
			}
			else
				break;
		}

		for (note in toFuckingKill)
			unspawnNotes.remove(note);

		if (songStarted)
		{
			if (!FlxG.save.data.ghost && FlxG.save.data.missMs < 1010)
			{
				var p1Notes = false;

				for (daNote in notes)
				{
					if (daNote.mustPress
						&& !daNote.tooLate
						&& !daNote.wasGoodHit
						&& !(daNote.strumTime - Conductor.songPosition > FlxG.save.data.missMs
							|| daNote.strumTime - Conductor.songPosition < -FlxG.save.data.missMs))
					{
						p1Notes = true;
						break;
					}
				}

				var p2Notes = false;

				for (daNote in notes)
				{
					if (!daNote.mustPress
						&& !daNote.tooLate
						&& !daNote.wasGoodHit
						&& !(daNote.strumTime - Conductor.songPosition > FlxG.save.data.missMs
							|| daNote.strumTime - Conductor.songPosition < -FlxG.save.data.missMs))
					{
						p2Notes = true;
						break;
					}
				}

				if (p1Notes)
					playerStrums.forEach(function(spr:StaticArrow)
					{
						spr.alpha = CoolUtil.coolLerp(spr.alpha, 1, 0.1);
					});
				else
					playerStrums.forEach(function(spr:StaticArrow)
					{
						spr.alpha = CoolUtil.coolLerp(spr.alpha, 0.5, 0.1);
					});

				if (p2Notes)
					cpuStrums.forEach(function(spr:StaticArrow)
					{
						spr.alpha = CoolUtil.coolLerp(spr.alpha, 1, 0.1);
					});
				else
					cpuStrums.forEach(function(spr:StaticArrow)
					{
						spr.alpha = CoolUtil.coolLerp(spr.alpha, 0.5, 0.1);
					});
			}
			else
			{
				strumLineNotes.forEach(function(spr:StaticArrow)
				{
					spr.alpha = CoolUtil.coolLerp(spr.alpha, 1, 0.1);
				});
			}
		}

		if (generatedMusic)
		{
			for (i in notes)
			{
				var diff = i.strumTime - Conductor.songPosition;
				if (diff < 2650 && diff >= -2650)
				{
					i.active = true;
					if (!i.mustPress && !FlxG.save.data.midscroll)
						i.visible = true;
				}
				else
				{
					i.active = false;
					i.visible = false;
				}
			}
		}

		if (updateFrame == 4)
		{
			TimingStruct.clearTimings();

			var currentIndex = 0;
			for (i in SONG.eventObjects)
			{
				if (i.type == "BPM Change")
				{
					var beat:Float = i.position;

					var endBeat:Float = Math.POSITIVE_INFINITY;

					var bpm = i.value;

					TimingStruct.addTiming(beat, bpm, endBeat, 0); // offset in this case = start time since we don't have a offset

					if (currentIndex != 0)
					{
						var data = TimingStruct.AllTimings[currentIndex - 1];
						data.endBeat = beat;
						data.length = (data.endBeat - data.startBeat) / (data.bpm / 60);
						var step = ((60 / data.bpm) * 1000) / 4;
						TimingStruct.AllTimings[currentIndex].startStep = Math.floor(((data.endBeat / (data.bpm / 60)) * 1000) / step);
						TimingStruct.AllTimings[currentIndex].startTime = data.startTime + data.length;
					}

					currentIndex++;
				}
			}

			updateFrame++;
		}
		else if (updateFrame != 5)
			updateFrame++;

		if (skipTime != 0)
		{
			if (Conductor.songPosition < skipTime && FlxG.keys.justPressed.SPACE)
			{
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition = skipTime;

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				skipTime = 0;
				remove(skipIntroText);
				skipIntroText.kill();
				skipIntroText.destroy();
			}
			else if ((Conductor.songPosition >= skipTime || FlxG.keys.justPressed.BACKSPACE) && skipIntroText != null)
			{
				skipTime = 0;
				FlxTween.tween(skipIntroText, {alpha: 0}, 1, {
					ease: FlxEase.quadIn,
					onComplete: function(twn:FlxTween)
					{
						remove(skipIntroText);
						skipIntroText.kill();
						skipIntroText.destroy();
					}
				});
			}
		}

		var timingSeg = TimingStruct.getTimingAtBeat(curDecimalBeat);

		if (timingSeg != null)
		{
			var timingSegBpm = timingSeg.bpm;

			if (timingSegBpm != Conductor.bpm)
			{
				trace("BPM CHANGE to " + timingSegBpm);
				Conductor.changeBPM(timingSegBpm, false);
				Conductor.crochet = (60 / (timingSegBpm) * 1000);
				Conductor.stepCrochet = Conductor.crochet / 4;
			}
		}

		var newScroll = PlayStateChangeables.scrollSpeed;

		if (SONG.eventObjects != null)
			for (i in SONG.eventObjects)
			{
				switch (i.type)
				{
					case "Scroll Speed Change":
						if (i.position <= curDecimalBeat && !pastScrollChanges.contains(i))
						{
							pastScrollChanges.push(i);
							trace("SCROLL SPEED CHANGE to " + i.value);
							newScroll = i.value;
						}
				}
			}

		PlayStateChangeables.scrollSpeed = newScroll;

		if (PlayStateChangeables.botPlay && FlxG.keys.justPressed.ONE)
			camHUD.visible = !camHUD.visible;

		if (useVideo && GlobalVideo.get() != null && !stopUpdate)
		{
			if (GlobalVideo.get().ended && !removedVideo)
			{
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}
		}

		#if cpp
		if (executeModchart && luaModchart != null && songStarted)
		{
			luaModchart.setVar('songPos', Conductor.songPosition);
			luaModchart.setVar('hudZoom', camHUD.zoom);
			luaModchart.setVar('curBeat', HelperFunctions.truncateFloat(curDecimalBeat, 3));
			luaModchart.setVar('cameraZoom', FlxG.camera.zoom);
			luaModchart.executeState('update', [elapsed]);

			for (key => value in luaModchart.luaWiggles)
			{
				trace('wiggle le gaming');
				value.update(elapsed);
			}

			/*for (i in 0...strumLineNotes.length) {
				var member = strumLineNotes.members[i];
				member.x = luaModchart.getVar("strum" + i + "X", "float");
				member.y = luaModchart.getVar("strum" + i + "Y", "float");
				member.angle = luaModchart.getVar("strum" + i + "Angle", "float");
			}*/

			// FlxG.camera.angle = luaModchart.getVar('cameraAngle', 'float');
			// camHUD.angle = luaModchart.getVar('camHudAngle', 'float');

			if (luaModchart.getVar("showOnlyStrums", 'bool'))
			{
				healthBarBG.visible = false;
				kadeEngineWatermark.visible = false;
				healthBar.visible = false;
				iconP1.visible = false;
				iconP2.visible = false;
				scoreTxt.visible = false;
			}
			else
			{
				healthBarBG.visible = true;
				kadeEngineWatermark.visible = true;
				healthBar.visible = true;
				iconP1.visible = true;
				iconP2.visible = true;
				scoreTxt.visible = true;
			}

			var p1 = luaModchart.getVar("strumLine1Visible", 'bool');
			var p2 = luaModchart.getVar("strumLine2Visible", 'bool');

			for (i in 0...4)
			{
				if (!FlxG.save.data.midscroll)
					strumLineNotes.members[i].visible = p1;
				if (i <= playerStrums.length)
					playerStrums.members[i].visible = p2;
			}
		}
		#end

		camNotes.zoom = camHUD.zoom;
		camNotes.x = camHUD.x;
		camNotes.y = camHUD.y;
		camNotes.angle = camHUD.angle;
		camNotes.visible = camHUD.visible;
		camSustains.zoom = camHUD.zoom;
		camSustains.x = camHUD.x;
		camSustains.y = camHUD.y;
		camSustains.angle = camHUD.angle;
		camSustains.visible = camHUD.visible;

		// reverse iterate to remove oldest notes first and not invalidate the iteration
		// stop iteration as soon as a note is not removed
		// all notes should be kept in the correct order and this is optimal, safe to do every frame/update
		{
			var balls = notesHitArray.length - 1;
			while (balls >= 0)
			{
				var cock:Date = notesHitArray[balls];
				if (cock != null && cock.getTime() + 1000 < Date.now().getTime())
					notesHitArray.remove(cock);
				else
					balls = 0;
				balls--;
			}
			nps = notesHitArray.length;
			if (nps > maxNPS)
				maxNPS = nps;
		}

		if (FlxG.keys.justPressed.NINE)
			iconP1.swapOldIcon();

		switch (curStage)
		{
			case 'philly':
				if (trainMoving && !PlayStateChangeables.Optimize)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
		}

		super.update(elapsed);

		scoreTxt.text = Ratings.CalculateRanking(songScore, songScoreDef, nps, maxNPS, accuracy);

		var lengthInPx = scoreTxt.textField.length * scoreTxt.frameHeight; // bad way but does more or less a better job

		scoreTxt.x = (originalX - (lengthInPx / 2)) + 335;

		if (controls.PAUSE && startedCountdown && canPause && !cannotDie)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				trace('GITAROO MAN EASTER EGG');
				FlxG.switchState(new GitarooPause());
				clean();
			}
			else
				openSubState(new PauseSubState(currentPlayer.getScreenPosition().x, currentPlayer.getScreenPosition().y));
		}

		if (FlxG.keys.justPressed.SEVEN && songStarted)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				#if sys
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				#end
				removedVideo = true;
			}
			cannotDie = true;
			#if cpp
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end

			FlxG.switchState(new ChartingState());
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(CoolUtil.coolLerp(150, iconP1.width, 0.5)));
		iconP2.setGraphicSize(Std.int(CoolUtil.coolLerp(150, iconP2.width, 0.5)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;

		var percent = (FlxG.save.data.playEnemy ? 100 - healthBar.percent : healthBar.percent);

		iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01) - iconOffset);
		iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);

		var p1thing = (FlxG.save.data.playEnemy ? iconP2 : iconP1);
		var p2thing = (!FlxG.save.data.playEnemy ? iconP2 : iconP1);

		if (health > 2)
			health = 2;
		if (healthBar.percent < 20)
			p1thing.animation.curAnim.curFrame = 1;
		else
			p1thing.animation.curAnim.curFrame = 0;

		if (healthBar.percent > 80)
			p2thing.animation.curAnim.curFrame = 1;
		else
			p2thing.animation.curAnim.curFrame = 0;

		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		#if debug
		if (FlxG.keys.justPressed.SIX)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(SONG.player2));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.EIGHT)
		{
			if (useVideo)
			{
				GlobalVideo.get().stop();
				remove(videoSprite);
				FlxG.stage.window.onFocusOut.remove(focusOut);
				FlxG.stage.window.onFocusIn.remove(focusIn);
				removedVideo = true;
			}

			FlxG.switchState(new AnimationDebug(SONG.gfVersion));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.FIVE)
		{
			FlxG.switchState(new AnimationDebug(SONG.player1, true));
			clean();
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
			FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
			#if cpp
			if (luaModchart != null)
			{
				luaModchart.die();
				luaModchart = null;
			}
			#end
		}

		if (FlxG.keys.justPressed.TWO)
		{ // Go 10 seconds into the future, credit: Shadow Mario#9396
			if (!usedTimeTravel && Conductor.songPosition + 10000 < FlxG.sound.music.length)
			{
				health = 2;
				usedTimeTravel = true;
				FlxG.sound.music.pause();
				vocals.pause();
				Conductor.songPosition += 10000;
				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.strumTime - 500 < Conductor.songPosition)
					{
						daNote.active = false;
						daNote.visible = false;

						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				});

				FlxG.sound.music.time = Conductor.songPosition;
				FlxG.sound.music.play();

				vocals.time = Conductor.songPosition;
				vocals.play();
				new FlxTimer().start(0.5, function(tmr:FlxTimer)
				{
					usedTimeTravel = false;
				});
			}
		}
		#end

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			// Conductor.songPosition = FlxG.sound.music.time;
			Conductor.songPosition += FlxG.elapsed * 1000;
			/*@:privateAccess
				{
					FlxG.sound.music._channel.
			}*/
			songPositionBar = Conductor.songPosition;
			if (FlxG.save.data.songPosition)
			{
				var remainingSeconds = (FlxG.sound.music.length - Conductor.songPosition) / 1000;
				var remainingMinutes = Math.floor(remainingSeconds / 60);
				remainingSeconds = Math.floor(Math.max(remainingSeconds % 60, 0));
				timeRemaining.text = Math.max(remainingMinutes, 0) + ":" + (remainingSeconds < 10 ? "0" : "") + remainingSeconds;
			}

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			closestNotes = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
					closestNotes.push(daNote);
			}); // Collect notes that can be hit

			closestNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

			if (closestNotes.length != 0)
				FlxG.watch.addQuick("Current Note", closestNotes[0].strumTime - Conductor.songPosition);

			// Make sure Girlfriend cheers only for certain songs
			if (allowedToHeadbang && !gf.curCharacter.startsWith('gf-cow') && gf.curCharacter != 'gf-pig')
			{
				// Don't animate GF if something else is already animating her (eg. train passing)
				if (gf.animation.curAnim.name == 'danceLeft'
					|| gf.animation.curAnim.name == 'danceRight'
					|| gf.animation.curAnim.name == 'idle')
				{
					// Per song treatment since some songs will only have the 'Hey' at certain times
					var songCheck = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase().split("-")[0];
					switch (songCheck)
					{
						case 'philly':
							{
								// General duration of the song
								if (curBeat < 250)
								{
									// Beats to skip or to stop GF from cheering
									if (curBeat != 184 && curBeat != 216)
									{
										if (curBeat % 16 == 8)
										{
											// Just a guarantee that it'll trigger just once
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'bopeebo':
							{
								// Where it starts || where it ends
								if (curBeat > 5 && curBeat < 130)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'blammed':
							{
								var cheerData:Map<String, Array<Array<Int>>> = [
									"Blammed" => [[34, 94], [128, 190]],
									"Blammed Week 4 Update" => [[34, 94], [128, 380]],
									"Blammed In-Game Version" => [[34, 94], [160, 220]]
								];
								var data = cheerData[SONG.song];
								if (data == null)
									data = cheerData["Blammed"];
								for (i in data)
								{
									if (curBeat < i[0] || curBeat > i[1])
										continue;
									if (curBeat % 4 == 2)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
						case 'cocoa':
							{
								if (curBeat < 170)
								{
									if (curBeat < 65 || curBeat > 130 && curBeat < 145)
									{
										if (curBeat % 16 == 15)
										{
											if (!triggeredAlready)
											{
												gf.playAnim('cheer');
												triggeredAlready = true;
											}
										}
										else
											triggeredAlready = false;
									}
								}
							}
						case 'eggnog':
							{
								if (curBeat > 10 && curBeat != 111 && curBeat < 220)
								{
									if (curBeat % 8 == 7)
									{
										if (!triggeredAlready)
										{
											gf.playAnim('cheer');
											triggeredAlready = true;
										}
									}
									else
										triggeredAlready = false;
								}
							}
					}
				}
			}

			#if cpp
			if (luaModchart != null)
				luaModchart.setVar("mustHit", PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			#end

			if (!inCutscene && !PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && camOnBf)
			{
				camOnBf = false;
				var offsetX = 0;
				var offsetY = 0;
				#if cpp
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}

				offsetX += stage.stageCamOffsets[1][0];
				offsetY += stage.stageCamOffsets[1][1];
				#end
				camFollow.setPosition(dad.getMidpoint().x + 150 + offsetX, dad.getMidpoint().y - 100 + offsetY);
				#if cpp
				if (luaModchart != null)
					luaModchart.executeState('playerTwoTurn', []);
				#end
				// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

				if (dad.characterData.cameraOffset != null)
					camFollow.setPosition(dad.getMidpoint().x
						+ dad.characterData.cameraOffset[0]
						+ offsetX,
						dad.getMidpoint().y
						+ dad.characterData.cameraOffset[1]
						+ offsetY);

				// var bruhMoment = dad.baseCharacter.split('-')[0];

				// switch (bruhMoment)
				// {
				// 	case 'mom':
				// 		camFollow.y = dad.getMidpoint().y;
				// 	case 'senpai':
				// 		camFollow.x = dad.getMidpoint().x - 100;
				// 		camFollow.y = dad.getMidpoint().y - 430;
				// }
			}

			if (!inCutscene && PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection && !camOnBf)
			{
				camOnBf = true;
				var offsetX = 0;
				var offsetY = 0;
				#if cpp
				if (luaModchart != null)
				{
					offsetX = luaModchart.getVar("followXOffset", "float");
					offsetY = luaModchart.getVar("followYOffset", "float");
				}
				#end
				if (boyfriend.characterData.cameraOffset != null)
				{
					offsetX += boyfriend.characterData.cameraOffset[0];
					offsetY += boyfriend.characterData.cameraOffset[1];
				}

				offsetX += stage.stageCamOffsets[0][0];
				offsetY += stage.stageCamOffsets[0][1];

				if (!inCutscene)
					camFollow.setPosition(boyfriend.getMidpoint().x - 100 + offsetX, boyfriend.getMidpoint().y - 100 + offsetY);

				#if cpp
				if (luaModchart != null)
					luaModchart.executeState('playerOneTurn', []);
				#end
			}
		}

		if (camZooming)
		{
			if (FlxG.save.data.zoom < 0.8)
				FlxG.save.data.zoom = 0.8;

			if (FlxG.save.data.zoom > 1.2)
				FlxG.save.data.zoom = 1.2;

			if (!executeModchart)
			{
				FlxG.camera.zoom = FlxMath.lerp(targetCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
			else
			{
				FlxG.camera.zoom = FlxMath.lerp(targetCamZoom, FlxG.camera.zoom, 0.95);
				camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);

				camNotes.zoom = camHUD.zoom;
				camSustains.zoom = camHUD.zoom;
			}
		}

		camNotes.zoom = camHUD.zoom;
		camSustains.zoom = camHUD.zoom;

		FlxG.watch.addQuick("curBPM", Conductor.bpm);

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);
		FlxG.watch.addQuick("Splat FX size shit", splatFXGroup.members.length);
		FlxG.watch.addQuick("Miss FX size shit", missFXGroup.members.length);

		/*if (curSong == 'Fresh')
			{
				switch (curBeat)
				{
					case 16:
						camZooming = true;
						gfSpeed = 2;
					case 48:
						gfSpeed = 1;
					case 80:
						gfSpeed = 2;
					case 112:
						gfSpeed = 1;
					case 163:
						// FlxG.sound.music.stop();
						// FlxG.switchState(new TitleState());
				}
		}*/
		/*
			if (curSong.startsWith('Bopeebo'))
			{
				switch (curBeat)
				{
					case 128, 129, 130:
						vocals.volume = 0;
						// FlxG.sound.music.stop();
						// FlxG.switchState(new PlayState());
				}
		}*/

		if (health <= 0 && !cannotDie)
		{
			if (!usedTimeTravel)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if cpp
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
			else
				health = 1;
		}
		if (!inCutscene && FlxG.save.data.resetButton)
		{
			if (FlxG.keys.justPressed.R)
			{
				boyfriend.stunned = true;

				persistentUpdate = false;
				persistentDraw = false;
				paused = true;

				vocals.stop();
				FlxG.sound.music.stop();

				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));

				#if cpp
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("GAME OVER -- "
					+ SONG.song
					+ " ("
					+ storyDifficultyText
					+ ") "
					+ Ratings.GenerateLetterRank(accuracy),
					"\nAcc: "
					+ HelperFunctions.truncateFloat(accuracy, 2)
					+ "% | Score: "
					+ songScore
					+ " | Misses: "
					+ misses, iconRPC);
				#end

				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
			}
		}

		if (generatedMusic)
		{
			var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];

			notes.forEachAlive(function(daNote:Note)
			{
				// instead of doing stupid y > FlxG.height
				// we be men and actually calculate the time :)
				if (daNote.tooLate)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					if (!daNote.mustPress && !FlxG.save.data.midscroll)
						daNote.visible = true;
					daNote.active = true;
				}
				var songLowercase = CoolUtil.lowerCaseSong(PlayState.SONG.song);

				if (!daNote.modifiedByLua)
				{
					if (PlayStateChangeables.useDownscroll)
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								+
								0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								- daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							// Remember: minus makes notes go up, plus makes them go down
							if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
								daNote.y += daNote.prevNote.height;
							else
								daNote.y += daNote.height / 2;

							// If not in botplay, only clip sustain notes when properly hit, botplay gets to clip it everytime
							if (!PlayStateChangeables.botPlay || !(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
							{
								if ((!daNote.mustPress
									|| daNote.wasGoodHit
									|| daNote.prevNote.wasGoodHit
									|| holdArray[Math.floor(Math.abs(daNote.noteData))]
									&& !daNote.tooLate
									&& daNote.sustainActive)
									&& daNote.y
									- daNote.offset.y * daNote.scale.y
									+ daNote.height >= (strumLine.y + Note.swagWidth / 2))
								{
									// Clip to strumline
									var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
									swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.y = daNote.frameHeight - swagRect.height;

									daNote.clipRect = swagRect;
								}
							}
							else
							{
								var swagRect = new FlxRect(0, 0, daNote.frameWidth * 2, daNote.frameHeight * 2);
								swagRect.height = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
									+ Note.swagWidth / 2
									- daNote.y) / daNote.scale.y;
								swagRect.y = daNote.frameHeight - swagRect.height;

								daNote.clipRect = swagRect;
							}
						}
					}
					else
					{
						if (daNote.mustPress)
							daNote.y = (playerStrums.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ daNote.noteYOff;
						else
							daNote.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
								- 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? SONG.speed : PlayStateChangeables.scrollSpeed,
									2))
								+ daNote.noteYOff;
						if (daNote.isSustainNote)
						{
							daNote.y -= daNote.height / 2;

							if (!(songLowercase == 'dad-battle-in-game-mix' && !daNote.mustPress && !FlxG.save.data.playEnemy))
							{
								if (!PlayStateChangeables.botPlay)
								{
									if ((!daNote.mustPress
										|| daNote.wasGoodHit
										|| daNote.prevNote.wasGoodHit
										|| holdArray[Math.floor(Math.abs(daNote.noteData))]
										&& !daNote.tooLate
										&& daNote.sustainActive)
										&& daNote.y
										+ daNote.offset.y * daNote.scale.y <= (strumLine.y + Note.swagWidth / 2))
									{
										// Clip to strumline
										var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
										swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
											+ Note.swagWidth / 2
											- daNote.y) / daNote.scale.y;
										swagRect.height -= swagRect.y;

										daNote.clipRect = swagRect;
									}
								}
								else
								{
									var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
									swagRect.y = (strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].y
										+ Note.swagWidth / 2
										- daNote.y) / daNote.scale.y;
									swagRect.height -= swagRect.y;

									daNote.clipRect = swagRect;
								}
							}
						}
					}
				}

				if (!daNote.mustPress
					&& daNote.wasGoodHit
					&& !(songLowercase == 'dad-battle-in-game-mix' && !FlxG.save.data.playEnemy)
					&& !daNote.isMine)
				{
					if (!SONG.song.startsWith('Tutorial'))
						camZooming = true;

					var altAnim:String = "";

					// if (SONG.notes[Math.floor(curStep / 16)] != null)
					// {
					// 	if (SONG.notes[Math.floor(curStep / 16)].p1AltAnim)
					// 		altAnim = '-alt';
					// }

					if (daNote.isAlt)
					{
						altAnim = '-alt';
						trace("YOO WTF THIS IS AN ALT NOTE????");
					}

					// Accessing the animation name directly to play it
					if (!daNote.isParent && daNote.parent != null)
					{
						if (daNote.spotInLine != daNote.parent.children.length - 1)
						{
							var singData:Int = Std.int(Math.abs(daNote.noteData));
							currentEnemy.playAnim('sing' + dataSuffix[singData] + altAnim, true);

							if (FlxG.save.data.cpuStrums)
							{
								cpuStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
								});
							}

							#if cpp
							if (luaModchart != null)
								luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
							#end

							currentEnemy.holdTimer = 0;

							if (SONG.needsVoices)
								vocals.volume = 1;
						}
					}
					else
					{
						var singData:Int = Std.int(Math.abs(daNote.noteData));
						currentEnemy.playAnim('sing' + dataSuffix[singData] + altAnim, true);

						if (FlxG.save.data.cpuStrums)
						{
							cpuStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
							});
						}

						#if cpp
						if (luaModchart != null)
							luaModchart.executeState('playerTwoSing', [Math.abs(daNote.noteData), Conductor.songPosition]);
						#end

						currentEnemy.holdTimer = 0;

						if (SONG.needsVoices)
							vocals.volume = 1;
					}
					daNote.active = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}
				else if (!daNote.mustPress
					&& ((!PlayStateChangeables.useDownscroll && daNote.y < -daNote.height)
						|| (PlayStateChangeables.useDownscroll && daNote.y > FlxG.height))
					&& !daNote.isMine)
				{
					if (!(daNote.isSustainNote && !daNote.isParent))
						noteMissFX(daNote.x, (FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}

				if (daNote.mustPress && !daNote.modifiedByLua)
				{
					daNote.visible = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote || daNote.isParent)
						daNote.modAngle = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = playerStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha * (daNote.isSustainNote ? 0.6 : 1);
					}
				}
				else if ((!daNote.wasGoodHit
					|| (!daNote.mustPress && songLowercase == 'dad-battle-in-game-mix' && !FlxG.save.data.playEnemy))
					&& !daNote.modifiedByLua)
				{
					if (!FlxG.save.data.midscroll)
						daNote.visible = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].visible;
					daNote.x = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].x;
					if (!daNote.isSustainNote || daNote.isParent)
						daNote.modAngle = strumLineNotes.members[Math.floor(Math.abs(daNote.noteData))].modAngle;
					if (daNote.sustainActive)
					{
						if (executeModchart)
							daNote.alpha = cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].alpha * (daNote.isSustainNote ? 0.6 : 1);
					}
				}

				if (daNote.isSustainNote)
				{
					daNote.x += daNote.width / 2 + 20;
					if (noteSkinData.type == 'pixel')
						daNote.x -= 11;
				}

				// trace(daNote.y);
				// WIP interpolation shit? Need to fix the pause issue
				// daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				if (daNote.isSustainNote && daNote.wasGoodHit && Conductor.songPosition >= daNote.strumTime)
				{
					if (!(!daNote.mustPress && songLowercase == 'dad-battle-in-game-mix' && !FlxG.save.data.playEnemy))
					{
						daNote.kill();
						notes.remove(daNote, true);
						daNote.destroy();
					}
				}
				else if (daNote.tooLate && daNote.mustPress && !daNote.isMine)
				{
					if (daNote.isSustainNote && daNote.wasGoodHit)
					{
						daNote.kill();
						notes.remove(daNote, true);
					}
					else
					{
						if (loadRep && daNote.isSustainNote)
						{
							// im tired and lazy this sucks I know i'm dumb
							if (findByTime(daNote.strumTime) != null)
								totalNotesHit += 1;
							else
							{
								if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
									vocals.volume = 0;
								if (theFunne && !daNote.isSustainNote)
								{
									noteMiss(daNote.noteData, daNote);
								}
								if (daNote.isParent)
								{
									if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
										health -= 0.15; // give a health punishment for failing a LN
									noteMissFX(daNote.x, (FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
									trace("hold fell over at the start");
									for (i in daNote.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
									}
								}
								else
								{
									if (!daNote.wasGoodHit
										&& daNote.isSustainNote
										&& daNote.sustainActive
										&& daNote.spotInLine != daNote.parent.children.length)
									{
										if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
											health -= 0.2; // give a health punishment for failing a LN
										noteMissFX((daNote.mustPress) ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x : cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].x,
											(FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
										trace("hold fell over at " + daNote.spotInLine);
										for (i in daNote.parent.children)
										{
											i.alpha = 0.3;
											i.sustainActive = false;
										}
										if (daNote.parent.wasGoodHit)
											misses++;
										updateAccuracy();
									}
									else
									{
										if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
											health -= 0.15;
										noteMissFX(daNote.x, (FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
									}
								}
							}
						}
						else
						{
							if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
								vocals.volume = 0;

							if (theFunne && !daNote.isSustainNote)
							{
								if (PlayStateChangeables.botPlay)
								{
									daNote.rating = "bad";
									goodNoteHit(daNote);
								}
								else
									noteMiss(daNote.noteData, daNote);
							}

							if (daNote.isParent)
							{
								if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
									health -= 0.15; // give a health punishment for failing a LN
								noteMissFX(daNote.x, (FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
								trace("hold fell over at the start");
								for (i in daNote.children)
								{
									i.alpha = 0.3;
									i.sustainActive = false;
									trace(i.alpha);
								}
							}
							else
							{
								if (!daNote.wasGoodHit
									&& daNote.isSustainNote
									&& daNote.sustainActive
									&& daNote.spotInLine != daNote.parent.children.length)
								{
									if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
										health -= 0.25; // give a health punishment for failing a LN
									noteMissFX((daNote.mustPress) ? playerStrums.members[Math.floor(Math.abs(daNote.noteData))].x : cpuStrums.members[Math.floor(Math.abs(daNote.noteData))].x,
										(FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
									trace("hold fell over at " + daNote.spotInLine);
									for (i in daNote.parent.children)
									{
										i.alpha = 0.3;
										i.sustainActive = false;
										trace(i.alpha);
									}
									if (daNote.parent.wasGoodHit)
										misses++;
									updateAccuracy();
								}
								else
								{
									if (!daNote.isSustainNote)
									{
										if (!(songLowercase == 'dad-battle-in-game-mix' && FlxG.save.data.playEnemy))
											health -= 0.15;
										noteMissFX(daNote.x, (FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
									}
								}
							}
						}
					}

					daNote.visible = false;
					daNote.kill();
					notes.remove(daNote, true);
				}
			});
		}

		if (FlxG.save.data.cpuStrums)
		{
			cpuStrums.forEach(function(spr:StaticArrow)
			{
				if (spr.animation.finished)
					spr.playAnim('static');
			});
			if (PlayStateChangeables.botPlay)
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					if (spr.animation.finished)
						spr.playAnim('static');
				});
			}
		}

		if (!inCutscene && songStarted)
			keyShit();

		#if debug
		if (FlxG.keys.justPressed.ONE)
			endSong();
		#end
	}

	function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
	{
		if (Math.abs(daNote.noteData) == idCheck)
		{
			if (!FlxG.save.data.stepMania)
			{
				spr.playAnim('confirm', true);
			}
			else
			{
				spr.localAngle = daNote.originAngle;
				spr.playAnim('dirCon' + daNote.originColor, true, daNote.mustPress);
			}

			if (noteHitSound != null && daNote.mustPress && (!daNote.isSustainNote || daNote.isParent) && !daNote.isMine)
				noteHitSound.play(true);

			var index = Std.int(curStep / 16);

			if (SONG.notes.length < index + 1)
				index = SONG.notes.length - 1;

			var mustHitSection = SONG.notes[index].mustHitSection;

			if (FlxG.save.data.playEnemy)
				mustHitSection = !mustHitSection;

			if (FlxG.save.data.camsway
				&& (!daNote.isSustainNote || daNote.isParent)
				&& (mustHitSection ? daNote.mustPress : !daNote.mustPress))
			{
				switch (daNote.noteData)
				{
					case 0:
						camGame.targetOffset.set(-15, 0);
					case 1:
						camGame.targetOffset.set(0, 15);
					case 2:
						camGame.targetOffset.set(0, -15);
					case 3:
						camGame.targetOffset.set(15, 0);
				}
			}

			if (FlxG.save.data.noteSplats
				&& ((daNote.rating == 'sick' || !daNote.mustPress) && (!daNote.isSustainNote || daNote.isParent))
				&& !daNote.isMine)
			{
				var receptorNum = Math.floor(Math.abs(daNote.noteData));
				var splat:NoteSplat = splatFXGroup.recycle(NoteSplat);
				splat.init(spr, receptorNum, (FlxG.save.data.stepMania) ? daNote.originColor : null);
				splat.cameras = [camNotes];
				add(splat);
			}
		}
	}

	public function endSong():Void
	{
		persistentUpdate = false;
		persistentDraw = true;
		endingSong = true;
		FlxG.sound.music.onComplete = null;
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleInput);
		FlxG.stage.removeEventListener(KeyboardEvent.KEY_UP, releaseInput);
		if (useVideo)
		{
			GlobalVideo.get().stop();
			FlxG.stage.window.onFocusOut.remove(focusOut);
			FlxG.stage.window.onFocusIn.remove(focusIn);
			PlayState.instance.remove(PlayState.instance.videoSprite);
		}

		if (!loadRep)
			rep.SaveReplay(saveNotes, saveJudge, replayAna);
		else
		{
			PlayStateChangeables.botPlay = false;
			PlayStateChangeables.scrollSpeed = 1;
			PlayStateChangeables.useDownscroll = false;
		}

		if (FlxG.save.data.fpsCap > 290)
			(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

		#if cpp
		if (luaModchart != null)
		{
			luaModchart.die();
			luaModchart = null;
		}
		#end

		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		FlxG.sound.music.pause();
		vocals.pause();
		trace(PlayStateChangeables.usedBotPlay);
		if (SONG.validScore && !PlayStateChangeables.usedBotPlay)
		{
			// adjusting the highscore song name to be compatible
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(PlayState.SONG.song, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			Highscore.saveScore(songHighscore, Math.round(songScore), storyDifficulty);
			Highscore.saveCombo(songHighscore, Ratings.GenerateLetterRank(accuracy), storyDifficulty);
			#end
		}

		if (offsetTesting)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			offsetTesting = false;
			LoadingState.loadAndSwitchState(new OptionsMenu());
			clean();
			FlxG.save.data.offset = offsetTest;
		}
		else
		{
			if (isStoryMode)
			{
				campaignScore += Math.round(songScore);
				campaignMisses += misses;
				campaignSicks += sicks;
				campaignGoods += goods;
				campaignBads += bads;
				campaignShits += shits;

				storyPlaylist.shift();

				#if sys
				var songe = StringTools.replace(SONG.song.toLowerCase(), " ", "-");
				if (FileSystem.exists('assets/data/SONGS/${songe}/${songe}-extra.json'))
				{
					var poop:String = Highscore.formatSong(songe, 3);
					var tempSong = Song.loadFromJson(poop, songe);
					StoryMenuState.unlockedExtras.push(SONG.song + " - " + tempSong.extraDiffDisplay);
				}
				#end

				if (storyPlaylist.length <= 0)
				{
					transIn = FlxTransitionableState.defaultTransIn;
					transOut = FlxTransitionableState.defaultTransOut;
					FlxG.sound.music.onComplete = null;
					paused = true;

					FlxG.sound.music.stop();
					vocals.stop();
					StoryMenuState.beatWeek = true;
					if (FlxG.save.data.scoreScreen && !loadRep)
					{
						openSubState(new ResultsScreen());
						camHUD.visible = true;
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							inResults = true;
						});
					}
					else
					{
						loadRep = false;
						rep = null;
						FlxG.sound.playMusic(Paths.music('freakyMenu'));
						Conductor.changeBPM(102);
						FlxG.switchState(new StoryMenuState());
						clean();
					}

					#if cpp
					if (luaModchart != null)
					{
						luaModchart.die();
						luaModchart = null;
					}
					#end

					if (SONG.validScore && !PlayStateChangeables.usedBotPlay)
					{
						NGio.unlockMedal(60961);
						Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
					}

					// StoryMenuState.unlockNextWeek(storyWeek);
				}
				else
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
					switch (songFormat)
					{
						case 'Dad-Battle':
							songFormat = 'Dadbattle';
						case 'Philly-Nice':
							songFormat = 'Philly';
					}

					var poop:String = Highscore.formatSong(songFormat, storyDifficulty);

					trace('LOADING NEXT SONG');
					trace(poop);
					var songe = StringTools.replace(PlayState.storyPlaylist[0], " ", "-").toLowerCase();
					var lightsOff = songe == 'fresh' || songe == 'winter-horrorland-short-version';
					if (lightsOff)
					{
						var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
							-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
						blackShit.scrollFactor.set();
						add(blackShit);
						camHUD.visible = false;

						FlxG.sound.play(Paths.sound('Lights_Shut_off'));
					}

					if (songe == "dad-battle-in-game-mix")
					{
						var screen = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.TRANSPARENT);
						var balls = new FlxGlitchEffect(10, 4);
						var screenGlitch = new FlxEffectSprite(screen, [balls]);
						add(screenGlitch);
						screenGlitch.scrollFactor.set();
						screen.drawFrame();
						var scrPix = screen.framePixels;
						if (FlxG.renderBlit)
							scrPix.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
						else
							scrPix.draw(FlxG.camera.canvas, new Matrix(1, 0, 0, 1, 0, 0));
						lightsOff = true;
						FlxG.sound.play(Paths.sound("crash", "shared"));
					}

					FlxTransitionableState.skipNextTransIn = true;
					FlxTransitionableState.skipNextTransOut = true;
					prevCamFollow = camFollow;
					FlxG.sound.music.stop();
					if (lightsOff)
					{
						new FlxTimer().start(1, function(tmr:FlxTimer)
						{
							PlayState.SONG = Song.conversionChecks(Song.loadFromJson(poop, PlayState.storyPlaylist[0]));
							LoadingState.loadAndSwitchState(new PlayState());
							clean();
						});
					}
					else
					{
						PlayState.SONG = Song.conversionChecks(Song.loadFromJson(poop, PlayState.storyPlaylist[0]));
						LoadingState.loadAndSwitchState(new PlayState());
						clean();
					}
				}
			}
			else
			{
				trace('WENT BACK TO FREEPLAY??');

				paused = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (FlxG.save.data.scoreScreen && !loadRep)
				{
					openSubState(new ResultsScreen());
					camHUD.visible = true;
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						inResults = true;
					});
				}
				else
				{
					loadRep = false;
					rep = null;
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					Conductor.changeBPM(102);
					FreeplayState.fromSong = true;
					FlxG.switchState(new FreeplayState());
					clean();
				}
			}
		}
	}

	var endingSong:Bool = false;
	var hits:Array<Float> = [];
	var offsetTest:Float = 0;
	var timeShown = 0;
	var currentTimingShown:FlxText = null;

	private function popUpScore(daNote:Note):Void
	{
		var noteDiff:Float = -(daNote.strumTime - Conductor.songPosition);
		var wife:Float = EtternaFunctions.wife3(-noteDiff, Conductor.timeScale);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;
		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55 + ((PlayStateChangeables.Optimize || FlxG.save.data.midscroll) ? 250 : 0);
		coolText.y -= 350;
		coolText.cameras = [camHUD];
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Float = 350;

		if (FlxG.save.data.accuracyMod == 1)
			totalNotesHit += wife;

		var daRating = daNote.rating;

		switch (daRating)
		{
			case 'shit':
				score = -300;
				combo = 0;
				misses++;
				if (SONG.song != 'Fresh Itch io Build')
					health -= 0.1;
				ss = false;
				shits++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit -= 1;
			case 'bad':
				daRating = 'bad';
				score = 0;
				if (SONG.song != 'Fresh Itch io Build')
					health -= 0.06;
				ss = false;
				bads++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.50;
			case 'good':
				if (storyDifficulty < 3 && SONG.song == 'Ballistic')
					health += 0.02;
				daRating = 'good';
				score = 200;
				ss = false;
				goods++;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 0.75;
			case 'sick':
				if (health < 2)
					health += 0.04;
				if (FlxG.save.data.accuracyMod == 0)
					totalNotesHit += 1;
				sicks++;
		}

		// trace('Wife accuracy loss: ' + wife + ' | Rating: ' + daRating + ' | Score: ' + score + ' | Weight: ' + (1 - wife));

		if (daRating != 'shit' || daRating != 'bad')
		{
			songScore += Math.round(score);
			songScoreDef += Math.round(ConvertScore.convertScore(noteDiff));

			/* if (combo > 60)
					daRating = 'sick';
				else if (combo > 12)
					daRating = 'good'
				else if (combo > 4)
					daRating = 'bad';
			 */

			var jamShit:String = "";
			var library:String = 'shared';

			if (SONG.song == "Spookeez In-Game Version" || SONG.song == "Ballistic Beta Mix")
			{
				jamShit = 'JAM/';
				library = 'week2';
			}

			var ratingCheck:String = (SONG.song == 'Fresh In-Game Version' && daRating == 'sick') ? 'gold' : daRating;

			if (jamShit != "" && ratingCheck != "gold")
				rating.loadGraphic(Paths.image(jamShit + ratingCheck, library));
			else
				rating.loadGraphic(Paths.image('uiskins/${noteSkinData.uiSkin}/$ratingCheck', 'shared'));

			rating.screenCenter();
			rating.y -= 50;
			rating.x = coolText.x - 125;

			if (FlxG.save.data.changedHit)
			{
				rating.x = FlxG.save.data.changedHitX;
				rating.y = FlxG.save.data.changedHitY;
			}
			rating.acceleration.y = 550;
			rating.velocity.y -= FlxG.random.int(140, 175);
			rating.velocity.x -= FlxG.random.int(0, 10);

			var msTiming = HelperFunctions.truncateFloat(noteDiff, 3);
			if (PlayStateChangeables.botPlay && !loadRep)
				msTiming = 0;

			if (loadRep)
				msTiming = HelperFunctions.truncateFloat(findByTime(daNote.strumTime)[3], 3);

			if (currentTimingShown != null)
				remove(currentTimingShown);

			currentTimingShown = new FlxText(0, 0, 0, "0ms");
			timeShown = 0;
			switch (daRating)
			{
				case 'shit' | 'bad':
					currentTimingShown.color = FlxColor.RED;
				case 'good':
					currentTimingShown.color = FlxColor.GREEN;
				case 'sick':
					currentTimingShown.color = FlxColor.CYAN;
			}
			currentTimingShown.borderStyle = OUTLINE;
			currentTimingShown.borderSize = 1;
			currentTimingShown.borderColor = FlxColor.BLACK;
			currentTimingShown.text = msTiming + "ms";
			currentTimingShown.size = 20;

			if (msTiming >= 0.03 && offsetTesting)
			{
				// Remove Outliers
				hits.shift();
				hits.shift();
				hits.shift();
				hits.pop();
				hits.pop();
				hits.pop();
				hits.push(msTiming);

				var total = 0.0;

				for (i in hits)
					total += i;

				offsetTest = HelperFunctions.truncateFloat(total / hits.length, 2);
			}

			if (currentTimingShown.alpha != 1)
				currentTimingShown.alpha = 1;

			if (!PlayStateChangeables.botPlay || loadRep)
				add(currentTimingShown);

			var comboSpr:FlxSprite = new FlxSprite();

			if (jamShit != "" && ratingCheck != "gold")
				comboSpr.loadGraphic(Paths.image(jamShit + 'combo', library));
			else
				comboSpr.loadGraphic(Paths.image('uiskins/${noteSkinData.uiSkin}/combo', 'shared'));

			comboSpr.screenCenter();
			comboSpr.x = rating.x;
			comboSpr.y = rating.y + 100;
			comboSpr.acceleration.y = 600;
			comboSpr.velocity.y -= 150;

			currentTimingShown.screenCenter();
			currentTimingShown.x = comboSpr.x + 100;
			currentTimingShown.y = rating.y + 100;
			currentTimingShown.acceleration.y = 600;
			currentTimingShown.velocity.y -= 150;

			comboSpr.velocity.x += FlxG.random.int(1, 10);
			currentTimingShown.velocity.x += comboSpr.velocity.x;
			if (!PlayStateChangeables.botPlay || loadRep)
				add(rating);

			if (noteSkinData.type != 'pixel')
			{
				rating.setGraphicSize(Std.int(rating.width * 0.7));
				rating.antialiasing = FlxG.save.data.antialiasing;
				comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
				comboSpr.antialiasing = FlxG.save.data.antialiasing;
			}
			else
			{
				rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
				comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
			}

			currentTimingShown.updateHitbox();
			comboSpr.updateHitbox();
			rating.updateHitbox();

			currentTimingShown.cameras = [camHUD];
			comboSpr.cameras = [camHUD];
			rating.cameras = [camHUD];

			var seperatedScore:Array<Int> = [];

			var comboSplit:Array<String> = (combo + "").split('');

			if (combo > highestCombo)
				highestCombo = combo;

			// make sure we have 3 digits to display (looks weird otherwise lol)
			if (comboSplit.length == 1)
			{
				seperatedScore.push(0);
				seperatedScore.push(0);
			}
			else if (comboSplit.length == 2)
				seperatedScore.push(0);

			for (i in 0...comboSplit.length)
			{
				var str:String = comboSplit[i];
				seperatedScore.push(Std.parseInt(str));
			}

			var daLoop:Int = 0;
			for (i in seperatedScore)
			{
				var numScore:FlxSprite = new FlxSprite();
				numScore.loadGraphic(Paths.image('uiskins/${noteSkinData.uiSkin}/num' + Std.int(i), 'shared'));
				numScore.screenCenter();
				numScore.x = rating.x + (43 * daLoop) - 50;
				numScore.y = rating.y + 100;
				numScore.cameras = [camHUD];

				if (noteSkinData.type != 'pixel')
				{
					numScore.antialiasing = FlxG.save.data.antialiasing;
					numScore.setGraphicSize(Std.int(numScore.width * 0.5));
				}
				else
				{
					numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
				}
				numScore.updateHitbox();

				numScore.acceleration.y = FlxG.random.int(200, 300);
				numScore.velocity.y -= FlxG.random.int(140, 160);
				numScore.velocity.x = FlxG.random.float(-5, 5);

				add(numScore);

				visibleCombos.push(numScore);

				FlxTween.tween(numScore, {alpha: 0}, 0.2, {
					onComplete: function(tween:FlxTween)
					{
						visibleCombos.remove(numScore);
						numScore.destroy();
					},
					onUpdate: function(tween:FlxTween)
					{
						if (!visibleCombos.contains(numScore))
						{
							tween.cancel();
							numScore.destroy();
						}
					},
					startDelay: Conductor.crochet * 0.002
				});

				if (visibleCombos.length > seperatedScore.length + 20)
				{
					for (i in 0...seperatedScore.length - 1)
					{
						visibleCombos.remove(visibleCombos[visibleCombos.length - 1]);
					}
				}

				daLoop++;
			}
			/* 
				trace(combo);
				trace(seperatedScore);
			 */

			coolText.text = Std.string(seperatedScore);
			// add(coolText);

			FlxTween.tween(rating, {alpha: 0}, 0.2, {
				startDelay: Conductor.crochet * 0.001,
				onUpdate: function(tween:FlxTween)
				{
					if (currentTimingShown != null)
						currentTimingShown.alpha -= 0.02;
					timeShown++;
				}
			});

			FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					coolText.destroy();
					comboSpr.destroy();
					if (currentTimingShown != null && timeShown >= 20)
					{
						remove(currentTimingShown);
						currentTimingShown = null;
					}
					rating.destroy();
				},
				startDelay: Conductor.crochet * 0.001
			});

			curSection += 1;
		}
	}

	/*function pressArrow(spr:StaticArrow, idCheck:Int, daNote:Note)
		{
			if ((daNote != null && Math.abs(daNote.noteData) == idCheck))
			{
				spr.playAnim('confirm', true);
			}
	}*/
	public function NearlyEquals(value1:Float, value2:Float, unimportantDifference:Float = 10):Bool
	{
		return Math.abs(FlxMath.roundDecimal(value1, 1) - FlxMath.roundDecimal(value2, 1)) < unimportantDifference;
	}

	var upHold:Bool = false;
	var downHold:Bool = false;
	var rightHold:Bool = false;
	var leftHold:Bool = false;

	// THIS FUNCTION JUST FUCKS WIT HELD NOTES AND BOTPLAY/REPLAY (also gamepad shit)

	private function keyShit():Void // I've invested in emma stocks
	{
		// control arrays, order L D R U
		var holdArray:Array<Bool> = [controls.LEFT, controls.DOWN, controls.UP, controls.RIGHT];
		var pressArray:Array<Bool> = [controls.LEFT_P, controls.DOWN_P, controls.UP_P, controls.RIGHT_P];
		var releaseArray:Array<Bool> = [controls.LEFT_R, controls.DOWN_R, controls.UP_R, controls.RIGHT_R];
		var keynameArray:Array<String> = ['left', 'down', 'up', 'right'];
		#if cpp
		if (luaModchart != null)
		{
			for (i in 0...pressArray.length)
			{
				if (pressArray[i] == true)
				{
					luaModchart.executeState('keyPressed', [keynameArray[i]]);
				}
			};

			for (i in 0...releaseArray.length)
			{
				if (releaseArray[i] == true)
				{
					luaModchart.executeState('keyReleased', [keynameArray[i]]);
				}
			};
		};
		#end

		// Prevent player input if botplay is on
		if (PlayStateChangeables.botPlay || (SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))
		{
			holdArray = [false, false, false, false];
			pressArray = [false, false, false, false];
			releaseArray = [false, false, false, false];
		}

		var anas:Array<Ana> = [null, null, null, null];

		for (i in 0...pressArray.length)
			if (pressArray[i])
				anas[i] = new Ana(Conductor.songPosition, null, false, "miss", i);

		// HOLDS, check for sustain notes
		if (holdArray.contains(true) && /*!boyfriend.stunned && */ generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdArray[daNote.noteData] && daNote.sustainActive)
				{
					// trace(daNote.sustainActive);
					goodNoteHit(daNote);
				}
			});
		}

		if ((KeyBinds.gamepad && !FlxG.keys.justPressed.ANY))
		{
			// PRESSES, check for note hits
			if (pressArray.contains(true) && generatedMusic)
			{
				currentPlayer.holdTimer = 0;

				var possibleNotes:Array<Note> = []; // notes that can be hit
				var directionList:Array<Int> = []; // directions that can be hit
				var dumbNotes:Array<Note> = []; // notes to kill later
				var directionsAccounted:Array<Bool> = [false, false, false, false]; // we don't want to do judgments for more than one presses

				notes.forEachAlive(function(daNote:Note)
				{
					if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit && !directionsAccounted[daNote.noteData])
					{
						if (directionList.contains(daNote.noteData))
						{
							directionsAccounted[daNote.noteData] = true;
							for (coolNote in possibleNotes)
							{
								if (coolNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - coolNote.strumTime) < 10)
								{ // if it's the same note twice at < 10ms distance, just delete it
									// EXCEPT u cant delete it in this loop cuz it fucks with the collection lol
									dumbNotes.push(daNote);
									break;
								}
								else if (coolNote.noteData == daNote.noteData && daNote.strumTime < coolNote.strumTime)
								{ // if daNote is earlier than existing note (coolNote), replace
									possibleNotes.remove(coolNote);
									possibleNotes.push(daNote);
									break;
								}
							}
						}
						else
						{
							directionsAccounted[daNote.noteData] = true;
							possibleNotes.push(daNote);
							directionList.push(daNote.noteData);
						}
					}
				});

				for (note in dumbNotes)
				{
					FlxG.log.add("killing dumb ass note at " + note.strumTime);
					note.kill();
					notes.remove(note, true);
					note.destroy();
				}

				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));

				var hit = [false, false, false, false];

				if (perfectMode)
					goodNoteHit(possibleNotes[0]);
				else if (possibleNotes.length > 0)
				{
					if (!FlxG.save.data.ghost && notes.length != 0)
					{
						trace(unspawnNotes.length);
						checkBadInput(pressArray);
					}
					for (coolNote in possibleNotes)
					{
						if (pressArray[coolNote.noteData] && !hit[coolNote.noteData])
						{
							trace('note hit');
							if (!coolNote.isMine)
							{
								if (mashViolations != 0)
									mashViolations--;
								hit[coolNote.noteData] = true;
								scoreTxt.color = FlxColor.WHITE;
								var noteDiff:Float = -(coolNote.strumTime - Conductor.songPosition);
								anas[coolNote.noteData].hit = true;
								anas[coolNote.noteData].hitJudge = Ratings.CalculateRating(noteDiff,
									Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
								anas[coolNote.noteData].nearestNote = [coolNote.strumTime, coolNote.noteData, coolNote.sustainLength];
								goodNoteHit(coolNote);
								trace('good note hit');
							}
							else
							{
								mineHit(coolNote);
							}
						}
					}
				};

				if (currentPlayer.holdTimer > Conductor.stepCrochet * 4 * 0.001
					&& (!holdArray.contains(true)
						|| (PlayStateChangeables.botPlay && !(SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))))
				{
					if (currentPlayer.animation.curAnim.name.startsWith('sing')
						&& !currentPlayer.animation.curAnim.name.endsWith('miss')
						&& (currentPlayer.animation.curAnim.curFrame >= 10 || currentPlayer.animation.curAnim.finished))
						currentPlayer.dance();
				}
				else if (!FlxG.save.data.ghost && notes.length != 0)
				{
					trace(unspawnNotes.length);
					checkBadInput(pressArray);
				}
			}

			if (!loadRep)
				for (i in anas)
					if (i != null)
						replayAna.anaArray.push(i); // put em all there
		}
		if (PlayStateChangeables.botPlay && !(SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))
			notes.forEachAlive(function(daNote:Note)
			{
				var diff = -(daNote.strumTime - Conductor.songPosition);

				daNote.rating = Ratings.CalculateRating(diff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));
				if (!daNote.isMine && (daNote.mustPress && daNote.rating == "sick" || (diff > 0 && daNote.mustPress)))
				{
					// Force good note hit regardless if it's too late to hit it or not as a fail safe
					if (loadRep)
					{
						// trace('ReplayNote ' + tmpRepNote.strumtime + ' | ' + tmpRepNote.direction);
						var n = findByTime(daNote.strumTime);
						trace(n);
						if (n != null)
						{
							goodNoteHit(daNote);
							currentPlayer.holdTimer = daNote.sustainLength;
							if (FlxG.save.data.cpuStrums)
							{
								playerStrums.forEach(function(spr:StaticArrow)
								{
									pressArrow(spr, spr.ID, daNote);
								});
							}
						}
					}
					else
					{
						goodNoteHit(daNote);
						currentPlayer.holdTimer = daNote.sustainLength;
						if (FlxG.save.data.cpuStrums)
						{
							playerStrums.forEach(function(spr:StaticArrow)
							{
								pressArrow(spr, spr.ID, daNote);
							});
						}
					}
				}
			});

		if (currentPlayer.holdTimer > Conductor.stepCrochet * 4 * 0.001
			&& (!holdArray.contains(true)
				|| (PlayStateChangeables.botPlay && !(SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))))
		{
			if (currentPlayer.animation.curAnim.name.startsWith('sing')
				&& !currentPlayer.animation.curAnim.name.endsWith('miss')
				&& (currentPlayer.animation.curAnim.curFrame >= 10 || currentPlayer.animation.curAnim.finished))
				currentPlayer.dance();
		}

		if (!PlayStateChangeables.botPlay || (SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))
		{
			playerStrums.forEach(function(spr:StaticArrow)
			{
				if (keys[spr.ID]
					&& spr.animation.curAnim.name != 'confirm'
					&& spr.animation.curAnim.name != 'pressed'
					&& !spr.animation.curAnim.name.startsWith('dirCon'))
					spr.playAnim('pressed', false);
				if (!keys[spr.ID])
					spr.playAnim('static', false);
			});
		}
	}

	public function findByTime(time:Float):Array<Dynamic>
	{
		for (i in rep.replay.songNotes)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (i[0] == time)
				return i;
		}
		return [0, 0, 0, 0];
	}

	public function findByTimeIndex(time:Float):Int
	{
		for (i in 0...rep.replay.songNotes.length)
		{
			// trace('checking ' + Math.round(i[0]) + ' against ' + Math.round(time));
			if (rep.replay.songNotes[i][0] == time)
				return i;
		}
		return -1;
	}

	public var fuckingVolume:Float = 1;
	public var useVideo = false;

	public static var webmHandler:WebmHandler;

	public var playingDathing = false;
	public var videoSprite:FlxSprite;

	public function focusOut()
	{
		if (paused)
			return;
		persistentUpdate = false;
		persistentDraw = true;
		paused = true;

		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.pause();
			vocals.pause();
		}

		openSubState(new PauseSubState(currentPlayer.getScreenPosition().x, currentPlayer.getScreenPosition().y));
	}

	public function focusIn()
	{
		// nada
		// h
	}

	function checkBadInput(pressArray:Array<Bool>, ?data:Int, ?ana:Ana)
	{
		var p1Notes = [];
		if (FlxG.save.data.missMs < 1010)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.mustPress
					&& !daNote.tooLate
					&& !daNote.wasGoodHit
					&& !(daNote.strumTime - Conductor.songPosition > FlxG.save.data.missMs
						|| daNote.strumTime - Conductor.songPosition < -FlxG.save.data.missMs))
					p1Notes.push(daNote);
			});

			p1Notes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
		}

		if (p1Notes.length != 0 || FlxG.save.data.missMs == 1010)
		{
			if (pressArray == null)
			{
				noteMiss(data, null);
				ana.hit = false;
				ana.hitJudge = "shit";
				ana.nearestNote = [];
				health -= 0.20;
				trace('bad input lmao idiot');
			}
			else
				for (shit in 0...pressArray.length)
					if (pressArray[shit])
						noteMiss(shit, null);
		}
	}

	public function backgroundVideo(source:String) // for background videos
	{
		#if cpp
		useVideo = true;

		FlxG.stage.window.onFocusOut.add(focusOut);
		FlxG.stage.window.onFocusIn.add(focusIn);

		var ourSource:String = "assets/videos/daWeirdVid/dontDelete.webm";
		// WebmPlayer.SKIP_STEP_LIMIT = 90;
		var str1:String = "WEBM SHIT";
		webmHandler = new WebmHandler();
		webmHandler.source(ourSource);
		webmHandler.makePlayer();
		webmHandler.webm.name = str1;

		GlobalVideo.setWebm(webmHandler);

		GlobalVideo.get().source(source);
		GlobalVideo.get().clearPause();
		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().updatePlayer();
		}
		GlobalVideo.get().show();

		if (GlobalVideo.isWebm)
		{
			GlobalVideo.get().restart();
		}
		else
		{
			GlobalVideo.get().play();
		}

		var data = webmHandler.webm.bitmapData;

		videoSprite = new FlxSprite(-470, -30).loadGraphic(data);

		videoSprite.setGraphicSize(Std.int(videoSprite.width * 1.2));

		remove(gf);
		remove(boyfriend);
		remove(dad);
		add(videoSprite);
		add(gf);
		add(boyfriend);
		add(dad);

		trace('poggers');

		if (!songStarted)
			webmHandler.pause();
		else
			webmHandler.resume();
		#end
	}

	function noteMiss(direction:Int = 1, daNote:Note):Void
	{
		if (!boyfriend.stunned)
		{
			// health -= 0.2;
			if (combo > 5 && gf.animOffsets.exists('sad') && !FlxG.save.data.playEnemy)
			{
				if (gf.curCharacter != "gf-sus" && !(gf.curCharacter == 'gf-whitty' && curSong.startsWith('Ballistic')))
					gf.playAnim('sad');
			}
			combo = 0;
			misses++;

			if (daNote != null)
			{
				noteMissFX(daNote.x, (FlxG.save.data.stepMania) ? daNote.originColor : daNote.noteData);
				if (!loadRep)
				{
					saveNotes.push([
						daNote.strumTime,
						0,
						direction,
						166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
					]);
					saveJudge.push("miss");
				}
			}
			else if (!loadRep)
			{
				saveNotes.push([
					Conductor.songPosition,
					0,
					direction,
					166 * Math.floor((PlayState.rep.replay.sf / 60) * 1000) / 166
				]);
				saveJudge.push("miss");
			}

			// var noteDiff:Float = Math.abs(daNote.strumTime - Conductor.songPosition);
			// var wife:Float = EtternaFunctions.wife3(noteDiff, FlxG.save.data.etternaMode ? 1 : 1.7);

			if (FlxG.save.data.accuracyMod == 1)
				totalNotesHit -= 1;

			if (daNote != null)
			{
				if (!daNote.isSustainNote)
					songScore -= 10;
			}
			else
				songScore -= 10;

			if (FlxG.save.data.missSounds && !(SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))
			{
				FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
				// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
				// FlxG.log.add('played imss note');
			}

			// Hole switch statement replaced with a single line :)
			if (!(SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))
				if (currentPlayer.animation.getByName('sing' + dataSuffix[direction] + 'miss') != null)
					currentPlayer.playAnim('sing' + dataSuffix[direction] + 'miss', true);

			#if cpp
			if (luaModchart != null)
				luaModchart.executeState('playerOneMiss', [direction, Conductor.songPosition]);
			#end

			updateAccuracy();
		}
	}

	function updateAccuracy()
	{
		totalPlayed += 1;
		accuracy = Math.max(0, totalNotesHit / totalPlayed * 100);
		accuracyDefault = Math.max(0, totalNotesHitDefault / totalPlayed * 100);
	}

	function getKeyPresses(note:Note):Int
	{
		var possibleNotes:Array<Note> = []; // copypasted but you already know that

		notes.forEachAlive(function(daNote:Note)
		{
			if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate)
			{
				possibleNotes.push(daNote);
				possibleNotes.sort((a, b) -> Std.int(a.strumTime - b.strumTime));
			}
		});
		if (possibleNotes.length == 1)
			return possibleNotes.length + 1;
		return possibleNotes.length;
	}

	var mashing:Int = 0;
	var mashViolations:Int = 0;
	var etternaModeScore:Int = 0;

	function noteCheck(controlArray:Array<Bool>, note:Note):Void // sorry lol
	{
		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		note.rating = Ratings.CalculateRating(noteDiff, Math.floor((PlayStateChangeables.safeFrames / 60) * 1000));

		/* if (loadRep)
			{
				if (controlArray[note.noteData])
					goodNoteHit(note, false);
				else if (rep.replay.keyPresses.length > repPresses && !controlArray[note.noteData])
				{
					if (NearlyEquals(note.strumTime,rep.replay.keyPresses[repPresses].time, 4))
					{
						goodNoteHit(note, false);
					}
				}
		}*/

		if (controlArray[note.noteData])
		{
			goodNoteHit(note, (mashing > getKeyPresses(note)));
		}
	}

	function goodNoteHit(note:Note, resetMashViolation = true):Void
	{
		if (mashing != 0)
			mashing = 0;

		var noteDiff:Float = -(note.strumTime - Conductor.songPosition);

		if (loadRep)
		{
			noteDiff = findByTime(note.strumTime)[3];
			note.rating = rep.replay.songJudgements[findByTimeIndex(note.strumTime)];
		}
		else
			note.rating = Ratings.CalculateRating(noteDiff);

		if (note.rating == "miss")
			return;

		// add newest note to front of notesHitArray
		// the oldest notes are at the end and are removed first
		if (!note.isSustainNote)
			notesHitArray.unshift(Date.now());

		if (!resetMashViolation && mashViolations >= 1)
			mashViolations--;

		if (mashViolations < 0)
			mashViolations = 0;

		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note);
				combo += 1;
			}
			else
				totalNotesHit += 1;

			var altAnim:String = "";
			if (note.isAlt)
			{
				altAnim = '-alt';
				trace("Alt note on BF");
			}

			currentPlayer.playAnim('sing' + dataSuffix[note.noteData] + altAnim, true);

			#if cpp
			if (luaModchart != null)
				luaModchart.executeState('playerOneSing', [note.noteData, Conductor.songPosition]);
			#end

			if (!loadRep && note.mustPress)
			{
				var array = [note.strumTime, note.sustainLength, note.noteData, noteDiff];
				if (note.isSustainNote)
					array[1] = -1;
				saveNotes.push(array);
				saveJudge.push(note.rating);
			}

			if (!PlayStateChangeables.botPlay || (SONG.song == 'Dad Battle In-Game Mix' && FlxG.save.data.playEnemy))
			{
				playerStrums.forEach(function(spr:StaticArrow)
				{
					pressArrow(spr, spr.ID, note);
					/*if (Math.abs(note.noteData) == spr.ID)
						{
							spr.animation.play('confirm', true);
					}*/
				});
			}

			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
			}
			else
			{
				note.wasGoodHit = true;
			}

			updateAccuracy();
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		if (FlxG.save.data.distractions)
		{
			stage.swagBacks.get('fastCar').x = -12600;
			stage.swagBacks.get('fastCar').y = FlxG.random.int(140, 250);
			stage.swagBacks.get('fastCar').velocity.x = 0;
			fastCarCanDrive = true;
		}
	}

	function fastCarDrive()
	{
		if (FlxG.save.data.distractions)
		{
			FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

			stage.swagBacks.get('fastCar').velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
			fastCarCanDrive = false;
			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				resetFastCar();
			});
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;
	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		if (FlxG.save.data.distractions)
		{
			trainMoving = true;
			if (!stage.swagSounds['trainSound'].playing)
				stage.swagSounds['trainSound'].play(true);
		}
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (FlxG.save.data.distractions)
		{
			if (stage.swagSounds['trainSound'].time >= 4700)
			{
				startedMoving = true;
				gf.playAnim('hairBlow');
			}

			if (startedMoving)
			{
				stage.swagBacks.get('phillyTrain').x -= 400;

				if (stage.swagBacks.get('phillyTrain').x < -2000 && !trainFinishing)
				{
					stage.swagBacks.get('phillyTrain').x = -1150;
					trainCars -= 1;

					if (trainCars <= 0)
						trainFinishing = true;
				}

				if (stage.swagBacks.get('phillyTrain').x < -4000 && trainFinishing)
					trainReset();
			}
		}
	}

	function trainReset():Void
	{
		if (FlxG.save.data.distractions)
		{
			gf.playAnim('hairFall');
			stage.swagBacks.get('phillyTrain').x = FlxG.width + 200;
			trainMoving = false;
			// trainSound.stop();
			// trainSound.time = 0;
			trainCars = 8;
			trainFinishing = false;
			startedMoving = false;
		}
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		cast(stage.swagBacks.get('halloweenBG'), FlxSprite).animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	var danced:Bool = false;

	override function stepHit()
	{
		super.stepHit();
		if (FlxG.sound.music.time > Conductor.songPosition + 20 || FlxG.sound.music.time < Conductor.songPosition - 20)
		{
			resyncVocals();
		}

		if (SONG.song == "Hungry")
		{
			// switch (curStep)
			// {
			// 	case 66:
			// 		boyfriend.playAnim("pogstart", true);
			// 	case 72:
			// 		boyfriend.playAnim("poglook", true);
			// 	case 78:
			// 		boyfriend.playAnim("pogpoint", true);
			// 	case 288:
			// 		remove(stage.swagBacks['da_bg']);
			// 	case 610:
			// 		stage.swagBacks['ratsAss'].visible = true;
			// 		dad.playAnim("bruh", true);
			// 		camHUD.visible = false;
			// 		camZooming = false;
			// 		camFollow.setPosition(530, 380);
			// 		FlxTween.tween(camGame, {zoom: 2.8}, 7.8, {ease: FlxEase.sineInOut});
			// }
		}

		if (SONG.song == "Dad Battle In-Game Mix" && curStep == 626)
		{
			var screen = new FlxSprite(-FlxG.width, -FlxG.height).makeGraphic(FlxG.width * 4, FlxG.height * 4, FlxColor.TRANSPARENT);
			var balls = new FlxGlitchEffect(10, 4);
			var screenGlitch = new FlxEffectSprite(screen, [balls]);
			add(screenGlitch);
			screenGlitch.scrollFactor.set();
			screen.drawFrame();
			var scrPix = screen.framePixels;
			if (FlxG.renderBlit)
				scrPix.copyPixels(FlxG.camera.buffer, FlxG.camera.buffer.rect, new Point());
			else
				scrPix.draw(FlxG.camera.canvas, new Matrix());
			var glitchImg = new FlxSprite().loadGraphic(Paths.image("glitch", "shared"));
			glitchImg.setGraphicSize(FlxG.width, FlxG.height);
			glitchImg.cameras = [camHUD];
			glitchImg.updateHitbox();
			glitchImg.screenCenter();
			glitchImg.alpha = 0.5;
			add(glitchImg);
			new FlxTimer().start((60 / Conductor.bpm) * 2, function(tmr:FlxTimer)
			{
				remove(screenGlitch);
				screen.destroy();
				balls.destroy();
				screenGlitch.destroy();
				remove(glitchImg);
				glitchImg.destroy();
			});
		}

		#if cpp
		if (executeModchart && luaModchart != null)
		{
			luaModchart.setVar('curStep', curStep);
			luaModchart.executeState('stepHit', [curStep]);
		}
		#end

		// yes this updates every step.
		// yes this is bad
		// but i'm doing it to update misses and accuracy
		#if cpp
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText
			+ " "
			+ SONG.song
			+ " ("
			+ storyDifficultyText
			+ ") "
			+ Ratings.GenerateLetterRank(accuracy),
			"Acc: "
			+ HelperFunctions.truncateFloat(accuracy, 2)
			+ "% | Score: "
			+ songScore
			+ " | Misses: "
			+ misses, iconRPC, true,
			songLength
			- Conductor.songPosition);
		#end
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	public var bumpEvery:Int = 4;
	public var bumpZooms:Array<Float> = [0.015, 0.03];

	override function beatHit()
	{
		super.beatHit();

		if (!PlayStateChangeables.Optimize)
			switch (StringTools.replace(SONG.song.toLowerCase(), ' ', '-'))
			{
				case 'philly':
					{
						switch (curBeat)
						{
							case 40:
								// Thank the lawd for the setFrames method, I was about to give up on saving the animations and
								// just do some funky shit where I make gf a different character and then re-add every object but
								// this works much better
								#if sys
								gf.setFrames(songCache.fromSparrow('gf-cow', 'characters/GFs/GF_cow', 'shared'), true);
								#else
								gf.setFrames(Paths.getSparrowAtlas('GFs/GF_cow', 'shared', true), true);
								#end
							case 264:
								#if sys
								gf.setFrames(songCache.fromSparrow('gf-cowidle', 'characters/GFs/GF_cowidle', 'shared'), true);
								#else
								gf.setFrames(Paths.getSparrowAtlas('GFs/GF_cowidle', 'shared', true), true);
								#end
						}
					}
				case 'winter-horrorland-short-version':
					{
						switch (curBeat)
						{
							case 24:
								#if sys
								dad.setFrames(songCache.fromSparrow('BEANED', 'characters/Monsters/monsterChristmas_bean', 'shared'), true);
								#else
								dad.setFrames(Paths.getSparrowAtlas('Monsters/monsterChristmas_bean', 'shared', true), true);
								#end
						}
					}
				case 'dad-battle':
					{
						if (curBeat == 224)
						{
							add(blueBallsLMAO);
							remove(boyfriend);
							blueBallsLMAO.playAnim('firstDeath', true);
							FlxG.sound.play(Paths.sound('fnf_loss_sfx'));
						}
					}
				case 'the-fab-fairies-dance':
					switch (curBeat)
					{
						case 5:
							var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image("uiskins/normal/ready", "shared"));
							ready.scrollFactor.set();
							ready.updateHitbox();
							ready.screenCenter();
							add(ready);
							FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									ready.destroy();
								}
							});
						case 6:
							var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image("uiskins/normal/set", "shared"));
							set.scrollFactor.set();
							set.screenCenter();
							add(set);
							FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									set.destroy();
								}
							});
						case 7:
							var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image("uiskins/normal/go", "shared"));
							go.scrollFactor.set();
							go.updateHitbox();
							go.screenCenter();
							add(go);
							FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
								ease: FlxEase.cubeInOut,
								onComplete: function(twn:FlxTween)
								{
									go.destroy();
								}
							});
					}
			}

		if (generatedMusic)
			notes.sort(FlxSort.byY, (PlayStateChangeables.useDownscroll ? FlxSort.ASCENDING : FlxSort.DESCENDING));

		#if cpp
		if (executeModchart && luaModchart != null)
			luaModchart.executeState('beatHit', [curBeat]);
		#end

		if (curSong.startsWith("Tutorial") && dad.curCharacter.startsWith('gf') && SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
				dad.dance();
			else
			{
				if (curBeat == 73 || curBeat % 4 == 0 || curBeat % 4 == 1)
					dad.playAnim('danceLeft', true);
				else
					dad.playAnim('danceRight', true);
			}
		}
		// else
		// Conductor.changeBPM(SONG.bpm);

		// Dad doesnt interupt his own notes
		if ((!currentEnemy.animation.curAnim.name.startsWith("sing")) && !currentEnemy.curCharacter.startsWith('gf'))
			if ((curBeat % idleBeat == 0 || !idleToBeat) || currentEnemy.biDirectional)
				if (SONG.notes[Math.floor(curStep / 16)] != null)
					currentEnemy.dance(idleToBeat, SONG.notes[Math.floor(curStep / 16)].p1AltAnim);
				else
					currentEnemy.dance(idleToBeat, false);
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (FlxG.save.data.camzoom)
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase().startsWith('milf') && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}

			if (bumpEvery > 0 && camZooming && FlxG.camera.zoom < 1.35 && curBeat % bumpEvery == 0)
			{
				FlxG.camera.zoom += bumpZooms[0];
				camHUD.zoom += bumpZooms[1];
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
			if (!(gf.curCharacter == 'gf-whitty' && curSong.startsWith('Ballistic')))
				gf.dance();

		if (!currentPlayer.animation.curAnim.name.startsWith("sing")
			&& ((curBeat % idleBeat == 0 || currentPlayer.biDirectional) || !idleToBeat)
			&& !(SONG.song == 'Fresh Vocal Mix' && Math.floor(curBeat) == 16))
		{
			currentPlayer.dance(idleToBeat, ((Math.floor(curStep / 16) < SONG.notes.length) && (SONG.notes[Math.floor(curStep / 16)].p2AltAnim
				&& currentPlayer.animation.getByName('idle-alt') != null)));
		}

		if (curSong.startsWith('Bopeebo'))
		{
			var inBetween = function(a:Int, b:Int):Bool
			{
				return curBeat >= a && curBeat < b;
			}
			var heyIsForHorses = false;
			switch (curSong)
			{
				case "Bopeebo Beta Mix":
					heyIsForHorses = curBeat % 8 == 7 && curBeat % 32 != 23 && curBeat < 126;
				case "Bopeebo Extended Version" | "Bopeebo Really Long Version":
					heyIsForHorses = curBeat % 8 == 7 && curBeat < 64;
				case "Bopeebo In-Game Version":
					heyIsForHorses = curBeat % 8 == 7 && curBeat > 32 && curBeat < 128;
				case "Bopeebo Newgrounds Build":
					if ((inBetween(0, 24) && inBetween(120, 128)))
						heyIsForHorses = curBeat % 8 == 7;
					else
						heyIsForHorses = curBeat % 16 == 7;
			}
			if (heyIsForHorses)
				boyfriend.playAnim('hey', true);
		}

		if (curBeat % 16 == 15
			&& SONG.song.startsWith("Tutorial")
			&& dad.curCharacter.startsWith('gf')
			&& curBeat > 16
			&& curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			if (dad.curCharacter != 'gf-yankin')
				dad.playAnim('cheer', true);
		}
		if (FlxG.save.data.distractions && !PlayStateChangeables.Optimize)
		{
			for (dancer in stage.swagDancers)
				dancer.dance(curBeat);
			for (group in stage.swagDancerGroup)
				for (dancer in group)
					dancer.dance(curBeat);
		}

		switch (curStage)
		{
			case 'arcade':
				if (curBeat % 2 == 0 && FlxG.save.data.distractions)
				{
					stage.swagGroup.get('phillyCityLights').forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, stage.swagGroup.get('phillyCityLights').length - 1);

					stage.swagGroup.get('phillyCityLights').members[curLight].visible = true;
				}
				if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 2 == 0)
				{
					FlxG.camera.zoom += 0.016;
					camHUD.zoom += 0.015;
				}
			case 'limo':
				if (FlxG.save.data.distractions)
				{
					if (FlxG.random.bool(10) && fastCarCanDrive)
						fastCarDrive();
				}
			case "philly":
				if (FlxG.save.data.distractions)
				{
					if (!trainMoving)
						trainCooldown += 1;

					if (curBeat % 4 == 0)
					{
						stage.swagGroup.get('phillyCityLights').forEach(function(light:FlxSprite)
						{
							light.visible = false;
							light.alpha = 1;
						});

						curLight = FlxG.random.int(0, stage.swagGroup.get('phillyCityLights').length - 1);

						stage.swagGroup.get('phillyCityLights').members[curLight].visible = true;

						FlxTween.tween(stage.swagGroup.get('phillyCityLights').members[curLight], {alpha: 0}, (Conductor.crochet / 1000) * 3.8);
					}
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					if (FlxG.save.data.distractions)
					{
						trainCooldown = FlxG.random.int(-4, 0);
						trainStart();
					}
				}
		}

		if (!PlayStateChangeables.Optimize
			&& stage.halloweenLevel
			&& FlxG.random.bool(10)
			&& curBeat > lightningStrikeBeat + lightningOffset)
		{
			if (FlxG.save.data.distractions)
			{
				lightningStrikeShit();
			}
		}
	}

	var curLight:Int = 0;
}
