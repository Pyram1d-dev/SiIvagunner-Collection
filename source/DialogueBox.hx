package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.text.FlxTypeText;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxSpriteGroup;
import flixel.input.FlxKeyManager;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class DialogueBox extends FlxSpriteGroup
{
	var box:FlxSprite;

	var curCharacter:String = '';
	var rootSong:String;

	var dialogue:Alphabet;
	var dialogueList:Array<String> = [];

	// SECOND DIALOGUE FOR THE PIXEL SHIT INSTEAD???
	var swagDialogue:FlxTypeText;

	var dropText:FlxText;

	public var finishThing:Void->Void;

	var portraitLeft:FlxSprite;
	var portraitRight:FlxSprite;
	var portraitMiddle:FlxSprite;

	var handSelect:FlxSprite;
	var bgFade:FlxSprite;

	var sound:FlxSound;

	public function new(talkingRight:Bool = true, ?dialogueList:Array<String>)
	{
		super();

		var songLowercase = StringTools.replace(PlayState.SONG.song, " ", "-").toLowerCase();

		rootSong = (songLowercase != 'lo-fight') ? songLowercase.split('-')[0] : songLowercase;

		var tempLol:Map<String, String> = [
			'senpai' => 'weeb/pixelUI/dialogueBox-pixel',
			'roses' => 'weeb/pixelUI/dialogueBox-senpaiMad',
			'thorns' => 'weeb/pixelUI/dialogueBox-evil'
		];

		var paths:Map<String, String> = [
			'dB' => tempLol[rootSong],
			'lP' => 'weeb/senpaiPortrait',
			'rP' => 'weeb/bfPortrait',
			'aS' => 'ANGRY_TEXT_BOX',
			'sF' => 'weeb/spiritFaceForward',
			'hS' => 'weeb/pixelUI/hand_textbox',
			'lB' => 'Lunchbox',
			'lBS' => 'LunchboxScary',
		];

		// Ah, how I love maps. Might be because I used to primarily program with Lua.

		trace(songLowercase);
		switch (songLowercase)
		{
			case 'senpai':
				paths.set('lB', 'Lunchbox-nightowl');
			case 'senpai-in-game-version':
				paths.set('dB', 'weeb/hypno/pixelUI/dialogueBox-pixel');
				paths.set('lP', 'weeb/hypno/senpaiPortrait');
				paths.set('rP', 'weeb/hypno/bfPortrait');
			case 'senpai-beta-mix':
				paths.set('lB', 'Lunchbox-wrr');
				paths.set('lP', 'weeb/wrr/senpaiPortrait');
			case 'roses':
				paths.set('dB', 'weeb/daftpunk/pixelUI/dialogueBox-senpaiMad');
				paths.set('rP', 'weeb/daftpunk/bfPortrait');
			case 'roses-beta-mix':
				paths.set('dB', 'weeb/willsmith/pixelUI/dialogueBox-senpaiMad');
			case 'roses-ost-version':
				paths.set('dB', 'weeb/terraria/pixelUI/dialogueBox-senpaiMad');
				paths.set('rP', 'weeb/terraria/bfPortrait');
				paths.set('aS', 'ANGRY_TEXT_BOX-skeletron');
			case 'thorns':
				paths.set('sF', 'weeb/clubpenguin/spiritFaceForward');
			case 'thorns-beta-mix':
				paths.set('sF', 'weeb/earthbound/spiritFaceForward');
				paths.set('hS', 'weeb/earthbound/pixelUI/hand_textbox');
				paths.set('dB', 'weeb/earthbound/pixelUI/dialogueBox-evil');
				paths.set('lBS', 'LunchboxScary-EB');
		}

		switch (rootSong)
		{
			case 'senpai':
				sound = new FlxSound().loadEmbedded(Paths.music(paths.get('lB')), true);
				sound.volume = 0;
				FlxG.sound.list.add(sound);
				sound.fadeIn(1, 0, 0.8);
			case 'thorns':
				sound = new FlxSound().loadEmbedded(Paths.music(paths.get('lBS')), true);
				sound.volume = 0;
				FlxG.sound.list.add(sound);
				sound.fadeIn(1, 0, 0.8);
		}

		var gaming:Bool = rootSong != 'lo-fight' && rootSong != 'overhead' && rootSong != 'ballistic';

		trace('not epic!!!');

		if (gaming)
		{
			bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), 0xFFB3DFd8);
			bgFade.scrollFactor.set();
			bgFade.alpha = 0;
			add(bgFade);

			new FlxTimer().start(0.83, function(tmr:FlxTimer)
			{
				bgFade.alpha += (1 / 5) * 0.7;
				if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
			}, 5);
		}
		else
		{
			bgFade = new FlxSprite(-200, -200).makeGraphic(Std.int(FlxG.width * 1.3), Std.int(FlxG.height * 1.3), FlxColor.GRAY);
			bgFade.scrollFactor.set();
			bgFade.alpha = 0;
			add(bgFade);

			new FlxTimer().start(0.83, function(tmr:FlxTimer)
			{
				bgFade.alpha += (1 / 5) * 0.7;
				if (bgFade.alpha > 0.7)
					bgFade.alpha = 0.7;
			}, 5);
		}

		trace('epic!!!');

		if (PlayState.storyWeek != 9)
			box = new FlxSprite(-20, 45);
		else
			box = new FlxSprite(0, 0);

		var hasDialog = false;

		switch (rootSong)
		{
			case 'wocky' | 'beathoven':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('kapiUI/dialogueBox-kapi', 'arcadeWeek');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'senpai':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas(paths.get('dB'), 'week6');
				box.animation.addByPrefix('normalOpen', 'Text Box Appear', 24, false);
				box.animation.addByIndices('normal', 'Text Box Appear', [4], "", 24);
			case 'roses':
				hasDialog = true;
				FlxG.sound.play(Paths.sound(paths.get('aS')));

				box.frames = Paths.getSparrowAtlas(paths.get('dB'), 'week6');
				box.animation.addByPrefix('normalOpen', 'SENPAI ANGRY IMPACT SPEECH', 24, false);
				box.animation.addByIndices('normal', 'SENPAI ANGRY IMPACT SPEECH', [4], "", 24);

			case 'thorns':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas(paths.get('dB'), 'week6');
				box.animation.addByPrefix('normalOpen', 'Spirit Textbox spawn', 24, false);
				box.animation.addByIndices('normal', 'Spirit Textbox spawn', [11], "", 24);

				var face:FlxSprite = new FlxSprite(320, 170).loadGraphic(Paths.image(paths.get('sF')));
				face.setGraphicSize(Std.int(face.width * 6));
				add(face);

			case 'lo-fight' | 'overhead' | 'ballistic':
				hasDialog = true;
				box.frames = Paths.getSparrowAtlas('speech_bubble_talking', 'shared');
				box.animation.addByPrefix('normalOpen', 'Speech Bubble Normal Open', 24, false);
				box.animation.addByIndices('normal', 'speech bubble normal', [11], "", 24);
				box.antialiasing = true;
		}

		box.animation.play('normalOpen');

		if (gaming)
			if (PlayState.storyWeek != 9)
				box.setGraphicSize(Std.int(box.width * PlayState.daPixelZoom * 0.9));
			else
				box.setGraphicSize(Std.int(box.width * 1));

		else
		{
			box.y = FlxG.height - 285;
			box.x = 20;
		}

		box.updateHitbox();

		if (!hasDialog)
			return;

		if (gaming)
		{
			if (PlayState.storyWeek != 9)
			{
				portraitLeft = new FlxSprite(-20, 40);
				portraitLeft.frames = Paths.getSparrowAtlas(paths.get('lP'), 'week6');
				portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * PlayState.daPixelZoom * 0.9));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				add(portraitLeft);
				portraitLeft.visible = false;

				portraitRight = new FlxSprite(0, 40);
				portraitRight.frames = Paths.getSparrowAtlas(paths.get('rP'), 'week6');
				portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
				portraitRight.setGraphicSize(Std.int(portraitRight.width * PlayState.daPixelZoom * 0.9));
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
				add(portraitRight);
				portraitRight.visible = false;
			}
			else
			{
				portraitLeft = new FlxSprite(0, 160);
				portraitLeft.frames = Paths.getSparrowAtlas('kapiUI/kapi', 'arcadeWeek');
				portraitLeft.animation.addByPrefix('enter', 'Senpai Portrait Enter', 24, false);
				portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 1));
				portraitLeft.updateHitbox();
				portraitLeft.scrollFactor.set();
				add(portraitLeft);
				portraitLeft.visible = false;

				portraitRight = new FlxSprite(700, 145);
				portraitRight.frames = Paths.getSparrowAtlas('kapiUI/bf', 'arcadeWeek');
				portraitRight.animation.addByPrefix('enter', 'Boyfriend portrait enter', 24, false);
				portraitRight.setGraphicSize(Std.int(portraitRight.width * 1));
				portraitRight.updateHitbox();
				portraitRight.scrollFactor.set();
				add(portraitRight);
				portraitRight.visible = false;

				portraitMiddle = new FlxSprite(350, 90);
				portraitMiddle.frames = Paths.getSparrowAtlas('kapiUI/gfwave', 'arcadeWeek');
				portraitMiddle.animation.addByPrefix('enter', 'Girlfriend portrait enter', 24, false);
				portraitMiddle.setGraphicSize(Std.int(portraitRight.width * 1));
				portraitMiddle.updateHitbox();
				portraitMiddle.scrollFactor.set();
				add(portraitMiddle);
				portraitMiddle.visible = false;
			}
		}
		else
		{
			portraitLeft = new FlxSprite(200, FlxG.height - 525);
			portraitRight = new FlxSprite(800, FlxG.height - 489);

			switch (rootSong)
			{
				case 'lo-fight':
					portraitLeft.frames = Paths.getSparrowAtlas('whittyPort', 'bonusWeek');
					portraitRight.frames = Paths.getSparrowAtlas('boyfriendPort', 'bonusWeek');
					portraitLeft.animation.addByPrefix('enter', 'Whitty Portrait Normal', 24, false);
				case 'overhead':
					portraitLeft.frames = Paths.getSparrowAtlas('OH/whittyPort', 'bonusWeek');
					portraitRight.frames = Paths.getSparrowAtlas('boyfriendPort', 'bonusWeek');
					portraitLeft.animation.addByPrefix('enter', 'Whitty Portrait Agitated', 24, false);
				case 'ballistic':
					portraitLeft.frames = Paths.getSparrowAtlas('Ballistic/whittyPort', 'bonusWeek');
					portraitRight.frames = Paths.getSparrowAtlas('Ballistic/boyfriendPort', 'bonusWeek');
					portraitLeft.animation.addByPrefix('enter', 'Whitty Portrait Crazy', 24, true);
			}

			portraitLeft.antialiasing = true;
			portraitLeft.updateHitbox();
			portraitLeft.scrollFactor.set();
			add(portraitLeft);
			portraitLeft.visible = false;

			portraitRight.animation.addByPrefix('enter', 'BF portrait enter', 24, true);
			portraitRight.antialiasing = true;
			portraitRight.updateHitbox();
			portraitRight.scrollFactor.set();
			add(portraitRight);
			portraitRight.visible = false;

			portraitRight.setGraphicSize(Std.int(portraitRight.width * 0.8));
			portraitLeft.setGraphicSize(Std.int(portraitLeft.width * 0.8));
		}

		add(box);

		box.screenCenter(X);

		if (gaming && PlayState.storyWeek != 9)
		{
			portraitLeft.screenCenter(X);
			handSelect = new FlxSprite(FlxG.width * 0.9, FlxG.height * 0.9).loadGraphic(Paths.image(paths.get('hS')));
			add(handSelect);
		}

		if (!talkingRight)
		{
			// box.flipX = true;
		}

		dropText = new FlxText(242, 502, Std.int(FlxG.width * 0.6), "", (PlayState.storyWeek == 9) ? 48 : 32);
		if (gaming)
		{
			dropText.font = (PlayState.storyWeek == 9) ? 'Delfino' : 'Pixel Arial 11 Bold';
			dropText.color = (PlayState.storyWeek == 9) ? 0x00000000 : 0xFFD89494;
		}
		else
		{
			dropText.font = 'VCR OSD Mono';
			dropText.color = FlxColor.RED;
			dropText.antialiasing = true;
		}
		add(dropText);

		swagDialogue = new FlxTypeText(240, 500, Std.int(FlxG.width * 0.6), "", dropText.size);
		swagDialogue.font = dropText.font;
		if (gaming)
		{
			swagDialogue.color = (PlayState.storyWeek == 9) ? 0xFFFFFFFF : 0xFF3F2021;
		}
		else
		{
			swagDialogue.color = FlxColor.BLACK;
			swagDialogue.antialiasing = true;
		}
		if (gaming)
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
		else if (rootSong == 'ballistic')
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('ballistic', 'shared'), 0.6)];
		else
			swagDialogue.sounds = [FlxG.sound.load(Paths.sound('whitty', 'shared'), 0.6)];
		add(swagDialogue);

		dialogue = new Alphabet(0, 80, "", false, true);
		// dialogue.x = 90;
		// add(dialogue);

		this.dialogueList = dialogueList;
	}

	var dialogueOpened:Bool = false;
	var dialogueStarted:Bool = false;

	override function update(elapsed:Float)
	{
		// HARD CODING CUZ IM STUPDI
		if (rootSong == 'roses')
			portraitLeft.visible = false;
		if (rootSong == 'thorns')
		{
			portraitLeft.visible = false;
			swagDialogue.color = FlxColor.WHITE;
			dropText.color = FlxColor.BLACK;
		}

		dropText.text = swagDialogue.text;

		if (box.animation.curAnim != null)
		{
			if (box.animation.curAnim.name == 'normalOpen' && box.animation.curAnim.finished)
			{
				box.animation.play('normal');
				dialogueOpened = true;
			}
		}

		if (dialogueOpened && !dialogueStarted)
		{
			startDialogue();
			dialogueStarted = true;
		}

		if (PlayerSettings.player1.controls.ACCEPT && dialogueStarted == true)
		{
			remove(dialogue);

			var pebis = (PlayState.storyWeek == 9) ? '-kapi' : '';

			FlxG.sound.play(Paths.sound('clickText' + pebis), 0.8);

			if (dialogueList[1] == null && dialogueList[0] != null)
			{
				if (!isEnding)
				{
					isEnding = true;

					if (rootSong == 'senpai' || rootSong == 'thorns')
						sound.fadeOut(2.2, 0);



					new FlxTimer().start(0.2, function(tmr:FlxTimer)
					{
						if (PlayState.storyWeek == 9)
							portraitMiddle.visible = false;
						box.alpha -= 1 / 5;
						bgFade.alpha -= 1 / 5 * 0.7;
						portraitLeft.visible = false;
						portraitRight.visible = false;
						swagDialogue.alpha -= 1 / 5;
						dropText.alpha = swagDialogue.alpha;
					}, 5);

					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						finishThing();
						kill();
					});
				}
			}
			else
			{
				dialogueList.remove(dialogueList[0]);
				startDialogue();
			}
		}

		super.update(elapsed);
	}

	var isEnding:Bool = false;

	function startDialogue():Void
	{
		cleanDialog();
		// var theDialog:Alphabet = new Alphabet(0, 70, dialogueList[0], false, true);
		// dialogue = theDialog;
		// add(theDialog);

		// swagDialogue.text = ;
		swagDialogue.resetText(dialogueList[0]);
		swagDialogue.start(0.04, true);

		if (PlayState.storyWeek == 9)
		{
			if (curCharacter.startsWith('bf'))
			{
				portraitLeft.visible = false;
				portraitMiddle.visible = false;
				portraitRight.frames = Paths.getSparrowAtlas('kapiUI/${curCharacter}', 'arcadeWeek');
				if (!portraitRight.visible)
				{
					portraitRight.visible = true;
					portraitRight.animation.play('enter');
				}
			}
			if (curCharacter.startsWith('kapi') || curCharacter.startsWith('remilia'))
			{
				portraitRight.visible = false;
				portraitMiddle.visible = false;
				portraitLeft.frames = Paths.getSparrowAtlas('kapiUI/${curCharacter}', 'arcadeWeek');
				if (!portraitLeft.visible)
				{
					portraitLeft.visible = true;
					portraitLeft.animation.play('enter');
				}
			}
			if (curCharacter.startsWith('gf') || curCharacter.startsWith('marisa'))
			{
				portraitLeft.visible = false;
				portraitRight.visible = false;
				portraitMiddle.frames = Paths.getSparrowAtlas('kapiUI/${curCharacter}', 'arcadeWeek');
				if (!portraitMiddle.visible)
				{
					portraitMiddle.visible = true;
					portraitMiddle.animation.play('enter');
				}
			}
		}
		else
		{
			switch (curCharacter)
			{
				case 'dad':
					portraitRight.visible = false;
					if (!portraitLeft.visible)
					{
						portraitLeft.visible = true;
						portraitLeft.animation.play('enter');

						if (rootSong == 'ballistic')
							swagDialogue.sounds = [FlxG.sound.load(Paths.sound('ballistic', 'shared'), 0.6)];
						else if (rootSong == 'lo-fight' || rootSong == 'overhead')
							swagDialogue.sounds = [FlxG.sound.load(Paths.sound('whitty', 'shared'), 0.6)];
					}
				case 'bf':
					portraitLeft.visible = false;
					if (!portraitRight.visible)
					{
						portraitRight.visible = true;
						portraitRight.animation.play('enter');
						swagDialogue.sounds = [FlxG.sound.load(Paths.sound('pixelText'), 0.6)];
					}
			}
		}
	}

	function cleanDialog():Void
	{
		var splitName:Array<String> = dialogueList[0].split(":");
		curCharacter = splitName[1];
		dialogueList[0] = dialogueList[0].substr(splitName[1].length + 2).trim();
	}
}
