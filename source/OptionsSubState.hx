package;

import Options;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class OptionText extends FlxText
{
	public var targetY:Float = 0;

	public function new(X:Float = 0, Y:Float = 0, FieldWidth:Float = 0, ?Text:String, Size:Int = 8, EmbeddedFont:Bool = true)
	{
		super(X, Y, FieldWidth, Text, Size, EmbeddedFont);
		targetY = Y;
	}

	public override function update(elapsed:Float)
	{
		y = FlxMath.lerp(y, targetY, 0.1);
		super.update(elapsed);
	}
}

// This whole substate went unused and I think it would've been really nice to have, so I finished the code. It's much nicer than having to go to the fucking options menu every time.
// all this code. all this time. and Kade releases 1.8 to make all this work obsolete. It's fine. I'm not sad I wasted my life doing this when the new official version of KE does it better anyway ;-;
// except maybe not? Ig 1.8 is busted so imma keep working on this one lol
class OptionsSubState extends MusicBeatSubstate
{
	private final fullOptions:Array<OptionCategory> = [
		new OptionCategory("Gameplay", [
			new DFJKOption(controls),
			new DownscrollOption("Toggle making the notes scroll down rather than up."),
			new GhostTapOption("Toggle counting pressing a directional input when no arrow is there as a miss. \"Miss Distance\" refers to the distance from the nearest note in ms that inputs will register a miss."),
			new UnderlayOption("Set the opacity of the note underlay that raises contrast between the notes and the background."),
			new Judgement("Customize your Hit Timings. (LEFT or RIGHT)"),
			#if desktop new FPSCapOption("Change your FPS Cap."),
			#end
			new ScrollSpeedOption("Change your scroll speed. (LEFT or RIGHT) - NOTE: Not recommended over 4 unless it's for the funny."),
			new AccuracyDOption("Change how accuracy is calculated. (Accurate = Simple, Complex = Milisecond Based)"),
			new ResetButtonOption("Toggle pressing R to gameover."),
			new InstantRespawn("Toggle if you instantly respawn after dying."),
			// new OffsetMenu("Get a note offset based off of your inputs!"),
			new CustomizeGameplay("Drag and drop gameplay modules to your prefered positions!")
		]),
		new OptionCategory("Appearance", [
			new EditorRes("Not showing the editor grid will greatly increase editor performance"),
			new MidscrollOption("Toggle placing the notes in the center or above your player."),
			new DistractionsAndEffectsOption("Toggle stage distractions that can hinder your gameplay."),
			new CamZoomOption("Toggle the camera zoom in-game."),
			new CamSwayOption("Toggle the camera swaying in the direction a note is pressed."),
			new NoteSplatsOption("Toggles the note splat effect when you hit a sick."),
			new MissGFXOption("Toggles the miss gradient effect when a note exits the top of the screen."),
			new StepManiaOption("Sets the colors of the arrows depending on quantization instead of direction."),
			new AccuracyOption("Display accuracy information on the info bar."),
			new SongPositionOption("Show the song's current position as a scrolling bar."),
			new Color("The color behind icons now fit with their theme. (e.g. Pico = green)."),
			new NPSDisplayOption("Shows your current Notes Per Second on the info bar."),
			new RainbowFPSOption("Make the FPS Counter flicker through rainbow colors."),
			new CpuStrums("Toggle the CPU's strumline lighting up when it hits a note."),
		]),
		new OptionCategory("Misc", [
			new FPSOption("Toggle the FPS Counter"),
			new HitSoundsOptions("Choose which sound plays when you hit a note."),
			new FlashingLightsOption("Toggle flashing lights that can cause epileptic seizures and strain."),
			new WatermarkOption("Enable and disable all watermarks from the engine."),
			new SkipIntroOption("Toggle the \"Skip Intro\" text in the beginning of a song (NOTE: You can still press space to skip, it's just a reminder)."),
			new AntialiasingOption("Toggle antialiasing, improving graphics quality at a slight performance penalty."),
			new MissSoundsOption("Toggle miss sounds playing when you don't hit a note."),
			new ScoreScreen("Show the score screen after the end of a song"),
			new ShowInput("Display every single input on the score screen."),
			new Optimization("No characters or backgrounds. Just a usual rhythm game layout."),
			// Just removed this. Not only would it delete all available memory but it doesn't even work because I restructured the shared\images\characters folder to be less cluttered for this specific mod.
			// new GraphicLoading("WARNING: THIS WILL TAKE FUCKIN FOREVER AND WILL USE A FUCK TON OF MEMORY! NOT RECOMMENDED!!!"),
			new BotPlay("Showcase your charts and mods with autoplay.")
		]),
		new OptionCategory("Saves and Data", [
			#if desktop new ReplayOption("View saved song replays."),
			#end
			new ResetScoreOption("Reset your score on all songs and weeks. This is irreversible!"),
			new LockWeeksOption("Reset your story mode progress. This is irreversible!"),
			new ResetSettings("Reset ALL your settings. This is irreversible!")
		], false),
		new OptionCategory("SiIvagunner", [
			new PlayEnemyOption("Play as the enemy and beat the shit outta bf!"),
			new ShortenNamesOption("Abbreviate the names of songs in freeplay. (Reopen Freeplay to take effect)"),
			new FreeplayCutscenesOption("Play story mode cutscenes in freeplay."),
			// STILL WORKIN ON IT SORRY FAM
			//new DisableCopyrightOption("Protect yourself from potentially copyrighted content."),
			new SupportSiIvagunnerButton("Check out the SiIvagunner channel!")
		])
	];

