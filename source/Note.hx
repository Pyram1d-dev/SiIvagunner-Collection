package;

import PlayState;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.math.FlxMath;
import haxe.Exception;

using StringTools;

typedef AnimData = 
{
	var prefix:String;
	var frameRate:Int;
	var directional:Bool;
	var offset:Array<Int>;
	var variation:Int;
	var sound:String;
	var scale:Float;
}

typedef MineData = 
{
	var name:String;
	var effect:String; 
	var effectAnimation:AnimData;
	var animations:Array<String>;
	var offsets:Array<Array<Array<Int>>>;
	var flipDownscroll:Bool;
}

typedef NoteSkinData =
{
	var name:String;
	var skinOverride:Null<String>;
	var type:String;
	var splats:String;
	var uiSkin:String;
	var mineSkin:String;
	var colors:Array<String>;
	var mineData:MineData;
}

class Note extends FlxSprite
{
	public var strumTime:Float = 0;
	public var baseStrum:Float = 0;
	
	public var charterSelected:Bool = false;

	public var rStrumTime:Float = 0;

	public var mustPress:Bool = false;
	public var noteData:Int = 0;
	public var rawNoteData:Int = 0;
	public var isMine:Bool = false; // TRICKY MOMENT POG
	public var canBeHit:Bool = false;
	public var tooLate:Bool = false;
	public var wasGoodHit:Bool = false;
	public var prevNote:Note;
	public var modifiedByLua:Bool = false;
	public var sustainLength:Float = 0;
	public var isSustainNote:Bool = false;
	public var originColor:Int = 0; // The sustain note's original note's color
	public var noteSection:Int = 0;

	public var luaID:Int = 0;

	public var isAlt:Bool = false;

	public var noteCharterObject:FlxSprite;

	public var noteScore:Float = 1;

	public var noteYOff:Int = 0;

	public var beat:Null<Float> = null;

	public static var swagWidth:Float = 160 * 0.7;
	public static var PURP_NOTE:Int = 0;
	public static var GREEN_NOTE:Int = 2;
	public static var BLUE_NOTE:Int = 1;
	public static var RED_NOTE:Int = 3;

	public var rating:String = "shit";

	public var modAngle:Float = 0; // The angle set by modcharts
	public var localAngle:Float = 0; // The angle to be edited inside Note.hx
	public var originAngle:Float = 0; // The angle the OG note of the sus note had (?)

	public var dataColor:Array<String> = ['purple', 'blue', 'green', 'red'];
	public var quantityColor:Array<Int> = [RED_NOTE, 2, BLUE_NOTE, 2, PURP_NOTE, 2, BLUE_NOTE, 2];
	public var arrowAngles:Array<Int> = [180, 90, 270, 0];

	public var isParent:Bool = false;
	public var parent:Note = null;
	public var spotInLine:Int = 0;
	public var sustainActive:Bool = true;

	public var children:Array<Note> = [];

	public var noteSkinData:NoteSkinData = null;

	var mineOffsets:Array<Array<Array<Int>>> = null;

