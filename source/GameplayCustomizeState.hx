import Stage.StageData;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.math.FlxMath;
import flixel.FlxCamera;
import flixel.math.FlxPoint;
import flixel.FlxObject;
#if windows
import Discord.DiscordClient;
import sys.thread.Thread;
#end

import flixel.group.FlxGroup.FlxTypedGroup;
import openfl.ui.Keyboard;
import flixel.FlxSprite;
import flixel.FlxG;

using StringTools;

class GameplayCustomizeState extends MusicBeatState
{

    var defaultX:Float = FlxG.width * 0.55 - 135;
    var defaultY:Float = FlxG.height / 2 - 50;

    var sick:FlxSprite;

    var text:FlxText;
    var blackBorder:FlxSprite;

    var bf:Boyfriend;
    var dad:Character;
    var gf:Character;

    var strumLine:FlxSprite;
    var strumLineNotes:FlxTypedGroup<FlxSprite>;
    var playerStrums:FlxTypedGroup<FlxSprite>;
    private var camHUD:FlxCamera;

    var camFollow:FlxObject;
    
    public override function create() {
        #if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Customizing Gameplay Modules", null);
		#end

        sick = new FlxSprite().loadGraphic(Paths.image('uiskins/normal/sick','shared'));
        sick.antialiasing = FlxG.save.data.antialiasing;
		sick.scrollFactor.set();

		//Conductor.changeBPM(102);
		persistentUpdate = true;

        super.create();

		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;
        FlxG.cameras.add(camHUD);

        camHUD.zoom = FlxG.save.data.zoom;

		camFollow = new FlxObject(0, 0, 1, 1);

		dad = new Character(100, 100, 'dad');

		bf = new Boyfriend(770, 450, 'bf');

		gf = new Character(400, 130, 'gf');
		gf.scrollFactor.set(0.95, 0.95);

		var stageCheck = "stage";

		var exceptions:Array<String> = ['monster-christmas'];

		var exceptionCheck:Bool = false;

		var vibeCheck:String = dad.curCharacter;

		if (exceptions.contains(dad.curCharacter))
		{
			exceptionCheck = true;
			for (i in exceptions)
			{
				if (dad.curCharacter.startsWith(i))
				{
					vibeCheck = i;
					break;
				}
			}
		}

		vibeCheck = (!exceptionCheck) ? dad.baseCharacter.split('-')[0] : vibeCheck;

		switch (vibeCheck)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'chama':
				dad.y += 400;
			case 'whitty' | 'whittyCrazy':
				dad.x -= 100;
			case 'pico':
				dad.y += 300;
			case 'parents':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				trace('I banged your mom'); // NOTE: this is true
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
			case 'tankman':
				dad.x += 110;
				dad.y += 220;
		}

		var camPos:FlxPoint = new FlxPoint(dad.getGraphicMidpoint().x + 400, dad.getGraphicMidpoint().y);

		camFollow.setPosition(camPos.x, camPos.y);

		var stage:StageData = HScriptHandler.loadStageFromHScript(stageCheck);

