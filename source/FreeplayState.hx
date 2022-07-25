package;

import openfl.utils.AssetType;
import haxe.Json;
import Song.SwagSong;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.app.Application;
import lime.utils.Assets;
import openfl.media.Sound;
import openfl.utils.Future;

using StringTools;

#if sys
import smTools.SMFile;
import sys.FileSystem;
import sys.io.File;
#end
#if cpp
import Discord.DiscordClient;
#end

typedef CategoryData = 
{
	public var title:String;
	public var icon:String;
	public var color:String;
	public var songs:Array<String>;
}

class FreeplayState extends MusicBeatState
{
	public static var songs:Array<SongMetadata> = [];

	var selector:FlxText;

	var inSection:Bool = false;

	public static var curSelected:Int = 0;
	public static var curSection:Int = 0;
	public static var curDifficulty:Int = 1;

	public static var fromSong = false;

	var bg:FlxSprite;

	var curColor:FlxColor = FlxColor.WHITE;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var diffCalcText:FlxText;
	var previewtext:FlxText;
	var scoreBG:FlxSprite;
	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;

	private var iconArray:Array<HealthIcon> = [];

	public static var blockInputs = false;

	public static var songData:Map<String, Array<SwagSong>> = [];

	public var categories:Array<CategoryData> = [];

	public static function loadDiff(diff:Int, format:String, name:String, array:Array<SwagSong>)
	{
		try
		{
			array.push(Song.loadFromJson(Highscore.formatSong(format, diff), name));
		}
		catch (ex)
		{
			// do nada
		}
	}

	function listSongs(?week:Int)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		grpSongs.clear();
		for (i in iconArray)
		{
			remove(i);
			i.kill();
			i.destroy();
		}
		iconArray = [];
		diffText.visible = true;
		diffCalcText.visible = true;
		comboText.visible = true;
		previewtext.y = scoreText.y + 94;
		scoreBG.setGraphicSize(Std.int(FlxG.width * 0.35), 135);
		scoreBG.updateHitbox();
		inSection = true;
		if (!fromSong)
			curSelected = 0;
		var initSonglist = CoolUtil.coolTextFile(Paths.txt('data/freeplaySonglist'));
		var copyrightedSonglist = CoolUtil.coolTextFile(Paths.txt('data/copyrightedSonglist'));
		var h:Array<String> = [];
		for (v in copyrightedSonglist)
			h.push(v.split(":")[0]);

		// var diffList = "";

		songData = [];
		songs = [];

		curColor = Std.parseInt(categories[week].color);

		for (i in 0...initSonglist.length)
		{
			var data:Array<String> = initSonglist[i].split(':');
			var inCategory = categories[week].songs.contains(data[0]);
			if (FlxG.save.data.noCopyright == 2 && h.contains(data[0]))
				continue;
			if (week != null && !inCategory)
				continue;
			var weekInfo:Dynamic = data[2];
			if (Std.parseInt(weekInfo) != null)
				weekInfo = Std.parseInt(weekInfo);
			var meta = new SongMetadata(data[0], weekInfo, data[1]);
			var format = StringTools.replace(meta.songName, " ", "-");
			switch (format)
			{
				case 'Dad-Battle':
					format = 'Dadbattle';
				case 'Philly-Nice':
					format = 'Philly';
			}

			var diffs = [];
			var diffsThatExist = [];

			var lowercase = CoolUtil.lowerCaseSong(format);

			if (Assets.exists('assets/data/SONGS/$lowercase/$lowercase-easy.json', TEXT))
				diffsThatExist.push("Easy");
			if (Assets.exists('assets/data/SONGS/$lowercase/$lowercase.json', TEXT))
				diffsThatExist.push("Normal");
			if (Assets.exists('assets/data/SONGS/$lowercase/$lowercase-hard.json', TEXT))
				diffsThatExist.push("Hard");
			if (Assets.exists('assets/data/SONGS/$lowercase/$lowercase-extra.json', TEXT))
				diffsThatExist.push("Extra");

			if (diffsThatExist.length == 0)
			{
				Application.current.window.alert('No difficulties found for ${lowercase}, skipping.', meta.songName + " Chart " + ${format});
				continue;
			}

			if (diffsThatExist.contains("Easy"))
				FreeplayState.loadDiff(0, format, meta.songName, diffs);
			if (diffsThatExist.contains("Normal"))
				FreeplayState.loadDiff(1, format, meta.songName, diffs);
			if (diffsThatExist.contains("Hard"))
				FreeplayState.loadDiff(2, format, meta.songName, diffs);
			if (diffsThatExist.contains("Extra"))
				FreeplayState.loadDiff(3, format, meta.songName, diffs);

			// trace(diffs.length, meta.songName, diffsThatExist);

			meta.diffs = diffsThatExist;

			if (diffsThatExist.length < 3)
				trace("I ONLY FOUND " + diffsThatExist);

			FreeplayState.songData.set(meta.songName, diffs);
			trace('loaded diffs for ' + meta.songName);
			songs.push(meta);
		}

