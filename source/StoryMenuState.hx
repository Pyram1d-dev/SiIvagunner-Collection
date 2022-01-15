package;

import flixel.effects.FlxFlicker;
import flixel.ui.FlxButton.FlxTypedButton;
import flixel.system.macros.FlxMacroUtil;
import haxe.Json;
import openfl.Assets;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.plugin.taskManager.FlxTask;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

using StringTools;

#if windows
import Discord.DiscordClient;
#end

class UnlockedWeekPog extends MusicBeatSubstate
{
	var uiShit:FlxSpriteGroup;
	var unlocks:Array<String>;
	var closing:Bool = false;

	override public function new(unlocks:Array<String>)
	{
		this.unlocks = unlocks;
		super();
	}

	override function create()
	{
		uiShit = new FlxSpriteGroup();
		uiShit.alpha = 1;
		add(uiShit);
		var bg = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		uiShit.add(bg);
		bg.alpha = 0;
		var unlockText = new FlxText(0, 0, FlxG.width * 0.9, "You unlocked new Extra difficulties!\n(Check them out in freeplay)\n\n");
		unlockText.alpha = 0;
		unlockText.autoSize = false;
		unlockText.setFormat("VCR OSD Mono", 40, FlxColor.WHITE, CENTER, OUTLINE, FlxColor.BLACK);
		unlockText.alignment = CENTER;
		unlockText.updateHitbox();
		unlockText.screenCenter(XY);
		unlockText.antialiasing = FlxG.save.data.antialiasing;
		for (i in unlocks)
			unlockText.text += "\n" + "- " + i;

		unlockText.text += "\n\n\n(Enter to continue)";
		uiShit.add(unlockText);
		FlxTween.tween(unlockText, {alpha: 1}, 1, {ease: FlxEase.quadIn});
		FlxTween.tween(bg, {alpha: 0.7}, 1, {ease: FlxEase.quadIn});
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.keys.justPressed.ENTER && !closing)
		{
			FlxTween.tween(uiShit, {alpha: 0}, 1, {
				ease: FlxEase.quadIn,
				onComplete: function(twn:FlxTween)
				{
					_parentState.closeSubState();
				}
			});
		}

		super.update(elapsed);
	}
}

class WeekItem extends FlxTypedSpriteGroup<FlxSprite>
{
	public var targetY:Int;
	var bg:FlxSprite;
	static var boxHeight = 80;
	var stopTweeningLol = false;
	var fakeTargetY:Int;

	public override function new(x:Float, y:Float, weekName:String, targetY:Int)
	{
		super(x, y);
		this.targetY = targetY;
		fakeTargetY = targetY;
		bg = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width / 2) + 100, boxHeight, FlxColor.WHITE);
		bg.color = FlxColor.BLACK;
		bg.alpha = 0.8;
		bg.updateHitbox();
		add(bg);
		var name = new FlxText(0, 0, 0, weekName);
		name.setFormat(Paths.font("vcr.ttf"), 40, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK, true);
		name.updateHitbox();
		name.offset.set(name.width + 40, name.height / 2);
		name.x = FlxG.width / 2;
		name.y = boxHeight/2;
		add(name);
	}

	public override function update(elapsed:Float)
	{
		super.update(elapsed);
		fakeTargetY = targetY;
		if (!stopTweeningLol)
		{
			x = FlxMath.lerp(x, (-Math.abs(fakeTargetY * (fakeTargetY / 2)) * 200 - 120), 0.2);
			y = FlxMath.lerp(y, FlxG.height / 2 + fakeTargetY * (boxHeight + 20), 0.2);
		}
		bg.color = FlxColor.interpolate(bg.color, FlxColor.BLACK, elapsed);
	}

	public function startFlashing(isSelected:Bool)
	{
		if (isSelected && FlxG.save.data.flashing)
			bg.color = FlxColor.WHITE;
		stopTweeningLol = true;
		FlxTween.tween(this, {x: x - FlxG.width / 2}, 0.75, {ease: FlxEase.backIn, startDelay: Math.abs(fakeTargetY) / 7});
	}
}