	public function new(strumTime:Float, noteData:Int, ?prevNote:Note, ?sustainNote:Bool = false, ?inCharter:Bool = false, ?isAlt:Bool = false, ?bet:Float)
	{
		super();

		if (prevNote == null)
			prevNote = this;

		beat = bet;

		this.isAlt = isAlt;

		this.prevNote = prevNote;
		isSustainNote = sustainNote;

		x += 50;
		// MAKE SURE ITS DEFINITELY OFF SCREEN?
		y -= 2000;

		if (inCharter)
		{
			this.strumTime = strumTime;
			rStrumTime = strumTime;
		}
		else
		{
			this.strumTime = strumTime;
			#if sys
			if (PlayState.isSM)
			{
				rStrumTime = strumTime;
			}
			else
				rStrumTime = (strumTime - FlxG.save.data.offset + PlayState.songOffset);
			#else
			rStrumTime = (strumTime - FlxG.save.data.offset + PlayState.songOffset);
			#end
		}


		if (this.strumTime < 0 )
			this.strumTime = 0;

		isMine = noteData > 7 || (isSustainNote && prevNote.isMine);

		this.noteData = noteData;

		if (!inCharter)
			this.noteData%=4;

		//defaults if no noteStyle was found in chart
		var noteTypeCheck:String = 'normal';
		if (inCharter)
		{
			frames = Paths.getSparrowAtlas('NOTE_assets');

			for (i in 0...4)
			{
				animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
				animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
				animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
			}

			setGraphicSize(Std.int(width * 0.7));
			updateHitbox();
			antialiasing = FlxG.save.data.antialiasing;
		}
		else
		{
			if (PlayState.SONG.noteStyle == null)
			{
				switch (PlayState.storyWeek)
				{
					case 6:
						noteTypeCheck = 'pixel';
				}
			}
			else
			{
				noteTypeCheck = PlayState.SONG.noteStyle;
			}

			noteSkinData = PlayState.instance.noteSkinData;

			switch (noteSkinData.type)
			{
				case 'pixel':
					loadGraphic(Paths.image('noteskins/' + noteSkinData.name, 'shared'), true, 17, 17);
					if (isSustainNote)
						loadGraphic(Paths.image('noteskins/' + noteSkinData.name + '-ends', 'shared'), true, 7, 6);

					// Pixel mines?!?!?
					if (isMine)
					{
						loadGraphic(Paths.image('NOTE_fire-pixel', "clown"), true, 21, 31);
						for (i in 0...4)
						{
							var c = i * 3;
							animation.add(dataColor[i] + 'Scroll', [c,c+1,c+2], 15); // Normal notes
						}
					}
					else
						for (i in 0...4)
						{
							animation.add(dataColor[i] + 'Scroll', [i + 4]); // Normal notes
							animation.add(dataColor[i] + 'hold', [i]); // Holds
							animation.add(dataColor[i] + 'holdend', [i + 4]); // Tails
						}

					var widthSize = Std.int(PlayState.curStage.startsWith('school') ? (width * PlayState.daPixelZoom) : (isSustainNote ? (width * (PlayState.daPixelZoom
						- 1.5)) : (width * PlayState.daPixelZoom)));

					if (isMine)
					{
						var myBalls = -Math.floor(widthSize * 0.34);
						mineOffsets = [[[], [], [], []], [[], [], [], []]];
						for (index => scrollOffsets in mineOffsets)
							for (i in scrollOffsets)
							{
								i[0] = myBalls;
								switch(index)
								{
									case 0:
										i[1] = myBalls - 12;
									case 1:
										i[1] = myBalls - 108;
								}
							}
					}

					setGraphicSize(Math.floor(widthSize * (isMine ? 1.5 : 1)));
					updateHitbox();
				default:
					if (!isMine)
					{
						frames = Paths.getSparrowAtlas('noteskins/' + noteSkinData.name, 'shared');
						for (i in 0...4)
						{
							animation.addByPrefix(dataColor[i] + 'Scroll', dataColor[i] + ' alone'); // Normal notes
							animation.addByPrefix(dataColor[i] + 'hold', dataColor[i] + ' hold'); // Hold
							animation.addByPrefix(dataColor[i] + 'holdend', dataColor[i] + ' tail'); // Tails
						}
					}
					else
					{
						if (PlayState.SONG.song == 'Madness')
						{
							// THESE. FUCKING. MINES. I CANNOT STRESS HOW FUCKING LONG GUESSING THE OFFSETS TOOK. THIS IS BEFORE I MADE MINE SKINS INTO A JSON FORMAT.
							frames = Paths.getSparrowAtlas('mines/fireNoteHK', "shared");
							mineOffsets = [
								[[-3, -22], [-12, -24], [-13, -3], [-2, -19]],
								[[-10, -4], [-14, -6], [-16, -8], [4, -10]]
							];
							for (index => scrollOffsets in mineOffsets)
								for (i in scrollOffsets)
								{
									i[0] += 43;
									switch (index)
									{
										case 0:
											i[1] += 60;
										case 1:
											i[1] += 195;
									}
								}
						}
						else
						{
							frames = Paths.getSparrowAtlas('mines/' + noteSkinData.mineData.name, "shared");
							mineOffsets = noteSkinData.mineData.offsets;
						}

						var mineAnim = noteSkinData.mineData.animations;
						if (mineAnim != null)
						{
							animation.addByPrefix('purpleScroll', mineAnim[0]);
							animation.addByPrefix('blueScroll', mineAnim[1]);
							animation.addByPrefix('greenScroll', mineAnim[2]);
							animation.addByPrefix('redScroll', mineAnim[3]);
						}

						if (noteSkinData.mineData.flipDownscroll && FlxG.save.data.downscroll)
						{
							var oldDown = animation.getByName('blueScroll').frames;
							animation.getByName('blueScroll').frames = animation.getByName('greenScroll').frames;
							animation.getByName('greenScroll').frames = oldDown;
							flipY = true;
						}
					}

					setGraphicSize(Std.int(width * 0.7));
					updateHitbox();

					antialiasing = FlxG.save.data.antialiasing;
			}
		}

		setupNote(inCharter);
	}

