package;

import flixel.FlxBasic;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxSpriteGroup;
import flixel.system.FlxSound;
import flixel.util.FlxColor;
import flixel.util.FlxGradient;

using StringTools;

class Stage // Stolen from KE 1.7 :troll:
{
	public var curStage:String = '';
	public var halloweenLevel:Bool = false;
	public var camZoom:Float;
	public var hideLastBG:Bool = false; // True = hide last BG and show ones from slowBacks on certain step, False = Toggle Visibility of BGs from SlowBacks on certain step
	public var tweenDuration:Float = 2; // How long will it tween hiding/showing BGs, variable above must be set to True for tween to activate
	public var toAdd:Array<Dynamic> = []; // Add BGs on stage startup, load BG in by using "toAdd.push(bgVar);"
	// Layering algorithm for noobs: Everything loads by the method of "On Top", example: You load wall first(Every other added BG layers on it), then you load road(comes on top of wall and doesn't clip through it), then loading street lights(comes on top of wall and road)
	public var swagBacks:Map<String, Dynamic> = []; // Store BGs here to use them later in PlayState or when slowBacks activate
	public var swagGroup:Map<String, FlxTypedGroup<Dynamic>> = []; // Store Groups
	public var animatedBacks:Array<FlxSprite> = []; // Store animated backgrounds and make them play animation(Animation must be named Idle!! Else use swagGroup)
	public var layInFront:Array<Array<Dynamic>> = [[], [], []]; // BG layering, format: first [0] - in front of GF, second [1] - in front of opponent, third [2] - in front of boyfriend(and techincally also opponent since Haxe layering moment)
	public var slowBacks:Map<Int, Array<FlxSprite>> = []; // Change/add/remove backgrounds mid song! Format: "slowBacks[StepToBeActivated] = [Sprites,To,Be,Changed,Or,Added];"
	public var swagDancers:Map<String, Dynamic> = []; // Group for objects with a dance() function so that doesn't have to be manually added to beatHit in PlayState. (This is something that wasn't in KE 1.7 that I added)
	public var distractions:Array<Dynamic> = []; // Why have I complicated this whole thing
	