	var options:Array<OptionCategory> = [];

	static final spacing:Int = 50;
	static final padding:Int = 20;
	static final sectionSize = 70;
	static final tabsPerSection = 4;

	var scrollIndex = 10; // How many menu items fit inside the box. Determines when to start scrolling. Weird variable name, idc.

	var curSection:Int = 0;
	var inSection:Bool = false;
	var selector:FlxSprite;
	var curSelected:Int = 0;
	var bgBox:FlxSprite;
	var acceptInput = true;
	var currentDescription:String = "";

	var numSections = 0;

	var bgMusic:FlxSound;

	var initBPM:Float;

	var wasPlaying:Bool = false;

	var inPlay:Bool;

	var versionShit:FlxText;
	var blackBorder:FlxSprite;
	var uiElements:FlxSpriteGroup;
	var sectionBoxes:FlxTypedGroup<FlxSprite>;
	var grpSectionsTexts:FlxTypedGroup<FlxText>;
	var swagRect:FlxRect;

	var changedSetting = false;
	var prevChangedSetting = false;

	var closed:Bool = false;

	var grpOptionsTexts:FlxSpriteGroup;

	var menuYOffset:Int = 0;

	public function new(inPlay:Bool = false) // lotta code taken from OptionsState lol
	{
		super();
		trace('Opening options...');

		this.inPlay = inPlay; // check if the user is currently in a song's pause menu

		uiElements = new FlxSpriteGroup();
		uiElements.setSize(FlxG.width, FlxG.height);
		uiElements.updateHitbox();
		uiElements.scrollFactor.set();
		add(uiElements);

		bgBox = new FlxSprite().makeGraphic(Math.floor(FlxG.width * .9), Math.floor(FlxG.height * .9), 0xFF000000);
		bgBox.alpha = 0;
		bgBox.screenCenter(XY);
		FlxTween.tween(bgBox, {alpha: .5}, .5, {ease: FlxEase.quadOut}); // BG fade in
		uiElements.add(bgBox);

		sectionBoxes = new FlxTypedGroup<FlxSprite>();
		add(sectionBoxes);

		grpSectionsTexts = new FlxTypedGroup<FlxText>();
		add(grpSectionsTexts);

		versionShit = new FlxText(bgBox.x
			+ 5, bgBox.y
			+ bgBox.height
			- 40, bgBox.width
			- 10,
			"Offset (Down, Up, Shift for slow): "
			+ HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)
			+ " - Description - "
			+ currentDescription, 12);
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

		blackBorder = new FlxSprite(bgBox.x, bgBox.y + bgBox.height - 40).makeGraphic((Math.ceil(bgBox.width)), 40, FlxColor.BLACK);
		blackBorder.alpha = 0.5;

		uiElements.add(blackBorder);
		uiElements.add(versionShit);

		for (bruh in uiElements)
			bruh.antialiasing = FlxG.save.data.antialiasing;