		for (i in 0...songs.length)
		{
			var songName:String = songs[i].songName;
			trace(songName);
			if (FlxG.save.data.shortenNames && songName.split(" ").length > 1) // Name shortener
			{
				var temp:Array<String> = songName.toLowerCase().split(" ");
				var converter:Map<String, String> = [
					"betamix" => "BM", "in-gameversion" => "IGV", "extendedversion" => "EV", "vocalmix" => "VM", "ostversion" => "OST",
					"alternateversion" => "AV", "itchiobuild" => "Itch Ver.", "poopversion" => "PV", "jpversion" => "JPV", "jpnversion" => "JPNV", "week4update" => "Updated",
					"in-gamemix" => "IGM", "alterneeyyytivemix" => "eyyyy", "shortversion" => "SHORT",
					"newgroundsbuild" => "NG Ver", "originalmix" => "OGM", "alphamix" => "AM"
				];
				var startIndex = (temp[temp.length - 3] == 'itch' || temp[temp.length - 3] == 'week') ? 3 : 2;
				var h:String = ""; // h
				for (gaming in temp.length - startIndex...temp.length)
					h += temp[gaming];
				var adder:String = converter[h]; // (temp[temp.length - 2][0]).toUpperCase() + (temp[temp.length - 1][0]).toUpperCase();
				// As you can see above, I did actually attempt to abbreviate but it kinda looked retarded
				if (adder != null)
				{
					var template:String = "";
					for (index in 0...temp.length - startIndex)
						template += temp[index] + " ";

					songName = template + adder;
				}
			}
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(songs[i].songCharacter);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		changeSelection();
		changeDiff();
	}

	function createSections()
	{
		for (i in iconArray)
		{
			remove(i);
			i.kill();
			i.destroy();
		}
		iconArray = [];
		scoreText.text = 'Select a category';
		diffText.visible = false;
		diffCalcText.visible = false;
		comboText.visible = false;
		previewtext.y = scoreText.y + 40;
		scoreBG.setGraphicSize(Std.int(FlxG.width * 0.35), 75);
		scoreBG.updateHitbox();
		inSection = false;
		grpSongs.clear();
		curSelected = curSection;
		for (i => data in categories)
		{
			var sectionName = data.title;
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, sectionName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var icon:HealthIcon = new HealthIcon(data.icon);
			icon.sprTracker = songText;

			iconArray.push(icon);
			add(icon);
		}
		changeSelection();
	}

	override function create()
	{
		clean();

		// Sorry SM files have to go bye-bye :(

		// trace("\n" + diffList);

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		#if cpp
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		persistentUpdate = true;

		// LOAD MUSIC

		// LOAD CHARACTERS

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'), false);
		bg.screenCenter();
		bg.color = FlxColor.WHITE;
		bg.updateHitbox();
		bg.antialiasing = FlxG.save.data.antialiasing;
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		scoreBG = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 135, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		diffCalcText = new FlxText(scoreText.x, scoreText.y + 66, 0, "", 24);
		diffCalcText.font = scoreText.font;
		add(diffCalcText);

		previewtext = new FlxText(scoreText.x, scoreText.y + 94, 0, "" + (KeyBinds.gamepad ? "[X]" : "SPACE") + " - Quick Options", 24);
		previewtext.font = scoreText.font;
		add(previewtext);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);

		if (categories.length <= 0)
		{
			trace("Loading category data...");
			var rawJson = Assets.getText(Paths.json("freeplayCategoryData")).trim();

			while (!rawJson.endsWith("}"))
				rawJson = rawJson.substr(0, rawJson.length - 1);

			categories = cast Json.parse(rawJson).list;
		}

