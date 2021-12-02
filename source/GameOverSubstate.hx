package;

import flixel.FlxG;
import flixel.FlxObject;
import flixel.math.FlxMath;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;

using StringTools;

class GameOverSubstate extends MusicBeatSubstate
{
	var bf:Boyfriend;
	var camFollow:FlxObject;

	var stageSuffix:String = "";
	var soundSuffix:String = ""; // Was there a better way than to add all these variables? Maybe. Do I care? No lol
	var confirmSuffix:String = "";
	var folder:String = null;
	var soundFolder:String = null;
	var daSong:String;
	var deathLine:FlxSound;

	public function new(x:Float, y:Float)
	{
		daSong = StringTools.replace(PlayState.SONG.song.toLowerCase(), ' ', '-');
		var p1 = PlayState.SONG.player1;
		if (p1.split('-')[1] == 'car') // There are a LOTTA character skins in this game so I have to make sure all the blueballs are also working. Unfortunately that resulted in this pain
		{
			var temp:Array<String> = p1.split('-');
			var p1final = temp[0];
			temp.remove('car');
			for (i in 1...temp.length)
				p1final += '-' + temp[i];
			p1 = p1final;
		}
		if (p1.split('-')[1] == 'christmas') // same as above comment sighhhhhh
		{
			var temp:Array<String> = p1.split('-');
			var p1final = temp[0];
			temp.remove('christmas');
			for (i in 1...temp.length)
				p1final += '-' + temp[i];
			p1 = p1final;
			if (p1.split('-')[1] == 'car') // ALSO THERE'S LITERALLY A CHARACTER CALLED 'bf-car-christmas' SO I HAVE TO DO THIS TERRIBLENESS... Is what I say but I could've literally just checked for that one case and reduced it to just "bf..."
				// I DONT CARE THIS WORKS FUCK YOU
			{
				var temp:Array<String> = p1.split('-');
				var p1final = temp[0];
				temp.remove('car');
				for (i in 1...temp.length)
					p1final += '-' + temp[i];
				p1 = p1final;
			}
		}
		var daBf:String = '';
		trace(p1);
		if (p1.startsWith('bf-pixel'))
		{
			stageSuffix = '-pixel';
			soundSuffix = stageSuffix + (p1 == 'bf-pixel-terraria' ? '-terraria' : '');
			confirmSuffix = stageSuffix;
			daBf = p1 + '-dead';
			if (PlayState.SONG.song.toLowerCase() == 'thorns')
				daBf = 'bf-pixel-dead-clp';
		}
		else
		{
			switch (p1)
			{
				case 'bf-slam':
					stageSuffix = '-slam';
					daBf = p1;
					folder = 'week2';
				case 'bf-samsung':
					stageSuffix = '-samsung';
					soundSuffix = stageSuffix;
					daBf = p1;
				case 'bf-quote':
					stageSuffix = '-cs';
					soundSuffix = stageSuffix;
					daBf = p1;
				case 'bf-richter':
					soundSuffix = '-richter';
					daBf = p1;
				case 'bf-sockdude':
					soundSuffix = '-games';
					daBf = p1;
				case 'bf-reimu':
					soundSuffix = '-reimu';
					daBf = p1;
				case 'bf-hk':
					soundSuffix = '-hk';
					stageSuffix = '-tricky';
					confirmSuffix = stageSuffix;
					daBf = 'signDeath';
				default:
					daBf = (p1.startsWith('bf')) ? p1 : 'bf';
					if (FlxG.random.bool(10)) // Oh shit is that a random chance to listen to a certified banger
					{
						stageSuffix = '-porter';
						confirmSuffix = stageSuffix;
					}
			}
		}

		if (daSong == 'guns-short-version')
			stageSuffix = '-pain';

		trace(daBf);

		super();

		Conductor.songPosition = 0;
		Conductor.changeBPM(100);

		if (PlayState.SONG.song == 'Roses OST Version')
		{
			var deathText = new FlxText(25,FlxG.height-60,0,"Boyfriend's balls were crushed by Skeletron", 26);
			deathText.setFormat(Paths.font("ANDYBOLD.ttf"), 26, FlxColor.RED);
			deathText.scrollFactor.set();
			deathText.updateHitbox();
			deathText.cameras = [FlxG.cameras.list[FlxG.cameras.list.length-1]];
			deathText.antialiasing = FlxG.save.data.antialiasing;
			add(deathText);
			var shittyCounter:Float = 0;
			new FlxTimer().start(.1, function(tmr:FlxTimer)
			{
				if (isEnding)
				{
					FlxTween.tween(deathText, {alpha: 0}, 1, {
						ease: FlxEase.quadOut
					});
					tmr.cancel();
					return;
				}
				deathText.color = FlxColor.interpolate(FlxColor.RED, 0xFF630000, (1 + FlxMath.fastSin(shittyCounter * 2)) / 2);
				shittyCounter += tmr.elapsedTime*50;
			}, 0);
		}

		bf = new Boyfriend(x, y, daBf);
		add(bf);

		if (daBf == 'signDeath')
		{
			bf.animation.getByName('deathLoop').destroy();
			bf.animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
		}

		var offset:Array<Int> = (daBf == 'bf-kapi') ? [360,-170] : [0,0];

		camFollow = new FlxObject(bf.getGraphicMidpoint().x + offset[0], bf.getGraphicMidpoint().y + offset[1], 1, 1);
		add(camFollow);

		FlxG.sound.play(Paths.sound('fnf_loss_sfx' + soundSuffix));

		// FlxG.camera.followLerp = 1;
		// FlxG.camera.focusOn(FlxPoint.get(FlxG.width / 2, FlxG.height / 2));
		FlxG.camera.scroll.set();
		FlxG.camera.target = null;

		bf.playAnim('firstDeath');
	}