		for (section in fullOptions)
			if (section.getSubAccess() || !inPlay) // Don't add anything that the substate shouldn't access if in-game (so basically save options lol)
				options.push(section);

		for (section in options)
			for (bruh in section.getOptions())
				if (!bruh.getSubAccess() && inPlay)
					section.removeOption(bruh);

		setupSections();

		wasPlaying = FlxG.sound.music.playing;

		FlxG.sound.music.pause();

		bgMusic = new FlxSound().loadEmbedded(Paths.music('options',
			'shared')); // We gotta have a banger in the background, thanks for the unused tracks KawaiSprite :3
		bgMusic.looped = true;
		bgMusic.volume = 0;
		FlxG.sound.list.add(bgMusic);
		bgMusic.play(true, FlxG.random.float(0, bgMusic.length));
		bgMusic.fadeIn(.5, 0, 0.3);

		if (!inPlay) // Don't ask. This caused me pain.
		{
			initBPM = Conductor.bpm;

			Conductor.changeBPM(117); // weird ass bpm (shits cutely)

			Conductor.songPosition = 0;
		}

		closeCallback = function() // make sure data saves when the substate is closed
		{
			trace('Closing options...');
			if (!inPlay)
				Conductor.changeBPM(initBPM);
			if (changedSetting)
			{
				trace('Overwriting Data...');
				FlxG.save.flush(0,
					function(complete)
					{
						trace((complete) ? 'Done!' : 'wtf'); // wtf
					}); // If this ever outputs 'wtf' I'm just going to drop this project, so if you're seeing this, it never happened
			}
			if (closed)
				return;
			cameras[0].zoom = 1;
			FlxTween.tween(bgMusic, {volume: 0}, .5, {
				ease: FlxEase.linear,
				onComplete: function(twn:FlxTween)
				{
					if (wasPlaying)
						FlxG.sound.music.resume();
				}
			});
		}

