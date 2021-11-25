#if sys
import flixel.FlxG;
import lime.utils.Assets;
#if haxe4
import haxe.xml.Access;
#else
import haxe.xml.Fast as Access;
#end
import flash.geom.Rectangle;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames.TexturePackerObject;
import flixel.graphics.frames.FlxFrame.FlxFrameAngle;
import flixel.graphics.frames.FlxFramesCollection.FlxFrameCollectionType;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets.FlxGraphicAsset;
import flixel.system.FlxAssets.FlxTexturePackerSource;
import openfl.display.BitmapData;
import flixel.graphics.FlxGraphic;
import flixel.FlxSprite;
import flixel.graphics.frames.FlxAtlasFrames;

// I feel bad for yoinking this from Tiky but I kinda need to make this shit a bit more efficient
// Thank you Kade
class GameCache
{
	public static var globalCache:GameCache;

    public function new() {}

    // so it doesn't brick your computer lol!
    public var cachedGraphics:Map<String,FlxGraphic> = new Map<String,FlxGraphic>();

    public var loaded = false;

    public static function initialize(assets:Map<String,Array<String>>)
	{
		globalCache = new GameCache();
		globalCache.loadFrames(assets);
    }

    public function fromSparrow(id:String, xmlName:String, directory:String)
    {
        var graphic = get(id);
        // No need to parse data again
		var frames:FlxAtlasFrames = FlxAtlasFrames.findFrame(graphic);
		if (frames != null)
			return frames;

		frames = new FlxAtlasFrames(graphic);
		var Description = Assets.getText(Paths.file('images/$xmlName.xml', directory));

		var data:Access = new Access(Xml.parse(Description).firstElement());

		for (texture in data.nodes.SubTexture)
		{
			var name = texture.att.name;
			var trimmed = texture.has.frameX;
			var rotated = (texture.has.rotated && texture.att.rotated == "true");
			var flipX = (texture.has.flipX && texture.att.flipX == "true");
			var flipY = (texture.has.flipY && texture.att.flipY == "true");

			var rect = FlxRect.get(Std.parseFloat(texture.att.x), Std.parseFloat(texture.att.y), Std.parseFloat(texture.att.width),
				Std.parseFloat(texture.att.height));

			var size = if (trimmed)
			{
				new Rectangle(Std.parseInt(texture.att.frameX), Std.parseInt(texture.att.frameY), Std.parseInt(texture.att.frameWidth),
					Std.parseInt(texture.att.frameHeight));
			}
			else
			{
				new Rectangle(0, 0, rect.width, rect.height);
			}

			var angle = rotated ? FlxFrameAngle.ANGLE_NEG_90 : FlxFrameAngle.ANGLE_0;

			var offset = FlxPoint.get(-size.left, -size.top);
			var sourceSize = FlxPoint.get(size.width, size.height);

			if (rotated && !trimmed)
				sourceSize.set(size.height, size.width);

			frames.addAtlasFrame(rect, sourceSize, offset, name, angle, flipX, flipY);
		}

        return frames;
    }

    public function get(id:String)
    {
        return cachedGraphics.get(id);
    }

    public function load(id:String, path:String, directory:String, persist:Bool)
    {
		var graph = FlxGraphic.fromAssetKey(Paths.image(path, directory));
		graph.persist = persist;
        graph.destroyOnNoUse = false;
        cachedGraphics.set(id,graph);
        trace('Loaded ' + id);
    }

    public function exists(id:String)
    {
        return (cachedGraphics.exists(id) || cachedGraphics.get(id).canBeDumped);
    }

    public function dumpFrames(id:String)
    {
        if (cachedGraphics.exists(id))
        {
            cachedGraphics.get(id).dump();
            trace('dumped ' + id);
        }
        else
            trace(id + " doesn't exist!");
    }

    public function loadFrames(toBeLoaded:Map<String,Array<String>>, persist:Bool = true)
	{
        #if cpp
		sys.thread.Thread.create(() ->
		{
			for (i in toBeLoaded.keys())
			{
				if (cachedGraphics.exists(i))
				{
					if (cachedGraphics.get(i).isDumped)
					{
						cachedGraphics.get(i).undump();
						trace('undumped ' + i);
					}
					else
						trace(i + ' is already loaded!');
					continue;
				}
				load(i, toBeLoaded.get(i)[0], toBeLoaded.get(i)[1], persist);
			}
			trace('finished queue');
			loaded = true;
		});
        #else
        for(i in toBeLoaded.keys())
        {
            if (cachedGraphics.exists(i))
            {
                if (cachedGraphics.get(i).isDumped)
                {
                    cachedGraphics.get(i).undump();
                    trace('undumped ' + i);
                }
                else
                    trace(i + ' is already loaded!');
                continue;
            }
            load(i, toBeLoaded.get(i)[0], toBeLoaded.get(i)[1], persist);
        }
        trace('loaded queue');
		loaded = true;
        #end
    }
}
#end