	var startVibin:Bool = false;
	var isEnding:Bool = false;

	override function update(elapsed:Float)
	{
		super.update(elapsed);

		if (controls.ACCEPT)
		{
			endBullshit();
		}

		if (FlxG.save.data.InstantRespawn)
		{
			if (deathLine != null)
				deathLine.stop();
			PlayState.fromDeath = true;
			LoadingState.loadAndSwitchState(new PlayState());
		}

		if (controls.BACK)
		{
			isEnding = true;
			if (deathLine != null)
				deathLine.stop();
			FlxG.sound.music.stop();

			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else
			{
				FreeplayState.fromSong = true;
				FlxG.switchState(new FreeplayState());
			}
			PlayState.loadRep = false;
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.curFrame == 12)
		{
			FlxG.camera.follow(camFollow, LOCKON, 0.01);
		}

		if (bf.animation.curAnim.name == 'firstDeath' && bf.animation.curAnim.finished)
		{
			// Death lines yeah baby
			if (PlayState.SONG.player2.startsWith("tankman"))
			{
				trace('burh');
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix), 0.2);
				var poop = (daSong == 'ugh-alterneeyyytive-mix') ? 'psy/' : (daSong == 'ugh') ? 'homedepot/' : '';
				var max:Map<String, Int> = ['homedepot/' => 13, '' => 24];
				var lineNum = (max.exists(poop)) ?	(FlxG.random.int(0, max.get(poop)) + 1) : 1;
				deathLine = new FlxSound().loadEmbedded(Paths.sound('${poop}jeffGameover/jeffGameover-${lineNum}', 'week7'), true);
				trace('${poop}jeffGameOver/jeffGameover-${lineNum}', 'week7');
				deathLine.onComplete = function() {
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.5, {ease: FlxEase.linear});
				}
				FlxG.sound.list.add(deathLine);
				deathLine.play();
				deathLine.looped = false;
			}
			else
				FlxG.sound.playMusic(Paths.music('gameOver' + stageSuffix));
			startVibin = true;
			bf.playAnim('deathLoop', true);
		}

		if (FlxG.sound.music.playing)
		{
			Conductor.songPosition = FlxG.sound.music.time;
		}
	}

	override function beatHit()
	{
		super.beatHit();
		if (startVibin && !isEnding && bf.curCharacter != 'signDeath')
			bf.playAnim('deathLoop', true);
		FlxG.log.add('beat');
	}

	function endBullshit():Void
	{
		if (!isEnding)
		{
			PlayState.startTime = 0;
			isEnding = true;
			bf.playAnim('deathConfirm', true);
			FlxG.sound.music.stop();
			FlxG.sound.play(Paths.music('gameOverEnd' + confirmSuffix));
			new FlxTimer().start(0.7, function(tmr:FlxTimer)
			{
				FlxG.camera.fade(FlxColor.BLACK, 2, false, function()
				{
					if (deathLine != null)
						deathLine.stop();
					PlayState.fromDeath = true;
					LoadingState.loadAndSwitchState(new PlayState());
				});
			});
		}
	}
}