		if (fromSong)
			listSongs(curSection);
		else
			createSections();

		fromSong = false;

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		// YEAH WELL I'M DOIN YOUR MOM!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Dynamic, songCharacter:String)
	{
		songs.push(new SongMetadata(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>)
	{
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs)
		{
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	override function closeSubState()
	{
		super.closeSubState();
		blockInputs = false;
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		if (FlxG.sound.music.volume > 0.8)
		{
			FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
		}

		bg.color = FlxColor.interpolate(bg.color, (inSection) ? curColor : FlxColor.CYAN, 0.05);

		if (inSection)
		{
			lerpScore = Math.floor(CoolUtil.coolLerp(lerpScore, intendedScore, 0.4));

			if (Math.abs(lerpScore - intendedScore) <= 10)
				lerpScore = intendedScore;

			scoreText.text = "PERSONAL BEST:" + lerpScore;
			comboText.text = combo + '\n';
		}

		if (!blockInputs)
		{
			var upP = FlxG.keys.justPressed.UP;
			var downP = FlxG.keys.justPressed.DOWN;
			var leftP = FlxG.keys.justPressed.LEFT;
			var rightP = FlxG.keys.justPressed.RIGHT;
			var accepted = FlxG.keys.justPressed.ENTER;

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					upP = true;
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					downP = true;
				}
				if (gamepad.justPressed.DPAD_LEFT)
				{
					leftP = true;
				}
				if (gamepad.justPressed.DPAD_RIGHT)
				{
					rightP = true;
				}

				if (gamepad.justPressed.X)
				{
					openSubState(new OptionsSubState());
					blockInputs = true;
				}
			}

			if (upP)
			{
				changeSelection(-1);
			}
			if (downP)
			{
				changeSelection(1);
			}

			if (FlxG.keys.justPressed.SPACE)
			{
				openSubState(new OptionsSubState());
				blockInputs = true;
			}

			if (inSection)
			{
				if (leftP)
					changeDiff(-1);
				if (rightP)
					changeDiff(1);
			}

			if (controls.BACK)
				if (!inSection)
					FlxG.switchState(new MainMenuState());
				else
					createSections();

			if (accepted)
			{
				if (inSection)
				{
					// adjusting the song name to be compatible
					var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
					switch (songFormat)
					{
						case 'Dad-Battle':
							songFormat = 'Dadbattle';
						case 'Philly-Nice':
							songFormat = 'Philly';
					}
					var hmm;
					try
					{
						hmm = songData.get(songs[curSelected].songName)[songs[curSelected].diffs.indexOf(CoolUtil.difficultyFromInt(curDifficulty))];
						if (hmm == null)
							return;
					}
					catch (sex)
					{
						return;
					}

					blockInputs = true;
					PlayState.SONG = Song.conversionChecks(hmm);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
					PlayState.storyWeek = songs[curSelected].week;
					trace('CUR WEEK' + PlayState.storyWeek);
					PlayState.isSM = false;
					LoadingState.loadAndSwitchState(new PlayState());
					clean();
				}
				else
				{
					listSongs(curSelected);
				}
			}
		}
	}

	function changeDiff(change:Int = 0)
	{
		curDifficulty += change;

		// Weird to explain, but basically instead of relying on the diffs array always being full, I used intFromDifficulty and difficultyFromInt to avoid referencing a null object. Which caused me to crash a lot lmao.
		if (!songs[curSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty))) // LOOK MOM, I FIXED IT!
		{
			if (curDifficulty < CoolUtil.intFromDifficulty(songs[curSelected].diffs[0]))
			{
				curDifficulty = CoolUtil.intFromDifficulty(songs[curSelected].diffs[songs[curSelected].diffs.length - 1]);
			}
			else if (curDifficulty > CoolUtil.intFromDifficulty(songs[curSelected].diffs[songs[curSelected].diffs.length - 1]))
			{
				curDifficulty = CoolUtil.intFromDifficulty(songs[curSelected].diffs[0]);
			}
			else
			{
				for (i in songs[curSelected].diffs)
				{
					trace(i, CoolUtil.intFromDifficulty(i), curDifficulty - change);
					if (change >= 0 && CoolUtil.intFromDifficulty(i) > (curDifficulty - change))
					{
						curDifficulty = CoolUtil.intFromDifficulty(i);
						break;
					}
					if (change < 0 && CoolUtil.intFromDifficulty(i) < (curDifficulty - change))
					{
						curDifficulty = CoolUtil.intFromDifficulty(i);
						break;
					}
				}
			}
		}

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore)
		{
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end
		var diffData = songData.get(songs[curSelected].songName)[songs[curSelected].diffs.indexOf(CoolUtil.difficultyFromInt(curDifficulty))];
		diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(diffData)}';
		var newtext = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
		if (newtext == "EXTRA")
			if (diffData.extraDiffDisplay != null)
				newtext = diffData.extraDiffDisplay.toUpperCase();
		diffText.text = newtext;
	}

	function changeSelection(change:Int = 0)
	{
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		// Modulo, as it turns out, is different from Lua in that negative numbers don't wrap back around to the max. Sadge.
		curSelected = ((curSelected + change) % grpSongs.length + grpSongs.length) % grpSongs.length;

		if (!inSection)
			curSection = curSelected;

		if (inSection)
		{
			// In case the previously selected difficulty doesn't exist. We don't want to reference any null objects 'round here.
			if (!songs[curSelected].diffs.contains(CoolUtil.difficultyFromInt(curDifficulty)))
			{
				if (curDifficulty >= songs[curSelected].diffs.length)
					changeDiff(-1);
				else
					changeDiff(1);
			}

			// selector.y = (70 * curSelected) + 30;

			// adjusting the highscore song name to be compatible (changeSelection)
			// would read original scores if we didn't change packages
			var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
			switch (songHighscore)
			{
				case 'Dad-Battle':
					songHighscore = 'Dadbattle';
				case 'Philly-Nice':
					songHighscore = 'Philly';
			}

			#if !switch
			intendedScore = Highscore.getScore(songHighscore, curDifficulty);
			combo = Highscore.getCombo(songHighscore, curDifficulty);
			// lerpScore = 0;
			#end
			
			var diffData = songData.get(songs[curSelected].songName)[songs[curSelected].diffs.indexOf(CoolUtil.difficultyFromInt(curDifficulty))];
			diffCalcText.text = 'RATING: ${DiffCalc.CalculateDiff(songData.get(songs[curSelected].songName)[songs[curSelected].diffs.indexOf(CoolUtil.difficultyFromInt(curDifficulty))])}';
			var newtext = CoolUtil.difficultyFromInt(curDifficulty).toUpperCase();
			if (newtext == "EXTRA")
				if (diffData.extraDiffDisplay != null)
					newtext = diffData.extraDiffDisplay.toUpperCase();
			diffText.text = newtext;

			/*#if PRELOAD_ALL
				if (songs[curSelected].songCharacter == "sm")
				{
					var data = songs[curSelected];
					trace("Loading " + data.path + "/" + data.sm.header.MUSIC);
					var bytes = File.getBytes(data.path + "/" + data.sm.header.MUSIC);
					var sound = new Sound();
					sound.loadCompressedDataFromByteArray(bytes.getData(), bytes.length);
					FlxG.sound.playMusic(sound);
				}
				else
					FlxG.sound.playMusic(Paths.inst(songs[curSelected].songName), 0);
				#end

			var hmm;
			try
			{
				hmm = songData.get(songs[curSelected].songName)[curDifficulty];
				/*if (hmm != null)
					Conductor.changeBPM(hmm.bpm);
			}
				catch (ex) {} */
		}

		var bullShit:Int = 0;

		for (i in 0...iconArray.length)
		{
			iconArray[i].alpha = 0.6;
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members)
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

class SongMetadata
{
	public var songName:String = "";
	public var week:Dynamic = 0;
	#if sys
	public var sm:SMFile;
	public var path:String;
	#end
	public var songCharacter:String = "";

	public var diffs = [];

	#if sys
	public function new(song:String, week:Dynamic, songCharacter:String, ?sm:SMFile = null, ?path:String = "")
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.sm = sm;
		this.path = path;
	}
	#else
	public function new(song:String, week:Dynamic, songCharacter:String)
	{
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
	}
	#end
}