typedef StoryWeekData =
{
	public var title:String;
	public var subtitle:String;
	public var preview:String;
	public var color:String;
	public var week:Dynamic;
	public var songs:Array<String>;
}

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [];
	public static var unlockedExtras:Array<String> = [];
	public static var beatWeek = false;

	var acceptInput:Bool = true;

	var weekData:Array<StoryWeekData>;

	var curWeek:Int = 0;

	var txtWeekTitle:FlxText;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<WeekItem>;

	var grpWeekPreviews:FlxSpriteGroup;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;
	var transitioning = true;

	var flash:FlxSprite;

	override public function closeSubState()
	{
		super.closeSubState();
		if (!transitioning)
			acceptInput = true;
		else
		{
			transitioning = false;
			if (unlockedExtras.length > 0 && beatWeek)
			{
				beatWeek = false;
				openSubState(new UnlockedWeekPog(unlockedExtras));
				unlockedExtras = [];
			}
		}
	}

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));

		Conductor.changeBPM(102);

		if (weekData == null)
		{
			trace("Loading week data...");
			var rawJson = Assets.getText(Paths.json("weekData", 'shared')).trim();

			while (!rawJson.endsWith("}"))
				rawJson = rawJson.substr(0, rawJson.length - 1);

			weekData = cast Json.parse(rawJson).data;
		}

		persistentUpdate = persistentDraw = true;

		grpWeekPreviews = new FlxSpriteGroup(0, 0);

		for (i in 0...weekData.length)
		{
			var previewBG = new FlxSprite(0, 0).loadGraphic(Paths.image("weekPreviews/" + weekData[i].preview, "shared"));
			previewBG.antialiasing = FlxG.save.data.antialiasing;
			previewBG.color = Std.parseInt(weekData[i].color);
			previewBG.setGraphicSize(Std.int(FlxG.width * 1.2), Std.int(FlxG.height * 1.2));
			previewBG.updateHitbox();
			previewBG.screenCenter();
			previewBG.alpha = (i == curWeek) ? 0.5 : 0;
			grpWeekPreviews.add(previewBG);
		}

		grpWeekPreviews.active = true;
		add(grpWeekPreviews);
		
		flash = new FlxSprite(0, 0).makeGraphic(FlxG.width, FlxG.height, FlxColor.WHITE);
		flash.alpha = 0;
		add(flash);

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<WeekItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		trace("Line 70");

		for (i in 0...weekData.length)
			grpWeekText.add(new WeekItem(0, yellowBG.y + yellowBG.height + 10, weekData[i].title, i));

		trace("Line 96");
		var diffBG = new FlxSprite(FlxG.width - 530, FlxG.height - 185).makeGraphic(1000, 500, FlxColor.BLACK);
		diffBG.alpha = 0.8;
		add(diffBG);
		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(FlxG.width - 470, FlxG.height - 130);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y - 50);
		sprDifficulty.frames = ui_tex;
		sprDifficulty.animation.addByPrefix('easy', 'EASY');
		sprDifficulty.animation.addByPrefix('normal', 'NORMAL');
		sprDifficulty.animation.addByPrefix('hard', 'HARD');
		sprDifficulty.animation.play('easy');
		changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(sprDifficulty.x + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);

		trace("Line 150");

		//add(yellowBG);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		//add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			bullShit++;
		}

		trace("Line 165");

		trace(unlockedExtras, beatWeek);

		if (unlockedExtras.length > 0 && beatWeek)
			acceptInput = false;
		else
		{
			unlockedExtras = [];
			beatWeek = false;
		}

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		var index = 0;
		if (!selectedWeek)
		{
			for (previewBG in grpWeekPreviews.members)
			{
				var alphaCheck = 0;
				if (index == curWeek)
					alphaCheck = 1;
				previewBG.color = FlxColor.interpolate(previewBG.color, Std.parseInt(weekData[curWeek].color), 0.02);
				previewBG.alpha = FlxMath.lerp(previewBG.alpha, alphaCheck, 0.015);
				index++;
			}
		}

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekData[curWeek].subtitle.toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = true;

		if (!movedBack && acceptInput)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						changeWeek(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						changeWeek(1);
					}

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (FlxG.keys.justPressed.UP)
				{
					changeWeek(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (stopspamming == false)
		{
			FlxG.sound.play(Paths.sound('confirmMenu'));

			for (index => b in grpWeekText.members)
			{
				b.startFlashing(index == curWeek);
			}
			stopspamming = true;
		}

		PlayState.storyPlaylist = weekData[curWeek].songs;
		PlayState.storyLength = PlayState.storyPlaylist.length;
		PlayState.isStoryMode = true;
		selectedWeek = true;

		for (i in grpWeekPreviews.members)
			i.alpha = 0;

		grpWeekPreviews.members[curWeek].alpha = 1;
		grpWeekPreviews.members[curWeek].color = Std.parseInt(weekData[curWeek].color);
		if (FlxG.save.data.flashing)
		{
			flash.alpha = 1;
			FlxTween.tween(flash, {alpha: 0}, 1.5);
			FlxTween.tween(FlxG.camera, {zoom: 1.25}, 3, {ease: FlxEase.cubeInOut});
		}

		PlayState.storyDifficulty = curDifficulty;

		// adjusting the song name to be compatible
		var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
		switch (songFormat)
		{
			case 'Dad-Battle':
				songFormat = 'Dadbattle';
			case 'Philly-Nice':
				songFormat = 'Philly';
		}

		var poop:String = Highscore.formatSong(songFormat, curDifficulty);
		PlayState.sicks = 0;
		PlayState.bads = 0;
		PlayState.shits = 0;
		PlayState.goods = 0;
		PlayState.campaignMisses = 0;
		PlayState.SONG = Song.conversionChecks(Song.loadFromJson(poop, PlayState.storyPlaylist[0]));
		PlayState.storyWeek = weekData[curWeek].week;
		PlayState.campaignScore = 0;
		new FlxTimer().start(1, function(tmr:FlxTimer)
		{
			LoadingState.loadAndSwitchState(new PlayState(), true);
		});
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = 2;
		if (curDifficulty > 2)
			curDifficulty = 0;

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.animation.play('easy');
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.animation.play('normal');
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.animation.play('hard');
				sprDifficulty.offset.x = 20;
		}

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData[curWeek].songs;

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