	public function setupNote(inCharter:Bool = false, switchDownscroll:Bool = false) // hoo boy hotswappable options
	{
		// x += swagWidth * noteData;
		// swap animations for up and down arrows if downscroll was changed in settings during the game
		if (isMine && switchDownscroll)
		{
			var oldDown = animation.getByName('blueScroll').frames;
			animation.getByName('blueScroll').frames = animation.getByName('greenScroll').frames;
			animation.getByName('greenScroll').frames = oldDown;
		}
		animation.play(dataColor[noteData] + 'Scroll');
		originColor = noteData; // The note's origin color will be checked by its sustain notes
		localAngle = 0;

		if (!inCharter)
		{
			switch (noteSkinData.type)
			{
				case 'pixel':
					setSize(17, 17);
					if (isSustainNote)
						setSize(7, 6);
					var widthSize = Std.int(PlayState.curStage.startsWith('school') ? (width * PlayState.daPixelZoom) : (isSustainNote ? (width * (PlayState.daPixelZoom
						- 1.5)) : (width * PlayState.daPixelZoom)));

					setGraphicSize(widthSize);
					updateHitbox();
				default:
					scale.set(0.7, 0.7);
			}
		}

		if (isMine && mineOffsets != null)
		{
			updateHitbox();
			var offsets = mineOffsets[(!FlxG.save.data.downscroll) ? 0 : 1];
			offset.set(offset.x + offsets[noteData][0], offset.y + offsets[noteData][1]);
		}

		if (inCharter)
		{
			scale.set(0.7, 0.7);
			updateHitbox();
		}

		if (FlxG.save.data.stepMania && !isSustainNote && !isMine)
		{
			var strumCheck:Float = rStrumTime;

			var strumStep = (beat != null ? beat * 8 : strumCheck / (Conductor.stepCrochet / 2));

			var ind:Int = Std.int(Math.round(strumStep));

			// trace(strumStep, ind % 8);

			var col:Int = 0;
			col = quantityColor[ind % 8]; // Set the color depending on the beats

			// var beatRow = Math.round(beat * 48);

			// // STOLEN ETTERNA CODE (IN 2002)

			// if (beatRow % (192 / 4) == 0)
			// 	col = quantityColor[0];
			// else if (beatRow % (192 / 8) == 0)
			// 	col = quantityColor[2];
			// else if (beatRow % (192 / 12) == 0)
			// 	col = quantityColor[4];
			// else if (beatRow % (192 / 16) == 0)
			// 	col = quantityColor[6];
			// else if (beatRow % (192 / 24) == 0)
			// 	col = quantityColor[4];
			// else if (beatRow % (192 / 32) == 0)
			// 	col = quantityColor[4];

			animation.play(dataColor[col] + 'Scroll');
			localAngle -= arrowAngles[col];
			localAngle += arrowAngles[noteData];
			originAngle = localAngle;
			originColor = col;
		}

		// we make sure its downscroll and its a SUSTAIN NOTE (aka a trail, not a note) or a MINE (aka the fire note from the tricky mod)
		// and flip it so it doesn't look weird.
		// THIS DOESN'T FUCKING FLIP THE NOTE, CONTRIBUTERS DON'T JUST COMMENT THIS OUT JESUS
		// then what is this lol
		// BRO IT LITERALLY SAYS IT FLIPS IF ITS A TRAIL AND ITS DOWNSCROLL
		// ok nerd

		if (FlxG.save.data.downscroll && (isSustainNote || isMine))
			flipY = true;
		else
			flipY = false;

		var stepHeight = (0.45 * Conductor.stepCrochet * FlxMath.roundDecimal(PlayStateChangeables.scrollSpeed == 1 ? PlayState.SONG.speed : PlayStateChangeables.scrollSpeed,
			2));

		try 
		{
			if (isSustainNote && prevNote != null)
			{
				noteScore * 0.2;
				alpha = 0.6;

				//x += width / 2;

				originColor = prevNote.originColor;
				originAngle = prevNote.originAngle;

				animation.play(dataColor[originColor] + 'holdend'); // This works both for normal colors and quantization colors
				updateHitbox();

				//x -= width / 2;

				// if (noteTypeCheck == 'pixel')
				//	x += 30;
				if (inCharter)
					x += 30;

				if (prevNote.isSustainNote)
				{
					prevNote.animation.play(dataColor[prevNote.originColor] + 'hold');
					prevNote.updateHitbox();

					prevNote.scale.y *= (stepHeight + 1) / prevNote.height; // + 1 so that there's no odd gaps as the notes scroll
					prevNote.updateHitbox();
					prevNote.noteYOff = Math.round(-prevNote.offset.y);

					prevNote.setGraphicSize();

					noteYOff = Math.round(-offset.y);
				}
			}
		}
		catch(e:Exception)
		{
			trace(e.details(), e.stack);			
		}
	}

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (isSustainNote && prevNote.isMine)
			this.kill(); 
		
