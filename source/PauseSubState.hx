package;

import flixel.util.FlxTimer;
import flixel.group.FlxSpriteGroup;
import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import openfl.Lib;

using StringTools;

#if cpp
import llua.Lua;
#end
#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;
	var perSongOffset:FlxText;

	var jokeText:FlxText;
	var explainingJoke:Bool = false;

	var offsetChanged:Bool = false;

	var acceptInput:Bool = true;

	var literallyEverythingOnScreen = new FlxSpriteGroup();

	public function new(x:Float, y:Float)
	{
		super();

		if (PlayState.isStoryMode) // Check if in story mode and there are songs to skip, add skip button if that's the case
			menuItems.insert(menuItems.length - 2, 'Skip Song');

		#if sys
		var format:String = StringTools.replace(PlayState.SONG.song.toLowerCase(), " ", "-");
		if (FileSystem.exists('assets/data/SONGS/${format}/thefunny.txt')) // Check if thefunny.txt exists, add joke explainer if it does
			menuItems.insert(menuItems.length - 2, 'Joke Explainer');
		#else
		menuItems.insert(menuItems.length - 2, 'Joke Explainer');
		#end

		if (PlayState.instance.useVideo)
		{
			menuItems.remove("Resume");
			if (GlobalVideo.get().playing)
				GlobalVideo.get().pause();
		}

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2))); // Un moment de bruh

		add(literallyEverythingOnScreen);

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		literallyEverythingOnScreen.add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		literallyEverythingOnScreen.add(levelInfo);
		
		var newtext = CoolUtil.difficultyFromInt(PlayState.storyDifficulty).toUpperCase();
		if (newtext == "EXTRA")
			if (PlayState.SONG.extraDiffDisplay != null)
				newtext = PlayState.SONG.extraDiffDisplay.toUpperCase();
		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += newtext;
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		literallyEverythingOnScreen.add(levelDifficulty);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);

		if (PlayState.isStoryMode)
		{
			var remainingSongs:FlxText = new FlxText(0, 0, 0, "", 32);
			remainingSongs.text = "Song " + (PlayState.storyLength - PlayState.storyPlaylist.length + 1) + "/" + PlayState.storyLength;
			remainingSongs.scrollFactor.set();
			remainingSongs.setFormat(Paths.font("vcr.ttf"), 32);
			remainingSongs.updateHitbox();
			remainingSongs.setPosition(FlxG.width - remainingSongs.width - 15, FlxG.height);
			remainingSongs.alpha = 0;
			literallyEverythingOnScreen.add(remainingSongs);
			FlxTween.tween(remainingSongs, {alpha: 1, y: FlxG.height - remainingSongs.height - 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.7});
		}

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);
		perSongOffset = new FlxText(5, FlxG.height
			- 18, 0,
			"Additive Offset (Left, Right): "
			+ PlayState.songOffset
			+ " - Description - "
			+ 'Adds value to global offset, per song.', 12);
		perSongOffset.scrollFactor.set();
		perSongOffset.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		#if cpp
		literallyEverythingOnScreen.add(perSongOffset);
		#end

		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		changeSelection();

		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		if (PlayState.instance.useVideo)
			menuItems.remove('Resume');

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		var upPcontroller:Bool = false;
		var downPcontroller:Bool = false;
		var leftPcontroller:Bool = false;
		var rightPcontroller:Bool = false;
		var oldOffset:Float = 0;

		if (gamepad != null && KeyBinds.gamepad)
		{
			upPcontroller = gamepad.justPressed.DPAD_UP;
			downPcontroller = gamepad.justPressed.DPAD_DOWN;
			leftPcontroller = gamepad.justPressed.DPAD_LEFT;
			rightPcontroller = gamepad.justPressed.DPAD_RIGHT;
		}

		// pre lowercasing the song name (update)
		var songLowercase = CoolUtil.lowerCaseSong(PlayState.SONG.song);
		var songPath = Paths.songPath + songLowercase + '/';

		#if sys
		if (PlayState.isSM && !PlayState.isStoryMode)
			songPath = PlayState.pathToSm;
		#end

		if (!acceptInput)
			return;
		if (controls.UP_P || upPcontroller)
		{
			changeSelection(-1);
		}
		else if (controls.DOWN_P || downPcontroller)
		{
			changeSelection(1);
		}

		#if cpp
		else if ((controls.LEFT_P || leftPcontroller) && !explainingJoke)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset -= 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = "Additive Offset (Left, Right): "
				+ PlayState.songOffset
				+ " - Description - "
				+ 'Adds value to global offset, per song.';

			// Prevent loop from happening every single time the offset changes
			if (!offsetChanged)
			{
				grpMenuShit.clear();

				menuItems = ['Restart Song', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				offsetChanged = true;
			}
		}
		else if ((controls.RIGHT_P || rightPcontroller) && !explainingJoke)
		{
			oldOffset = PlayState.songOffset;
			PlayState.songOffset += 1;
			sys.FileSystem.rename(songPath + oldOffset + '.offset', songPath + PlayState.songOffset + '.offset');
			perSongOffset.text = "Additive Offset (Left, Right): "
				+ PlayState.songOffset
				+ " - Description - "
				+ 'Adds value to global offset, per song.';
			if (!offsetChanged)
			{
				grpMenuShit.clear();

				menuItems = ['Restart Song', 'Exit to menu'];

				for (i in 0...menuItems.length)
				{
					var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
					songText.isMenuItem = true;
					songText.targetY = i;
					grpMenuShit.add(songText);
				}

				changeSelection();

				cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
				offsetChanged = true;
			}
		}
		#end

		if (controls.BACK && explainingJoke) // Allow the exiting of the funny explain the joke menu
		{
			grpMenuShit.clear();
			remove(jokeText);
			jokeText.destroy();
			jokeText = null;
			menuItems = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
			explainingJoke = false;
			if (PlayState.isStoryMode)
				menuItems.insert(menuItems.length - 2, 'Skip Song');

			menuItems.insert(menuItems.length - 2, 'Joke Explainer');

			for (i in 0...menuItems.length)
			{
				var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
				songText.isMenuItem = true;
				songText.targetY = i;
				grpMenuShit.add(songText);
			}

			curSelected = menuItems.indexOf('Joke Explainer');

			changeSelection();
		}

		if (controls.ACCEPT && !FlxG.keys.pressed.ALT)
		{
			var daSelected:String = (menuItems[curSelected].startsWith('#')) ? 'source' : menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					acceptInput = false;
					FlxTween.tween(literallyEverythingOnScreen, {alpha: 0}, 1);
					grpMenuShit.forEachAlive(function(spr:Alphabet)
					{
						FlxTween.tween(spr, {alpha: 0}, 1);
					});
					var timeRemainingText = new FlxText();
					timeRemainingText.setFormat(Paths.font('vcr.ttf'), 100, FlxColor.WHITE);
					timeRemainingText.borderColor = FlxColor.BLACK;
					timeRemainingText.borderSize = 3;
					timeRemainingText.borderStyle = FlxTextBorderStyle.OUTLINE;
					timeRemainingText.centerOrigin();
					timeRemainingText.updateHitbox();
					timeRemainingText.screenCenter();
					timeRemainingText.cameras = [PlayState.instance.camHUD];
					add(timeRemainingText);
					var funnyTween = function(text:String)
					{
						timeRemainingText.text = text;
						timeRemainingText.alpha = 1;
						timeRemainingText.scale.x = 1.3;
						timeRemainingText.scale.y = 1.3;
						FlxTween.tween(timeRemainingText, {alpha: 0}, .45, {ease: FlxEase.quadOut});
						FlxTween.tween(timeRemainingText.scale, {x: 1, y: 1}, .45, {ease: FlxEase.quadOut});
					}
					funnyTween("3");
					new FlxTimer().start(0.5, function(tmr:FlxTimer)
					{
						funnyTween(Std.string(tmr.loopsLeft));
						if (tmr.loopsLeft == 0)
							close(); // Lol
					}, 3);
				case "Restart Song":
					PlayState.fromDeath = true;
					PlayState.startTime = 0;
					if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					PlayState.instance.clean();
					FlxG.resetState();
				case "Exit to menu":
					PlayState.startTime = 0;
					if (PlayState.instance.useVideo)
					{
						GlobalVideo.get().stop();
						PlayState.instance.remove(PlayState.instance.videoSprite);
						PlayState.instance.removedVideo = true;
					}
					if (PlayState.loadRep)
					{
						FlxG.save.data.botplay = false;
						FlxG.save.data.scrollSpeed = 1;
						FlxG.save.data.downscroll = false;
					}
					PlayState.loadRep = false;
					#if cpp
					if (PlayState.luaModchart != null)
					{
						PlayState.luaModchart.die();
						PlayState.luaModchart = null;
					}
					#end
					if (FlxG.save.data.fpsCap > 290)
						(cast(Lib.current.getChildAt(0), Main)).setFPSCap(290);

					PlayState.instance.clean();

					if (PlayState.isStoryMode)
						FlxG.switchState(new StoryMenuState());
					else
					{
						FreeplayState.fromSong = true;
						FlxG.switchState(new FreeplayState());
					}

				case "Skip Song": // This used to be copypasted code from PlayState wtf is wrong with me
					PlayState.instance.endSong();
					close();
				case "Joke Explainer": // Joke explainer code (obviously lmao)
					curSelected = 0;
					grpMenuShit.clear(); // Clear all current menu options
					menuItems = [];
					explainingJoke = true;
					var format:String = StringTools.replace(PlayState.SONG.song.toLowerCase(), " ", "-");
					var jokeData = CoolUtil.coolTextFile(Paths.txt('data/SONGS/${format}/thefunny')); // Get joke data from txt file and create text object
					jokeText = new FlxText(100, 100, Std.int(FlxG.width * 0.9), "Joke: ", 28);
					jokeText.text += jokeData[0];
					jokeText.scrollFactor.set();
					jokeText.setFormat(Paths.font('vcr.ttf'), 28);
					jokeText.borderColor = FlxColor.BLACK;
					jokeText.borderSize = 3;
					jokeText.borderStyle = FlxTextBorderStyle.OUTLINE;
					jokeText.updateHitbox();
					literallyEverythingOnScreen.add(jokeText);
					trace(jokeData);
					for (i in 1...jokeData.length) // Generate source links
					{
						trace(i);
						menuItems.push('#--${jokeData[i].split(":")[1]}'); // menuItems entry != Button text. Ex: Button text = "Poop", menuItems entry = "#--(link)". This is so that we can tell which buttons are sources and what the link is.
						var songText:Alphabet = new Alphabet(0, (70 * i) + 30, jokeData[i].split("--")[0], true, false);
						songText.isMenuItem = true;
						songText.targetY = i;
						grpMenuShit.add(songText);
					}

					changeSelection(); // Update selection

				case "source": // Open source link
					var link = menuItems[curSelected].split("--")[1]; // Again, source entries are formatted "#--(link)" so this just gets the link portion
					#if linux
					Sys.command('/usr/bin/xdg-open', [link, "&"]);
					#else
					FlxG.openURL(link);
					#end
				case "Options": // Open options
					PlayState.instance.inOptions = true;
					FlxG.state.openSubState(new OptionsSubState(true));
			}
		}

		if (FlxG.keys.justPressed.J)
		{
			// for reference later!
			// PlayerSettings.player1.controls.replaceBinding(Control.LEFT, Keys, FlxKey.J, null);
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected += change;

		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