		for (i in stage.toAdd)
		{
			cast(i, FlxSprite).cameras = [camHUD];
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
					{
						cast(bg, FlxSprite).cameras = [camHUD];
						add(bg);
					}
				case 1:
					add(dad);
					for (bg in array)
					{
						cast(bg, FlxSprite).cameras = [camHUD];
						add(bg);
					}
				case 2:
					add(bf);
					for (bg in array)
					{
						cast(bg, FlxSprite).cameras = [camHUD];
						add(bg);
                    }
			}
		}

		var vibeCheck2 = (stageCheck.startsWith('school')) ? 'school' : stageCheck;

		trace(vibeCheck2);

		switch (vibeCheck2)
		{
			case 'nevada':
				bf.x += 260;
			case 'limo':
				bf.y -= 220;
				bf.x += 260;
			case 'mall':
				bf.x += 200;
			case 'hellsKitchen':
				bf.x += 320;
				bf.y += 300;
				gf.y += 300;
			case 'mallEvil':
				bf.x += 320;
				dad.y -= 80;
			case 'school':
				bf.x += 200;
				bf.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'whitty':
				bf.x -= 25;
				if (stageCheck == "ballisticAlley")
				{
					gf.x += 15;
					gf.y += 200;
				}
				else
				{
					gf.x -= 100;
					gf.y += 50;
				}
			case 'militaryzone' | 'homedepot':
				bf.x += 195;
		}

        add(sick);

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.01);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = 0.9;
		FlxG.camera.focusOn(camFollow.getPosition());

		strumLine = new FlxSprite(0, FlxG.save.data.strumline).makeGraphic(FlxG.width, 14);
		strumLine.scrollFactor.set();
        strumLine.alpha = 0.4;

        add(strumLine);
		
		if (FlxG.save.data.downscroll)
			strumLine.y = FlxG.height - 165;

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		playerStrums = new FlxTypedGroup<FlxSprite>();

        sick.cameras = [camHUD];
        strumLine.cameras = [camHUD];
        playerStrums.cameras = [camHUD];
        
		generateStaticArrows(0);
		generateStaticArrows(1);

        text = new FlxText(5, FlxG.height + 40, 0, "Click and drag around gameplay elements to customize their positions. Press R to reset. Q/E to change zoom. Press Escape to go back.", 12);
		text.scrollFactor.set();
		text.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        
        blackBorder = new FlxSprite(-30,FlxG.height + 40).makeGraphic((Std.int(text.width + 900)),Std.int(text.height + 600),FlxColor.BLACK);
		blackBorder.alpha = 0.5;

        text.cameras = [camHUD];

        text.scrollFactor.set();

		//add(blackBorder);

		//add(text);

		FlxTween.tween(text,{y: FlxG.height - 18},2,{ease: FlxEase.elasticInOut});
		FlxTween.tween(blackBorder,{y: FlxG.height - 18},2, {ease: FlxEase.elasticInOut});

        if (!FlxG.save.data.changedHit)
        {
            FlxG.save.data.changedHitX = defaultX;
            FlxG.save.data.changedHitY = defaultY;
        }

        sick.x = FlxG.save.data.changedHitX;
        sick.y = FlxG.save.data.changedHitY;


        FlxG.mouse.visible = true;

    }

    override function update(elapsed:Float) {
		if (FlxG.sound.music != null)
			Conductor.songPosition = FlxG.sound.music.time;

        super.update(elapsed);

        if (FlxG.save.data.zoom < 0.8)
            FlxG.save.data.zoom = 0.8;

        if (FlxG.save.data.zoom > 1.2)
			FlxG.save.data.zoom = 1.2;

        FlxG.camera.zoom = FlxMath.lerp(0.9, FlxG.camera.zoom, 0.95);
        camHUD.zoom = FlxMath.lerp(FlxG.save.data.zoom, camHUD.zoom, 0.95);

        if (FlxG.mouse.overlaps(sick) && FlxG.mouse.pressed)
        {
            sick.x = (FlxG.mouse.x - sick.width / 2) - 60;
            sick.y = (FlxG.mouse.y - sick.height) - 60;
        }

        for (i in playerStrums)
            i.y = strumLine.y;
        for (i in strumLineNotes)
            i.y = strumLine.y;

        if (FlxG.keys.justPressed.Q)
        {
            FlxG.save.data.zoom += 0.02;
            camHUD.zoom = FlxG.save.data.zoom;
        }

        if (FlxG.keys.justPressed.E)
        {
            FlxG.save.data.zoom -= 0.02;
            camHUD.zoom = FlxG.save.data.zoom;
        }

		if (FlxG.keys.pressed.W)
			camFollow.y -= 100 * elapsed;

		if (FlxG.keys.pressed.S)
			camFollow.y += 100 * elapsed;

		if (FlxG.keys.pressed.A)
			camFollow.x -= 100 * elapsed;

		if (FlxG.keys.pressed.D)
			camFollow.x += 100 * elapsed;

		camHUD.focusOn(camFollow.getPosition());

        if (FlxG.mouse.overlaps(sick) && FlxG.mouse.justReleased)
        {
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = true;
        }

        if (FlxG.keys.justPressed.R)
        {
            sick.x = defaultX;
            sick.y = defaultY;
            FlxG.save.data.zoom = 1;
            camHUD.zoom = FlxG.save.data.zoom;
            FlxG.save.data.changedHitX = sick.x;
            FlxG.save.data.changedHitY = sick.y;
            FlxG.save.data.changedHit = false;
        }

        if (controls.BACK)
        {
            FlxG.mouse.visible = false;
            FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
        }

    }

    override function beatHit() 
    {
        super.beatHit();

        bf.playAnim('idle', true);
        dad.dance(true);
        gf.dance();

        FlxG.camera.zoom += 0.015;
        camHUD.zoom += 0.010;

        trace('beat');

    }


    // ripped from play state cuz im lazy
    
	private function generateStaticArrows(player:Int):Void
        {
            for (i in 0...4)
            {
                // FlxG.log.add(i);
                var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
                babyArrow.frames = Paths.getSparrowAtlas('noteskins/normal', 'shared');
                babyArrow.animation.addByPrefix('green', 'arrowUP');
                babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
                babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
                babyArrow.animation.addByPrefix('red', 'arrowRIGHT');
                babyArrow.antialiasing = FlxG.save.data.antialiasing;
                babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));
                switch (Math.abs(i))
                {
                    case 0:
                        babyArrow.x += Note.swagWidth * 0;
                        babyArrow.animation.addByPrefix('static', 'arrowLEFT');
                        babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
                    case 1:
                        babyArrow.x += Note.swagWidth * 1;
                        babyArrow.animation.addByPrefix('static', 'arrowDOWN');
                        babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
                    case 2:
                        babyArrow.x += Note.swagWidth * 2;
                        babyArrow.animation.addByPrefix('static', 'arrowUP');
                        babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
                    case 3:
                        babyArrow.x += Note.swagWidth * 3;
                        babyArrow.animation.addByPrefix('static', 'arrowRIGHT');
                        babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
                        babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
                }
                babyArrow.updateHitbox();
                babyArrow.scrollFactor.set();
    
                babyArrow.ID = i;
    
                if (player == 1)
                    playerStrums.add(babyArrow);
    
                babyArrow.animation.play('static');
                babyArrow.x += 50;
                babyArrow.x += ((FlxG.width / 2) * player);
    
                strumLineNotes.add(babyArrow);
            }
        }
}