package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;

class StickersAnimationSubState extends FlxSubState
{
    static public var stickersNames:Array<String> = 
    [
        'bfSticker2',
        'bfSticker3',
        'dadSticker1',
        'dadSticker2',
        'dadSticker3',
        'gfSticker1',
        'gfSticker2',
        'gfSticker3',
        'momSticker1',
        'momSticker2',
        'momSticker3',
        'monsterSticker1',
        'monsterSticker2',
        'monsterSticker3',
        'picoSticker1',
        'picoSticker2',
        'picoSticker3'
    ];

    public var stickersArray:Array<FlxSprite> = [];

    public function new()
    {
        super();
    }

    public function generateStickers(stickersAmount:Int = 0, alpha:Int = 0, finalAlpha:Int = 0)
    {
        var stickers:Int = stickersAmount;
        for (i in 0...stickers)
        {
            var randomImage:Int = FlxG.random.int(0, stickersNames.length - 1);
            var sprite:FlxSprite = new FlxSprite(FlxG.random.int(-200, FlxG.width), FlxG.random.int(-200, FlxG.height));
            sprite.loadGraphic('assets/images/stickers/' + stickersNames[randomImage] + '.png');
            sprite.antialiasing = true;
            sprite.setGraphicSize(255);
            sprite.alpha = alpha;
            add(sprite);
            stickersArray.push(sprite);
            FlxTween.tween(sprite, { alpha: finalAlpha }, 0.5,
                { 
                    type:       ONESHOT,
                    ease:       FlxEase.backIn,
                    onComplete: null,
                    startDelay: 0,
                    loopDelay:  0.5
                }
            );
        }
    }

    public function removeStickers(time:Int = 2)
    {
        new FlxTimer().start(time, (timer) -> 
        {
            for (sprite in stickersArray)
            {
                var sp:FlxSprite = cast sprite;
                remove(sp);
            }
        });
    }
}