		if (FlxG.cameras.list.length > 1)
			cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]]; // SET THE FUCKING CAMERA TO THE CORRECT ONE SO THE SUBSTATE ACTUALLY COVERS THE SCREEN
	}

	override function beatHit() // oomf
	{
		if (acceptInput && !inPlay)
			cameras[0].zoom = 1.01;
		super.beatHit();
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		// I didn't know I had to update the cliprect every frame. This also caused me a lot of pain and sadness.
		grpOptionsTexts.clipRect = swagRect;

		for (i in 0...sectionBoxes.members.length)
		{
			var newColor = (curSelected == i && !inSection && !closed) ? FlxColor.WHITE : FlxColor.BLACK;
			sectionBoxes.members[i].color = FlxColor.interpolate(sectionBoxes.members[i].color, newColor, 0.1);
			sectionBoxes.members[i].updateHitbox();
			sectionBoxes.members[i].update(elapsed);
		}

		if (!inPlay)
			// For good measure
			bgMusic.update(elapsed);

		// cameras[0].zoom = FlxMath.lerp(cameras[0].zoom,1,.1);

		if (acceptInput)
		{
			var pressArray = [
				"up" => FlxG.keys.pressed.UP,
				"down" => FlxG.keys.pressed.DOWN,
				"left" => FlxG.keys.pressed.LEFT,
				"right" => FlxG.keys.pressed.RIGHT
			];
			var justPressed = [
				"up" => FlxG.keys.justPressed.UP,
				"down" => FlxG.keys.justPressed.DOWN,
				"left" => FlxG.keys.justPressed.LEFT,
				"right" => FlxG.keys.justPressed.RIGHT
			];
			if (inSection)
			{
				pressArray.set("up", FlxG.keys.pressed.RIGHT);
				pressArray.set("down", FlxG.keys.pressed.LEFT);
				pressArray.set("left", FlxG.keys.pressed.UP);
				pressArray.set("right", FlxG.keys.pressed.DOWN);
				justPressed.set("up", FlxG.keys.justPressed.RIGHT);
				justPressed.set("down", FlxG.keys.justPressed.LEFT);
				justPressed.set("left", FlxG.keys.justPressed.UP);
				justPressed.set("right", FlxG.keys.justPressed.DOWN);
			}
			if (!inPlay)
			{
				cameras[0].zoom = FlxMath.lerp(cameras[0].zoom, 1, .1); // Where would we be without (b-a)*alpha honestly
				// Conductor.songPosition += elapsed * 1000;
				// doing the above made it start to desync every loop (obviously I'm kind of a dumbass) so I'm just making it equal to the song's time
				Conductor.songPosition = bgMusic.time;
			}

			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null) // gamepad shit
			{
				if (((inSection && gamepad.justPressed.DPAD_UP) || (!inSection && gamepad.justPressed.DPAD_LEFT)) && !prevChangedSetting)
					changeSelection(-1);

				if (((inSection && gamepad.justPressed.DPAD_DOWN) || (!inSection && gamepad.justPressed.DPAD_RIGHT))
					&& !prevChangedSetting)
					changeSelection(1);
			}

			if (justPressed["left"] && !prevChangedSetting) // change selection shit
				changeSelection(-1);

			if (justPressed["right"] && !prevChangedSetting)
				changeSelection(1);

			if ((FlxG.keys.justPressed.ESCAPE || FlxG.keys.justPressed.BACKSPACE) && !prevChangedSetting) // close menu shit
			{
				trace(inSection);
				if (!inSection)
				{
					acceptInput = false;
					close();
				}
				else
				{
					inSection = false;
					curSelected = curSection;
					curSection = 0;
					menuYOffset = 0;
					changeSelection();
				}
			}

			if (inSection) // option input shit
			{
				var curOption = options[curSection].getOptions()[curSelected];
				if (curOption.getAccept())
				{
					if (FlxG.keys.pressed.SHIFT)
					{
						if (FlxG.keys.pressed.RIGHT)
						{
							curOption.right();
							changedSetting = true;
						}
						if (FlxG.keys.pressed.LEFT)
						{
							curOption.left();
							changedSetting = true;
						}
					}
					else
					{
						if (FlxG.keys.justPressed.RIGHT)
						{
							curOption.right();
							changedSetting = true;
						}
						if (FlxG.keys.justPressed.LEFT)
						{
							curOption.left();
							changedSetting = true;
						}
					}
					var optionName = curOption.getDisplay().split(':')[0].toLowerCase();
					if (curOption.getupdateOption() && !changedSetting && prevChangedSetting && inPlay)
						PlayState.instance.updateOption(optionName);
					updateText();
				}
				else
				{
					// disable the changing of offset during play because fuck you
					if (!inPlay && !curOption.getAccept())
					{
						changedSetting = getOffsetChange(pressArray, justPressed);

						versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2)
							+ " - Description - " + currentDescription;
					}
					else
					{
						versionShit.text = "Description - " + currentDescription;
					}
				}
			}
			else
			{
				if (!inPlay)
				{
					changedSetting = getOffsetChange(pressArray, justPressed);

					versionShit.text = "Offset (Down, Up, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
						+ currentDescription;
				}
				else
				{
					versionShit.text = "Description - " + currentDescription;
				}
			}

			if (FlxG.keys.justPressed.ENTER)
			{
				if (!inSection)
				{
					inSection = true;
					curSection = curSelected;
					curSelected = 0;
					changeSelection();
				}
				else
				{
					var curOption = options[curSection].getOptions()[curSelected];
					if (curOption.press())
					{
						if (curOption.getupdateOption() && inPlay)
						{
							var optionName = curOption.getDisplay().split(':')[0].toLowerCase();
							PlayState.instance.updateOption(optionName);
						}
						updateText();
						changedSetting = true;
					}
				}
			}
			if (!changedSetting && prevChangedSetting)
			{ // this is so that if someone were to update an option every frame it would wait until they're done
				trace("Saved");
				FlxG.sound.play(Paths.sound('optionSelect'), 0.5);
				FlxG.save.flush();
				if (inPlay && options[curSection].getOptions()[curSelected].getupdateOption())
					PlayState.instance.resetPauseMenu = true; // disable resuming the song if the selected opion requires a reset
			}
			prevChangedSetting = changedSetting;
			changedSetting = false;
		}
	}

	// This is a long-ass line of code that was just copy-pasted like 4 times in the OG optionsmenu code so I made it a function. It controls the offset. Obviously.
	function getOffsetChange(pressArray:Map<String, Bool>, justPressed:Map<String, Bool>):Bool
	{
		if (FlxG.keys.pressed.SHIFT)
		{
			if (pressArray["up"])
			{
				FlxG.save.data.offset += 0.1;
				return true;
			}
			else if (pressArray["down"])
			{
				FlxG.save.data.offset -= 0.1;
				return true;
			}
			return changedSetting;
		}
		else if (justPressed["up"])
		{
			FlxG.save.data.offset += 0.1;
			return true;
		}
		else if (justPressed["down"])
		{
			FlxG.save.data.offset -= 0.1;
			return true;
		}
		return changedSetting;
	}

	function changeSelection(change:Int = 0) // poop
	{
		// if (change != 0)
		FlxG.sound.play(Paths.sound('scrollMenu'));

		curSelected += change;

		var curLength = (inSection) ? grpOptionsTexts.length : sectionBoxes.length;

		if (curSelected < 0)
			curSelected = curLength - 1;
		if (curSelected >= curLength)
			curSelected = 0;

		if (!inSection)
		{
			currentDescription = "Please select a category";
			refreshText();
		}
		if (inSection)
		{
			var scrollStart = Math.floor(scrollIndex / 2);
			if (curSelected > scrollStart && curSelected < grpOptionsTexts.length - scrollStart)
				menuYOffset = (curSelected - scrollStart) * spacing;
			else if (curSelected > scrollStart
				&& curSelected >= grpOptionsTexts.length - scrollIndex
				&& grpOptionsTexts.length > scrollIndex)
				menuYOffset = (grpOptionsTexts.length - scrollIndex) * spacing;
			else
				menuYOffset = 0;
			var curOption = options[curSection].getOptions()[curSelected];
			// updateText();
			currentDescription = curOption.getDescription();
			if (!inPlay && !curOption.getAccept())
				versionShit.text = "Offset (Left, Right, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
					+ currentDescription;
			else
				versionShit.text = "Description - " + currentDescription;
		}
		else if (!inPlay)
		{
			versionShit.text = "Offset (Down, Up, Shift for slow): " + HelperFunctions.truncateFloat(FlxG.save.data.offset, 2) + " - Description - "
				+ currentDescription;
		}
		else
		{
			versionShit.text = "Description - " + currentDescription;
		}

		if (grpOptionsTexts.members.length > 0)
			grpOptionsTexts.forEach(function(txt:FlxSprite)
			{
				txt.color = FlxColor.WHITE;

				if (txt.ID == curSelected && inSection)
					txt.color = FlxColor.YELLOW;

				var txt = cast(txt, OptionText);
				txt.targetY = 20 + txt.ID * spacing - menuYOffset + grpOptionsTexts.y;
			});
	}

	function updateText()
	{
		for (i in 0...grpOptionsTexts.members.length)
		{
			// I'm not gonna attempt to make all options changeable on the fly lmao
			// Alright Kade, I see you. Wanna fuckin' go? I'll make ALL this shit changeable on the fly >:)
			// Despite the fact you probably aleady did just that and now this is useless until 1.8 comes out
			var curOption = options[curSection].getOptions()[i];
			var txt = cast(grpOptionsTexts.members[i], FlxText);
			txt.text = curOption.getDisplay();

			if (curOption.getAccept())
				txt.text = curOption.getDisplay() + curOption.getValue();
		}
	}

	function refreshText()
	{
		grpOptionsTexts.forEach(function(txt:FlxSprite)
		{
			remove(txt);
			txt.kill();
			txt.destroy();
		});
		grpOptionsTexts.clear();
		var newOptions = options[curSelected].getOptions();
		for (i in 0...newOptions.length)
		{
			var text = newOptions[i].getDisplay();
			if (newOptions[i].getAccept())
				text = newOptions[i].getDisplay() + newOptions[i].getValue();
			createOptionText(text, i);
		}
	}

	function setupSections() // Menu used to be a bit more barebones but now Imma redesign this bitch
	{
		var offset = Math.floor(bgBox.width / Math.min(options.length, 4));
		for (i in 0...options.length)
		{
			if (i % 4 == 0)
				numSections += 1;
			var finalOffset = offset;
			if (i % 4 == 3)
				finalOffset = Math.ceil((bgBox.x + bgBox.width) - (bgBox.x + (Math.floor(offset) * i)));
			var sectionBG = new FlxSprite(bgBox.x + (Math.floor(offset) * (i % 4)),
				bgBox.y + (sectionSize * (numSections - 1))).makeGraphic(finalOffset, sectionSize, FlxColor.WHITE);
			sectionBG.color = FlxColor.BLACK;
			sectionBG.updateHitbox();
			sectionBoxes.add(sectionBG);
			sectionBG.alpha = 0.5;
			var sectionText:FlxText = new FlxText(0, 0, offset * .95, options[i].getName(), 28);
			sectionText.font = "VCR OSD Mono";
			sectionText.antialiasing = FlxG.save.data.antialiasing;
			sectionText.autoSize = false;
			sectionText.alignment = CENTER;
			sectionText.color = FlxColor.WHITE;
			sectionText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK, 2, 1);
			sectionText.updateHitbox();
			sectionText.offset.set(sectionText.frameWidth / 2, sectionText.frameHeight / 2);
			sectionText.setPosition(sectionBG.getMidpoint().x, sectionBG.getMidpoint().y);
			sectionText.scrollFactor.set();
			grpSectionsTexts.add(sectionText);
		}

		if (numSections > 1 && sectionBoxes.length % 4 != 0)
		{
			for (i in sectionBoxes.length % 4...5 - sectionBoxes.length % 4)
			{
				var finalOffset = offset;
				if (i % 4 == 3)
					finalOffset = Math.ceil((bgBox.x + bgBox.width) - (bgBox.x + (Math.floor(offset) * i)));
				var dummyBox = new FlxSprite(bgBox.x + (Math.floor(offset) * (i % 4)),
					bgBox.y + (sectionSize * (numSections - 1))).makeGraphic(finalOffset, sectionSize, FlxColor.BLACK);
				dummyBox.updateHitbox();
				dummyBox.alpha = 0.5;
				uiElements.add(dummyBox);
			}
		}

		var height = bgBox.height - (sectionSize * numSections) - 40;

		// I didn't know that the cliprect's position was actually an offset from what it's clipping. This caused me a lot of pain and sadness.
		swagRect = new FlxRect(0, 0, bgBox.width, height);

		grpOptionsTexts = new FlxSpriteGroup(bgBox.x, bgBox.y + (sectionSize * numSections));
		grpOptionsTexts.setSize(bgBox.width, height);
		grpOptionsTexts.updateHitbox();
		grpOptionsTexts.clipRect = swagRect;
		add(grpOptionsTexts);

		scrollIndex = Math.floor(height / spacing);

		trace(height, spacing, height / spacing);

		changeSelection();
	}

	function createOptionText(text:String, i:Int)
	{
		var optionText:OptionText = new OptionText(padding, padding + (i * spacing), 0, text);
		optionText.ID = i;
		optionText.setFormat(null, 30, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		optionText.borderSize = 2;
		optionText.font = "VCR OSD Mono";
		optionText.scrollFactor.set();
		optionText.updateHitbox();
		grpOptionsTexts.add(optionText);

		optionText.antialiasing = FlxG.save.data.antialiasing;
	}

	override function close() // Bababooey
	{
		closed = true;

		remove(grpOptionsTexts);
		remove(grpSectionsTexts);

		if (!inPlay)
			Conductor.changeBPM(initBPM);

		cameras[0].zoom = 1;

		FlxTween.tween(bgMusic, {volume: 0}, .5, { // bye bye music
			ease: FlxEase.linear,
			onComplete: function(twn:FlxTween)
			{
				if (wasPlaying)
					FlxG.sound.music.resume();
			}
		});

		for (box in sectionBoxes.members)
			FlxTween.tween(box, {alpha: 0}, .5, {ease: FlxEase.quadOut});

		FlxTween.tween(uiElements, {alpha: 0}, .5, { // Make the shit fade
			ease: FlxEase.quadOut,
			onComplete: function(twn:FlxTween)
			{
				_parentState.closeSubState(); // _parentState is extremely useful for toggling input acceptance upon closing a substate by overriding closeSubState() (as well as openSubState()).
				// In fact, I changed KeyBindMenu to be compatible anywhere using this method, removing the reference to OptionsMenu.instance (because that would result in a null object reference in this case).
			}
		});
	}
}