	public function new(stageCheck:String, rootSong:String, songLowercase:String, daPixelZoom:Float)
	{
		curStage = stageCheck;
		camZoom = 1.05; // Don't change zoom here, unless you want to change zoom of every stage that doesn't have custom one
		halloweenLevel = false;
		switch (stageCheck)
		{
			case 'halloween':
				{
					halloweenLevel = true;

					var hallowTex = Paths.getSparrowAtlas('halloween_bg', 'week2');

					var halloweenBG = new FlxSprite(-200, -100);
					halloweenBG.frames = hallowTex;
					halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
					halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
					halloweenBG.animation.play('idle');
					halloweenBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['halloweenBG'] = halloweenBG;
					toAdd.push(halloweenBG);
				}
			case 'philly' | 'phillySS':
				{

					curStage = 'philly';
                    var adder = (stageCheck == 'phillySS') ? 'SS' : '';
					var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly$adder/sky', 'week3'));
					bg.scrollFactor.set(0.1, 0.1);
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly$adder/city', 'week3'));
					city.scrollFactor.set(0.3, 0.3);
					city.setGraphicSize(Std.int(city.width * 0.85));
					city.updateHitbox();
					swagBacks['city'] = city;
					toAdd.push(city);

					var phillyCityLights = new FlxTypedGroup<FlxSprite>();
					distractions.push(phillyCityLights);
					//if (FlxG.save.data.distractions)
					//{
						swagGroup['phillyCityLights'] = phillyCityLights;
						toAdd.push(phillyCityLights);
					//}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly$adder/win' + i, 'week3'));
						light.scrollFactor.set(0.3, 0.3);
						light.visible = false;
						light.setGraphicSize(Std.int(light.width * 0.85));
						light.updateHitbox();
						light.antialiasing = FlxG.save.data.antialiasing;
						phillyCityLights.add(light);
					}

					var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly$adder/behindTrain', 'week3'));
					swagBacks['streetBehind'] = streetBehind;
					toAdd.push(streetBehind);

					var phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train', 'week3'));
					distractions.push(phillyCityLights);
					if (FlxG.save.data.distractions)
					{
						swagBacks['phillyTrain'] = phillyTrain;
						toAdd.push(phillyTrain);
					}

					PlayState.instance.trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes', 'week3'));
					FlxG.sound.list.add(PlayState.instance.trainSound);

					// var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

					var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly$adder/street', 'week3'));
					swagBacks['street'] = street;
					toAdd.push(street);
				}
			case 'limo':
				{
					camZoom = 0.90;

					var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset', 'week4'));
					skyBG.scrollFactor.set(0.1, 0.1);
					skyBG.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['skyBG'] = skyBG;
					toAdd.push(skyBG);

					var h = (songLowercase == 'satin-panties-in-game-version') ? 'Christmas' : '';

					var bgLimo:FlxSprite = new FlxSprite(-200, 480);
					bgLimo.frames = Paths.getSparrowAtlas('limo$h/bgLimo', 'week4');
					bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
					bgLimo.animation.play('drive');
					bgLimo.scrollFactor.set(0.4, 0.4);
					bgLimo.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['bgLimo'] = bgLimo;
					toAdd.push(bgLimo);

					var fastCar:FlxSprite;
					fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol', 'week4'));
					fastCar.antialiasing = FlxG.save.data.antialiasing;

					//if (FlxG.save.data.distractions)
					//{
						var grpLimoDancers = new FlxTypedGroup<Dancer>();
						toAdd.push(grpLimoDancers);
						distractions.push(grpLimoDancers);

						for (i in 0...5)
						{
							var dancer:Dancer = new Dancer((370 * i) + 130, bgLimo.y - 400, true);
							var special:String = (PlayState.SONG.player1 == 'bf-car-vitas') ? 'Vitas' : (songLowercase == 'milf-jp-version') ? 'Neko' : h;

							dancer.frames = Paths.getSparrowAtlas('limo$special/limoDancer', 'week4');
							dancer.animation.addByIndices('danceLeft', 'bg dancer sketch PINK', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14], "", 24, false);
							dancer.animation.addByIndices('danceRight', 'bg dancer sketch PINK', [15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29], "", 24, false);
							dancer.animation.play('danceLeft');
							dancer.antialiasing = FlxG.save.data.antialiasing;
							dancer.scrollFactor.set(0.4, 0.4);
							swagDancers['bgDancer$i'] = dancer;
							grpLimoDancers.add(dancer);
						}

						swagBacks['fastCar'] = fastCar;
						layInFront[2].push(fastCar);
						distractions.push(fastCar);
					//}

					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay', 'week4'));
					overlayShit.alpha = 0.5;
					// add(overlayShit);

					// var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

					// FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

					// overlayShit.shader = shaderBullshit;

					var ljhgwefouj = (songLowercase == 'milf-jp-version') ? 'Neko' : h;

					var limoTex = Paths.getSparrowAtlas('limo$ljhgwefouj/limoDrive', 'week4');

					var limo = new FlxSprite(-120, 550);
					limo.frames = limoTex;
					limo.animation.addByPrefix('drive', "Limo stage", 24);
					limo.animation.play('drive');
					limo.antialiasing = FlxG.save.data.antialiasing;
					layInFront[0].push(limo);
					swagBacks['limo'] = limo;

					// Testing
					//
					// hideLastBG = true;
					// slowBacks[40] = [limo];
					// slowBacks[120] = [limo, bgLimo, skyBG, fastCar];
				}
			case 'mall':
				{
					camZoom = 0.80;

					var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var upperBoppers = new Dancer(-240, -90);
					upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop', 'week5');
					upperBoppers.animation.addByPrefix('idle', "Upper Crowd Bob", 24, false);
					upperBoppers.antialiasing = FlxG.save.data.antialiasing;
					upperBoppers.scrollFactor.set(0.33, 0.33);
					upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
					upperBoppers.updateHitbox();
					//if (FlxG.save.data.distractions)
					//{
						swagDancers['upperBoppers'] = upperBoppers;
						toAdd.push(upperBoppers);
						animatedBacks.push(upperBoppers);
					//}

					var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator', 'week5'));
					bgEscalator.antialiasing = FlxG.save.data.antialiasing;
					bgEscalator.scrollFactor.set(0.3, 0.3);
					bgEscalator.active = false;
					bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
					bgEscalator.updateHitbox();
					swagBacks['bgEscalator'] = bgEscalator;
					toAdd.push(bgEscalator);

					var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree', 'week5'));
					tree.antialiasing = FlxG.save.data.antialiasing;
					tree.scrollFactor.set(0.40, 0.40);
					swagBacks['tree'] = tree;
					toAdd.push(tree);

					var bottomBoppers = new Dancer(-300, 140);
					bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop', 'week5');
					bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
					bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
					bottomBoppers.scrollFactor.set(0.9, 0.9);
					bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
					bottomBoppers.updateHitbox();
					//if (FlxG.save.data.distractions)
					//{
						swagDancers['bottomBoppers'] = bottomBoppers;
						toAdd.push(bottomBoppers);
						animatedBacks.push(bottomBoppers);
					//}

					var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow', 'week5'));
					fgSnow.active = false;
					fgSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['fgSnow'] = fgSnow;
					toAdd.push(fgSnow);

					var santa = new Dancer(-840, 150);
					santa.frames = Paths.getSparrowAtlas('christmas/santa', 'week5');
					santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
					santa.antialiasing = FlxG.save.data.antialiasing;
					//if (FlxG.save.data.distractions)
					//{
						swagDancers['santa'] = santa;
						toAdd.push(santa);
						animatedBacks.push(santa);
					//}
				}
			case 'mallEvil':
				{
					var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG', 'week5'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.2, 0.2);
					bg.active = false;
					bg.setGraphicSize(Std.int(bg.width * 0.8));
					bg.updateHitbox();
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree', 'week5'));
					evilTree.antialiasing = FlxG.save.data.antialiasing;
					evilTree.scrollFactor.set(0.2, 0.2);
					swagBacks['evilTree'] = evilTree;
					toAdd.push(evilTree);

					var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow", 'week5'));
					evilSnow.antialiasing = FlxG.save.data.antialiasing;
					swagBacks['evilSnow'] = evilSnow;
					toAdd.push(evilSnow);
				}
			case 'school' | 'schoolReplay' | 'schoolHypno' | 'schoolGoodTime' | 'terraria':
				{
					curStage = 'school';

					var adders:Map<String, String> = [
						'school' => '',
						'schoolReplay' => '/replay',
						'schoolGoodTime' => '/goodtime',
						'schoolHypno' => '/hypno',
						'terraria' => '/terraria'];
                    // I believe in hashmap supremacy
                    var existingAssets:Map<String,Array<String>> = [
                        'school' => ['school','schoolReplay','schoolGoodTime','schoolHypno'], 
						'trees' => ['school','schoolGoodTime'],
						'treeleaves' => ['school'],
						'fgtrees' => ['school']
                    ];

                    var toLoad:Array<FlxSprite> = [];

					var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb${(stageCheck != 'schoolGoodTime') ? adders.get(stageCheck) : ''}/weebSky', 'week6'));
                    bgSky.scrollFactor.set(0.1, 0.1);
                    swagBacks['bgSky'] = bgSky;
					toLoad.push(bgSky);

                    var repositionShit = -200;

					var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb${adders.get(stageCheck)}/weebStreet', 'week6'));
                    bgStreet.scrollFactor.set(0.95, 0.95);
                    swagBacks['bgStreet'] = bgStreet;
					toLoad.push(bgStreet);

                    if (existingAssets.get('school').contains(stageCheck))
                    {
						var bgSchool:FlxSprite = new FlxSprite(repositionShit,
							0).loadGraphic(Paths.image('weeb${adders.get(stageCheck)}/weebSchool', 'week6'));
                        bgSchool.scrollFactor.set(0.6, 0.90);
                        swagBacks['bgSchool'] = bgSchool;
						toLoad.push(bgSchool);
                    }

                    if (existingAssets.get('trees').contains(stageCheck))
                    {
                        var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
						var treetex = Paths.getPackerAtlas('weeb${adders.get(stageCheck)}/weebTrees', 'week6');
                        bgTrees.frames = treetex;
                        bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
						bgTrees.animation.play('treeLoop');
						bgTrees.ID = 455;
                        bgTrees.scrollFactor.set(0.85, 0.85);
                        swagBacks['bgTrees'] = bgTrees;
						toLoad.push(bgTrees);
                    }

                    if (existingAssets.get('fgtrees').contains(stageCheck))
                    {
						var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170,
							130).loadGraphic(Paths.image('weeb${adders.get(stageCheck)}/weebTreesBack', 'week6'));
						fgTrees.scrollFactor.set(0.9, 0.9);
						fgTrees.ID = 8008;
                        swagBacks['fgTrees'] = fgTrees;
						toLoad.push(fgTrees);
                    }

