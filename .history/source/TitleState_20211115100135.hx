package;

#if sys
import smTools.SMFile;
#end
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.transition.FlxTransitionSprite.GraphicTransTileDiamond;
import flixel.addons.transition.FlxTransitionableState;
import flixel.addons.transition.TransitionData;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.system.ui.FlxSoundTray;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;
import openfl.Assets;

#if windows
import Discord.DiscordClient;
#end

#if cpp
import sys.thread.Thread;
#end

using StringTools;

class TitleState extends MusicBeatState
{
	static var initialized:Bool = false;

	static var once:Bool = true;

	static var randomAssNumber = FlxG.random.int(1, 30);

	var blackScreen:FlxSprite;
	var credGroup:FlxGroup;
	var credTextShit:Alphabet;
	var textGroup:FlxGroup;
	var ngSpr:FlxSprite;

	var curWacky:Array<String> = [];

	var wackyImage:FlxSprite;

	override public function create():Void
	{
		#if polymod
		//polymod.Polymod.init({modRoot: "mods", dirs: ['introMod']}); // This kept crashing my game so I kinda had to remove it. I have no idea why that is but whatever lol
		#end
		
		#if sys
		if (!sys.FileSystem.exists(Sys.getCwd() + "/assets/replays"))
			sys.FileSystem.createDirectory(Sys.getCwd() + "/assets/replays");
		#end

		@:privateAccess
		{
			trace("Loaded " + openfl.Assets.getLibrary("default").assetsLoaded + " assets (DEFAULT)");
		}
		
		// FlxG.save.bind('funkin', 'ninjamuffin99');

		// PlayerSettings.init();

		// KadeEngineData.initSave();
		
		Highscore.load();

		#if sys
		var importantAssets:Map<String, Array<String>> = [];
		importantAssets.set('noteSplashes', ['noteSplashes', 'shared']);
		importantAssets.set('pixelNoteSplashes', ['weeb/pixelUI/noteSplashes-pixel', 'week6']);
		importantAssets.set('yellowNoteSplashes', ['weeb/clubpenguin/pixelUI/yellowsplashlmao', 'week6']);

		GameCache.initialize(importantAssets);
		#end

		trace('hello');

		// DEBUG BULLSHIT

		super.create();

		// NGio.noLogin(APIStuff.API);

		#if ng
		var ng:NGio = new NGio(APIStuff.API, APIStuff.EncKey);
		trace('NEWGROUNDS LOL');
		#end

		#if FREEPLAY
		FlxG.switchState(new FreeplayState());
		clean();
		#elseif CHARTING
		FlxG.switchState(new ChartingState());
		clean();
		#else
		#if !cpp
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			startIntro();
		});
		#else
		startIntro();
		#end
		#end
	}

	var logoBl:FlxSprite;
	var gfDance:FlxSprite;
	var danceLeft:Bool = false;
	var titleText:FlxSprite;
	var titleVersion:String = '';
	var daBois:FlxSprite;
	var backupMen:FlxSprite;
	var prevWacky:Array<Array<String>> = [];

	function startIntro()
	{
		persistentUpdate = true;

		titleVersion = (randomAssNumber == 1) ? '-PH' : (randomAssNumber > 1 && randomAssNumber <= 15) ? '-tricky' : '';

		if (titleVersion != '-PH')
			curWacky = (titleVersion == '') ? ['graffiti is art', 'but vandalism is a crime'] : FlxG.random.getObject(getIntroTextShit());

		var bg:FlxSprite = new FlxSprite();
		if (titleVersion != '-tricky')
			bg.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		else
		{
			bg.loadGraphic(Paths.image('bg'));
			bg.setPosition(-10, -10);
		}
		// bg.antialiasing = FlxG.save.data.antialiasing;
		// bg.setGraphicSize(Std.int(bg.width * 0.6));
		// bg.updateHitbox();
		add(bg);

		if (titleVersion != '-tricky')
		{
			logoBl = new FlxSprite(-150, -100);
			logoBl.frames = Paths.getSparrowAtlas('logoBumpin' + titleVersion);
			logoBl.animation.addByPrefix('bump', 'logo', 24, false);
			logoBl.updateHitbox();
		}
		else
		{
			logoBl = new FlxSprite(-200, -160);
			logoBl.frames = Paths.getSparrowAtlas('TrickyLogo');
			logoBl.animation.addByPrefix('bump', 'Logo', 34);
			logoBl.animation.play('bump');
			logoBl.setGraphicSize(Std.int(logoBl.width * 0.5));
			logoBl.updateHitbox();
		}

		logoBl.antialiasing = FlxG.save.data.antialiasing;

		if (titleVersion != '-tricky')
		{
			gfDance = new FlxSprite(FlxG.width * 0.4, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('gfDanceTitle' + ((titleVersion == '') ? '-JSR' : ''));
			gfDance.animation.addByIndices('danceLeft', 'gfDance', [30, 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
			gfDance.animation.addByIndices('danceRight', 'gfDance', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
		}
		else
		{
			gfDance = new FlxSprite(FlxG.width * 0.23, FlxG.height * 0.07);
			gfDance.frames = Paths.getSparrowAtlas('DJ_Tricky');
			gfDance.animation.addByPrefix('dance', 'mixtape', 24, true);
			gfDance.setGraphicSize(Std.int(gfDance.width * 0.6));
		}
		gfDance.antialiasing = FlxG.save.data.antialiasing;
		add(gfDance);
		add(logoBl);

		titleText = new FlxSprite(100, FlxG.height * 0.8);
		titleText.frames = Paths.getSparrowAtlas('titleEnter' + ((titleVersion == '') ? '-JSR' : ''));
		titleText.animation.addByPrefix('idle', "Press Enter to Begin", 24);
		titleText.animation.addByPrefix('press', "ENTER PRESSED", 24);
		titleText.antialiasing = FlxG.save.data.antialiasing;
		titleText.animation.play('idle');
		titleText.updateHitbox();
		// titleText.screenCenter(X);
		add(titleText);

		var logo:FlxSprite = new FlxSprite().loadGraphic(Paths.image('logo'));
		logo.screenCenter();
		logo.antialiasing = FlxG.save.data.antialiasing;
		// add(logo);

		// FlxTween.tween(logoBl, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG});
		// FlxTween.tween(logo, {y: logoBl.y + 50}, 0.6, {ease: FlxEase.quadInOut, type: PINGPONG, startDelay: 0.1});

		credGroup = new FlxGroup();
		add(credGroup);
		textGroup = new FlxGroup();

		blackScreen = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		credGroup.add(blackScreen);

		credTextShit = new Alphabet(0, 0, "ninjamuffin99\nPhantomArcade\nkawaisprite\nevilsk8er", true);
		credTextShit.screenCenter();

		// credTextShit.alignment = CENTER;

		credTextShit.visible = false;

		ngSpr = new FlxSprite(0, FlxG.height * 0.52).loadGraphic(Paths.image('newgrounds_logo'));
		add(ngSpr);
		ngSpr.visible = false;
		ngSpr.setGraphicSize(Std.int(ngSpr.width * 0.8));
		ngSpr.updateHitbox();
		ngSpr.screenCenter(X);
		ngSpr.antialiasing = FlxG.save.data.antialiasing;

		if (titleVersion == '-tricky')
		{
			daBois = new FlxSprite(0, FlxG.height * 0.55).loadGraphic(Paths.image('ThePalsV2'));
			daBois.visible = false;
			daBois.setGraphicSize(Std.int(daBois.width * 1.1));
			daBois.updateHitbox();
			daBois.screenCenter(X);
			daBois.y -= 100;
			daBois.antialiasing = true;

			backupMen = new FlxSprite(0, FlxG.height * 0.55).loadGraphic(Paths.image('TheBackupMen'));
			backupMen.visible = false;
			backupMen.setGraphicSize(Std.int(backupMen.width * 1.1));
			backupMen.updateHitbox();
			backupMen.screenCenter(X);
			backupMen.y -= 100;
			backupMen.antialiasing = true;

			add(daBois);
			add(backupMen);
		}

		FlxTween.tween(credTextShit, {y: credTextShit.y + 20}, 2.9, {ease: FlxEase.quadInOut, type: PINGPONG});

		FlxG.mouse.visible = false;

		if (initialized)
			skipIntro();
		else {
			var diamond:FlxGraphic = FlxGraphic.fromClass(GraphicTransTileDiamond);
			diamond.persist = true;
			diamond.destroyOnNoUse = false;

			FlxTransitionableState.defaultTransIn = new TransitionData(FADE, FlxColor.BLACK, 1, new FlxPoint(0, -1), {asset: diamond, width: 32, height: 32},
				new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));
			FlxTransitionableState.defaultTransOut = new TransitionData(FADE, FlxColor.BLACK, 0.7, new FlxPoint(0, 1),
				{asset: diamond, width: 32, height: 32}, new FlxRect(-200, -200, FlxG.width * 1.4, FlxG.height * 1.4));

			transIn = FlxTransitionableState.defaultTransIn;
			transOut = FlxTransitionableState.defaultTransOut;

			// HAD TO MODIFY SOME BACKEND SHIT
			// IF THIS PR IS HERE IF ITS ACCEPTED UR GOOD TO GO
			// https://github.com/HaxeFlixel/flixel-addons/pull/348

			// var music:FlxSound = new FlxSound();
			// music.loadStream(Paths.music('freakyMenu'));
			// FlxG.sound.list.add(music);
			// music.play();
			FlxG.sound.playMusic(Paths.music(titleVersion != '-tricky' ? ('freakyMenu' + titleVersion) : 'Tiky_Demce'), 0, true);

			FlxG.sound.music.fadeIn(4, 0, 0.7);
			Conductor.changeBPM(titleVersion != '-tricky'? 102 : 139);
			initialized = true;
			if (titleVersion == '-PH')
			{
				var video:MP4Handler = new MP4Handler();
				video.finishCallback = skipIntro;
				video.playMP4(Paths.video('PHintro'));
				
				new FlxTimer().start(0.75, function(tmr:FlxTimer)
				{
					logoBl.animation.play('bump', true);
					danceLeft = !danceLeft;

					if (danceLeft)
						gfDance.animation.play('danceRight');
					else
						gfDance.animation.play('danceLeft');
				}, 0);

			}
		}

		// credGroup.add(credTextShit);
	}

	function getIntroTextShit():Array<Array<String>>
	{
		var fullText:String = Assets.getText(Paths.txt('data/introText' + titleVersion));

		var firstArray:Array<String> = fullText.split('\n');
		var swagGoodArray:Array<Array<String>> = [];

		for (i in firstArray)
		{
			swagGoodArray.push(i.split('--'));
		}

		// No repeat >:(
		for (i in prevWacky)
			if (swagGoodArray.contains(i))
				swagGoodArray.remove(i);

		return swagGoodArray;
	}

	var transitioning:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;
		// FlxG.watch.addQuick('amp', FlxG.sound.music.amplitude);

		if (FlxG.keys.justPressed.F)
		{
			FlxG.fullscreen = !FlxG.fullscreen;
		}

		var pressedEnter:Bool = controls.ACCEPT;

		#if mobile
		for (touch in FlxG.touches.list)
		{
			if (touch.justPressed)
			{
				pressedEnter = true;
			}
		}
		#end

		if (pressedEnter && !transitioning && skippedIntro)
		{
			#if !switch
			NGio.unlockMedal(60960);

			// If it's Friday according to da clock
			if (Date.now().getDay() == 5)
				NGio.unlockMedal(61034);
			#end

			if (FlxG.save.data.flashing)
				titleText.animation.play('press');

			FlxG.camera.flash(FlxColor.WHITE, 1);
			FlxG.sound.play(Paths.sound('confirmMenu'), 0.7);

			transitioning = true;

			trace(FlxG.save.data.firstTime);
			if (titleVersion == '-tricky' && once)
				FlxG.sound.music.fadeOut(1.5, 0);
			// FlxG.sound.music.stop();

			MainMenuState.firstStart = true;
			MainMenuState.finishedFunnyMove = false;
			// FlxTransitionableState.skipNextTransIn = true;

			new FlxTimer().start(2, function(tmr:FlxTimer)
			{
				if (titleVersion == '-tricky' && once)
					FlxG.sound.music.stop();
				once = false;
				if (FlxG.save.data.firstTime)
					FlxG.switchState(new WelcomeState());
				else
				{
					#if cpp
					if (!OutdatedSubState.leftState)
					{
						FlxTransitionableState.skipNextTransIn = true;
						FlxG.switchState(new UpdaterState());
					}
					else
						FlxG.switchState(new MainMenuState());
					#else
					FlxG.switchState(new MainMenuState());
					#end
				}
				clean();
				// Get current version of Kade Engine
				// No lmao
				
				/* var http = new haxe.Http("https://raw.githubusercontent.com/KadeDev/Kade-Engine/master/version.downloadMe");
				var returnedData:Array<String> = [];
				
				http.onData = function (data:String)
				{
					returnedData[0] = data.substring(0, data.indexOf(';'));
					returnedData[1] = data.substring(data.indexOf('-'), data.length);
				  	if (!MainMenuState.kadeEngineVer.contains(returnedData[0].trim()) && !OutdatedSubState.leftState)
					{
						trace('outdated lmao! ' + returnedData[0] + ' != ' + MainMenuState.kadeEngineVer);
						OutdatedSubState.needVer = returnedData[0];
						OutdatedSubState.currChanges = returnedData[1];
						FlxG.switchState(new OutdatedSubState());
						clean();
					}
					else
					{
						FlxG.switchState(new MainMenuState());
						clean();
					//}
				}
				
				http.onError = function (error) {
				  trace('error: $error');
				  FlxG.switchState(new MainMenuState()); // fail but we go anyway
				  clean();
				}
				
				http.request();*/
			});
			// FlxG.sound.play(Paths.music('titleShoot'), 0.7);
		}

		if (pressedEnter && !skippedIntro && initialized && titleVersion != '-PH')
		{
			skipIntro();
		}

		super.update(elapsed);
	}

	function createCoolText(textArray:Array<String>, yOffset:Float = 0)
	{
		for (i in 0...textArray.length)
		{
			var money:Alphabet = new Alphabet(0, 0, textArray[i], true, false);
			money.screenCenter(X);
			if (yOffset != 0)
				money.y -= yOffset;
			money.y += (i * 60) + 200;
			credGroup.add(money);
			textGroup.add(money);
		}
	}

	function addMoreText(text:String, yOffset:Float = 0)
	{
		var coolText:Alphabet = new Alphabet(0, 0, text, true, false);
		coolText.screenCenter(X);
		if (yOffset != 0)
			coolText.y -= yOffset;
		coolText.y += (textGroup.length * 60) + 200;
		credGroup.add(coolText);
		textGroup.add(coolText);
	}

	function deleteCoolText()
	{
		while (textGroup.members.length > 0)
		{
			credGroup.remove(textGroup.members[0], true);
			textGroup.remove(textGroup.members[0], true);
		}
	}

	override function beatHit()
	{
		super.beatHit();

		logoBl.animation.play('bump');
		danceLeft = !danceLeft;

		if (titleVersion != '-tricky')
		{
			if (danceLeft)
				gfDance.animation.play('danceRight');
			else
				gfDance.animation.play('danceLeft');
		}
		else
			gfDance.animation.play('dance');

		FlxG.log.add(curBeat);

		if (!once)
			return;

		if (titleVersion != '-tricky')
		{
			switch (curBeat)
			{
				case 0:
					deleteCoolText();
				case 1:
					createCoolText(['ninjamuffin99', 'phantomArcade', 'kawaisprite', 'evilsk8er']);
				// credTextShit.visible = true;
				case 3:
					addMoreText('present');
				// credTextShit.text += '\npresent...';
				// credTextShit.addText();
				case 4:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 5:
					if (Main.watermarks)
						createCoolText(['Kade Engine', 'by']);
					else
						createCoolText(['In Partnership', 'with']);
				case 7:
					if (Main.watermarks)
						addMoreText('KadeDeveloper');
					else
					{
						addMoreText('Newgrounds');
						ngSpr.visible = true;
					}
				// credTextShit.text += '\nNewgrounds';
				case 8:
					deleteCoolText();
					ngSpr.visible = false;
				// credTextShit.visible = false;

				// credTextShit.text = 'Shoutouts Tom Fulp';
				// credTextShit.screenCenter();
				case 9:
					createCoolText([curWacky[0]]);
				// credTextShit.visible = true;
				case 11:
					addMoreText(curWacky[1]);
				// credTextShit.text += '\nlmao';
				case 12:
					deleteCoolText();
				// credTextShit.visible = false;
				// credTextShit.text = "Friday";
				// credTextShit.screenCenter();
				case 13:
					addMoreText('Sunday');
				// credTextShit.visible = true;
				case 14:
					addMoreText('Night');
				// credTextShit.text += '\nNight';
				case 15:
					addMoreText('SiIva'); // credTextShit.text += '\nFunkin';

				case 16:
					skipIntro();
			}
		}
		else
		{
			switch (curBeat)
			{
				case 5:
					createCoolText(['KadeDev'], 135);
				// credTextShit.visible = true;
				case 6:
					addMoreText('Banbuds', 135);
				case 7:
					addMoreText('Cval', 135);
				case 8:
					addMoreText('Rozebud', 135);
				case 9:
					daBois.visible = true;
				// credTextShit.visible = false;
				// credTextShit.text = 'In association \nwith';
				// credTextShit.screenCenter();
				case 10:
					deleteCoolText();
					daBois.visible = false;
					createCoolText(['With help from'], 135);
				case 11:
					addMoreText('MORO', 135);
				case 12:
					addMoreText('YingYang', 135);
				case 13:
					addMoreText('Jads', 135);
				case 14:
					backupMen.visible = true;
				case 15:
					deleteCoolText();
					createCoolText(['Newgrounds']);
					backupMen.visible = false;
				case 16:
					addMoreText('is pog');
					ngSpr.visible = true;
				case 17:
					ngSpr.visible = false;
					deleteCoolText();
					createCoolText([curWacky[0]]);
				case 18:
					addMoreText(curWacky[1]);
				case 19:
					curWacky = FlxG.random.getObject(getIntroTextShit());
					prevWacky.push(curWacky);
					deleteCoolText();
					createCoolText([curWacky[0]]);
				case 20:
					addMoreText(curWacky[1]);
				case 21:
					curWacky = FlxG.random.getObject(getIntroTextShit());
					prevWacky.push(curWacky);
					deleteCoolText();
					createCoolText([curWacky[0]]);
				case 22:
					addMoreText(curWacky[1]);
				case 23:
					curWacky = FlxG.random.getObject(getIntroTextShit());
					prevWacky.push(curWacky);
					deleteCoolText();
					createCoolText([curWacky[0]]);
				case 24:
					addMoreText(curWacky[1]);
				case 25:
					curWacky = FlxG.random.getObject(getIntroTextShit());
					prevWacky.push(curWacky);
					deleteCoolText();
					createCoolText([curWacky[0]]);
				case 26:
					addMoreText(curWacky[1]);
				case 27:
					deleteCoolText();
					createCoolText(['chicken dance remix']);
				case 28:
					addMoreText('by Tsuraran');
				case 30:
					deleteCoolText();
					createCoolText(['the drop']);
				case 31:
					addMoreText('or smth lol');
				case 32:
					deleteCoolText();
					skipIntro();
			}
		}
	}

	var skippedIntro:Bool = false;

	function skipIntro():Void
	{
		if (!skippedIntro)
		{
			remove(ngSpr);

			if (titleVersion == '-tricky')
			{
				remove(daBois);
				remove(backupMen);
			}

			FlxG.camera.flash(FlxColor.WHITE, 4);
			remove(credGroup);

			if (titleVersion != '-tricky')
			{
				FlxTween.tween(logoBl, {y: -100}, 1.4, {ease: FlxEase.expoInOut});

				logoBl.angle = -4;

				new FlxTimer().start(0.01, function(tmr:FlxTimer)
				{
					if (logoBl.angle == -4)
						FlxTween.angle(logoBl, logoBl.angle, 4, 4, {ease: FlxEase.quartInOut});
					if (logoBl.angle == 4)
						FlxTween.angle(logoBl, logoBl.angle, -4, 4, {ease: FlxEase.quartInOut});
				}, 0);
			}

			skippedIntro = true;
		}
	}
}