		if (!modifiedByLua)
			angle = modAngle + localAngle;
		else
			angle = localAngle;

		if (!modifiedByLua)
		{
			if (!sustainActive)
			{
				alpha = 0.3;
			}
		}

		if (mustPress)
		{
			if (!isMine)
			{
				if (isSustainNote)
				{
					if (strumTime - Conductor.songPosition <= ((166 * Conductor.timeScale) * 0.5)
						&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale))
						canBeHit = true;
					else
						canBeHit = false;
				}
				else
				{
					if (strumTime - Conductor.songPosition <= (166 * Conductor.timeScale)
						&& strumTime - Conductor.songPosition >= (-166 * Conductor.timeScale))
						canBeHit = true;
					else
						canBeHit = false;
				}
				if (strumTime - Conductor.songPosition < -166 && !wasGoodHit)
					tooLate = true;
			}
			else
			{
				if (strumTime > Conductor.songPosition - (Conductor.safeZoneOffset * 0.6)
					&& strumTime < Conductor.songPosition + (Conductor.safeZoneOffset * 0.4))
					canBeHit = true;
				else
					canBeHit = false;
			}
		}
		else
		{
			canBeHit = false;

			if (strumTime <= Conductor.songPosition)
				wasGoodHit = true;
		}

		if (tooLate && !wasGoodHit)
		{
			if (alpha > 0.3)
				alpha = 0.3;
		}
	}
}