                    if (existingAssets.get('treeleaves').contains(stageCheck))
                    {
                        var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
                        treeLeaves.frames = Paths.getSparrowAtlas('weeb${adders.get(stageCheck)}/petals', 'week6');
                        treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
                        treeLeaves.animation.play('leaves');
                        treeLeaves.scrollFactor.set(0.85, 0.85);
                        swagBacks['treeLeaves'] = treeLeaves;
                        toLoad.push(treeLeaves);
                    }

                    var widShit = Std.int(bgSky.width * 6);

                    for (obj in toLoad)
					{
						switch (obj.ID)
                        {
							case 455:
								obj.setGraphicSize(Std.int(widShit * 1.4));
							case 8008:
								obj.setGraphicSize(Std.int(widShit * 0.8));
							default:
								obj.setGraphicSize(widShit);
                        }
						obj.updateHitbox();

						toAdd.push(obj);
					}

					var bgGirls = new Dancer(-100, 190, true);

					var adder = (PlayState.SONG.stage == 'schoolHypno') ? '/hypno' : (PlayState.SONG.stage == 'terraria') ? '/terraria' : '';

					bgGirls.frames = Paths.getSparrowAtlas('weeb${adder}/bgFreaks', 'week6');
					bgGirls.scrollFactor.set(0.9, 0.9);
					//if (FlxG.save.data.distractions)
					//{
					if (songLowercase.startsWith('roses') && songLowercase != 'roses-beta-mix')
					{
						bgGirls.animation.addByIndices('danceLeft', 'BG fangirls dissuaded', CoolUtil.numberArray(14), "", 24, false);
						bgGirls.animation.addByIndices('danceRight', 'BG fangirls dissuaded', CoolUtil.numberArray(30, 15), "", 24, false);
					}
					else
					{
						bgGirls.animation.addByIndices('danceLeft', 'BG girls group', CoolUtil.numberArray(14), "", 24, false);
						bgGirls.animation.addByIndices('danceRight', 'BG girls group', CoolUtil.numberArray(30, 15), "", 24, false);
					}
					//}
					bgGirls.animation.play('danceLeft');

                    bgGirls.visible = true; //(stageCheck != 'terraria');
					bgGirls.setGraphicSize(Std.int(bgGirls.width * PlayState.daPixelZoom));
					bgGirls.updateHitbox();
					//if (FlxG.save.data.distractions)
					//{
						swagDancers['bgGirls'] = bgGirls;
						toAdd.push(bgGirls);
					//}
				}
			case 'schoolEvil' | 'schoolEB':
				{
					curStage = 'schoolEvil';

                    if (!PlayStateChangeables.Optimize)
					{
						var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
						var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);
					}

					var posX = 400;
					var posY = 200;

					var schoolVer = (stageCheck == 'schoolEB') ? '/earthbound' : '';

					var bg:FlxSprite = new FlxSprite(posX, posY);
					bg.frames = Paths.getSparrowAtlas('weeb${schoolVer}/animatedEvilSchool', 'week6');
					bg.animation.addByPrefix('idle', 'background 2', 24);
					bg.animation.play('idle');
					bg.scrollFactor.set(0.8, 0.9);
					bg.scale.set(6, 6);
					swagBacks['bg'] = bg;
					toAdd.push(bg);
				}

			case 'arcade': // Kapi moment
				{
					curStage = 'stage';
					camZoom = 0.9;
					var bg:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('stageback', 'arcadeWeek'));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront', 'arcadeWeek'));
					stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
					stageFront.updateHitbox();
					stageFront.antialiasing = FlxG.save.data.antialiasing;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					swagBacks['stageFront'] = stageFront;
					toAdd.push(stageFront);

					var phillyCityLights = new FlxTypedGroup<FlxSprite>();
					swagGroup['phillyCityLights'] = phillyCityLights;

					if (songLowercase == "beathoven")
					{
						var bottomBoppers = new Dancer(25, 200);
						bottomBoppers.frames = Paths.getSparrowAtlas('littleguys', 'arcadeWeek');
						bottomBoppers.animation.addByPrefix('idle', 'Bottom Level Boppers', 24, false);
						bottomBoppers.antialiasing = FlxG.save.data.antialiasing;
						bottomBoppers.scrollFactor.set(0.9, 0.9);
						bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
						bottomBoppers.updateHitbox();
						swagDancers['bottomBoppers'] = bottomBoppers;
						distractions.push(phillyCityLights);
						toAdd.push(phillyCityLights);
						toAdd.push(bottomBoppers);
						animatedBacks.push(bottomBoppers);
					}

					for (i in 0...5)
					{
						var light:FlxSprite = new FlxSprite(-600, -200).loadGraphic(Paths.image('lights/win' + i, 'arcadeWeek'));
						light.scrollFactor.set(0.9, 0.9);
						light.visible = false;
						light.updateHitbox();
						light.antialiasing = FlxG.save.data.antialiasing;
						phillyCityLights.add(light);
					}

					if (songLowercase == 'beathoven' && PlayState.storyDifficulty == 3)
					{
						trace('gottem');
						var ok:FlxSprite = new FlxSprite(50, 200).loadGraphic(Paths.image('ok', 'arcadeWeek'));
						ok.scrollFactor.set(0.9, 0.9);
						ok.updateHitbox();
						ok.antialiasing = FlxG.save.data.antialiasing;
						toAdd.push(ok);
					}
				}

			case 'alley' | 'ballisticAlley': // Holy shit is that Whitmore from the Friday Night Funkin': V.S. Whitmore Full Week mod?
				{
					trace('alley moment');
					curStage = 'whitty';
					camZoom = 0.9;
					var stageSuffix = '';
					switch (PlayState.SONG.song)
					{
						case 'Overhead':
							stageSuffix = 'OH/';
						case 'Ballistic':
							stageSuffix = 'Ballistic/';
					}
					var wBg = new FlxSprite(-500, -300).loadGraphic(Paths.image(stageSuffix + 'whittyBack', 'bonusWeek'));
					swagBacks['wBg'] = wBg;

					var wstageFront = new FlxSprite(-650, 600).loadGraphic(Paths.image('whittyFront', 'bonusWeek'));
					wstageFront.setGraphicSize(Std.int(wstageFront.width * 1.1));
					wstageFront.updateHitbox();
					wstageFront.antialiasing = FlxG.save.data.antialiasing;
					wstageFront.scrollFactor.set(0.9, 0.9);
					wstageFront.active = false;
					swagBacks['wstageFront'] = wstageFront;

					if (PlayState.SONG.stage == 'ballisticAlley')
					{
						trace('pogging');
						wBg.antialiasing = FlxG.save.data.antialiasing;
						var bgTex = Paths.getSparrowAtlas('BallisticBackground', 'bonusWeek');
						var nwBg = new FlxSprite(-600, -200);
						nwBg.frames = bgTex;
						nwBg.antialiasing = FlxG.save.data.antialiasing;
						nwBg.scrollFactor.set(0.9, 0.9);
						nwBg.active = true;
						nwBg.animation.addByPrefix('start', 'Background Whitty Start', 24, false);
						nwBg.animation.addByPrefix('gaming', 'Background Whitty Startup', 24, false);
						nwBg.animation.addByPrefix('gameButMove', 'Background Whitty Moving', 16, true);
						swagBacks['nwBg'] = nwBg;
						toAdd.push(wBg);
						toAdd.push(nwBg);
						nwBg.alpha = 0;
						toAdd.push(wBg);
						toAdd.push(wstageFront);
					}
					else
					{
						wBg.antialiasing = FlxG.save.data.antialiasing;
						wBg.scrollFactor.set(0.9, 0.9);
						wBg.active = false;
						toAdd.push(wBg);
						toAdd.push(wstageFront);
					}
					// bg.setGraphicSize(Std.int(bg.width * 2.5));
					// bg.updateHitbox();
				}

			case 'militaryzone' | 'homedepot':
				{
					camZoom = 0.9;

					var adder = (stageCheck == 'homedepot') ? 'homedepot/' : '';

					var bg = new FlxSprite(-400, -400).loadGraphic(Paths.image('tankSky', 'week7'));
					bg.scrollFactor.set();
					bg.antialiasing = FlxG.save.data.antialiasing;
					toAdd.push(bg);

					var clouds = new FlxSprite(FlxG.random.int(-700, -100),FlxG.random.int(-20, 20)).loadGraphic(Paths.image('tankClouds', 'week7'));

					clouds.antialiasing = FlxG.save.data.antialiasing;
					clouds.scrollFactor.set(0.1, 0.1);
					clouds.velocity.x = FlxG.random.float(5, 15);
					toAdd.push(clouds);

					var mountains = new FlxSprite(-300, -20).loadGraphic(Paths.image('tankMountains', 'week7'));
					mountains.antialiasing = FlxG.save.data.antialiasing;
					mountains.setGraphicSize(Std.int(mountains.width * 1.2));
					mountains.updateHitbox();
					mountains.scrollFactor.set(0.2, 0.2);
					toAdd.push(mountains);
                    
					var building = new FlxSprite(-200).loadGraphic(Paths.image('${adder}tankBuildings', 'week7'));
					building.setGraphicSize(Std.int(building.width * 1.1));
					building.antialiasing = FlxG.save.data.antialiasing;
					building.updateHitbox();
					building.scrollFactor.set(0.3, 0.3);
					toAdd.push(building);

					var ruins = new FlxSprite(-200).loadGraphic(Paths.image('${adder}tankRuins', 'week7'));
					ruins.scrollFactor.set(0.35, 0.35);
					ruins.setGraphicSize(Std.int(1.1 * ruins.width));
					ruins.updateHitbox();
					ruins.antialiasing = FlxG.save.data.antialiasing;
					toAdd.push(ruins);
                    
					var smokeLeft = new FlxSprite(-200, -100);
					smokeLeft.frames = Paths.getSparrowAtlas('smokeLeft', 'week7');
					smokeLeft.animation.addByPrefix('idle', 'SmokeBlurLeft', 24, true);
					smokeLeft.animation.play('idle', true);
					smokeLeft.scrollFactor.set(0.4, 0.4);
					smokeLeft.antialiasing = FlxG.save.data.antialiasing;
					toAdd.push(smokeLeft);

					var smokeRight = new FlxSprite(1100, -100);
					smokeRight.frames = Paths.getSparrowAtlas('smokeRight', 'week7');
					smokeRight.animation.addByPrefix('idle', 'SmokeRight', 24, true);
					smokeRight.animation.play('idle', true);
					smokeRight.scrollFactor.set(0.4, 0.4);
					smokeRight.antialiasing = FlxG.save.data.antialiasing;
					toAdd.push(smokeRight);
                    
					var tower = new Dancer(100, 50, false, [2, 0]);
					tower.frames = Paths.getSparrowAtlas('${(songLowercase == "guns-short-version") ? 'pain/' : adder}tankWatchtower', 'week7');
					tower.animation.addByPrefix('idle', 'watchtower gradient color', 24, false);
					tower.animation.play('idle', true);
					tower.scrollFactor.set(0.5, 0.5);
					tower.updateHitbox();
					tower.antialiasing = FlxG.save.data.antialiasing;
					swagDancers.set('tower', tower);
					toAdd.push(tower);

					var rollingTank = new RollingTank(300, 300, adder);
					rollingTank.antialiasing = FlxG.save.data.antialiasing;
					rollingTank.scrollFactor.set(0.5, 0.5);
					swagBacks['rollingTank'] = rollingTank;
					toAdd.push(rollingTank);
					distractions.push(rollingTank);

					var ground = new FlxSprite(-420, -150).loadGraphic(Paths.image('tankGround', 'week7'));
					ground.setGraphicSize(Std.int(1.15 * ground.width));
					ground.updateHitbox();
					ground.antialiasing = FlxG.save.data.antialiasing;
					toAdd.push(ground);

					var tankmen = new FlxTypedGroup();
					swagGroup.set('tankmen', tankmen);
					distractions.push(tankmen);

					var tank0 = new Dancer(-200, 650, false, [2, 0]);
					tank0.frames = Paths.getSparrowAtlas('tank0', 'week7');
					tank0.antialiasing = FlxG.save.data.antialiasing;
					tank0.animation.addByPrefix("idle", "fg", 24, false);
					tank0.scrollFactor.set(1.7, 1.5);
					tank0.animation.play("idle");
					tankmen.add(tank0);

					var tank1 = new Dancer(-100, 750, false, [2, 0]);
					tank1.frames = Paths.getSparrowAtlas('tank1', 'week7');
					tank1.antialiasing = FlxG.save.data.antialiasing;
					tank1.animation.addByPrefix("idle", "fg", 24, false);
					tank1.scrollFactor.set(2, 0.2);
					tank1.animation.play("idle");
					tankmen.add(tank1);

					var tank2 = new Dancer(650, 940, false, [2, 0]);
					tank2.frames = Paths.getSparrowAtlas('tank2', 'week7');
					tank2.antialiasing = FlxG.save.data.antialiasing;
					tank2.animation.addByPrefix("idle", "foreground", 24, false);
					tank2.scrollFactor.set(1.5, 1.5);
					tank2.animation.play("idle");
					tankmen.add(tank2);

					var tank4 = new Dancer(1500, 900, false, [2, 0]);
					tank4.frames = Paths.getSparrowAtlas('tank4', 'week7');
					tank4.antialiasing = FlxG.save.data.antialiasing;
					tank4.animation.addByPrefix("idle", "fg", 24, false);
					tank4.scrollFactor.set(1.5, 1.5);
					tank4.animation.play("idle");
					tankmen.add(tank4);

					var tank5 = new Dancer(1820, 700, false, [2, 0]);
					tank5.frames = Paths.getSparrowAtlas('tank5', 'week7');
					tank5.antialiasing = FlxG.save.data.antialiasing;
					tank5.animation.addByPrefix("idle", "fg", 24, false);
					tank5.scrollFactor.set(1.5, 1.5);
					tank5.animation.play("idle");
					tankmen.add(tank5);

					var tank3 = new Dancer(1850, 1200, false, [2,0]);
					tank3.frames = Paths.getSparrowAtlas('tank3', 'week7');
					tank3.antialiasing = FlxG.save.data.antialiasing;
					tank3.animation.addByPrefix("idle", "fg", 24, false);
					tank3.scrollFactor.set(3.5, 2.5);
					tank3.animation.play("idle");
					tankmen.add(tank3);

					layInFront[2].push(tankmen);

                }

			case 'nevada':
				{
					camZoom = 0.75;
					curStage = 'nevada';

					var bg:FlxSprite = new FlxSprite(-350, -300).loadGraphic(Paths.image('red', 'clown'));
					// bg.setGraphicSize(Std.int(bg.width * 2.5));
					// bg.updateHitbox();
					bg.antialiasing = true;
					bg.scrollFactor.set(0.9, 0.9);
					var stageFront:FlxSprite;
					if (songLowercase != 'madness')
					{
						toAdd.push(bg);
						stageFront = new FlxSprite(-1100, -460).loadGraphic(Paths.image('island_but_dumb', 'clown'));
					}
					else
						stageFront = new FlxSprite(-1100, -460).loadGraphic(Paths.image('island_but_rocks_float', 'clown'));

					stageFront.setGraphicSize(Std.int(stageFront.width * 1.4));
					stageFront.antialiasing = true;
					stageFront.scrollFactor.set(0.9, 0.9);
					stageFront.active = false;
					toAdd.push(stageFront);

					var MAINLIGHT = new FlxSprite(-470, -150).loadGraphic(Paths.image('hue', 'clown'));
					MAINLIGHT.alpha = 0.3;
					MAINLIGHT.setGraphicSize(Std.int(MAINLIGHT.width * 0.9));
					MAINLIGHT.blend = "screen";
					MAINLIGHT.updateHitbox();
					MAINLIGHT.antialiasing = true;
					MAINLIGHT.scrollFactor.set(1.2, 1.2);
					layInFront[2].push(MAINLIGHT);
				}

			default:
				{
					var adders:Map<String, String> = [
						'stageGrandpa' => 'grandpa/',
						'stageIgor' => 'igor/',
						'stageAscended' => 'test/',
						'stageCrazyBus' => 'CrazyBus/',
						'stageIG' => 'BopeeboIGM/',
						'stageZelda' => 'Zelda/',
						'stageGames' => 'videogames/',
						'angyBirds' => 'angryBirds/'
					];
					// I still believe in hashmap supremacy
					var existingAssets:Map<String, Array<String>> = [
						'front' => [
							'stage',
							'stageGrandpa',
							'stageIgor',
							'stageAscended',
							'stageCrazyBus',
							'stageGames',
							'angyBirds'],
						'curtains' => ['stage', 'stageAscended', 'stageCrazyBus', 'stageGames', 'angyBirds']
					];

					var exceptions:Map<String, Array<String>> = [
						'bg' => ['stage', 'stageAscended', 'stageGames'],
						'front' => ['stage',  'stageAscended'],
						'curtains' => ['stage', 'stageCrazyBus']
                    ];

					camZoom = 0.9;
					curStage = 'stage';
					var bg:FlxSprite = new FlxSprite(-600,
						-200).loadGraphic(Paths.image('${!(exceptions.get('bg').contains(stageCheck)) ? adders.get(stageCheck) : ''}stageback',
						!(exceptions.get('bg').contains(stageCheck)) ? 'week1' : null));
					bg.antialiasing = FlxG.save.data.antialiasing;
					bg.scrollFactor.set(0.9, 0.9);
					bg.active = false;
					swagBacks['bg'] = bg;
					toAdd.push(bg);

					if (existingAssets.get('front').contains(stageCheck))
					{
						var stageFront:Dynamic = null;
						if (stageCheck == 'angyBirds')
						{
							stageFront = new Dancer(-650, 600, false, [2, 0], true);
							stageFront = cast(stageFront, Dancer);
							swagDancers['stageFront'] = stageFront;
						}
						else
						{
							stageFront = new FlxSprite(-650, 600);
							stageFront = cast(stageFront, FlxSprite);
							swagBacks['stageFront'] = stageFront;
						}
						stageFront = cast stageFront;
						stageFront.loadGraphic(Paths.image('${!(exceptions.get('front').contains(stageCheck)) ? adders.get(stageCheck) : ''}stagefront',
							!(exceptions.get('front').contains(stageCheck)) ? 'week1' : null));
						stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
						stageFront.updateHitbox();
						stageFront.antialiasing = FlxG.save.data.antialiasing;
						stageFront.scrollFactor.set(0.9, 0.9);
						stageFront.active = false;
						toAdd.push(stageFront);
					}

					if (existingAssets.get('curtains').contains(stageCheck))
					{
						var stageCurtains:Dynamic = null;
						if (stageCheck == 'angyBirds')
						{
							stageCurtains = new Dancer(-500, -300, false, [2, 0], true);
							stageCurtains = cast(stageCurtains, Dancer);
							swagDancers['stageCurtains'] = stageCurtains;
						}
						else
						{
							stageCurtains = new FlxSprite(-500, -300);
							stageCurtains = cast(stageCurtains, FlxSprite);
							swagBacks['stageCurtains'] = stageCurtains;
						}
						stageCurtains.loadGraphic(Paths.image('${!(exceptions.get('curtains').contains(stageCheck)) ? adders.get(stageCheck) : ''}stagecurtains',
							!(exceptions.get('curtains').contains(stageCheck)) ? 'week1' : null));
						stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
						stageCurtains.updateHitbox();
						stageCurtains.antialiasing = FlxG.save.data.antialiasing;
						stageCurtains.scrollFactor.set(1.3, 1.3);
						stageCurtains.active = false;

						toAdd.push(stageCurtains);
					}
				}
		}

		if (songLowercase == 'test')
			layInFront[2].push(new AscendedPixelBF(15, 15));

		for (i in swagDancers)
			distractions.push(i);

		trace(curStage);
		PlayState.curStage = curStage;
    }
}